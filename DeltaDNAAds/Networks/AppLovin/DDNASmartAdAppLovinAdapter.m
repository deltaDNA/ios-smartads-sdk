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

#import "DDNASmartAdAppLovinAdapter.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface DDNASmartAdAppLovinAdapter () <ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>

@property (nonatomic, copy) NSString *sdkKey;
@property (nonatomic, copy) NSString *placement;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, strong) ALSdk *alSdk;
@property (nonatomic, strong) ALInterstitialAd *interstitialAd;
@property (nonatomic, strong) NSNumber *reward;
@property (nonatomic, strong) ALAd *lastAd;

@end

@implementation DDNASmartAdAppLovinAdapter

- (instancetype)initWithSdkKey:(NSString *)sdkKey placement:(NSString *)placement testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"APPLOVIN" version:[ALSdk version] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        _sdkKey = sdkKey;
        _placement = placement;
        _testMode = testMode;
        
        ALSdkSettings *settings = [[ALSdkSettings alloc] init];
        settings.isVerboseLogging = NO;
        settings.isTestAdsEnabled = testMode;
        _alSdk = [ALSdk sharedWithKey:sdkKey settings:settings];
        [_alSdk initializeSdk];
        _interstitialAd = [[ALInterstitialAd alloc] initWithSdk:_alSdk];
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"sdkKey"]) return nil;
    
    return [self initWithSdkKey:configuration[@"sdkKey"] placement:configuration[@"placement"] testMode:[configuration[@"testMode"] boolValue] eCPM:[configuration[@"eCPM"] integerValue] waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (_lastAd || [_alSdk.adService hasPreloadedAdOfSize:[ALAdSize sizeInterstitial]]) {
        [self.delegate adapterDidLoadAd:self];
    } else {
        // preload interstitial
        [_alSdk.adService loadNextAd:[ALAdSize sizeInterstitial] andNotify:self];
    }
    
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([_interstitialAd isReadyForDisplay]) {
        _interstitialAd.adDisplayDelegate = self;
        _interstitialAd.adVideoPlaybackDelegate = self;
        
        if (_placement) {
            if (_lastAd) {
                [_interstitialAd showOver:[[UIApplication sharedApplication] keyWindow] placement:_placement andRender:_lastAd];
            } else {
                [_interstitialAd showOverPlacement:_placement];
            }
        } else {
            if (_lastAd) {
                [_interstitialAd showOver:[[UIApplication sharedApplication] keyWindow] andRender:_lastAd];
            } else {
                [_interstitialAd showOver:[[UIApplication sharedApplication] keyWindow]];
            }
        }
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

- (BOOL)isReady
{
    return [_interstitialAd isReadyForDisplay];
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
    _lastAd = ad;
    _reward = nil;
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
    _lastAd = nil;
    [self.delegate adapterDidCloseAd:self canReward:_reward == nil || [_reward boolValue]];
    _reward = nil;
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

#pragma mark - AlAdVideoPlaybackDelegate

/**
 * This method is invoked when a video starts playing in an ad.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad Ad in which video playback began.
 */
- (void)videoPlaybackBeganInAd:(alnonnull ALAd *)ad
{
    
}

/**
 * This method is invoked when a video stops playing in an ad.
 *
 * This method is invoked on the main UI thread.
 *
 * @param ad                Ad in which video playback ended.
 * @param percentPlayed     How much of the video was watched, as a percent.
 * @param wasFullyWatched   Whether or not the video was watched to, or very near to, completion.
 */
- (void)videoPlaybackEndedInAd:(alnonnull ALAd *)ad atPlaybackPercent:(alnonnull NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched
{
    _reward = [NSNumber numberWithBool:wasFullyWatched];
}

@end
