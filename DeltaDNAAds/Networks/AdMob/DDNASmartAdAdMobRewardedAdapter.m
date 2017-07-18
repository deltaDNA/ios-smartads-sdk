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
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface DDNASmartAdAdMobRewardedAdapter () <GADRewardBasedVideoAdDelegate>
    
@property (nonatomic, strong) GADRewardBasedVideoAd *videoAd;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, assign) BOOL reward;
    
@end

@implementation DDNASmartAdAdMobRewardedAdapter
    
- (instancetype)initWithAdUnitId:(NSString *)adUnitId testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"ADMOB"
                            version:[GADRequest sdkVersion]
                               eCPM:eCPM
                     waterfallIndex:waterfallIndex])) {
        
        self.adUnitId = adUnitId;
        self.testMode = testMode;
        
        [GADRewardBasedVideoAd sharedInstance].delegate = self;
        [self requestRewardedVideo];
    }
    return self;
}
    
- (void)requestRewardedVideo
{
    self.reward = NO;
    GADRequest *request = [GADRequest request];
    if (self.testMode) {
        // Requests test ads on test devices.  We could expand this to list of known devices
        // to run test ads on them too.
        request.testDevices = @[kGADSimulatorID];
    }
    
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                           withAdUnitID:self.adUnitId];
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
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
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
    DDNASmartAdRequestResult *result;
    
    switch (error.code) {
        case kGADErrorInvalidRequest:
            
            /// The ad request is invalid. The localizedFailureReason error description will have more
            /// details. Typically this is because the ad did not have the ad unit ID or root view
            /// controller set.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        case kGADErrorNoFill:
            /// The ad request was successful, but no ad was returned.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
            break;
            
        case kGADErrorNetworkError:
            /// There was an error loading data from the network.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
            break;
            
        case kGADErrorServerError:
            /// The ad server experienced a failure processing the request.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        case kGADErrorOSVersionTooLow:
            /// The current device's OS is below the minimum required version.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration];
            break;
            
        case kGADErrorTimeout:
            /// The request was unable to be loaded before being timed out.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
            break;
            
        case kGADErrorInterstitialAlreadyUsed:
            /// Will not send request because the interstitial object has already been used.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        case kGADErrorMediationDataError:
            /// The mediation response was invalid.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        case kGADErrorMediationAdapterError:
            /// Error finding or creating a mediation ad network adapter.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        case kGADErrorMediationNoFill:
            /// The mediation request was successful, but no ad was returned from any ad networks.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
            break;
            
        case kGADErrorMediationInvalidAdSize:
            /// Attempting to pass an invalid ad size to an adapter.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration];
            break;
            
        case kGADErrorInternalError:
            /// Internal error.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        case kGADErrorInvalidArgument:
            /// Invalid argument error.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        case kGADErrorReceivedInvalidResponse:
            /// Received invalid response.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        default:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
            break;
    }
    result.errorDescription = [error localizedDescription];
    
    [self.delegate adapterDidFailToLoadAd:self withResult:result];
}

@end
