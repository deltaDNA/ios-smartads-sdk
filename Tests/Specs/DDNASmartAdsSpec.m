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

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/SmartAds/DDNASmartAds.h>
#import "DDNAFakeSmartAdFactory.h"
#import "DDNAFakeSmartAdService.h"
#import <objc/runtime.h>

// Get access to the factory so we can inject a fake.
@interface DDNASmartAds (Test)

@property (strong, nonatomic) DDNASmartAdFactory *factory;

- (void)registerForAdsInternalWithConfig:(nonnull NSDictionary *)config;

@end

SpecBegin(DDNASmartAds)

describe(@"registers for ads", ^{
    
    __block DDNASmartAds *smartAds;
    __block id<DDNASmartAdsRegistrationDelegate> mockRegistrationDelegate;
    __block DDNAFakeSmartAdFactory *fakeFactory;
    
    beforeEach(^{
        
        mockRegistrationDelegate = mockProtocol(@protocol(DDNASmartAdsRegistrationDelegate));
        
        fakeFactory = [[DDNAFakeSmartAdFactory alloc] init];
        fakeFactory.fakeSmartAdService = [[DDNAFakeSmartAdService alloc] init];
        
        smartAds = [[DDNASmartAds alloc] init];
        smartAds.factory = fakeFactory;
        
        smartAds.registrationDelegate = mockRegistrationDelegate;
        smartAds.settings.advertiserGdprUserConsent = YES;
    });
    
    it(@"succeeds with a good response", ^{

        [smartAds registerForAdsInternalWithConfig:@{}];
        
        [verify(mockRegistrationDelegate) didRegisterForInterstitialAds];
        [verifyCount(mockRegistrationDelegate, never()) didFailToRegisterForInterstitialAdsWithReason:anything()];
        
        [verify(mockRegistrationDelegate) didRegisterForRewardedAds];
        [verifyCount(mockRegistrationDelegate, never()) didFailToRegisterForRewardedAdsWithReason:anything()];
    });
    
    it(@"allows an interstitial ad with a null engagement", ^{
        
        [smartAds registerForAdsInternalWithConfig:@{}];
        
        [verify(mockRegistrationDelegate) didRegisterForInterstitialAds];
        [verifyCount(mockRegistrationDelegate, never()) didFailToRegisterForInterstitialAdsWithReason:anything()];
        
        [verify(mockRegistrationDelegate) didRegisterForRewardedAds];
        [verifyCount(mockRegistrationDelegate, never()) didFailToRegisterForRewardedAdsWithReason:anything()];
        
        expect([smartAds isInterstitialAdAllowed:nil checkTime:NO]).to.beTruthy();
    });
    
    it(@"allows a rewarded ad with a null engagement", ^{
        
        [smartAds registerForAdsInternalWithConfig:@{}];
        
        [verify(mockRegistrationDelegate) didRegisterForInterstitialAds];
        [verifyCount(mockRegistrationDelegate, never()) didFailToRegisterForInterstitialAdsWithReason:anything()];
        
        [verify(mockRegistrationDelegate) didRegisterForRewardedAds];
        [verifyCount(mockRegistrationDelegate, never()) didFailToRegisterForRewardedAdsWithReason:anything()];
        
        expect([smartAds isRewardedAdAllowed:nil checkTime:NO]).to.beTruthy();
    });
    
});

SpecEnd
