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

#import <DeltaDNAAds/SmartAds/DDNAInterstitialAd.h>
#import <DeltaDNA/DDNAEngagement.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAdService.h>
#import "DDNAFakeSmartAdFactory.h"
#import <DeltaDNA/NSString+DeltaDNA.h>
#import "DDNAFakeSmartAds.h"


SpecBegin(DDNAInterstitialAd)

describe(@"interstitial ad", ^{

    __block id<DDNAInterstitialAdDelegate> mockDelegate;

    beforeEach(^{
        mockDelegate = mockProtocol(@protocol(DDNAInterstitialAdDelegate));
        
        [[DDNAFakeSmartAds sharedInstance] reset];
        [DDNAFakeSmartAds sharedInstance].allowInterstitial = YES;
    });

    it(@"can be created without an Engagement", ^{
        
        DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithDelegate:mockDelegate];
        expect(interstitialAd).toNot.beNil();
        expect([interstitialAd.parameters isEqualToDictionary:@{}]).to.beTruthy();
        expect(interstitialAd.sessionCount).to.equal(0);
        expect(interstitialAd.sessionLimit).to.equal(0);
        expect(interstitialAd.dailyCount).to.equal(0);
        expect(interstitialAd.dailyLimit).to.equal(0);
        expect(interstitialAd.lastShown).to.beNil();
        expect(interstitialAd.showWaitSecs).to.equal(0);
    });

    it(@"can be created with a valid Engagement", ^{

        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.json = @{ @"parameters":
                                 @{@"customParam":@5,
                                   @"ddnaAdSessionCount":@4,
                                   @"ddnaAdDailyCount":@6,
                                   @"ddnaAdShowWaitSecs":@2}};
        DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithEngagement:engagement delegate:mockDelegate];

        expect(interstitialAd).toNot.beNil();
        expect([interstitialAd.parameters isEqualToDictionary:@{@"customParam": @5,
                                                                @"ddnaAdSessionCount":@4,
                                                                @"ddnaAdDailyCount":@6,
                                                                @"ddnaAdShowWaitSecs":@2
                                                                }]).to.beTruthy();
        expect(interstitialAd.decisionPoint).to.equal(@"testDecisionPoint");
        expect(interstitialAd.engagement).to.equal(engagement);
        expect(interstitialAd.sessionCount).to.equal(0);
        expect(interstitialAd.sessionLimit).to.equal(4);
        expect(interstitialAd.dailyCount).to.equal(0);
        expect(interstitialAd.dailyLimit).to.equal(6);
        expect(interstitialAd.lastShown).to.beNil();
        expect(interstitialAd.showWaitSecs).to.equal(2);
    });
    
    it(@"can be created with a nil Engagement", ^{

        DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithEngagement:nil delegate:mockDelegate];
        
        expect(interstitialAd).toNot.beNil();
        expect([interstitialAd.parameters isEqualToDictionary:@{}]).to.beTruthy();
        expect([interstitialAd engagement]).to.beNil();
        expect([interstitialAd decisionPoint]).to.beNil();
    });
    
    it(@"can be created with an invalid Engagement", ^{
        
        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithEngagement:engagement delegate:mockDelegate];
        
        expect(interstitialAd).toNot.beNil();
        expect([interstitialAd.parameters isEqualToDictionary:@{}]).to.beTruthy();
        expect([interstitialAd engagement]).to.beNil();
        expect([interstitialAd decisionPoint]).to.beNil();
    });
    
    it(@"returns nil if not allowed to create", ^{
       
        [DDNAFakeSmartAds sharedInstance].allowInterstitial = NO;
        
        DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithDelegate:mockDelegate];
        expect(interstitialAd).to.beNil();
        
        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        interstitialAd = [DDNAInterstitialAd interstitialAdWithEngagement:engagement delegate:mockDelegate];
        expect(interstitialAd).to.beNil();
    });
    
    it(@"returns nil if not allowed to create with an Engagement", ^{
        
        [DDNAFakeSmartAds sharedInstance].allowInterstitial = NO;
        
        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.statusCode = 200;
        engagement.raw = @"{\"parameters\":{\"adShowPoint\":false}}";
        
        DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithEngagement:engagement delegate:mockDelegate];
        expect(interstitialAd).to.beNil();
    });
});

SpecEnd
