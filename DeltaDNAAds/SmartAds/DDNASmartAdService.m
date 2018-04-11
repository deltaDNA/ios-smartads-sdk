//
// Copyright (c) 2016 deltaDNA Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "DDNASmartAdService.h"
#import <DeltaDNA/DDNALog.h>
#import "DDNASmartAdFactory.h"
#import "DDNASmartAdAgent.h"
#import "DDNASmartAds.h"
#import <DeltaDNA/NSString+DeltaDNA.h>
#import <DeltaDNA/NSDictionary+DeltaDNA.h>
#import "DDNASmartAdStatus.h"
#import "DDNASmartAdWaterfall.h"
#import "DDNASmartAdMetrics.h"
#import <DeltaDNA/DDNAEngagement.h>

NSString * const AD_TYPE_UNKNOWN = @"UNKNOWN";
NSString * const AD_TYPE_INTERSTITIAL = @"INTERSTITIAL";
NSString * const AD_TYPE_REWARDED = @"REWARDED";

static const NSInteger REGISTER_FOR_ADS_RETRY_SECONDS = 60;
static const NSInteger MAX_ERROR_STRING_LENGTH = 512;

NSString * const kDDNAAdsDisabledEngage = @"com.deltadna.AdsDisabledEngage";
NSString * const kDDNAAdsDisabledNoNetworks = @"com.deltadna.AdDisabledNoNetworks";
NSString * const kDDNALoadedAd = @"com.deltadna.LoadedAd";
NSString * const kDDNAShowingAd = @"com.deltadna.ShowingAd";
NSString * const kDDNAClosedAd = @"com.deltadna.ClosedAd";
NSString * const kDDNAAdType = @"com.deltadna.AdType";
NSString * const kDDNAAdPoint = @"com.deltadna.AdPoint";
NSString * const kDDNAAdNetwork = @"com.deltadna.AdNetwork";
NSString * const kDDNARequestTime = @"com.deltadna.RequestTime";
NSString * const kDDNAFullyWatched = @"com.deltadna.FullyWatched";

@interface DDNASmartAdService () <DDNASmartAdAgentDelegate>

@property (nonatomic, strong) NSDictionary *adConfiguration;
@property (nonatomic, strong) DDNASmartAdAgent *interstitialAgent;
@property (nonatomic, strong) DDNASmartAdAgent *rewardedAgent;
@property (nonatomic, assign) NSInteger adMinimumInterval;
@property (nonatomic, assign) BOOL recordAdRequests;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nonatomic, assign) BOOL dispatchQueueSuspended;
@property (nonatomic, strong) DDNASmartAdMetrics *metrics;

@end

@implementation DDNASmartAdService

- (instancetype)init
{
    if ((self = [super init])) {
        self.factory = [DDNASmartAdFactory sharedInstance];
        self.dispatchQueue = dispatch_queue_create("com.deltadna.ios.sdk.adService", DISPATCH_QUEUE_SERIAL);
        self.dispatchQueueSuspended = NO;
        self.metrics = [[DDNASmartAdMetrics alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"DDNASDKNewSession" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self.metrics newSessionWithDate:[NSDate date]];
        }];
    }
    return self;
}

