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
#import <DeltaDNA/DDNALog.h>
#import <IronSource/IronSource.h>

@interface DDNASmartAdIronSourceRewardedAdapter () <DDNASmartAdIronSourceRewardedDelegate>

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *placementName;
@property (nonatomic, assign) BOOL reward;
@property (nonatomic, weak) NSTimer *loadedTimer;

@end

@implementation DDNASmartAdIronSourceRewardedAdapter

- (instancetype)initWithAppKey:(NSString *)appKey
                 placementName:(NSString *)placementName
                         eCPM:(NSInteger)eCPM
               waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"IRONSOURCE" version:[[DDNASmartAdIronSourceHelper sharedInstance] getSDKVersion] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        [[DDNASmartAdIronSourceHelper sharedInstance] setRewardedDelegate:self];
        self.appKey = appKey;
        self.placementName = placementName;
        self.reward = NO;
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appKey"]) return nil;
    
    return [self initWithAppKey:configuration[@"appKey"]
                  placementName:configuration[@"placementName"]
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
    else {
    
        // start a timer to give it a chance to call the availability callback
        if (self.loadedTimer) {
            [self.loadedTimer invalidate];
        }
        
        self.loadedTimer = [NSTimer scheduledTimerWithTimeInterval:self.delegate ? self.delegate.adapterTimeoutSeconds - 1.0 : 10.0
                                                      target:[NSBlockOperation blockOperationWithBlock:^{
            if (![[DDNASmartAdIronSourceHelper sharedInstance] hasRewardedVideo]) {
                [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill]];
            } else {
                [self.delegate adapterDidLoadAd:self];
            }
        }]
                                                    selector: @selector(main)
                                                    userInfo: nil
                                                     repeats: NO];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([[DDNASmartAdIronSourceHelper sharedInstance] hasRewardedVideo]) {
        [[DDNASmartAdIronSourceHelper sharedInstance] showRewardedVideoWithViewController:viewController placement:self.placementName];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeExpired]];
    }
}

#pragma mark - DDNASmartAdIronSourceRewardedDelegate

- (void)rewardedVideoHasChangedAvailability:(BOOL)available
{
    if (self.loadedTimer && available) {
        [self.loadedTimer invalidate];
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo
{
    if ([_placementName isEqualToString:placementInfo.placementName]) {
        self.reward = YES;
    }
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error
{
    [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeError]];
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

- (void)didClickRewardedVideoForPlacement:(ISPlacementInfo *)placementInfo
{
    if ([_placementName isEqualToString:placementInfo.placementName]) {
        [self.delegate adapterWasClicked:self];
    }
}

@end

