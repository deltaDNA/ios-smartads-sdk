//
// Copyright (c) 2018 deltaDNA Ltd. All rights reserved.
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

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "DDNASDK.h"
#import "DDNAEngagement.h"
#import "DDNASmartAdEngageFactory.h"
#import "DDNAInterstitialAd.h"
#import "DDNARewardedAd.h"

#import "DDNAFakeSmartAds.h"

SpecBegin(DDNAEngageFactory)

describe(@"engage factory", ^{
    
    __block DDNASDK *mockSdk;
    __block DDNASmartAdEngageFactory *engageFactory;
    __block DDNAEngagement *fakeEngagement;
    
    beforeEach(^{
        mockSdk = mock([DDNASDK class]);
        engageFactory = [[DDNASmartAdEngageFactory alloc] initWithDDNASDK:mockSdk];
        
        [[DDNAFakeSmartAds sharedInstance] reset];
        [DDNAFakeSmartAds sharedInstance].allowInterstitial = YES;
        [DDNAFakeSmartAds sharedInstance].allowRewarded = YES;
        
        [givenVoid([mockSdk requestEngagement:anything() engagementHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
            void (^engagementHandler)(DDNAEngagement *engagement) = [invocation mkt_arguments][1];
            engagementHandler(fakeEngagement);
            return nil;
        }];
    });
    
    it(@"requests an interstitial ad", ^{
        fakeEngagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        fakeEngagement.json = @{@"parameters":@{@"ddnaAdSessionLimit": @1, @"ddnaAdDailyLimit": @2}};
        
        [engageFactory requestInterstitialAdForDecisionPoint:@"testDecisionPoint" handler:^(DDNAInterstitialAd * _Nullable interstitialAd) {
            expect(interstitialAd).toNot.beNil();
            expect([[interstitialAd parameters] isEqualToDictionary:fakeEngagement.json[@"parameters"]]);
        }];
    });
    
    it(@"returns an interstitial ad with an invalid engagement", ^{
        fakeEngagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        fakeEngagement.json = nil;
        
        [engageFactory requestInterstitialAdForDecisionPoint:@"testDecisionPoint" handler:^(DDNAInterstitialAd * _Nonnull interstitialAd) {
            expect(interstitialAd).toNot.beNil();
            expect([interstitialAd parameters]).to.haveACountOf(0);
            expect([interstitialAd engagement]).to.beNil();
            expect([interstitialAd decisionPoint]).to.beNil();
        }];
    });
    
    it(@"requests a rewarded ad", ^{
        fakeEngagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        fakeEngagement.json = @{@"parameters":@{@"ddnaAdSessionLimit": @1, @"ddnaAdDailyLimit": @2}};
        
        [engageFactory requestRewardedAdForDecisionPoint:@"testDecisionPoint" handler:^(DDNARewardedAd * _Nullable rewardedAd) {
            expect(rewardedAd).toNot.beNil();
            expect([[rewardedAd parameters] isEqualToDictionary:fakeEngagement.json[@"parameters"]]);
        }];
    });
    
    it(@"returns a rewarded ad with an invalid engagement", ^{
        fakeEngagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        fakeEngagement.json = nil;
        
        [engageFactory requestRewardedAdForDecisionPoint:@"testDecisionPoint" handler:^(DDNARewardedAd * _Nonnull rewardedAd) {
            expect(rewardedAd).toNot.beNil();
            expect([rewardedAd parameters]).to.haveACountOf(0);
            expect([rewardedAd engagement]).to.beNil();
            expect([rewardedAd decisionPoint]).to.beNil();
        }];
    });
});

SpecEnd