- (void)beginSessionWithDecisionPoint:(NSString *)decisionPoint
{
    [self.delegate requestEngagementWithDecisionPoint:decisionPoint
                                              flavour:@"internal"
                                           parameters:@{@"adSdkVersion" : [DDNASmartAds sdkVersion]}
                                    completionHandler:^(NSString *response, NSInteger statusCode, NSError *connectionError){
                                        
        NSDictionary *responseDict = [NSDictionary dictionaryWithJSONString:response];
        if (!responseDict || !responseDict[@"parameters"]) {
            DDNALogWarn(@"No SmartAds configuration returned by Engage due to missing 'parameters' key, trying again in %ld seconds.", (long)REGISTER_FOR_ADS_RETRY_SECONDS);
            
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW,
                                                  REGISTER_FOR_ADS_RETRY_SECONDS*NSEC_PER_SEC);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self beginSessionWithDecisionPoint:decisionPoint];
            });
        }
        else {
            if (responseDict[@"isCachedResponse"] && [responseDict[@"isCachedResponse"] boolValue]) {
                DDNALogDebug(@"Using cached SmartAds configuration");
            } else {
                DDNALogDebug(@"Using live SmartAds configuration");
            }
            
            self.adConfiguration = responseDict[@"parameters"];
            
            if (!self.adConfiguration[@"adShowSession"] || (![self.adConfiguration[@"adShowSession"] boolValue])) {
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:kDDNAAdsDisabledEngage
                                      object:self
                                    userInfo:nil];
                [self.delegate didFailToRegisterForInterstitialAdsWithReason:@"Ads disabled for this session by Engage."];
                [self.delegate didFailToRegisterForRewardedAdsWithReason:@"Ads disabled for this session by Engage."];
                return;
            }
            
            NSNumber *maxAdsPerSession = self.adConfiguration[@"adMaxPerSession"];
            self.adMinimumInterval = [self.adConfiguration[@"adMinimumInterval"] integerValue];
            self.recordAdRequests = self.adConfiguration[@"adRecordAdRequests"] ? [self.adConfiguration[@"adRecordAdRequests"] boolValue] : YES;
            
            NSInteger floorPrice = [self.adConfiguration[@"adFloorPrice"] integerValue];
            NSInteger maxRequests = [self.adConfiguration[@"adMaxPerNetwork"] integerValue];
            NSUInteger demoteCode = [self.adConfiguration[@"adDemoteOnRequestCode"] unsignedIntegerValue];
            
            NSArray *adProviders = self.adConfiguration[@"adProviders"];
            
            if (adProviders != nil && [adProviders isKindOfClass:[NSArray class]] && adProviders.count > 0) {
                NSArray *adapters = [self.factory buildInterstitialAdapterWaterfallWithAdProviders:adProviders floorPrice:floorPrice];
                if (adapters == nil || adapters.count == 0) {
                    DDNALogWarn(@"No interstitial ad networks enabled");
                    
                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                    [center postNotificationName:kDDNAAdsDisabledNoNetworks
                                          object:self
                                        userInfo:@{kDDNAAdType: AD_TYPE_INTERSTITIAL}];
                    [self.delegate didFailToRegisterForInterstitialAdsWithReason:@"No interstitial ad networks enabled"];
                } else {
                    DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:demoteCode maxRequests:maxRequests];
                    self.interstitialAgent = [self.factory buildSmartAdAgentWithWaterfall:waterfall adLimit:maxAdsPerSession delegate:self];
                    [self.interstitialAgent requestAd];
                    
                    [self.delegate didRegisterForInterstitialAds];
                }
            }
            else {
                DDNALogWarn(@"No interstitial ad networks configured");
                
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:kDDNAAdsDisabledNoNetworks
                                      object:self
                                    userInfo:@{kDDNAAdType: AD_TYPE_INTERSTITIAL}];
                [self.delegate didFailToRegisterForInterstitialAdsWithReason:@"No interstitial ad networks configured"];
            }
            
            NSArray *adRewardedProviders = self.adConfiguration[@"adRewardedProviders"];
            
            if (adRewardedProviders != nil && [adRewardedProviders isKindOfClass:[NSArray class]] && adRewardedProviders.count > 0) {
                NSArray *adapters = [self.factory buildRewardedAdapterWaterfallWithAdProviders:adRewardedProviders floorPrice:floorPrice];
                if (adapters == nil || adapters.count == 0) {
                    DDNALogWarn(@"No rewarded ad networks enabled");
                    
                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                    [center postNotificationName:kDDNAAdsDisabledNoNetworks
                                          object:self
                                        userInfo:@{kDDNAAdType: AD_TYPE_REWARDED}];
                    [self.delegate didFailToRegisterForRewardedAdsWithReason:@"No rewarded ad networks enabled"];
                } else {
                    DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:demoteCode maxRequests:maxRequests];
                    self.rewardedAgent = [self.factory buildSmartAdAgentWithWaterfall:waterfall adLimit:maxAdsPerSession delegate:self];
                    [self.rewardedAgent requestAd];
                    
                    [self.delegate didRegisterForRewardedAds];
                }
            }
            else {
                DDNALogWarn(@"No rewarded ad networks configured");
                
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:kDDNAAdsDisabledNoNetworks
                                      object:self
                                    userInfo:@{kDDNAAdType: AD_TYPE_REWARDED}];
                [self.delegate didFailToRegisterForRewardedAdsWithReason:@"No rewarded ad networks configured"];
            }
        }
    }];
}

