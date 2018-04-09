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

#import "DDNARewardedAd.h"
#import <DeltaDNA/DDNAEngagement.h>
#import "DDNASmartAds.h"
#import "DDNASmartAdService.h"
#import <DeltaDNA/DDNALog.h>

@interface DDNARewardedAd () <DDNASmartAdsRewardedDelegate>

@property (nonatomic, strong, readwrite) DDNAEngagement *engagement;
@property (nonatomic, strong) id loadObserverId;
@property (nonatomic, strong) id showObserverId;
@property (nonatomic, assign) BOOL waitingToLoad;

@end

@implementation DDNARewardedAd

@synthesize engagement;

+ (instancetype)rewardedAdWithDelegate:(id<DDNARewardedAdDelegate>)delegate
{
    DDNARewardedAd *rewardedAd = [[DDNARewardedAd alloc] init];
    if (rewardedAd) {
        rewardedAd.delegate = delegate;
    }
    return rewardedAd;
}

+ (instancetype)rewardedAdWithEngagement:(DDNAEngagement *)engagement delegate:(id<DDNARewardedAdDelegate>)delegate
{
    DDNARewardedAd *rewardedAd = [[DDNARewardedAd alloc] initWithEngagement:engagement];
    if (rewardedAd) {
        rewardedAd.delegate = delegate;
    }
    return rewardedAd;
}

+ (instancetype)rewardedAdWithUncheckedEngagement:(DDNAEngagement *)engagement delegate:(id<DDNARewardedAdDelegate>)delegate
{
    DDNARewardedAd *rewardedAd = [[DDNARewardedAd alloc] initWithEngagement:nil];
    if (rewardedAd) {
        rewardedAd.delegate = delegate;
        if (engagement != nil && engagement.json != nil && engagement.json[@"parameters"] != nil) {
            rewardedAd.engagement = engagement;
        }
    }
    return rewardedAd;
}

- (instancetype)init
{
    if ((self = [super initWithEngagement:nil])) {
        if (![[DDNASmartAds sharedInstance] isRewardedAdAllowed:nil checkTime:NO]) return nil;
        [self registerListeners];
    }
    return self;
}

- (instancetype)initWithEngagement:(DDNAEngagement *)engagement
{
    if ((self = [super initWithEngagement:engagement])) {
        if (![[DDNASmartAds sharedInstance] isRewardedAdAllowed:engagement checkTime:NO]) return nil;
        [self registerListeners];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterListeners];
}

- (BOOL)isReady
{
    if (self.engagement) {
        return [[DDNASmartAds sharedInstance] isRewardedAdAllowed:self.engagement checkTime:YES] && [[DDNASmartAds sharedInstance] hasLoadedRewardedAd];
    } else {
        return [[DDNASmartAds sharedInstance] hasLoadedRewardedAd];
    }
}

- (void)showFromRootViewController:(UIViewController *)viewController
{
    if (self.engagement) {
        [DDNASmartAds sharedInstance].rewardedDelegate = self;  // set ourself as delegate to receive open/close messages
        [[DDNASmartAds sharedInstance] showRewardedAdFromRootViewController:viewController engagement:self.engagement];
    } else {
        DDNALogWarn(@"Prefer showing ads with Engagements");
        [[DDNASmartAds sharedInstance] showRewardedAdFromRootViewController:viewController engagement:nil];
    }
}

- (NSString *)rewardType
{
    return [self parameters] ? [self parameters][@"ddnaAdRewardType"] : nil;
}

- (NSInteger)rewardAmount
{
    return [self parameters] ? [([self parameters][@"ddnaAdRewardAmount"]) integerValue] : 0;
}


#pragma mark - DDNASmartAdsRewardedDelegate

- (void)didOpenRewardedAd
{
    if ([self.delegate respondsToSelector:@selector(didOpenRewardedAd:)]) {
        [self.delegate didOpenRewardedAd:self];
    }
}

- (void)didFailToOpenRewardedAdWithReason:(NSString *)reason
{
    if ([self.delegate respondsToSelector:@selector(didFailToOpenRewardedAd:withReason:)]) {
        [self.delegate didFailToOpenRewardedAd:self withReason:reason];
    }
}

- (void)didCloseRewardedAdWithReward:(BOOL)reward
{
    if ([self.delegate respondsToSelector:@selector(didCloseRewardedAd:withReward:)]) {
        [self.delegate didCloseRewardedAd:self withReward:reward];
    }
}

#pragma mark - Private Helpers

- (void)registerListeners
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    __weak typeof(self) weakSelf = self;
    self.loadObserverId = [center addObserverForName:kDDNALoadedAd object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSString *adType = note.userInfo[kDDNAAdType];
        if ([adType isEqualToString:AD_TYPE_REWARDED] && [weakSelf.delegate respondsToSelector:@selector(didLoadRewardedAd:)]) {
            if ([[DDNASmartAds sharedInstance] isRewardedAdAllowed:weakSelf.engagement checkTime:YES]) {
                weakSelf.waitingToLoad = NO;
                [weakSelf.delegate didLoadRewardedAd:weakSelf];
            } else if ([[DDNASmartAds sharedInstance] isRewardedAdAllowed:weakSelf.engagement checkTime:NO] && !weakSelf.waitingToLoad) {
                weakSelf.waitingToLoad = YES;
                NSTimeInterval waitSecs = [[DDNASmartAds sharedInstance] timeUntilRewardedAdAllowedForEngagement:weakSelf.engagement];
                dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW,
                                                      waitSecs*NSEC_PER_SEC);
                dispatch_after(delay, dispatch_get_main_queue(), ^{
                    if (weakSelf.waitingToLoad) {
                        weakSelf.waitingToLoad = NO;
                        if ([[DDNASmartAds sharedInstance] hasLoadedRewardedAd]) {
                            [weakSelf.delegate didLoadRewardedAd:weakSelf];
                        }
                    }
                });
            }
        }
    }];
    self.showObserverId = [center addObserverForName:kDDNAShowingAd object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSString *adType = note.userInfo[kDDNAAdType];
        NSString *decisionPoint = note.userInfo[kDDNAAdPoint];
        if ([adType isEqualToString:AD_TYPE_REWARDED] && ![decisionPoint isEqualToString:weakSelf.decisionPoint] && [[DDNASmartAds sharedInstance] isRewardedAdAllowed:weakSelf.engagement checkTime:NO] && !weakSelf.waitingToLoad && [weakSelf.delegate respondsToSelector:@selector(didLoadRewardedAd:)]) {
            [weakSelf.delegate didExpireRewardedAd:weakSelf];
        }
    }];
}

- (void)unregisterListeners
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self.loadObserverId];
    [center removeObserver:self.showObserverId];
}

@end
