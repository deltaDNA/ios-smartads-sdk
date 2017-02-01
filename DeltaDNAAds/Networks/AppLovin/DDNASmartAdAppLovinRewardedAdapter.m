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

#import "DDNASmartAdAppLovinRewardedAdapter.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface DDNASmartAdAppLovinRewardedAdapter () <ALAdLoadDelegate, ALAdDisplayDelegate, ALAdRewardDelegate>

@property (nonatomic, copy) NSString *sdkKey;
@property (nonatomic, copy) NSString *placement;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, strong) ALSdk *alSdk;
@property (nonatomic, strong) ALIncentivizedInterstitialAd *rewardedAd;
@property (nonatomic, assign) BOOL reward;
@property (nonatomic, assign) BOOL preloading;

@end

@implementation DDNASmartAdAppLovinRewardedAdapter

- (instancetype)initWithSdkKey:(NSString *)sdkKey placement:(NSString *)placement testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"APPLOVIN" version:[ALSdk version] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        _sdkKey = sdkKey;
        _placement = placement;
        _testMode = testMode;
        
        ALSdkSettings *settings = [[ALSdkSettings alloc] init];
        settings.isVerboseLogging = YES;
        settings.isTestAdsEnabled = testMode;
        _alSdk = [ALSdk sharedWithKey:sdkKey settings:settings];
        
        _rewardedAd = [[ALIncentivizedInterstitialAd alloc] initWithSdk:_alSdk];
        _rewardedAd.adDisplayDelegate = self;
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"sdkKey"] || !configuration[@"placement"]) return nil;
    
    return [self initWithSdkKey:configuration[@"sdkKey"] placement:configuration[@"placement"] testMode:[configuration[@"testMode"] boolValue] eCPM:[configuration[@"eCPM"] integerValue] waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if ([_rewardedAd isReadyForDisplay]) {
        [self.delegate adapterDidLoadAd:self];
    } else if (!_preloading) {
        [_rewardedAd preloadAndNotify:self];
        _reward = NO;
        _preloading = YES;
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([_rewardedAd isReadyForDisplay]) {
        [_rewardedAd showOver:[UIApplication sharedApplication].keyWindow placement:_placement andNotify:self];
    }
}

- (BOOL)isReady
{
    return [_rewardedAd isReadyForDisplay];
}

#pragma mark - ALAdLoadDelegate

/**
 * This method is invoked when an ad is loaded by the AdService.
 *
 * This method is invoked on the main UI thread.
 *
 * @param adService AdService which loaded the ad. Will not be nil.
 * @param ad        Ad that was loaded. Will not be nil.
 */
- (void)adService:(alnonnull ALAdService *)adService didLoadAd:(alnonnull ALAd *)ad
{
    _preloading = NO;
    
    [self.delegate adapterDidLoadAd:self];
}

/**
 * This method is invoked when an ad load fails.
 *
 * This method is invoked on the main UI thread.
 *
 * @param adService AdService which failed to load an ad. Will not be nil.
 * @param code      An error code corresponding with a constant defined in <code>ALErrorCodes.h</code>.
 */
- (void)adService:(alnonnull ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    _preloading = NO;
    
    DDNASmartAdRequestResultCode resultCode;
    
    switch (code) {
            
        case kALErrorCodeNoFill:
            resultCode = DDNASmartAdRequestResultCodeNoFill;
            break;
            
        case kALErrorCodeAdRequestNetworkTimeout:
            resultCode = DDNASmartAdRequestResultCodeTimeout;
            break;
            
        case kALErrorCodeNotConnectedToInternet:
            resultCode = DDNASmartAdRequestResultCodeNetwork;
            break;
            
        default:
            resultCode = DDNASmartAdRequestResultCodeError;
            break;
    }
    
    DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:resultCode errorDescription:[NSString stringWithFormat:@"code = %d", code]];
    
    [self.delegate adapterDidFailToLoadAd:self withResult:result];
}

#pragma mark - ALAdDisplayDelegate

/**
 * This method is invoked when the ad is displayed in the view.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad     Ad that was just displayed. Will not be nil.
 * @param view   Ad view in which the ad was displayed. Will not be nil.
 */
- (void)ad:(alnonnull ALAd *)ad wasDisplayedIn:(alnonnull UIView *)view
{
    [self.delegate adapterIsShowingAd:self];
}

/**
 * This method is invoked when the ad is hidden from in the view.
 * This occurs when the user "X's" out of an interstitial.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad     Ad that was just hidden. Will not be nil.
 * @param view   Ad view in which the ad was hidden. Will not be nil.
 */
- (void)ad:(alnonnull ALAd *)ad wasHiddenIn:(alnonnull UIView *)view
{
    [self.delegate adapterDidCloseAd:self canReward:_reward];
    _reward = NO;
}

/**
 * This method is invoked when the ad is clicked from in the view.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad     Ad that was just clicked. Will not be nil.
 * @param view   Ad view in which the ad was hidden. Will not be nil.
 */
- (void)ad:(alnonnull ALAd *)ad wasClickedIn:(alnonnull UIView *)view
{
    [self.delegate adapterWasClicked:self];
}

#pragma mark - ALAdRewardDelegate

/**
 *  This method is invoked if a user viewed a rewarded video and their reward was approved by the AppLovin server.
 *
 * If you are using reward validation for incentivized videos, this method
 * will be invoked if we contacted AppLovin successfully. This means that we believe the
 * reward is legitimate and should be awarded. Please note that ideally you should refresh the
 * user's balance from your server at this point to prevent tampering with local data on jailbroken devices.
 *
 * The response NSDictionary will typically includes the keys "currency" and "amount", which point to NSStrings containing the name and amount of the virtual currency to be awarded.
 *
 *  @param ad       Ad which was viewed.
 *  @param response Dictionary containing response data, including "currency" and "amount".
 */
- (void)rewardValidationRequestForAd:(alnonnull ALAd *)ad didSucceedWithResponse:(alnonnull NSDictionary *)response
{
    _reward = YES;
}

/**
 * This method will be invoked if we were able to contact AppLovin, but the user has already received
 * the maximum number of coins you allowed per day in the web UI.
 *
 *  @param ad       Ad which was viewed.
 *  @param response Dictionary containing response data from the server.
 */
- (void)rewardValidationRequestForAd:(alnonnull ALAd *)ad didExceedQuotaWithResponse:(alnonnull NSDictionary *)response
{
    _reward = NO;
}

/**
 * This method will be invoked if the AppLovin server rejected the reward request.
 * This would usually happen if the user fails to pass an anti-fraud check.
 *
 *  @param ad       Ad which was viewed.
 *  @param response Dictionary containing response data from the server.
 */
- (void)rewardValidationRequestForAd:(alnonnull ALAd *)ad wasRejectedWithResponse:(alnonnull NSDictionary *)response
{
    _reward = NO;
}

/**
 * This method will be invoked if were unable to contact AppLovin, so no ping will be heading to your server.
 *
 *  @param ad           Ad which was viewed.
 *  @param responseCode A failure code corresponding to a constant defined in <code>ALErrorCodes.h</code>.
 */
- (void)rewardValidationRequestForAd:(alnonnull ALAd *)ad didFailWithError:(NSInteger)responseCode
{
    _reward = NO;
}

/**
 * This method will be invoked if the user chooses 'no' when asked if they want to view a rewarded video.
 *
 * This is only possible if you have the pre-video modal enabled in the Manage Apps UI.
 *
 * @param ad       Ad which was offered to the user, but declined.
 */
- (void)userDeclinedToViewAd:(alnonnull ALAd *)ad
{
    _reward = NO;
}




@end
