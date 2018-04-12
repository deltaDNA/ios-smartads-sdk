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

#import "DDNASmartAdMachineZoneRewardedAdapter.h"
#import "DDNASmartAdMachineZoneHelper.h"
#import <FMAdZone/FMAdZone.h>

@interface DDNASmartAdMachineZoneRewardedAdapter () <FMAdDelegate, FMRewardedVideoAdDelegate>
    
@property (nonatomic, strong) FMAdRequest *adRequest;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, assign) BOOL reward;

@end

@implementation DDNASmartAdMachineZoneRewardedAdapter
    
- (instancetype)initWithAdUnitId:(NSString *)adUnitId testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"MACHINEZONE"
                            version:[DDNASmartAdMachineZoneHelper sdkVersion]
                               eCPM:eCPM
                     waterfallIndex:waterfallIndex])) {
        
        self.adUnitId = adUnitId;
        self.testMode = testMode;
        
        [[DDNASmartAdMachineZoneHelper sharedInstance] startAdZone];
    }
    return self;
}
    
#pragma mark - DDNASmartAdAdapter
    
- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"adUnitId"]) return nil;
    
    return [self initWithAdUnitId:configuration[@"adUnitId"]
                         testMode:[configuration[@"testMode"] boolValue]
                             eCPM:[configuration[@"eCPM"] integerValue]
                   waterfallIndex:waterfallIndex];
}
    
- (void)requestAd
{
    self.reward = NO;
    if ([DDNASmartAdMachineZoneHelper sharedInstance].adZoneStarted) {
        self.adRequest = [[FMAdZone sharedAdZone] rewardedWithAdUnitID:self.adUnitId delegate:self];
    } else {
        [DDNASmartAdMachineZoneHelper sharedInstance].requestRewarded = ^{
            [self requestAd];
        };
    }
}
    
- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.adRequest && self.adRequest.state == FMAdRequestStateReadyToShow) {
        [self.adRequest show:viewController];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeExpired]];
    }
}
    
#pragma mark - FMAdDelegate
    
-  (void)adZoneAdDidLoad:(FMAdRequest *)adRequest
{
    if (adRequest == self.adRequest) {
        [self.delegate adapterDidLoadAd:self];
    }
}
    
- (void)adZoneAdDidFail:(FMAdRequest *)adRequest withError:(FMError *)error
{
    if (self.adRequest == nil) {
        DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration errorDescription:@"Invalid adUnitId"];
            [self.delegate adapterDidFailToLoadAd:self withResult:result];
    }
    else if (adRequest == self.adRequest) {
        // Not getting any information from the error object.
        DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
        [self.delegate adapterDidFailToLoadAd:self withResult:result];
    }
}
    
- (void)adZoneAdDidShow:(FMAdRequest *)adRequest
{
    if (adRequest == self.adRequest) {
        [self.delegate adapterIsShowingAd:self];
    }
}
    
- (void)adZoneAdDidClose:(FMAdRequest *)adRequest
{
    if (adRequest == self.adRequest) {
        [self.delegate adapterDidCloseAd:self canReward:self.reward];
        self.adRequest = nil;
    }
}
    
- (void)adZoneAdDidReceiveClick:(FMAdRequest *)adRequest
{
    if (adRequest == self.adRequest) {
        [self.delegate adapterWasClicked:self];
    }
}
    
#pragma mark - FMRewardedVideoDelegate
    
- (void)adZoneAdShouldRewardUser:(FMAdRequest *)adRequest
{
    if (adRequest == self.adRequest) {
        self.reward = YES;
    }
}
    
@end

