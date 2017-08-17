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

#import "DDNASmartAdLoopMeAdapter.h"
#import <LoopMeSDK/LoopMeDefinitions.h>
#import <LoopMeSDK/LoopMeInterstitial.h>
#import <LoopMeSDK/LoopMeError.h>
#import <LoopMeSDK/LoopMeLogging.h>

@interface DDNASmartAdLoopMeAdapter () <LoopMeInterstitialDelegate>

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, assign) BOOL reward;
@property (nonatomic, strong) LoopMeInterstitial *interstitial;

@end

@implementation DDNASmartAdLoopMeAdapter

- (instancetype)initWithAppKey:(NSString *)appKey testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"LOOPME" version:LOOPME_SDK_VERSION eCPM:eCPM waterfallIndex:waterfallIndex])) {
        
        self.appKey = testMode ? @"test_interstitial_l" : appKey;
        self.testMode = testMode;
        self.reward = NO;
        
        setLoopMeLogLevel(LoopMeLogLevelDebug);
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appKey"]) return nil;
    
    return [self initWithAppKey:configuration[@"appKey"] testMode:[configuration[@"testMode"] boolValue] eCPM:[configuration[@"eCPM"] integerValue] waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (!self.interstitial) {
        self.interstitial = [LoopMeInterstitial interstitialWithAppKey:self.appKey delegate:self];
    }
    
    if ([self.interstitial isReady]) {
        [self.delegate adapterDidLoadAd:self];
    }
    else {
        [self.interstitial loadAd];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([self.interstitial isReady]) {
        [self.interstitial showFromViewController:viewController animated:YES];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - LoopMeInterstitialDelegate

- (void)loopMeInterstitial:(LoopMeInterstitial *)interstitial didFailToLoadAdWithError:(NSError *)error
{
    if (interstitial == self.interstitial) {
        
        DDNASmartAdRequestResult *result;
        
        switch (error.code) {
            case LoopMeErrorCodeNoAdsFound : {
                result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
                break;
            }
            case LoopMeErrorCodeInvalidAppKey : {
                result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration];
                break;
            }
            case LoopMeErrorCodeVideoDownloadTimeout :
            case LoopMeErrorCodeSpecificHost :
            case LoopMeErrorCodeHTMLRequestTimeOut :
            case LoopMeErrorCodeURLResolve : {
                result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
                break;
            }
            default : {
                result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            }
        }
        
        result.errorDescription = [error localizedDescription];
        
        [self.delegate adapterDidFailToLoadAd:self withResult:result];

    }
}

- (void)loopMeInterstitialDidLoadAd:(LoopMeInterstitial *)interstitial
{
    if (interstitial == self.interstitial) {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)loopMeInterstitialDidAppear:(LoopMeInterstitial *)interstitial
{
    if (interstitial == self.interstitial) {
        [self.delegate adapterIsShowingAd:self];
    }
}

- (void)loopMeInterstitialDidReceiveTap:(LoopMeInterstitial *)interstitial
{
    if (interstitial == self.interstitial) {
        [self.delegate adapterWasClicked:self];
    }
}

- (void)loopMeInterstitialWillLeaveApplication:(LoopMeInterstitial *)interstitial
{
    if (interstitial == self.interstitial) {
        [self.delegate adapterLeftApplication:self];
    }
}

- (void)loopMeInterstitialVideoDidReachEnd:(LoopMeInterstitial *)interstitial
{
    self.reward = YES;
}

- (void)loopMeInterstitialDidExpire:(LoopMeInterstitial *)interstitial
{
    // Request for ad in order to keep ad content up-to-date
    [interstitial loadAd];
}

- (void)loopMeInterstitialDidDisappear:(LoopMeInterstitial *)interstitial
{
    if (interstitial == self.interstitial) {
        [self.delegate adapterDidCloseAd:self canReward:self.reward];
        self.reward = NO;
    }
}


@end
