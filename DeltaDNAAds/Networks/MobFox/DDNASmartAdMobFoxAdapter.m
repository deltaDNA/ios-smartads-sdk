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

#import "DDNASmartAdMobFoxAdapter.h"
#import <MobFoxSDKCore/MobFoxSDKCore.h>
#import <DeltaDNA/DDNALog.h>

@interface DDNASmartAdMobFoxAdapter () <MobFoxInterstitialAdDelegate>

@property (nonatomic, strong) MobFoxInterstitialAd *interstitial;

@property (nonatomic, copy) NSString *publicationId;

@end

@implementation DDNASmartAdMobFoxAdapter

- (instancetype)initWithPublicationId:(NSString *)publicationId eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"MOBFOX"
                            version:SDK_VERSION
                               eCPM:eCPM
                     waterfallIndex:waterfallIndex])) {

        self.publicationId = publicationId;
        
        [MobFoxInterstitialAd locationServicesDisabled:YES];
        [MobFoxNativeAd locationServicesDisabled:YES];
        [MobFoxAd locationServicesDisabled:YES];
    }
    return self;
}

- (MobFoxInterstitialAd *)createAndLoadInterstitial
{
    MobFoxInterstitialAd *interstitial = [[MobFoxInterstitialAd alloc] init:self.publicationId];
    interstitial.delegate = self;

    [interstitial loadAd];

    return interstitial;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"publicationId"]) return nil;

    return [self initWithPublicationId:configuration[@"publicationId"]
                                  eCPM:[configuration[@"eCPM"] integerValue]
                        waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    // TODO: put this a level up
//    @try {
        self.interstitial = [self createAndLoadInterstitial];
//    }
//    @catch (NSException *exception) {
//        [self.delegate adapterDidFailToLoadAd:self withStatus:[DDNASmartAdStatus statusWithStatusCode:DDNASmartAdStatusCodeInternalError]];
//    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.interstitial.ready) {
        self.interstitial.rootViewController = viewController;
        [self.interstitial show];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self
                                   withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - MobFoxInterstitialDelegate

//called when ad is displayed
- (void)MobFoxInterstitialAdDidLoad:(MobFoxInterstitialAd *)interstitial
{
    [self.delegate adapterDidLoadAd:self];
}

//called when an ad cannot be displayed
- (void)MobFoxInterstitialAdDidFailToReceiveAdWithError:(NSError *)error
{
    DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];

    if ([error.description containsString:@"no fill"]) {
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
    }
    result.error = error.description;

    [self.delegate adapterDidFailToLoadAd:self withResult:result];
}

- (void)MobFoxInterstitialAdWillShow:(MobFoxInterstitialAd *)interstitial
{
    [self.delegate adapterIsShowingAd:self];
}

//called when ad is closed/skipped
- (void)MobFoxInterstitialAdClosed
{
    [self.delegate adapterDidCloseAd:self canReward:YES];
}

//called w mobfoxInterAd.delegate = self;hen ad is clicked
- (void)MobFoxInterstitialAdClicked
{
    [self.delegate adapterWasClicked:self];
}

//called when if the ad is a video ad and it has finished playing
- (void)MobFoxInterstitialAdFinished
{

}

@end
