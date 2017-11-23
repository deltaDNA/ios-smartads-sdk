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
NSString * const kDDNAAdNetwork = @"com.deltadna.AdNetwork";
NSString * const kDDNARequestTime = @"com.deltadna.RequestTime";
NSString * const kDDNAFullyWatched = @"com.deltadna.FullyWatched";

@interface DDNASmartAdService () <DDNASmartAdAgentDelegate>

@property (nonatomic, strong) NSDictionary *adConfiguration;
@property (nonatomic, strong) DDNASmartAdAgent *interstitialAgent;
@property (nonatomic, strong) DDNASmartAdAgent *rewardedAgent;
@property (nonatomic, assign) NSInteger adMinimumInterval;
@property (nonatomic, assign) BOOL recordAdRequests;
@property (nonatomic, assign) BOOL requestDecisionPoints;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nonatomic, assign) BOOL dispatchQueueSuspended;

@end

@implementation DDNASmartAdService

- (instancetype)init
{
    if ((self = [super init])) {
        self.factory = [DDNASmartAdFactory sharedInstance];
        self.dispatchQueue = dispatch_queue_create("com.deltadna.ios.sdk.adService", DISPATCH_QUEUE_SERIAL);
        self.dispatchQueueSuspended = NO;
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
            DDNALogDebug(@"No valid SmartAds configuration received, trying again in %ld seconds.", (long)REGISTER_FOR_ADS_RETRY_SECONDS);
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
                [self.delegate didFailToRegisterForInterstitialAdsWithReason:@"Ads disabled for this session."];
                [self.delegate didFailToRegisterForRewardedAdsWithReason:@"Ads disabled for this session."];
                return;
            }
            
            NSNumber *maxAdsPerSession = self.adConfiguration[@"adMaxPerSession"];
            self.adMinimumInterval = [self.adConfiguration[@"adMinimumInterval"] integerValue];
            self.recordAdRequests = self.adConfiguration[@"adRecordAdRequests"] ? [self.adConfiguration[@"adRecordAdRequests"] boolValue] : YES;
            self.requestDecisionPoints = !self.adConfiguration[@"adShowPoint"] || [self.adConfiguration[@"adShowPoint"] boolValue];
            
            NSInteger floorPrice = [self.adConfiguration[@"adFloorPrice"] integerValue];
            NSInteger maxRequests = [self.adConfiguration[@"adMaxPerNetwork"] integerValue];
            NSUInteger demoteCode = [self.adConfiguration[@"adDemoteOnRequestCode"] unsignedIntegerValue];
            
            NSArray *adProviders = self.adConfiguration[@"adProviders"];
            
            if (adProviders != nil && [adProviders isKindOfClass:[NSArray class]] && adProviders.count > 0) {
                NSArray *adapters = [self.factory buildInterstitialAdapterWaterfallWithAdProviders:adProviders floorPrice:floorPrice];
                if (adapters == nil || adapters.count == 0) {
                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                    [center postNotificationName:kDDNAAdsDisabledNoNetworks
                                          object:self
                                        userInfo:@{kDDNAAdType: AD_TYPE_INTERSTITIAL}];
                    [self.delegate didFailToRegisterForInterstitialAdsWithReason:[NSString stringWithFormat:@"Failed to build interstitial waterfall from engage response %@", response]];
                } else {
                    DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:demoteCode maxRequests:maxRequests];
                    self.interstitialAgent = [self.factory buildSmartAdAgentWithWaterfall:waterfall adLimit:maxAdsPerSession delegate:self];
                    [self.interstitialAgent requestAd];
                    
                    [self.delegate didRegisterForInterstitialAds];
                }
            }
            else {
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:kDDNAAdsDisabledNoNetworks
                                      object:self
                                    userInfo:@{kDDNAAdType: AD_TYPE_INTERSTITIAL}];
                [self.delegate didFailToRegisterForInterstitialAdsWithReason:@"No interstitial ad providers defined"];
            }
            
            NSArray *adRewardedProviders = self.adConfiguration[@"adRewardedProviders"];
            
            if (adRewardedProviders != nil && [adRewardedProviders isKindOfClass:[NSArray class]] && adRewardedProviders.count > 0) {
                NSArray *adapters = [self.factory buildRewardedAdapterWaterfallWithAdProviders:adRewardedProviders floorPrice:floorPrice];
                if (adapters == nil || adapters.count == 0) {
                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                    [center postNotificationName:kDDNAAdsDisabledNoNetworks
                                          object:self
                                        userInfo:@{kDDNAAdType: AD_TYPE_REWARDED}];
                    [self.delegate didFailToRegisterForRewardedAdsWithReason:[NSString stringWithFormat:@"Failed to build rewarded waterfall from engage response %@", response]];
                } else {
                    DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:demoteCode maxRequests:maxRequests];
                    self.rewardedAgent = [self.factory buildSmartAdAgentWithWaterfall:waterfall adLimit:maxAdsPerSession delegate:self];
                    [self.rewardedAgent requestAd];
                    
                    [self.delegate didRegisterForRewardedAds];
                }
            }
            else {
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:kDDNAAdsDisabledNoNetworks
                                      object:self
                                    userInfo:@{kDDNAAdType: AD_TYPE_REWARDED}];
                [self.delegate didFailToRegisterForRewardedAdsWithReason:@"No rewarded ad providers defined"];
            }
        }
    }];
}

