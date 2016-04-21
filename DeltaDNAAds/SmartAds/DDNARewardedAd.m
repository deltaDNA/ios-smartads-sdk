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

@interface DDNARewardedAd () <DDNASmartAdsRewardedDelegate>

@property (nonatomic, strong) NSDictionary *parameters;

@end

@implementation DDNARewardedAd

+ (instancetype)rewardedAdWithDelegate:(id<DDNARewardedAdDelegate>)delegate
{
    DDNARewardedAd *rewardedAd = [[DDNARewardedAd alloc] init];
    rewardedAd.delegate = delegate;
    return rewardedAd;
}

+ (instancetype)rewardedAdWithEngagement:(DDNAEngagement *)engagement delegate:(id<DDNARewardedAdDelegate>)delegate
{
    DDNARewardedAd *rewardedAd = [[DDNARewardedAd alloc] initWithEngagement:engagement];
    rewardedAd.delegate = delegate;
    return rewardedAd;
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.parameters = [[NSDictionary alloc] init];
        [DDNASmartAds sharedInstance].rewardedDelegate = self;
    }
    return self;
}

- (instancetype)initWithEngagement:(DDNAEngagement *)engagement
{
    if (engagement == nil) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"engagement cannot be nil" userInfo:nil]);
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:engagement.json[@"parameters"]];
    
    // Test if we're prevented from showing an ad for this decision point.
    if (parameters && parameters[@"adShowPoint"] && ![parameters[@"adShowPoint"] boolValue]) return nil;
    
    if ((self = [super init])) {
        self.parameters = parameters;
        [DDNASmartAds sharedInstance].rewardedDelegate = self;
    }
    return self;
}

- (BOOL)isReady
{
    return [[DDNASmartAds sharedInstance] isRewardedAdAvailable];
}

- (void)showFromRootViewController:(UIViewController *)viewController
{
    [[DDNASmartAds sharedInstance] showRewardedAdFromRootViewController:viewController];
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

@end