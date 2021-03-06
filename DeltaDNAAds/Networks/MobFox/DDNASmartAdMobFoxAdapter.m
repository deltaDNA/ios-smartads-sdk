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
@property (nonatomic, assign) BOOL initialised;

@end

@implementation DDNASmartAdMobFoxAdapter

- (instancetype)initWithPublicationId:(NSString *)publicationId eCPM:(NSInteger)eCPM privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"MOBFOX"
                            version:SDK_VERSION
                               eCPM:eCPM
                            privacy:privacy
                     waterfallIndex:waterfallIndex])) {

        self.publicationId = publicationId;
        self.initialised = NO;
    }
    return self;
}

- (MobFoxInterstitialAd *)createAndLoadInterstitial
{
    MobFoxInterstitialAd *interstitial = [[MobFoxInterstitialAd alloc] init:self.publicationId];
    interstitial.gdpr = YES;
    interstitial.gdpr_consent = self.privacy.advertiserGdprUserConsent ? @"1" : nil;
    interstitial.delegate = self;

    [interstitial loadAd];

    return interstitial;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"publicationId"]) return nil;

    return [self initWithPublicationId:configuration[@"publicationId"]
                                  eCPM:[configuration[@"eCPM"] integerValue]
                               privacy:privacy
                        waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (!self.initialised) {
        // Not sure if this is still required, it doesn't seem to be triggering the location permission anymore.
        [[MFLocationServicesManager sharedInstance] stopFindingLocation];
        self.initialised = YES;
    }
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.interstitial.ready) {
        self.interstitial.rootViewController = viewController;
        [self.interstitial show];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self
                                   withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeExpired]];
    }
}

- (BOOL)isGdprCompliant
{
    return YES;
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
    result.errorDescription = [error localizedDescription];

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
