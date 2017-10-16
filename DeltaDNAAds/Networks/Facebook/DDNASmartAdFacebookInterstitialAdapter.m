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

#import "DDNASmartAdFacebookInterstitialAdapter.h"
#import "DDNASmartAdFacebookHelper.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface DDNASmartAdFacebookInterstitialAdapter () <FBInterstitialAdDelegate>

@property (nonatomic, copy, readwrite) NSString *placementId;
@property (nonatomic, strong) FBInterstitialAd *interstitialAd;
@property (nonatomic, assign) BOOL testMode;

@end

@implementation DDNASmartAdFacebookInterstitialAdapter

- (instancetype)initWithPlacementId:(NSString *)placementId
                           testMode:(BOOL)testMode
                               eCPM:(NSInteger)eCPM
                     waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"FACEBOOK" version:[[DDNASmartAdFacebookHelper sharedInstance] getSDKVersion] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        self.placementId = placementId;
        
        [[DDNASmartAdFacebookHelper sharedInstance] setTestMode:testMode];
        self.testMode = testMode;
    }
    return self;
}

- (FBInterstitialAd *)createAndLoadInterstitial {
    FBInterstitialAd *interstitial = [[FBInterstitialAd alloc] initWithPlacementID:self.placementId];
    interstitial.delegate = self;
    // For auto play video ads, it's recommended to load the ad
    // at least 30 seconds before it is shown
    [interstitial loadAd];
    return interstitial;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"placementId"]) return nil;
    
    return [self initWithPlacementId:configuration[@"placementId"]
                            testMode:[configuration[@"testMode"] boolValue]
                                eCPM:[configuration[@"eCPM"] integerValue]
                      waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    self.interstitialAd = [self createAndLoadInterstitial];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.interstitialAd && [self.interstitialAd isAdValid]) {
        [self.interstitialAd showAdFromRootViewController:viewController];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - FBInterstitialAdDelegate

/**
 Sent after an ad in the FBInterstitialAd object is clicked. The appropriate app store view or
 app browser will be launched.
 
 - Parameter interstitialAd: An FBInterstitialAd object sending the message.
 */
- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
    if (interstitialAd == self.interstitialAd) {
        [self.delegate adapterWasClicked:self];
    }
}

/**
 Sent after an FBInterstitialAd object has been dismissed from the screen, returning control
 to your application.
 
 - Parameter interstitialAd: An FBInterstitialAd object sending the message.
 */
- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
    if (interstitialAd == self.interstitialAd) {
        [self.delegate adapterDidCloseAd:self canReward:YES];
    }
}

/**
 Sent when an FBInterstitialAd successfully loads an ad.
 
 - Parameter interstitialAd: An FBInterstitialAd object sending the message.
 */
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    if (interstitialAd == self.interstitialAd) {
        [self.delegate adapterDidLoadAd:self];
    }
}

/**
 Sent when an FBInterstitialAd failes to load an ad.
 
 - Parameter interstitialAd: An FBInterstitialAd object sending the message.
 - Parameter error: An error object containing details of the error.
 */
- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    if (interstitialAd == self.interstitialAd) {
        DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:[[DDNASmartAdFacebookHelper sharedInstance] resultCodeFromError:error]];
        result.errorDescription = error.localizedDescription;
        
        [self.delegate adapterDidFailToLoadAd:self withResult:result];
    }
}

/**
 Sent immediately before the impression of an FBInterstitialAd object will be logged.
 
 - Parameter interstitialAd: An FBInterstitialAd object sending the message.
 */
- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd
{
    if (interstitialAd == self.interstitialAd) {
        [self.delegate adapterIsShowingAd:self];
    }
}

@end