- (BOOL)isInterstitialAdAllowedForDecisionPoint:(nullable NSString *)decisionPoint
                                     parameters:(nullable NSDictionary *)parameters
                                      checkTime:(BOOL)checkTime
{
    if (self.interstitialAgent == nil) {
        DDNALogDebug(@"Interstitial ads disabled for this session");
        return NO;
    }
    
    if (decisionPoint != nil && decisionPoint.length > 0 && parameters != nil) {
        return [self isAdAllowedForAdAgent:self.interstitialAgent decisionPoint:decisionPoint parameters:parameters checkTime:checkTime];
    }
    
    return YES;
}

- (BOOL)hasLoadedInterstitialAd
{
    return self.interstitialAgent && self.interstitialAgent.hasLoadedAd;
}

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController
                                   decisionPoint:(NSString *)decisionPoint
                                      parameters:(NSDictionary *)parameters
{
    if (!self.interstitialAgent) {
        [self.delegate didFailToOpenInterstitialAdWithReason:@"Not configured for interstitial ads"];
    } else {
        self.interstitialAgent.decisionPoint = decisionPoint;
        [self showAdFromRootViewController:viewController adAgent:self.interstitialAgent parameters:parameters];
    }
}

- (BOOL)isShowingInterstitialAd
{
    return self.interstitialAgent && self.interstitialAgent.isShowingAd;
}

- (BOOL)isRewardedAdAllowedForDecisionPoint:(NSString *)decisionPoint parameters:(NSDictionary *)parameters checkTime:(BOOL)checkTime
{
    if (self.rewardedAgent == nil) {
        DDNALogDebug(@"Rewarded ads disabled for this session");
        return NO;
    }
    
    if (decisionPoint != nil && decisionPoint.length > 0 && parameters != nil) {
        return [self isAdAllowedForAdAgent:self.rewardedAgent decisionPoint:decisionPoint parameters:parameters checkTime:checkTime];
    }
    
    return YES;
}

- (NSTimeInterval)timeUntilRewardedAdAllowedForDecisionPoint:(NSString *)decisionPoint parameters:(NSDictionary *)parameters
{
    if (decisionPoint != nil && decisionPoint.length > 0 && parameters != nil) {
        return [self timeUntilAdAllowedForAdAgent:self.rewardedAgent decisionPoint:decisionPoint parameters:parameters];
    }
    return 0;
}

- (BOOL)hasLoadedRewardedAd
{
    return self.rewardedAgent && self.rewardedAgent.hasLoadedAd;
}

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController
                               decisionPoint:(NSString *)decisionPoint
                                  parameters:(NSDictionary *)parameters
{
    if (!self.rewardedAgent) {
        [self.delegate didFailToOpenRewardedAdWithReason:@"Not configured for rewarded ads"];
    } else {
        self.rewardedAgent.decisionPoint = decisionPoint;
        [self showAdFromRootViewController:viewController adAgent:self.rewardedAgent parameters:parameters];
    }
}

- (BOOL)isShowingRewardedAd
{
    return self.rewardedAgent && self.rewardedAgent.isShowingAd;
}

- (NSDate *)lastShownForDecisionPoint:(NSString *)decisionPoint
{
    return [self.metrics lastShownAtDecisionPoint:decisionPoint];
}

- (NSInteger)sessionCountForDecisionPoint:(NSString *)decisionPoint
{
    return [self.metrics sessionCountAtDecisionPoint:decisionPoint];
}

