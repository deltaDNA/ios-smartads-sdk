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

#import "DDNASmartAds.h"
#import "DDNASmartAdFactory.h"
#import "DDNASmartAdService.h"
#import <DeltaDNA/DeltaDNA.h>
#import <DeltaDNA/DDNALog.h>
#import <DeltaDNA/NSString+DeltaDNA.h>



@interface DDNAEngagement(DeltaDNAAds)

@property (nonatomic, copy) NSString *flavour;

@end

@interface DDNASmartAds () <DDNASmartAdServiceDelegate>
{

}

@property (nonatomic, strong) DDNASmartAdFactory *factory;
@property (nonatomic, strong) DDNASmartAdService *adService;

@end

@implementation DDNASmartAds

+ (void)load
{
    NSLog(@"Loaded DDNASmartAds class");
}

- (id)init
{
    if ((self = [super init])) {
        self.factory = [DDNASmartAdFactory sharedInstance];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSString *)sdkVersion
{
    return @"SmartAds v1.5.1";
}

- (void)registerForAds
{
    @synchronized(self) {
        @try{
            if (!self.adService) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDNASDKNewSession" object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerForAds) name:@"DDNASDKNewSession" object:nil];
            }

            self.adService = [self.factory buildSmartAdServiceWithDelegate:self];
            [self.adService beginSessionWithDecisionPoint:@"advertising"];
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error registering for ads: %@", exception);
        }
        @finally {
            if (!self.adService) {
                DDNALogWarn(@"Failed to register for ads.");
                [self.registrationDelegate didFailToRegisterForInterstitialAdsWithReason:@"Couldn't create ad service."];
                [self.registrationDelegate didFailToRegisterForRewardedAdsWithReason:@"Couldn't create ad service."];
            }
        }
    }
}

- (BOOL)isInterstitialAdAllowed:(DDNAEngagement *)engagement
{
    @synchronized (self) {
        if (!self.adService) return NO;

        if (engagement != nil && engagement.json != nil) {
            return [self.adService isInterstitialAdAllowedForDecisionPoint:engagement.decisionPoint
                                                      engagementParameters:engagement.json[@"parameters"]];
        } else {
            return [self.adService isInterstitialAdAllowed];
        }
    }
}

- (BOOL)isInterstitialAdAvailable
{
    @synchronized(self) {
        if (self.adService) {
            return [self.adService isInterstitialAdAvailable];
        }
        return NO;
    }
}

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController
{
    @synchronized(self) {
        @try {
            if (self.adService) {
                [self.adService showInterstitialAdFromRootViewController:viewController];
            } else {
                DDNALogWarn(@"RegisterForAds must be called before showing ads will work.");
                [self.interstitialDelegate didFailToOpenInterstitialAdWithReason:@"Not registered"];
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error showing ad: %@", exception);
            [self.interstitialDelegate didFailToOpenInterstitialAdWithReason:exception.reason];
        }
    }
}

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController decisionPoint:(NSString *)decisionPoint
{
    @synchronized(self) {
        @try {
            if (self.adService) {
                [self.adService showInterstitialAdFromRootViewController:viewController decisionPoint:decisionPoint];
            } else {
                DDNALogWarn(@"RegisterForAds must be called before showing ads will work.");
                [self.interstitialDelegate didFailToOpenInterstitialAdWithReason:@"Not registered"];
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error showing ad: %@", exception);
            [self.interstitialDelegate didFailToOpenInterstitialAdWithReason:exception.reason];
        }
    }
}

- (BOOL)isRewardedAdAllowed:(DDNAEngagement *)engagement
{
    @synchronized (self) {
        if (!self.adService) return NO;

        if (engagement != nil && engagement.json != nil) {
            return [self.adService isRewardedAdAllowedForDecisionPoint:engagement.decisionPoint
                                                  engagementParameters:engagement.json[@"parameters"]];
        } else {
            return [self.adService isRewardedAdAllowed];
        }
    }
}


- (BOOL)isRewardedAdAvailable
{
    @synchronized(self) {
        if (self.adService) {
            return [self.adService isRewardedAdAvailable];
        }
        return NO;
    }
}

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController
{
    @synchronized(self) {
        @try {
            if (self.adService) {
                [self.adService showRewardedAdFromRootViewController:viewController];
            } else {
                DDNALogWarn(@"RegisterForAds must be called before showing ads will work.");
                [self.rewardedDelegate didFailToOpenRewardedAdWithReason:@"Not registered"];
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error showing ad: %@", exception);
            [self.rewardedDelegate didFailToOpenRewardedAdWithReason:exception.reason];
        }
    }
}

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController decisionPoint:(NSString *)decisionPoint
{
    @synchronized(self) {
        @try {
            if (self.adService) {
                [self.adService showRewardedAdFromRootViewController:viewController decisionPoint:decisionPoint];
            } else {
                DDNALogWarn(@"RegisterForAds must be called before showing ads will work.");
                [self.rewardedDelegate didFailToOpenRewardedAdWithReason:@"Not registered"];
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error showing ad: %@", exception);
            [self.rewardedDelegate didFailToOpenRewardedAdWithReason:exception.reason];
        }
    }
}

- (void)pause
{
    [self.adService pause];
}

- (void)resume
{
    [self.adService resume];
}


#pragma mark - DDNASmartAdServiceDelegate

- (void)didRegisterForInterstitialAds
{
    DDNALogDebug(@"Registered for interstitial ads.");
    if ([self.registrationDelegate respondsToSelector:@selector(didRegisterForInterstitialAds)]) {
        [self.registrationDelegate didRegisterForInterstitialAds];
    }
}

- (void)didFailToRegisterForInterstitialAdsWithReason:(NSString *)reason
{
    DDNALogDebug(@"Failed to register for interstitial ads: %@.", reason);
    if ([self.registrationDelegate respondsToSelector:@selector(didFailToRegisterForRewardedAdsWithReason:)]) {
        [self.registrationDelegate didFailToRegisterForInterstitialAdsWithReason:reason];
    }
}

- (void)recordEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    [[DDNASDK sharedInstance] recordEventWithName:eventName eventParams:parameters];
}

- (void)requestEngagementWithDecisionPoint:(NSString *)decisionPoint flavour:(NSString *)flavour parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSString *, NSInteger, NSError *))completionHandler
{
    DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:decisionPoint];
    engagement.flavour = flavour;
    for (NSString *key in parameters) {
        [engagement setParam:parameters[key] forKey:key];
    }

    [[DDNASDK sharedInstance] requestEngagement:engagement completionHandler:^(NSDictionary *parameters, NSInteger statusCode, NSError *error) {
        completionHandler([NSString stringWithContentsOfDictionary:parameters], statusCode, error);
    }];
}

