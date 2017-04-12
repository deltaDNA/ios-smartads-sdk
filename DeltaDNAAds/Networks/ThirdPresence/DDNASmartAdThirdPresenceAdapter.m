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

#import "DDNASmartAdThirdPresenceAdapter.h"
#import "DDNASmartAds.h"
#import <ThirdpresenceAdSDK.h>

@interface DDNASmartAdThirdPresenceAdapter () <TPRVideoAdDelegate>

@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, assign) BOOL testMode;

@property (nonatomic, strong) TPRVideoInterstitial *interstitial;
@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, assign) BOOL reward;

@end

@implementation DDNASmartAdThirdPresenceAdapter

- (instancetype)initWithAccountName:(NSString *)accountName placementId:(NSString *)placementId testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"THIRDPRESENCE" version:[DDNASmartAdThirdPresenceAdapter getSdkVersion] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        self.accountName = testMode ? @"sdk-demo" : accountName;
        self.placementId = testMode ? @"sa7nvltbrn" : placementId;
        self.testMode = testMode;
        self.loaded = NO;
        self.reward = NO;
    }
    return self;
}

- (void)initInterstitial
{
    self.loaded = NO;
    self.reward = NO;
    
    if (self.interstitial) {
        [self.interstitial removePlayer];
        self.interstitial.delegate = nil;
        self.interstitial = nil;
    }
    
    // Environment dictionary must contain at least key TPR_ENVIRONMENT_KEY_ACCOUNT and
    // TPR_ENVIRONMENT_KEY_PLACEMENT_ID
    // TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE allows to force player to landscape orientation
    NSMutableDictionary *environment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        self.accountName, TPR_ENVIRONMENT_KEY_ACCOUNT,
                                        self.placementId, TPR_ENVIRONMENT_KEY_PLACEMENT_ID,
                                        TPR_VALUE_TRUE, TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE,
                                        TPR_VALUE_FALSE, TPR_ENVIRONMENT_KEY_USE_INSECURE_HTTP,
                                        TPR_SERVER_TYPE_PRODUCTION, TPR_ENVIRONMENT_KEY_SERVER,
                                        nil];
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    NSMutableDictionary *playerParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         appName, TPR_PLAYER_PARAMETER_KEY_APP_NAME,
                                         appVersion,TPR_PLAYER_PARAMETER_KEY_APP_VERSION,
                                         nil];
    
    // Initialize the interstitial
    self.interstitial = [[TPRVideoInterstitial alloc] initWithEnvironment:environment params:playerParams timeout:15];
    
    self.interstitial.delegate = self;
}


#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"accountName"]) return nil;
    if (!configuration[@"placementId"]) return nil;
    
    return [self initWithAccountName:configuration[@"accountName"] placementId:configuration[@"placementId"] testMode:[configuration[@"testMode"] boolValue] eCPM:[configuration[@"eCPM"] integerValue] waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    [self initInterstitial];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.loaded) {
        [self.interstitial displayAd];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

- (BOOL)isReady
{
    return self.loaded;
}

#pragma mark - TPRVideoAdDelegate

- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error
{
    if (videoAd == self.interstitial) {
        if (self.loaded) {
            [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
        } else {
            DDNASmartAdRequestResultCode code = DDNASmartAdRequestResultCodeError;
            DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:code];
            result.errorDescription = error.localizedDescription;
            [self.delegate adapterDidFailToLoadAd:self withResult:result];
        }
    }
}

- (void)videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event
{
    if (videoAd == self.interstitial) {
        NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
        if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
            if (self.interstitial.ready) {
                [self.interstitial loadAd];
            }
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_ERROR]) {
            DDNASmartAdRequestResultCode code = DDNASmartAdRequestResultCodeError;
            NSString *reason = event[@"arg1"];
            if ([@"No fill" isEqualToString:reason]) {
                code = DDNASmartAdRequestResultCodeNoFill;
            }
            else if ([@"Timeout during ad request" isEqualToString:reason]) {
                code = DDNASmartAdRequestResultCodeTimeout;
            }
            DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:code];
            result.errorDescription = event[@"arg1"];
            [self.delegate adapterDidFailToLoadAd:self withResult:result];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LOADED]) {
            self.loaded = YES;
            [self.delegate adapterDidLoadAd:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STARTED]) {
            [self.delegate adapterIsShowingAd:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_ERROR]) {
            self.loaded = NO;
            [self.interstitial reset];
            [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_CLICKTHRU]) {
            [self.delegate adapterWasClicked:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_LEFT_APPLICATION]) {
            [self.delegate adapterLeftApplication:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_VIDEO_COMPLETE]) {
            self.reward = YES;
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STOPPED]) {
            self.loaded = NO;
            [self.interstitial reset];
            [self.delegate adapterDidCloseAd:self canReward:self.reward];
        }
    }
}

+ (NSString *)getSdkVersion
{
    NSString *versionString = @"1.0+";
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThirdpresenceAdSDK-Info" ofType:@"plist"]];
    
    versionString = [dictionary objectForKey:@"CFBundleShortVersionString"];
    return versionString;
}

@end
