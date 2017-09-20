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

#import "DDNASmartAdAdMobInterstitialAdapter.h"
#import "DDNASmartAdAdMobHelper.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface DDNASmartAdAdMobInterstitialAdapter () <GADInterstitialDelegate>

@property (nonatomic, strong) GADInterstitial *interstitial;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, assign) BOOL testMode;

@end

@implementation DDNASmartAdAdMobInterstitialAdapter

- (instancetype)initWithAdUnitId:(NSString *)adUnitId testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"ADMOB"
                            version:[DDNASmartAdAdMobHelper sdkVersion]
                               eCPM:eCPM
                     waterfallIndex:waterfallIndex])) {
        
        self.adUnitId = testMode ? @"ca-app-pub-3940256099942544/1033173712" : adUnitId;
        self.testMode = testMode;
        
        [DDNASmartAdAdMobHelper configureWithAppId:@"ca-app-pub-3940256099942544~1458002511"];
    }
    return self;
}

- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.adUnitId];
    interstitial.delegate = self;
    
    GADRequest *request = [GADRequest request];
    [interstitial loadRequest:request];
    return interstitial;
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
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.interstitial && [self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:viewController];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - GADInterstitialDelegate protocol

/// Called when an interstitial ad request succeeded. Show it at the next transition point in your
/// application such as when transitioning between view controllers.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    if (ad == self.interstitial) {
        [self.delegate adapterDidLoadAd:self];
    }
}

/// Called when an interstitial ad request completed without an interstitial to
/// show. This is common since interstitials are shown sparingly to users.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    if (ad == self.interstitial) {
        [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdAdMobHelper resultCodeFromError:error]];
    }
}

/// Called just before presenting an interstitial. After this method finishes the interstitial will
/// animate onto the screen. Use this opportunity to stop animations and save the state of your
/// application in case the user leaves while the interstitial is on screen (e.g. to visit the App
/// Store from a link on the interstitial).
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
    if (ad == self.interstitial) {
        [self.delegate adapterIsShowingAd:self];
    }
}

/// Called before the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    
}

/// Called just after dismissing an interstitial and it has animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    if (ad == self.interstitial) {
        self.interstitial = nil;
        [self.delegate adapterDidCloseAd:self canReward:YES];
    }
}

/// Called just before the application will background or terminate because the user clicked on an
/// ad that will launch another application (such as the App Store). The normal
/// UIApplicationDelegate methods, like applicationDidEnterBackground:, will be called immediately
/// before this.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    if (ad == self.interstitial) {
        [self.delegate adapterWasClicked:self];
        [self.delegate adapterLeftApplication:self];
    }
}

@end