- (void)didFailToOpenInterstitialAdWithReason:(NSString *)reason
{
    if ([self.interstitialDelegate respondsToSelector:@selector(didFailToOpenInterstitialAdWithReason:)]) {
        [self.interstitialDelegate didFailToOpenInterstitialAdWithReason:reason];
    }
}

- (void)didOpenInterstitialAd
{
    if ([self.interstitialDelegate respondsToSelector:@selector(didOpenInterstitialAd)]) {
        [self.interstitialDelegate didOpenInterstitialAd];
    }
}

- (void)didCloseInterstitialAd
{
    if ([self.interstitialDelegate respondsToSelector:@selector(didCloseInterstitialAd)]) {
        [self.interstitialDelegate didCloseInterstitialAd];
    }
}

- (void)didRegisterForRewardedAds
{
    DDNALogDebug(@"Registered for rewarded ads.");
    if ([self.registrationDelegate respondsToSelector:@selector(didRegisterForRewardedAds)]) {
        [self.registrationDelegate didRegisterForRewardedAds];
    }
}

- (void)didFailToRegisterForRewardedAdsWithReason:(NSString *)reason
{
    DDNALogDebug(@"Failed to register for rewarded ads: %@.", reason);
    if ([self.registrationDelegate respondsToSelector:@selector(didFailToRegisterForRewardedAdsWithReason:)]) {
        [self.registrationDelegate didFailToRegisterForRewardedAdsWithReason:reason];
    }
}

- (void)didFailToOpenRewardedAdWithReason:(NSString *)reason
{
    DDNALogDebug(@"Failed to open rewarded ad: %@", reason);
    if ([self.rewardedDelegate respondsToSelector:@selector(didFailToOpenRewardedAdWithReason:)]) {
        [self.rewardedDelegate didFailToOpenRewardedAdWithReason:reason];
    }
}

- (void)didOpenRewardedAd
{
    DDNALogDebug(@"Opened rewarded ad.");
    if ([self.rewardedDelegate respondsToSelector:@selector(didOpenRewardedAd)]) {
        [self.rewardedDelegate didOpenRewardedAd];
    }
}

- (void)didCloseRewardedAdWithReward:(BOOL)reward
{
    DDNALogDebug(@"Closed rewarded ad with reward %@", reward ? @"YES" : @"NO");
    if ([self.rewardedDelegate respondsToSelector:@selector(didCloseRewardedAdWithReward:)]) {
        [self.rewardedDelegate didCloseRewardedAdWithReward:reward];
    }
}

@end