- (NSInteger)dailyCountForDecisionPoint:(NSString *)decisionPoint
{
    return [self.metrics dailyCountAtDecisionPoint:decisionPoint];
}


- (void)pause
{
    if (!self.dispatchQueueSuspended) {
        DDNALogDebug(@"Pausing SmartAds");
        dispatch_suspend(self.dispatchQueue);
        self.dispatchQueueSuspended = YES;
    }
}

- (void)resume
{
    if (self.dispatchQueueSuspended) {
        dispatch_resume(self.dispatchQueue);
        DDNALogDebug(@"Resuming SmartAds");
        self.dispatchQueueSuspended = NO;
    }
}

#pragma mark - DDNASmartAdAgent

- (void)adAgent:(DDNASmartAdAgent *)adAgent didLoadAdWithAdapter:(DDNASmartAdAdapter *)adapter requestTime:(NSTimeInterval)requestTime
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kDDNALoadedAd
                          object:self
                        userInfo:@{
        kDDNAAdType: self.interstitialAgent == adAgent ? AD_TYPE_INTERSTITIAL : AD_TYPE_REWARDED,
        kDDNAAdNetwork: adapter.name,
        kDDNARequestTime: [NSNumber numberWithDouble:requestTime],
        kDDNAAdPoint: adAgent.decisionPoint ? adAgent.decisionPoint : @""
    }];
    
    [self postAdRequestEvent:adAgent
                     adapter:adapter
             requestDuration:requestTime
                      result:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeLoaded]];
    
    if (adAgent == self.rewardedAgent) {
        [self.delegate didLoadRewardedAd];
    }
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didFailToLoadAdWithAdapter:(DDNASmartAdAdapter *)adapter requestTime:(NSTimeInterval)requestTime requestResult:(DDNASmartAdRequestResult *)result
{
    DDNALogDebug(@"Failed to load %@ ad from %@. %@ - %@",
                 adAgent == self.interstitialAgent ? @"interstitial" : @"rewarded",
                 adapter.name,
                 result.desc,
                 result.errorDescription);

    [self postAdRequestEvent:adAgent adapter:adapter requestDuration:requestTime result:result];
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didOpenAdWithAdapter:(DDNASmartAdAdapter *)adapter
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kDDNAShowingAd
                          object:self
                        userInfo:@{
       kDDNAAdType: self.interstitialAgent == adAgent ? AD_TYPE_INTERSTITIAL : AD_TYPE_REWARDED,
       kDDNAAdNetwork: adapter.name,
       kDDNAAdPoint: adAgent.decisionPoint ? adAgent.decisionPoint : @""
    }];

    if (adAgent == self.interstitialAgent) {
        [self.delegate didOpenInterstitialAd];
    }
    else if (adAgent == self.rewardedAgent) {
        [self.delegate didOpenRewardedAdForDecisionPoint:adAgent.decisionPoint];
    }
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didFailToOpenAdWithAdapter:(DDNASmartAdAdapter *)adapter showResult:(DDNASmartAdShowResult *)result
{
    DDNALogDebug(@"Failed to open %@ ad from %@.",
                 adAgent == self.interstitialAgent ? @"interstitial" : @"rewarded",
                 adapter != nil ? adapter.name : @"N/A");
    
    [self postAdShowEvent:adAgent resultCode:result.code];

    if (adAgent == self.interstitialAgent) {
        [self.delegate didFailToOpenInterstitialAdWithReason:result.desc];
    }
    else if (adAgent == self.rewardedAgent) {
        [self.delegate didFailToOpenRewardedAdWithReason:result.desc];
    }
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didCloseAdWithAdapter:(DDNASmartAdAdapter *)adapter canReward:(BOOL)canReward
{
    if (adAgent.decisionPoint && adAgent.decisionPoint.length > 0) {
        [self.metrics recordAdShownAtDecisionPoint:adAgent.decisionPoint withDate:adAgent.lastAdShownTime];
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kDDNAClosedAd
                          object:self
                        userInfo:@{
       kDDNAAdType: self.interstitialAgent == adAgent ? AD_TYPE_INTERSTITIAL : AD_TYPE_REWARDED,
       kDDNAAdNetwork: adapter.name,
       kDDNAFullyWatched: [NSNumber numberWithBool:canReward],
       kDDNAAdPoint: adAgent.decisionPoint ? adAgent.decisionPoint : @""
    }];
    
    [self postAdClosedEvent:adAgent adapter:adapter];

    if (adAgent == self.interstitialAgent) {
        [self.delegate didCloseInterstitialAd];
    }
    else if (adAgent == self.rewardedAgent) {
        [self.delegate didCloseRewardedAdWithReward:canReward];
    }

}

- (dispatch_queue_t)getDispatchQueue
{
    return self.dispatchQueue;
}

#pragma mark - Private

- (BOOL)isAdAllowedForAdAgent:(DDNASmartAdAgent *)adAgent decisionPoint:(NSString *)decisionPoint parameters:(NSDictionary *)parameters checkTime:(BOOL)checkTime
{
    DDNASmartAdShowResultCode result = [self isAdAllowedResultForAdAgent:adAgent decisionPoint:decisionPoint parameters:parameters];
    
    BOOL allowed = NO;
    
    switch (result) {
        case DDNASmartAdShowResultCodeMinTimeNotElapsed:
        case DDNASmartAdShowResultCodeMinTimeDecisionPointNotElapsed:
        case DDNASmartAdShowResultCodeNotLoaded: {
            allowed = !checkTime;
            break;
        }
        case DDNASmartAdShowResultCodeFulfilled: {
            allowed = YES;
            break;
        }
        default: {
            allowed = NO;
        }
    }
    return allowed;
}

- (DDNASmartAdShowResultCode)isAdAllowedResultForAdAgent:(DDNASmartAdAgent *)adAgent decisionPoint:(NSString *)decisionPoint parameters:(NSDictionary *)parameters
{
    if (adAgent.hasReachedAdLimit) {
        return DDNASmartAdShowResultCodeAdSessionLimitReached;
    }
    
    if (parameters[@"ddnaAdSessionCount"]) {
        NSInteger adSessionCount = [parameters[@"ddnaAdSessionCount"] integerValue];
        if ([self.metrics sessionCountAtDecisionPoint:decisionPoint] >= adSessionCount) {
            return DDNASmartAdShowResultCodeAdSessionDecisionPointLimitReached;
        }
    }
    
    if (parameters[@"ddnaAdDailyCount"]) {
        NSInteger adDailyCount = [parameters[@"ddnaAdDailyCount"] integerValue];
        if ([self.metrics dailyCountAtDecisionPoint:decisionPoint] >= adDailyCount) {
            return DDNASmartAdShowResultCodeAdDailyDecisionPointLimitReached;
        }
    }
    
    if (parameters[@"adShowPoint"] && ![parameters[@"adShowPoint"] boolValue]) {
        return DDNASmartAdShowResultCodeAdShowPoint;
    }
    
    NSDate *now = [NSDate date];
    if ([now timeIntervalSinceDate:adAgent.lastAdShownTime] < self.adMinimumInterval) {
        return DDNASmartAdShowResultCodeMinTimeNotElapsed;
    }
    
    if (parameters[@"ddnaAdShowWaitSecs"]) {
        NSInteger adShowWaitSecs = [parameters[@"ddnaAdShowWaitSecs"] integerValue];
        NSDate *lastShownAdDecisionPoint = [self.metrics lastShownAtDecisionPoint:decisionPoint];
        if (lastShownAdDecisionPoint && [now timeIntervalSinceDate:lastShownAdDecisionPoint] < adShowWaitSecs) {
            return DDNASmartAdShowResultCodeMinTimeDecisionPointNotElapsed;
        }
    }
    
    if (!adAgent.hasLoadedAd) {
        return DDNASmartAdShowResultCodeNotLoaded;
    }
    
    return DDNASmartAdShowResultCodeFulfilled;
}

- (NSTimeInterval)timeUntilAdAllowedForAdAgent:(DDNASmartAdAgent *)adAgent decisionPoint:(NSString *)decisionPoint parameters:(NSDictionary *)parameters
{
    // How long must we wait if we must wait at all
    NSDate *now = [NSDate date];
    NSInteger adShowWaitSecs = 0;
    if (parameters[@"ddnaAdShowWaitSecs"]) {
        adShowWaitSecs = [parameters[@"ddnaAdShowWaitSecs"] integerValue];
    }
    
    if (self.adMinimumInterval >= adShowWaitSecs) {
        NSTimeInterval lastAdShownSession = [now timeIntervalSinceDate:adAgent.lastAdShownTime];
        if (lastAdShownSession < self.adMinimumInterval) {
            return ceil(self.adMinimumInterval - lastAdShownSession);
        }
    } else {
        NSDate *lastShownAdDecisionPoint = [self.metrics lastShownAtDecisionPoint:decisionPoint];
        NSTimeInterval lastAdShownDecisionPoint = [now timeIntervalSinceDate:lastShownAdDecisionPoint];
        if (lastAdShownDecisionPoint < adShowWaitSecs) {
            return ceil(adShowWaitSecs - lastAdShownDecisionPoint);
        }
    }
    
    return 0;
}

- (void)showAdFromRootViewController:(UIViewController *)viewController adAgent:(DDNASmartAdAgent *)adAgent parameters:(NSDictionary *)parameters
{
    if (adAgent.decisionPoint != nil && parameters != nil) {
    
        DDNASmartAdShowResultCode resultCode = [self isAdAllowedResultForAdAgent:adAgent decisionPoint:adAgent.decisionPoint parameters:parameters];
        [self postAdShowEvent:adAgent resultCode:resultCode];
        
        switch (resultCode) {
            case DDNASmartAdShowResultCodeAdShowPoint: {
                [self didFailToOpenAdWithAdAgent:adAgent reason:@"Engage disallowed the ad"];
                break;
            }
            case DDNASmartAdShowResultCodeMinTimeNotElapsed: {
                [self didFailToOpenAdWithAdAgent:adAgent reason:@"Minimum environment time between ads not elapsed"];
                break;
            }
            case DDNASmartAdShowResultCodeMinTimeDecisionPointNotElapsed: {
                [self didFailToOpenAdWithAdAgent:adAgent reason:@"Minimum decision point time between ads not elapsed"];
                break;
            }
            case DDNASmartAdShowResultCodeAdSessionLimitReached: {
                [self didFailToOpenAdWithAdAgent:adAgent reason:@"Session limit for environment reached"];
                break;
            }
            case DDNASmartAdShowResultCodeAdSessionDecisionPointLimitReached: {
                [self didFailToOpenAdWithAdAgent:adAgent reason:@"Session limit for decision point reached"];
                break;
            }
            case DDNASmartAdShowResultCodeAdDailyDecisionPointLimitReached: {
                [self didFailToOpenAdWithAdAgent:adAgent reason:@"Daily limit for decision point reached"];
                break;
            }
            case DDNASmartAdShowResultCodeNotLoaded: {
                [self didFailToOpenAdWithAdAgent:adAgent reason:@"Ad not loaded"];
                break;
            }
            default: {
                [adAgent showAdFromRootViewController:viewController decisionPoint:adAgent.decisionPoint];
                break;
            }
        }
    }
    else if (adAgent.decisionPoint != nil && parameters == nil) {
        [self didFailToOpenAdWithAdAgent:adAgent reason:@"Invalid Engagement"];
    }
    else {
        [self postAdShowEvent:adAgent resultCode:DDNASmartAdShowResultCodeFulfilled];
        [adAgent showAdFromRootViewController:viewController decisionPoint:nil];
    }
}

- (void)didFailToOpenAdWithAdAgent:(DDNASmartAdAgent *)adAgent reason:(NSString *)reason
{
    if (adAgent == self.interstitialAgent) {
        [self.delegate didFailToOpenInterstitialAdWithReason:reason];
    }
    else if (adAgent == self.rewardedAgent) {
        [self.delegate didFailToOpenRewardedAdWithReason:reason];
    }
}

- (void)postAdShowEvent:(DDNASmartAdAgent *)agent resultCode:(DDNASmartAdShowResultCode)resultCode
{
    DDNASmartAdAdapter *adapter = agent.currentAdapter;
    DDNASmartAdShowResult *result = [DDNASmartAdShowResult resultWith:resultCode];
    
    NSString *adType = AD_TYPE_UNKNOWN;
    if (agent == self.interstitialAgent) {
        adType = AD_TYPE_INTERSTITIAL;
    } else if (agent == self.rewardedAgent) {
        adType = AD_TYPE_REWARDED;
    }

    NSMutableDictionary *eventParams = [[NSMutableDictionary alloc] initWithCapacity:10];
    eventParams[@"adProvider"] = adapter ? [adapter name] : @"N/A";
    eventParams[@"adProviderVersion"] = adapter ? [adapter version] : @"N/A";
    eventParams[@"adType"] = adType;
    eventParams[@"adStatus"] = result.desc;
    eventParams[@"adSdkVersion"] = [DDNASmartAds sdkVersion];
    if ([agent decisionPoint] != nil) {
        eventParams[@"adPoint"] = [agent decisionPoint];
    }

    [self.delegate recordEventWithName:@"adShow" parameters:eventParams];
}

- (void)postAdClosedEvent:(DDNASmartAdAgent *)agent adapter:(DDNASmartAdAdapter *)adapter
{
    NSString *adType = AD_TYPE_UNKNOWN;
    if (agent == self.interstitialAgent) {
        adType = AD_TYPE_INTERSTITIAL;
    } else if (agent == self.rewardedAgent) {
        adType = AD_TYPE_REWARDED;
    }


    NSMutableDictionary *eventParams = [[NSMutableDictionary alloc] initWithCapacity:7];
    eventParams[@"adProvider"] = adapter.name;
    eventParams[@"adProviderVersion"] = adapter.version;
    eventParams[@"adType"] = adType;
    eventParams[@"adClicked"] = [NSNumber numberWithBool:[agent adWasClicked]];
    eventParams[@"adLeftApplication"] = [NSNumber numberWithBool:[agent adLeftApplication]];
    eventParams[@"adEcpm"] = [NSNumber numberWithInteger:adapter.eCPM];
    eventParams[@"adSdkVersion"] = [DDNASmartAds sdkVersion];
    eventParams[@"adStatus"] = @"Success";

    [self.delegate recordEventWithName:@"adClosed" parameters:eventParams];
}

- (void)postAdRequestEvent:(DDNASmartAdAgent *)agent adapter:(DDNASmartAdAdapter *)adapter requestDuration:(NSTimeInterval)requestDuration result:(DDNASmartAdRequestResult *)result
{
    if (self.recordAdRequests) {

        NSString *adType = AD_TYPE_UNKNOWN;
        if (agent == self.interstitialAgent) {
            adType = AD_TYPE_INTERSTITIAL;
        } else if (agent == self.rewardedAgent) {
            adType = AD_TYPE_REWARDED;
        }

        NSMutableDictionary *eventParams = [[NSMutableDictionary alloc] initWithCapacity:8];
        eventParams[@"adProvider"] = adapter.name;
        eventParams[@"adProviderVersion"] = adapter.version;
        eventParams[@"adType"] = adType;
        eventParams[@"adSdkVersion"] = [DDNASmartAds sdkVersion];
        eventParams[@"adRequestTimeMs"] = [NSNumber numberWithInteger:(int)requestDuration];
        eventParams[@"adWaterfallIndex"] = [NSNumber numberWithInteger:adapter.waterfallIndex];
        eventParams[@"adStatus"] = result.desc;
        if (result.errorDescription) {
            NSString *errorStr = result.errorDescription;
            if (errorStr.length > MAX_ERROR_STRING_LENGTH) {
                errorStr = [NSString stringWithFormat:@"%@...", [errorStr substringToIndex:MAX_ERROR_STRING_LENGTH-3]];
            }
            eventParams[@"adProviderError"] = errorStr;
        }

        [self.delegate recordEventWithName:@"adRequest" parameters:eventParams];
    }
}

@end
