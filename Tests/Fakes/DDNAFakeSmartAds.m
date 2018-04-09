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

#import "DDNAFakeSmartAds.h"
#import "DDNASmartAdService.h"
#import <DeltaDNA/DeltaDNA.h>
#import <objc/runtime.h>

@implementation DDNAFakeSmartAds

+(void)load
{
    // replace singleton with our mock
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(sharedInstance);
        SEL swizzledSelector = @selector(mockSharedInstance);
        
        Method originalMethod = class_getClassMethod(class, originalSelector);
        Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

+(instancetype)mockSharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&pred, ^{
        sharedObject = [[DDNAFakeSmartAds alloc] init];
    });
    return sharedObject;
}

- (void)reset
{
    self.allowInterstitial = NO;
    self.allowRewarded = NO;
    self.loadedInterstitial = NO;
    self.loadedRewarded = NO;
    self.showInterstitial = NO;
    self.showRewarded = NO;
    self.decisionPoint = nil;
    self.lastShown = [[NSMutableDictionary alloc] init];
}

- (BOOL)isInterstitialAdAllowed:(DDNAEngagement *)engagement checkTime:(BOOL)checkTime
{
    return [self isAdAllowed:engagement checkTime:checkTime];
}

- (BOOL)hasLoadedInterstitialAd
{
    return self.loadedInterstitial;
}

- (void)loadInterstitialAd
{
    self.loadedInterstitial = YES;
}

- (void)showInterstitialAdWithDecisionPoint:(NSString *)decisionPoint
{
    self.showInterstitial = YES;
    self.decisionPoint = decisionPoint;
}


- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController engagement:(DDNAEngagement *)engagement
{
    if (self.showInterstitial) {
        self.loadedInterstitial = NO;
        [self.interstitialDelegate didOpenInterstitialAd];
    } else {
        [self.interstitialDelegate didFailToOpenInterstitialAdWithReason:@"Not allowed"];
    }
}

- (void)closeInterstitialAd
{
    self.showInterstitial = NO;
    self.loadedInterstitial = NO;
    [self.interstitialDelegate didCloseInterstitialAd];
}

- (void)closeInterstitialAdAtDecisionPoint:(NSString *)decisionPoint
{
    self.decisionPoint = decisionPoint;
    self.showInterstitial = NO;
    self.loadedInterstitial = NO;
    [self.interstitialDelegate didCloseInterstitialAd];
    [self.lastShown setObject:[NSDate date] forKey:decisionPoint];
}

- (void)loadRewardedAd
{
    self.loadedRewarded = YES;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kDDNALoadedAd
                          object:self
                        userInfo:@{
        kDDNAAdType: AD_TYPE_REWARDED,
        kDDNAAdNetwork: @"FakeAdapter",
        kDDNAAdPoint: self.decisionPoint ? self.decisionPoint : @"",
        kDDNARequestTime: @2        
    }];
}

- (void)showRewardedAdWithDecisionPoint:(NSString *)decisionPoint
{
    self.showRewarded = YES;
    self.decisionPoint = decisionPoint;
}

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController engagement:(DDNAEngagement *)engagement
{
    if (self.showRewarded) {
        self.loadedRewarded = NO;
        [self.rewardedDelegate didOpenRewardedAd];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:kDDNAShowingAd
                          object:self
                        userInfo:@{
                                   kDDNAAdType: AD_TYPE_REWARDED,
                                   kDDNAAdNetwork: @"FakeAdapter",
                                   kDDNAAdPoint: self.decisionPoint ? self.decisionPoint : @"",
                                   kDDNARequestTime: @2
        }];
    } else {
        [self.rewardedDelegate didFailToOpenRewardedAdWithReason:@"Not allowed"];
    }
}

- (void)closeRewardedAdWithReward:(BOOL)reward
{
    [self closeRewardedAdWithReward:reward atDecisionPoint:self.decisionPoint];
}

- (void)closeRewardedAdWithReward:(BOOL)reward atDecisionPoint:(NSString *)decisionPoint
{
    self.decisionPoint = decisionPoint;
    self.showRewarded = NO;
    self.loadedRewarded = NO;
    [self.rewardedDelegate didCloseRewardedAdWithReward:reward];
    [self.lastShown setObject:[NSDate date] forKey:decisionPoint];
}

- (BOOL)isRewardedAdAllowed:(DDNAEngagement *)engagement checkTime:(BOOL)checkTime
{
    return [self isAdAllowed:engagement checkTime:checkTime];
}

- (BOOL)isAdAllowed:(DDNAEngagement *)engagement checkTime:(BOOL)checkTime
{
    if (checkTime && self.lastShown[engagement.decisionPoint]) {
        NSDictionary *params = engagement.json[@"parameters"];
        NSInteger adShowWaitSecs = [params[@"ddnaAdShowWaitSecs"] integerValue];
        NSTimeInterval timeSinceLastAd = [[NSDate date] timeIntervalSinceDate:self.lastShown[engagement.decisionPoint]];
        return timeSinceLastAd >= adShowWaitSecs;
    }
    return self.allowInterstitial || self.allowRewarded;
}

- (NSTimeInterval)timeUntilRewardedAdAllowedForEngagement:(DDNAEngagement *)engagement
{
    NSTimeInterval timeSinceLastAd = [[NSDate date] timeIntervalSinceDate:self.lastShown[engagement.decisionPoint]];
    if (self.lastShown[engagement.decisionPoint]) {
        NSDictionary *params = engagement.json[@"parameters"];
        NSInteger adShowWaitSecs = [params[@"ddnaAdShowWaitSecs"] integerValue];
        return adShowWaitSecs - timeSinceLastAd;
    }
    return 0;
}

- (BOOL)hasLoadedRewardedAd
{
    return self.loadedRewarded;
}

- (BOOL)isRewardedAdReadyForEngagement:(DDNAEngagement *)engagement
{
    return self.loadedRewarded;
}

- (NSDate *)lastShownForDecisionPoint:(NSString *)decisionPoint
{
    return nil;
}

- (NSInteger)sessionCountForDecisionPoint:(NSString *)decisionPoint
{
    return 0;
}

- (NSInteger)dailyCountForDecisionPoint:(NSString *)decisionPoint
{
    return 0;
}


@end
