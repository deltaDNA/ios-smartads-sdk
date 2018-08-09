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


#import "DDNASmartAdAdMobRewardedAdapter.h"
#import "DDNASmartAdAdMobHelper.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface DDNASmartAdAdMobRewardedAdapter () <GADRewardBasedVideoAdDelegate>

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, assign) BOOL reward;
@property (nonatomic, assign) BOOL initialised;
    
@end

@implementation DDNASmartAdAdMobRewardedAdapter
    
- (instancetype)initWithAppId:(NSString *)appId adUnitId:(NSString *)adUnitId testMode:(BOOL)testMode eCPM:(NSInteger)eCPM privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"ADMOB"
                            version:[DDNASmartAdAdMobHelper sdkVersion]
                               eCPM:eCPM
                            privacy:privacy
                     waterfallIndex:waterfallIndex])) {
        
        self.appId = testMode ? @"ca-app-pub-3940256099942544~1458002511" : appId;
        self.adUnitId = testMode ? @"ca-app-pub-3940256099942544/1712485313" : adUnitId;
        self.testMode = testMode;
        self.initialised = NO;
    }
    return self;
}
    
- (void)requestRewardedVideo
{
    if (!self.initialised) {
        [DDNASmartAdAdMobHelper configureWithAppId:self.appId];
        [GADRewardBasedVideoAd sharedInstance].delegate = self;
        self.initialised = YES;
    }
    self.reward = NO;
    
    GADRequest *request = [GADRequest request];
    if (!self.privacy.advertiserGdprUserConsent) {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{@"npa": @"1"};
        [request registerAdNetworkExtras:extras];
    }
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                           withAdUnitID:self.adUnitId];
}
    
#pragma mark - DDNASmartAdAdapter
    
- (instancetype)initWithConfiguration:(NSDictionary *)configuration privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"adUnitId"] || !configuration[@"appId"]) return nil;
    
    return [self initWithAppId:configuration[@"appId"]
                      adUnitId:configuration[@"adUnitId"]
                      testMode:[configuration[@"testMode"] boolValue]
                          eCPM:[configuration[@"eCPM"] integerValue]
                       privacy:privacy
                waterfallIndex:waterfallIndex];
}
    
- (void)requestAd
{
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [self.delegate adapterDidLoadAd:self];
    } else {
        [self requestRewardedVideo];
    }
}
    
- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:viewController];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeExpired]];
    }
}

- (BOOL)isGdprCompliant
{
    return YES;
}
    
#pragma mark - GADRewardBasedVideoAdDelegate
    
- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward
{
    self.reward = YES;
}
    
- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
    [self.delegate adapterDidLoadAd:self];
}
    
- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
    [self.delegate adapterIsShowingAd:self];
}
    
- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
    
}

- (void)rewardBasedVideoAdDidCompletePlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
    
}
    
- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
    [self.delegate adapterDidCloseAd:self canReward:self.reward];
}
    
- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd
{
    [self.delegate adapterWasClicked:self];
    [self.delegate adapterLeftApplication:self];
}
    
- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error
{
    [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdAdMobHelper resultCodeFromError:error]];
}

@end
