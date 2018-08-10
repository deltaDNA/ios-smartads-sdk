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

#import "DDNASmartAdAmazonAdapter.h"
#import <AmazonAd/AmazonAdInterstitial.h>
#import <AmazonAd/AmazonAdOptions.h>
#import <AmazonAd/AmazonAdRegistration.h>
#import <AmazonAd/AmazonAdError.h>

@interface DDNASmartAdAmazonAdapter () <AmazonAdInterstitialDelegate>

@property (nonatomic, strong) AmazonAdInterstitial *interstitial;
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, assign) BOOL initialised;

@end

@implementation DDNASmartAdAmazonAdapter

- (instancetype)initWithAppKey:(NSString *)appKey testMode:(BOOL)testMode eCPM:(NSInteger)eCPM privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"AMAZON"
                            version:[AmazonAdRegistration sharedRegistration].sdkVersion
                               eCPM:eCPM
                            privacy:privacy
                     waterfallIndex:waterfallIndex])) {
        
        self.appKey = appKey;
        self.testMode = testMode;
        self.initialised = NO;
    }
    return self;
}

- (AmazonAdInterstitial *)createAndLoadInterstitial {
    AmazonAdInterstitial *interstitial = [AmazonAdInterstitial amazonAdInterstitial];
    interstitial.delegate = self;
    
    // Set the adOptions.
    AmazonAdOptions *options = [AmazonAdOptions options];
    
    // Turn on isTestRequest to load a test interstitial
    options.isTestRequest = self.testMode;
    
    // Load an interstitial
    [interstitial load:options];
    
    return interstitial;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appKey"]) return nil;
    
    return [self initWithAppKey:configuration[@"appKey"]
                       testMode:[configuration[@"testMode"] boolValue]
                           eCPM:[configuration[@"eCPM"] integerValue]
                        privacy:privacy
                 waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (!self.initialised) {
        [[AmazonAdRegistration sharedRegistration] setAppKey:self.appKey];
        [[AmazonAdRegistration sharedRegistration] setLogging:self.testMode];
        self.initialised = YES;
    }
    
    if (self.interstitial) {
        self.interstitial.delegate = nil;
        self.interstitial = nil;
    }
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    // Present the interstitial on screen
    if (self.interstitial.isReady) {
        [self.interstitial presentFromViewController:viewController];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeExpired]];
    }
}

- (BOOL)isGdprCompliant
{
    return YES;
}

#pragma mark - AmazonAdInterstitial protocol

// Sent when load has succeeded and the interstitial isReady for display at the appropriate moment.
- (void)interstitialDidLoad:(AmazonAdInterstitial *)interstitial
{
    [self.delegate adapterDidLoadAd:self];
}

// Sent when load has failed, typically because of network failure, an application configuration error or lack of interstitial inventory
- (void)interstitialDidFailToLoad:(AmazonAdInterstitial *)interstitial withError:(AmazonAdError *)error
{
    DDNASmartAdRequestResult *result;
    switch (error.errorCode) {
        case AmazonAdErrorNoFill:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
            break;
        case AmazonAdErrorNetworkConnection:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
            break;
        case AmazonAdErrorRequest:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration];
            break;
        case AmazonAdErrorRequestTimeout:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeTimeout];
            break;
        default:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
    }
    result.errorDescription = error.errorDescription;
    
    [self.delegate adapterDidFailToLoadAd:self withResult:result];
}

// Sent immediately before interstitial is presented on the screen. At this point you should pause any animations, timers or other
// activities that assume user interaction and save app state. User may press Home or touch links to other apps like iTunes within the
// interstitial, leaving your app.
- (void)interstitialWillPresent:(AmazonAdInterstitial *)interstitial {
    
}

// Sent when interstitial has been presented on the screen.
- (void)interstitialDidPresent:(AmazonAdInterstitial *)interstitial {
    [self.delegate adapterIsShowingAd:self];
}

// Sent immediately before interstitial leaves the screen, restoring your app and your view controller used for presentAdFromViewController:.
// At this point you should restart any foreground activities paused as part of interstitialWillPresent:.
- (void)interstitialWillDismiss:(AmazonAdInterstitial *)interstitial {
    
}

// Sent when the user has dismissed interstitial and it has left the screen.
- (void)interstitialDidDismiss:(AmazonAdInterstitial *)interstitial {
    [self.delegate adapterDidCloseAd:self canReward:YES];
}

@end
