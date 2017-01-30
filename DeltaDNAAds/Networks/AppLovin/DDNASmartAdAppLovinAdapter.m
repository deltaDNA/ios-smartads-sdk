//
// Copyright (c) 2016 deltaDNA Ltd. All rights reserved.
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
#import <AppLovinSDK/ALInterstitialAd.h>

@interface DDNASmartAdAppLovinAdapter () <ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>

@property (nonatomic, copy) NSString *sdkKey;
@property (nonatomic, assign) BOOL testMode;

@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) BOOL loaded;

@property (nonatomic, assign) BOOL reward;
@property (nonatomic, strong) ALSdk *alSdk;
@property (nonatomic, strong) ALInterstitialAd *alInterstitial;

@property (nonatomic, strong) ALAd *ad;

@end

@implementation DDNASmartAdAppLovinAdapter

- (instancetype)initWithSdkKey:(NSString *)sdkKey testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"APPLOVIN" version:[ALSdk version] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        self.sdkKey = sdkKey;
        self.testMode = testMode;
        
        ALSdkSettings *settings = [[ALSdkSettings alloc] init];
        settings.isVerboseLogging = YES;
//        settings.autoPreloadAdSizes = @"INTER";
//        settings.autoPreloadAdTypes = @"REGULAR";
//        
        self.alSdk = [ALSdk sharedWithKey:sdkKey settings:settings];
        
        self.alInterstitial = [[ALInterstitialAd alloc] initWithSdk:self.alSdk];
        
        [self.alSdk initializeSdk];
        
        self.started = YES;
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"sdkKey"]) return nil;
    
    return [self initWithSdkKey:configuration[@"sdkKey"] testMode:[configuration[@"testMode"] boolValue] eCPM:[configuration[@"eCPM"] integerValue] waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (!self.started) {
        return;
    }
    
    [self.alSdk.adService loadNextAd: [ALAdSize sizeInterstitial] andNotify: self];
    
    self.reward = NO;
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    self.alInterstitial.adDisplayDelegate = self;
    self.alInterstitial.adVideoPlaybackDelegate = self;
    
    if (self.loaded) {
        [self.alInterstitial showOver: [UIApplication sharedApplication].keyWindow andRender: self.ad];
    }
    else{
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

- (BOOL)isReady
{
    return self.loaded;
}

#pragma mark - ALAdLoadDelegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    self.ad = ad;
    self.loaded = YES;
    self.reward = NO;
    [self.delegate adapterDidLoadAd:self];
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
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

-(void) ad:(ALAd *) ad wasDisplayedIn: (UIView *)view
{
    [self.delegate adapterIsShowingAd:self];
}

-(void) ad:(ALAd *) ad wasHiddenIn: (UIView *)view
{
    self.loaded = NO;
    [self.delegate adapterDidCloseAd:self canReward:self.reward];
}

-(void) ad:(ALAd *) ad wasClickedIn: (UIView *)view
{
    [self.delegate adapterWasClicked:self];
}

#pragma mark - ALAdVideoPlaybackDelegate

-(void) videoPlaybackBeganInAd: (ALAd*) ad
{
    
}

-(void) videoPlaybackEndedInAd: (ALAd*) ad atPlaybackPercent:(NSNumber*) percentPlayed fullyWatched: (BOOL) wasFullyWatched
{
    self.reward = wasFullyWatched;
}

@end