- (BOOL)isInterstitialAdAllowed
{
    return [self isAdAllowedForAdAgent:self.interstitialAgent decisionPoint:nil engagementParameters:nil];
}

- (BOOL)isInterstitialAdAllowedForDecisionPoint:(NSString *)decisionPoint engagementParameters:(NSDictionary *)engagementParameters
{
    return [self isAdAllowedForAdAgent:self.interstitialAgent decisionPoint:decisionPoint engagementParameters:engagementParameters];
}

- (BOOL)isInterstitialAdAvailable
{
    return self.interstitialAgent && self.interstitialAgent.hasLoadedAd;
}

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController
{
    [self showInterstitialAdFromRootViewController:viewController decisionPoint:nil];
}

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController decisionPoint:(NSString *)decisionPoint
{
    if (decisionPoint != nil && decisionPoint.length == 0) decisionPoint = nil;

    if (self.interstitialAgent) {
        self.interstitialAgent.decisionPoint = decisionPoint;
        [self showAdFromRootViewController:viewController adAgent:self.interstitialAgent];

    } else {
        [self.delegate didFailToOpenInterstitialAdWithReason:@"Not registered"];
    }
}

- (BOOL)isShowingInterstitialAd
{
    return self.interstitialAgent && self.interstitialAgent.isShowingAd;
}

- (BOOL)isRewardedAdAllowed
{
    return [self isAdAllowedForAdAgent:self.rewardedAgent decisionPoint:nil engagementParameters:nil];
}

- (BOOL)isRewardedAdAllowedForDecisionPoint:(NSString *)decisionPoint engagementParameters:(NSDictionary *)engagementParameters
{
    return [self isAdAllowedForAdAgent:self.rewardedAgent decisionPoint:decisionPoint engagementParameters:engagementParameters];
}


- (BOOL)isRewardedAdAvailable
{
    return self.rewardedAgent && self.rewardedAgent.hasLoadedAd;
}

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController
{
    [self showRewardedAdFromRootViewController:viewController decisionPoint:nil];
}

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController decisionPoint:(NSString *)decisionPoint
{
    if (decisionPoint != nil && decisionPoint.length == 0) decisionPoint = nil;

    if (self.rewardedAgent) {
        self.rewardedAgent.decisionPoint = decisionPoint;
        [self showAdFromRootViewController:viewController adAgent:self.rewardedAgent];
    } else {
        [self.delegate didFailToOpenRewardedAdWithReason:@"Not registered"];
    }
}

- (BOOL)isShowingRewardedAd
{
    return self.rewardedAgent && self.rewardedAgent.isShowingAd;
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
        kDDNARequestTime: [NSNumber numberWithDouble:requestTime]
    }];
    
    [self postAdRequestEvent:adAgent
                     adapter:adapter
             requestDuration:requestTime
                      result:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeLoaded]];
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
       kDDNAAdNetwork: adapter.name
    }];

    if (adAgent == self.interstitialAgent) {
        [self.delegate didOpenInterstitialAd];
    }
    else if (adAgent == self.rewardedAgent) {
        [self.delegate didOpenRewardedAd];
    }
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didFailToOpenAdWithAdapter:(DDNASmartAdAdapter *)adapter closedResult:(DDNASmartAdClosedResult *)result
{
    DDNALogDebug(@"Failed to open %@ ad from %@.",
                 adAgent == self.interstitialAgent ? @"interstitial" : @"rewarded",
                 adapter != nil ? adapter.name : @"N/A");
    
    [self postAdClosedEvent:adAgent adapter:adapter result:result];

    if (adAgent == self.interstitialAgent) {
        [self.delegate didFailToOpenInterstitialAdWithReason:result.desc];
    }
    else if (adAgent == self.rewardedAgent) {
        [self.delegate didFailToOpenRewardedAdWithReason:result.desc];
    }
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didCloseAdWithAdapter:(DDNASmartAdAdapter *)adapter canReward:(BOOL)canReward
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kDDNAClosedAd
                          object:self
                        userInfo:@{
       kDDNAAdType: self.interstitialAgent == adAgent ? AD_TYPE_INTERSTITIAL : AD_TYPE_REWARDED,
       kDDNAAdNetwork: adapter.name,
       kDDNAFullyWatched: [NSNumber numberWithBool:canReward]
    }];
    
    [self postAdClosedEvent:adAgent adapter:adapter result:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeSuccess]];

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

