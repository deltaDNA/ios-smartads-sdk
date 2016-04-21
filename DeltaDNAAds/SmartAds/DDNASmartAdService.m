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

static NSString * const AD_TYPE_UNKNOWN = @"UNKNOWN";
static NSString * const AD_TYPE_INTERSTITIAL = @"INTERSTITIAL";
static NSString * const AD_TYPE_REWARDED = @"REWARDED";

static const NSInteger REGISTER_FOR_ADS_RETRY_SECONDS = 60;

@interface DDNASmartAdService () <DDNASmartAdAgentDelegate>

@property (nonatomic, strong) NSDictionary *adConfiguration;
@property (nonatomic, strong) DDNASmartAdAgent *interstitialAgent;
@property (nonatomic, strong) DDNASmartAdAgent *rewardedAgent;
@property (nonatomic, assign) NSInteger maxAdsPerSession;
@property (nonatomic, assign) NSInteger adMinimumIntervalMs;
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
        self.dispatchQueue = dispatch_queue_create("com.deltadna.ios.sdk.adService", DISPATCH_QUEUE_CONCURRENT);
        self.dispatchQueueSuspended = NO;
    }
    return self;
}

- (void)beginSessionWithDecisionPoint:(NSString *)decisionPoint
{
    [self.delegate requestEngagementWithDecisionPoint:decisionPoint
                                              flavour:@"internal"
                                           parameters:nil
                                    completionHandler:^(NSString *response, NSInteger statusCode, NSError *connectionError){

        if (connectionError) {
            // Assume it's a temporary network glitch and try again
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW,
                                                  REGISTER_FOR_ADS_RETRY_SECONDS*NSEC_PER_SEC);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self beginSessionWithDecisionPoint:decisionPoint];
            });
        }
        else if (statusCode != 200) {
            [self.delegate didFailToRegisterForInterstitialAdsWithReason:[NSString stringWithFormat:@"Engage returned: %ld %@", (long)statusCode, response]];
            [self.delegate didFailToRegisterForRewardedAdsWithReason:[NSString stringWithFormat:@"Engage returned: %ld %@", (long)statusCode, response]];
        }
        else {
            NSDictionary *responseDict = [NSDictionary dictionaryWithJSONString:response];

            if (!responseDict[@"parameters"]) {
                [self.delegate didFailToRegisterForInterstitialAdsWithReason:@"Invalid Engage response, missing 'parameters' key."];
                [self.delegate didFailToRegisterForRewardedAdsWithReason:@"Invalid Engage response, missing 'parameters' key."];
                return;
            }

            self.adConfiguration = responseDict[@"parameters"];

            if (!self.adConfiguration[@"adShowSession"] || (![self.adConfiguration[@"adShowSession"] boolValue])) {
                [self.delegate didFailToRegisterForInterstitialAdsWithReason:@"Ads disabled for this session."];
                [self.delegate didFailToRegisterForRewardedAdsWithReason:@"Ads disabled for this session."];
                return;
            }

            self.maxAdsPerSession = [self.adConfiguration[@"adMaxPerSession"] integerValue];
            self.adMinimumIntervalMs = [self.adConfiguration[@"adMinimumInterval"] integerValue];
            self.recordAdRequests = self.adConfiguration[@"adRecordAdRequests"] ? [self.adConfiguration[@"adRecordAdRequests"] boolValue] : YES;
            self.requestDecisionPoints = !self.adConfiguration[@"adShowPoint"] || [self.adConfiguration[@"adShowPoint"] boolValue];

            NSInteger floorPrice = [self.adConfiguration[@"adFloorPrice"] integerValue];
            NSInteger maxRequests = [self.adConfiguration[@"adMaxPerNetwork"] integerValue];
            NSUInteger demoteCode = [self.adConfiguration[@"adDemoteOnRequestCode"] unsignedIntegerValue];

            NSArray *adProviders = self.adConfiguration[@"adProviders"];

            if (adProviders != nil && [adProviders isKindOfClass:[NSArray class]] && adProviders.count > 0) {
                NSArray *adapters = [self.factory buildInterstitialAdapterWaterfallWithAdProviders:adProviders floorPrice:floorPrice];
                if (adapters == nil || adapters.count == 0) {
                    [self.delegate didFailToRegisterForInterstitialAdsWithReason:[NSString stringWithFormat:@"Failed to build interstitial waterfall from engage response %@", response]];
                } else {
                    DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:demoteCode maxRequests:maxRequests];
                    self.interstitialAgent = [self.factory buildSmartAdAgentWithWaterfall:waterfall delegate:self];
                    [self.interstitialAgent requestAd];

                    [self.delegate didRegisterForInterstitialAds];
                }
            }
            else {
                [self.delegate didFailToRegisterForInterstitialAdsWithReason:@"No interstitial ad providers defined"];
            }

            NSArray *adRewardedProviders = self.adConfiguration[@"adRewardedProviders"];

            if (adRewardedProviders != nil && [adRewardedProviders isKindOfClass:[NSArray class]] && adRewardedProviders.count > 0) {
                NSArray *adapters = [self.factory buildRewardedAdapterWaterfallWithAdProviders:adRewardedProviders floorPrice:floorPrice];
                if (adapters == nil || adapters.count == 0) {
                    [self.delegate didFailToRegisterForRewardedAdsWithReason:[NSString stringWithFormat:@"Failed to build rewarded waterfall from engage response %@", response]];
                } else {
                    DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:demoteCode maxRequests:maxRequests];
                    self.rewardedAgent = [self.factory buildSmartAdAgentWithWaterfall:waterfall delegate:self];
                    [self.rewardedAgent requestAd];

                    [self.delegate didRegisterForRewardedAds];
                }
            }
            else {
                [self.delegate didFailToRegisterForRewardedAdsWithReason:@"No rewarded ad providers defined"];
            }
        }

    }];
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
    DDNALogDebug(@"Loaded %@ ad from %@.",
                 adAgent == self.interstitialAgent ? @"interstitial" : @"rewarded",
                 adapter.name);

    [self postAdRequestEvent:adAgent
                     adapter:adapter
             requestDuration:requestTime
                      result:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeLoaded]];
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didFailToLoadAdWithAdapter:(DDNASmartAdAdapter *)adapter requestTime:(NSTimeInterval)requestTime requestResult:(DDNASmartAdRequestResult *)result
{
    DDNALogDebug(@"Failed to load %@ ad from %@. %@",
                 adAgent == self.interstitialAgent ? @"interstitial" : @"rewarded",
                 adapter.name,
                 result.desc);

    [self postAdRequestEvent:adAgent adapter:adapter requestDuration:requestTime result:result];
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didOpenAdWithAdapter:(DDNASmartAdAdapter *)adapter
{
    if (adAgent == self.interstitialAgent) {
        [self.delegate didOpenInterstitialAd];
    }
    else if (adAgent == self.rewardedAgent) {
        [self.delegate didOpenRewardedAd];
    }
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didFailToOpenAdWithAdapter:(DDNASmartAdAdapter *)adapter closedResult:(DDNASmartAdClosedResult *)result
{
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

- (void)showAdFromRootViewController:(UIViewController *)viewController adAgent:(DDNASmartAdAgent *)adAgent
{
    if ([[NSDate date] timeIntervalSinceDate:adAgent.lastAdShownTime] * 1000 < self.adMinimumIntervalMs) {
        DDNALogDebug(@"showAd called before minimum interval %ld ms between ads elasped", (long)self.adMinimumIntervalMs);
        [self postAdShowEvent:adAgent
                      adapter:adAgent.currentAdapter
                       result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeMinTimeNotElapsed]];

        [self didFailToOpenAdWithAdAgent:adAgent reason:@"Too soon"];
        return;
    }

    if (adAgent.adsShown >= self.maxAdsPerSession) {
        DDNALogDebug(@"Max ad per session count of %ld reached", (long)self.maxAdsPerSession);
        [self postAdShowEvent:self.interstitialAgent
                      adapter:self.interstitialAgent.currentAdapter
                       result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeAdSessionLimitReached]];

        [self didFailToOpenAdWithAdAgent:adAgent reason:@"Session limit reached"];
        return;
    }

    if (!adAgent.hasLoadedAd) {
        DDNALogDebug(@"No ad available");
        [self postAdShowEvent:adAgent
                      adapter:adAgent.currentAdapter
                       result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeNotReady]];

        [self didFailToOpenAdWithAdAgent:adAgent reason:@"Not ready"];
        return;
    }

    if (!adAgent.decisionPoint) {
        // show ad immediately
        [self postAdShowEvent:adAgent
                      adapter:adAgent.currentAdapter
                       result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeFulfilled]];

        [adAgent showAdFromRootViewController:viewController decisionPoint:nil];
    }
    else if (self.requestDecisionPoints) {
        // check with engage first
        [self.delegate requestEngagementWithDecisionPoint:adAgent.decisionPoint
                                                  flavour:@"advertising"
                                               parameters:nil
                                        completionHandler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {

            if (connectionError != nil || statusCode >= 400) {
                // Couldn't get a response from Engage, show ad anyway
                // TODO - maybe change the default timeout so this is faster?
                DDNALogDebug(@"Engage request failed: %@: showing ad anyway at %@", response, adAgent.decisionPoint);
                [self postAdShowEvent:adAgent
                              adapter:adAgent.currentAdapter
                               result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeEngageFailed]];

                [adAgent showAdFromRootViewController:viewController decisionPoint:adAgent.decisionPoint];
            }
            else {
                NSDictionary *responseDict = [NSDictionary dictionaryWithJSONString:response][@"parameters"];
                if (!responseDict[@"adShowPoint"] || [responseDict[@"adShowPoint"] boolValue]) {
                    DDNALogDebug(@"Engage allowing ad at %@", adAgent.decisionPoint);
                    [self postAdShowEvent:adAgent
                                  adapter:adAgent.currentAdapter
                                   result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeFulfilled]];

                    [adAgent showAdFromRootViewController:viewController decisionPoint:adAgent.decisionPoint];
                }
                else {
                    DDNALogDebug(@"Engage prevented ad from opening at %@", adAgent.decisionPoint);
                    [self postAdShowEvent:adAgent
                                  adapter:adAgent.currentAdapter
                                   result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeAdShowPoint]];

                    [self didFailToOpenAdWithAdAgent:adAgent reason:@"Engage disallowed the ad"];
                }
            }

        }];
    }
    else {
        // ad points explicitly disabled
        [self postAdShowEvent:adAgent
                      adapter:adAgent.currentAdapter
                       result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeAdShowPoint]];

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
    eventParams[@"adProvider"] = [adapter name];
    eventParams[@"adProviderVersion"] = [adapter version];
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
        if (result.error) {
            eventParams[@"adProviderError"] = result.error;
        }

        [self.delegate recordEventWithName:@"adRequest" parameters:eventParams];
    }
}

@end
