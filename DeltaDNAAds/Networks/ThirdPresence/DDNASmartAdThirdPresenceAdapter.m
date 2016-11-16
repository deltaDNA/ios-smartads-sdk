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
@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) BOOL requestWhenReady;
@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, assign) BOOL reward;

@end

@implementation DDNASmartAdThirdPresenceAdapter

- (instancetype)initWithAccountName:(NSString *)accountName placementId:(NSString *)placementId testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"THIRDPRESENCE" version:@"1.3.3" eCPM:eCPM waterfallIndex:waterfallIndex])) {
        self.accountName = testMode ? @"sdk-demo" : accountName;
        self.placementId = testMode ? @"sa7nvltbrn" : placementId;
        self.testMode = testMode;
        
        NSDictionary *environment = [NSDictionary dictionaryWithObjectsAndKeys:
                                     self.accountName, TPR_ENVIRONMENT_KEY_ACCOUNT,
                                     self.placementId, TPR_ENVIRONMENT_KEY_PLACEMENT_ID,
                                     TPR_VALUE_TRUE, TPR_ENVIRONMENT_KEY_FORCE_LANDSCAPE, nil];
        
        self.interstitial = [[TPRVideoInterstitial alloc] initWithEnvironment:environment params:nil timeout:10.0];
        self.interstitial.delegate = self;
        
        self.started = YES;
    }
    return self;
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
    if (!self.started) {
        return;
    }
    
    if (!self.interstitial.ready) {
        self.requestWhenReady = YES;
    } else if (!self.loaded) {
        [self.interstitial loadAd];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
//    if ([UnityAds isSupported] && [self isReady]) {
//        self.showing = YES;
//        id mediationMetaData = [[UADSMediationMetaData alloc] init];
//        [mediationMetaData setOrdinal:self.delegate.sessionAdCount+1];
//        [mediationMetaData commit];
//        [UnityAds show:viewController placementId:self.zoneId];
//    } else {
//        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
//    }

    if (self.loaded) {
        [self.interstitial displayAd];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

- (BOOL)isReady
{
    //return self.zoneId ? [UnityAds isReady:self.zoneId] : [UnityAds isReady];
    return self.loaded;
}

#pragma mark - TPRVideoAdDelegate

- (void)videoAd:(TPRVideoAd*)videoAd failed:(NSError*)error
{
    if (videoAd == self.interstitial) {
        NSLog(@"ThirdPresence failed: %@", error.localizedDescription);
        // Handle the error
    }
}

- (void)videoAd:(TPRVideoAd*)videoAd eventOccured:(TPRPlayerEvent*)event
{
    if (videoAd == self.interstitial) {
        NSLog(@"ThirdPresence event: %@", event);
        
        NSString* eventName = [event objectForKey:TPR_EVENT_KEY_NAME];
        if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_READY]) {
            // The player is ready for loading ads
            self.loaded = NO;
            if (self.requestWhenReady) {
                self.requestWhenReady = NO;
                [self requestAd];
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
            // An ad is loaded
            self.loaded = YES;
            [self.delegate adapterDidLoadAd:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_AD_STARTED]) {
            [self.delegate adapterIsShowingAd:self];
        } else if ([eventName isEqualToString:TPR_EVENT_NAME_PLAYER_ERROR]) {
            // Failed displaying the loaded ad
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
            // Displaying ad stopped
            // Close and reset the interstitial
            self.loaded = NO;
            [self.interstitial reset];
            [self.delegate adapterDidCloseAd:self canReward:self.reward];
        }
    }
}

@end
