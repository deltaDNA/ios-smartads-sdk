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

#import "DDNASmartAdFacebookRewardedAdapter.h"
#import "DDNASmartAdFacebookHelper.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface DDNASmartAdFacebookRewardedAdapter () <FBRewardedVideoAdDelegate>

@property (nonatomic, copy, readwrite) NSString *placementId;
@property (nonatomic, strong) FBRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, assign) BOOL reward;
@property (nonatomic, assign) BOOL initialised;

@end

@implementation DDNASmartAdFacebookRewardedAdapter

- (instancetype)initWithPlacementId:(NSString *)placementId
                           testMode:(BOOL)testMode
                               eCPM:(NSInteger)eCPM
                            privacy:(DDNASmartAdPrivacy *)privacy
                     waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"FACEBOOK" version:[[DDNASmartAdFacebookHelper sharedInstance] getSDKVersion]  eCPM:eCPM privacy:privacy waterfallIndex:waterfallIndex])) {
        self.placementId = placementId;
        self.testMode = testMode;
        self.reward = NO;
        self.initialised = NO;
    }
    return self;
}

- (FBRewardedVideoAd *)createAndLoadRewardedVideo {
    FBRewardedVideoAd *rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:self.placementId];
    rewardedVideoAd.delegate = self;
    [rewardedVideoAd loadAd];
    return rewardedVideoAd;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"placementId"]) return nil;
    
    return [self initWithPlacementId:configuration[@"placementId"]
                            testMode:[configuration[@"testMode"] boolValue]
                                eCPM:[configuration[@"eCPM"] integerValue]
                             privacy:privacy
                      waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (!self.initialised) {
        [[DDNASmartAdFacebookHelper sharedInstance] setTestMode:self.testMode];
        [FBAdSettings setMediationService:@"deltaDNA"];
        self.initialised = YES;
    }
    self.reward = NO;
    self.rewardedVideoAd = [self createAndLoadRewardedVideo];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.rewardedVideoAd && [self.rewardedVideoAd isAdValid]) {
        [self.rewardedVideoAd showAdFromRootViewController:viewController];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeExpired]];
    }
}

#pragma mark - FBRewardedVideoAdDelegate

/**
  The methods declared by the FBRewardedVideoAdDelegate protocol allow the adopting delegate to respond
 to messages from the FBRewardedVideoAd class and thus respond to operations such as whether the ad has
 been loaded, the person has clicked the ad or closed video/end card.
 */

/**
  Sent after an ad has been clicked by the person.

 - Parameter rewardedVideoAd: An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd
{
    if (rewardedVideoAd == self.rewardedVideoAd) {
        [self.delegate adapterWasClicked:self];
    }
}

/**
  Sent when an ad has been successfully loaded.

 - Parameter rewardedVideoAd: An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd
{
    if (rewardedVideoAd == self.rewardedVideoAd) {
        [self.delegate adapterDidLoadAd:self];
    }
}

/**
  Sent after an FBRewardedVideoAd object has been dismissed from the screen, returning control
 to your application.

 - Parameter rewardedVideoAd: An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    if (rewardedVideoAd == self.rewardedVideoAd) {
        [self.delegate adapterDidCloseAd:self canReward:self.reward];
        self.reward = NO;
    }
}

/**
  Sent after an FBRewardedVideoAd fails to load the ad.

 - Parameter rewardedVideoAd: An FBRewardedVideoAd object sending the message.
 - Parameter error: An error object containing details of the error.
 */
- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    if (rewardedVideoAd == self.rewardedVideoAd) {
        DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:[[DDNASmartAdFacebookHelper sharedInstance] resultCodeFromError:error]];
        result.errorDescription = error.localizedDescription;
        
        [self.delegate adapterDidFailToLoadAd:self withResult:result];
    }
}

/**
  Sent after the FBRewardedVideoAd object has finished playing the video successfully.
 Reward the user on this callback.

 - Parameter rewardedVideoAd: An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdComplete:(FBRewardedVideoAd *)rewardedVideoAd
{
    if (rewardedVideoAd == self.rewardedVideoAd) {
        self.reward = YES;
    }
}

/**
  Sent immediately before the impression of an FBRewardedVideoAd object will be logged.

 - Parameter rewardedVideoAd: An FBRewardedVideoAd object sending the message.
 */
- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd
{
    if (rewardedVideoAd == self.rewardedVideoAd) {
        [self.delegate adapterIsShowingAd:self];
    }
}

@end

