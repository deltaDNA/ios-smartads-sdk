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
#import "DDNASmartAds.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface DDNASmartAdAppLovinAdapter () <ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>

@property (nonatomic, copy) NSString *sdkKey;
@property (nonatomic, copy) NSString *zoneId;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, strong) ALSdk *alSdk;
@property (nonatomic, strong) ALInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALAd *ad;
@property (nonatomic, strong) NSNumber *reward;

@end

@implementation DDNASmartAdAppLovinAdapter

- (instancetype)initWithSdkKey:(NSString *)sdkKey zoneId:(NSString *)zoneId testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"APPLOVIN" version:[ALSdk version] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        self.sdkKey = sdkKey;
        self.zoneId = zoneId;
        self.testMode = testMode;
        
        ALSdkSettings *settings = [[ALSdkSettings alloc] init];
        settings.isVerboseLogging = testMode;
        settings.isTestAdsEnabled = testMode;
        ALSdk *alSdk = [ALSdk sharedWithKey:sdkKey settings:settings];
        [alSdk setMediationProvider:@"deltaDNA"];
        [alSdk setPluginVersion:[DDNASmartAds sdkVersion]];
        [alSdk initializeSdk];
        
        self.alSdk = alSdk;
        
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"sdkKey"]) return nil;
    // ZoneId is optional
    
    return [self initWithSdkKey:configuration[@"sdkKey"] zoneId:configuration[@"zoneId"] testMode:[configuration[@"testMode"] boolValue] eCPM:[configuration[@"eCPM"] integerValue] waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (self.interstitialAd && self.ad) {
        [self.delegate adapterDidLoadAd:self];
    }
    else if (!self.interstitialAd && !self.ad) {
        ALInterstitialAd *interstitialAd = [[ALInterstitialAd alloc] initWithSdk:self.alSdk];
        interstitialAd.adDisplayDelegate = self;
        interstitialAd.adVideoPlaybackDelegate = self;
    
        if (self.zoneId) {
            [self.alSdk.adService loadNextAdForZoneIdentifier:self.zoneId andNotify: self];
        } else {
            [self.alSdk.adService loadNextAd:[ALAdSize sizeInterstitial] andNotify:self];
        }
        
        self.interstitialAd = interstitialAd;
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.ad) {
        [self.interstitialAd showOver:[[UIApplication sharedApplication] keyWindow] andRender:self.ad];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

- (BOOL)isReady
{
    return self.ad != nil;
}

#pragma mark - ALAdLoadDelegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    self.ad = ad;
    [self.delegate adapterDidLoadAd:self];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    DDNASmartAdRequestResultCode resultCode;
    
    switch (code) {
            
        case kALErrorCodeNoFill: {
            resultCode = DDNASmartAdRequestResultCodeNoFill;
            break;
        }
        case kALErrorCodeAdRequestNetworkTimeout: {
            resultCode = DDNASmartAdRequestResultCodeTimeout;
            break;
        }
        case kALErrorCodeNotConnectedToInternet: {
            resultCode = DDNASmartAdRequestResultCodeNetwork;
            break;
        }
        case kALErrorCodeInvalidZone: {
            resultCode = DDNASmartAdRequestResultCodeConfiguration;
            break;
        }
        default: {
            resultCode = DDNASmartAdRequestResultCodeError;
            break;
        }
    }
    
    DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:resultCode errorDescription:[NSString stringWithFormat:@"code = %d", code]];
    
    [self.delegate adapterDidFailToLoadAd:self withResult:result];
    self.interstitialAd = nil;
}

#pragma mark - ALAdDisplayDelegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
    [self.delegate adapterIsShowingAd:self];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
    [self.delegate adapterDidCloseAd:self canReward:self.reward == nil || [self.reward boolValue]];

    self.reward = nil;
    self.ad = nil;
    self.interstitialAd = nil;
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view
{
    [self.delegate adapterWasClicked:self];
}

#pragma mark - AlAdVideoPlaybackDelegate

- (void)videoPlaybackBeganInAd:(ALAd *)ad
{
    
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched
{
    self.reward = [NSNumber numberWithBool:wasFullyWatched];
}

@end
