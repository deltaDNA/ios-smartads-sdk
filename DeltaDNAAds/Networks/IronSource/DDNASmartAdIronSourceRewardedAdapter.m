//
// Copyright (c) 2017 deltaDNA Ltd. All rights reserved.
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

#import "DDNASmartAdIronSourceRewardedAdapter.h"
#import "DDNASmartAdIronSourceHelper.h"

@interface DDNASmartAdIronSourceRewardedAdapter () <DDNASmartAdIronSourceRewardedDelegate>

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, assign) BOOL reward;

@end

@implementation DDNASmartAdIronSourceRewardedAdapter

- (instancetype)initWithAppKey:(NSString *)appKey
                         eCPM:(NSInteger)eCPM
               waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"IRONSOURCE" version:[[DDNASmartAdIronSourceHelper sharedInstance] getSDKVersion] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        [[DDNASmartAdIronSourceHelper sharedInstance] setRewardedDelegate:self];
        self.appKey = appKey;
        self.reward = NO;
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appKey"]) return nil;
    
    return [self initWithAppKey:configuration[@"appKey"]
                          eCPM:[configuration[@"eCPM"] integerValue]
                waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    self.reward = NO;
    [[DDNASmartAdIronSourceHelper sharedInstance] startWithAppKey:self.appKey];
    if ([[DDNASmartAdIronSourceHelper sharedInstance] hasRewardedVideo]) {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([[DDNASmartAdIronSourceHelper sharedInstance] hasRewardedVideo]) {
        [[DDNASmartAdIronSourceHelper sharedInstance] showRewardedVideoWithViewController:viewController placement:nil];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - DDNASmartAdIronSourceRewardedDelegate

- (void)rewardedVideoHasChangedAvailability:(BOOL)available
{
    if (available) {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo
{
    self.reward = YES;
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error
{
    [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
}

- (void)rewardedVideoDidOpen
{
    [self.delegate adapterIsShowingAd:self];
}

- (void)rewardedVideoDidClose
{
    [self.delegate adapterDidCloseAd:self canReward:self.reward];
}

- (void)rewardedVideoDidStart
{
    
}

- (void)rewardedVideoDidEnd
{
    
}

@end