- (BOOL)isAdAllowedForAdAgent:(DDNASmartAdAgent *)adAgent decisionPoint:(NSString *)decisionPoint engagementParameters:(NSDictionary *)engagementParameters
{
    if (adAgent == nil) {
        DDNALogDebug(@"Ads disabled for this session");
        return NO;
    }
    
    if (![NSString stringIsNilOrEmpty:decisionPoint]) {
        adAgent.decisionPoint = decisionPoint;
    } else {
        adAgent.decisionPoint = nil;
    }
    
    NSString *adTypeLabel = adAgent == self.interstitialAgent ? @"interstitial" : @"rewarded";
    
    if ([[NSDate date] timeIntervalSinceDate:adAgent.lastAdShownTime] < self.adMinimumInterval) {
        DDNALogDebug(@"Attempting to show %@ ad before minimum interval of %ld seconds has elasped.", adTypeLabel, (long)self.adMinimumInterval);
        [self postAdShowEvent:adAgent
                      adapter:adAgent.currentAdapter
                       result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeMinTimeNotElapsed]];
        return NO;
    }
    
    if (adAgent.hasReachedAdLimit) {
        DDNALogDebug(@"Maximum %@ ads per session of %ld reached.", adTypeLabel, adAgent.adsShown);
        [self postAdShowEvent:adAgent
                      adapter:adAgent.currentAdapter
                       result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeAdSessionLimitReached]];
        return NO;
    }
    
    if ((adAgent.decisionPoint && !self.requestDecisionPoints) ||
        (engagementParameters != nil && engagementParameters[@"adShowPoint"] != nil && ![engagementParameters[@"adShowPoint"] boolValue])) {
        
        DDNALogDebug(@"Engage preventing %@ ad from opening at %@.", adTypeLabel, decisionPoint);
        [self postAdShowEvent:adAgent
                      adapter:adAgent.currentAdapter
                       result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeAdShowPoint]];
        return NO;
    }
    
    if (!adAgent.hasLoadedAd) {
        DDNALogDebug(@"No %@ ad available to show.", adTypeLabel);
        [self postAdShowEvent:adAgent
                      adapter:adAgent.currentAdapter
                       result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeNoAdAvailable]];
        return NO;
    }
    
    DDNALogDebug(@"Allowed to show %@ ad.", adTypeLabel);
    [self postAdShowEvent:adAgent
                  adapter:adAgent.currentAdapter
                   result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeFulfilled]];
    
    return YES;
}

- (void)showAdFromRootViewController:(UIViewController *)viewController adAgent:(DDNASmartAdAgent *)adAgent
{
    if ([[NSDate date] timeIntervalSinceDate:adAgent.lastAdShownTime] < self.adMinimumInterval) {
        [self didFailToOpenAdWithAdAgent:adAgent reason:@"Too soon"];
        return;
    }

    if (adAgent.hasReachedAdLimit) {
        [self didFailToOpenAdWithAdAgent:adAgent reason:@"Session limit reached"];
        return;
    }

    if (!adAgent.hasLoadedAd) {
        [self didFailToOpenAdWithAdAgent:adAgent reason:@"Not ready"];
        return;
    }

    if (!adAgent.decisionPoint) {
        [adAgent showAdFromRootViewController:viewController decisionPoint:nil];
    }
    else if (self.requestDecisionPoints) {
        // check with engage first
        [self.delegate requestEngagementWithDecisionPoint:adAgent.decisionPoint
                                                  flavour:@"advertising"
                                               parameters:nil
                                        completionHandler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {

            if (connectionError != nil || statusCode >= 400) {
                [adAgent showAdFromRootViewController:viewController decisionPoint:adAgent.decisionPoint];
            }
            else {
                NSDictionary *responseDict = [NSDictionary dictionaryWithJSONString:response][@"parameters"];
                if (!responseDict[@"adShowPoint"] || [responseDict[@"adShowPoint"] boolValue]) {
                    [adAgent showAdFromRootViewController:viewController decisionPoint:adAgent.decisionPoint];
                }
                else {
                    [self didFailToOpenAdWithAdAgent:adAgent reason:@"Engage disallowed the ad"];
                }
            }

        }];
    }
    else {
        [self didFailToOpenAdWithAdAgent:adAgent reason:@"Engage disallowed all ads for this session"];
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

- (void)postAdShowEvent:(DDNASmartAdAgent *)agent adapter:(DDNASmartAdAdapter *)adapter result:(DDNASmartAdShowResult *)result
{
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

- (void)postAdClosedEvent:(DDNASmartAdAgent *)agent adapter:(DDNASmartAdAdapter *)adapter result:(DDNASmartAdClosedResult *)result
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
    eventParams[@"adStatus"] = result.desc;

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
