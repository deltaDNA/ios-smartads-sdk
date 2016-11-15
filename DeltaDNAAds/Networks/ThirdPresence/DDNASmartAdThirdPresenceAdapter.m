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
    
    if (self.interstitial.ready) {
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

    [self.interstitial displayAd];
}

- (BOOL)isReady
{
    //return self.zoneId ? [UnityAds isReady:self.zoneId] : [UnityAds isReady];
    return NO;
}

#pragma mark - TPRVideoAdDelegate

@end
