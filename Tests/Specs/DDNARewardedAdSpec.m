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

#import <DeltaDNAAds/SmartAds/DDNARewardedAd.h>
#import <DeltaDNA/DDNAEngagement.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAds.h>
#import "DDNAFakeSmartAds.h"

SpecBegin(DDNARewardedAd)

describe(@"rewarded ad", ^{

    __block id<DDNARewardedAdDelegate> mockDelegate;

    beforeEach(^{
        mockDelegate = mockProtocol(@protocol(DDNARewardedAdDelegate));
        
        [DDNAFakeSmartAds sharedInstance].allowRewarded = YES;
    });

    it(@"can be created without an Engagement", ^{

        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithDelegate:mockDelegate];
        expect(rewardedAd).toNot.beNil();
        expect([rewardedAd.parameters isEqualToDictionary:@{}]).to.beTruthy();
    });

    it(@"can be created with a valid Engagement", ^{

        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.json = @{ @"parameters": @{} };
        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:engagement delegate:mockDelegate];

        expect(rewardedAd).toNot.beNil();
        expect([rewardedAd.parameters isEqualToDictionary:@{}]).to.beTruthy();
    });
    
    it (@"can be created with a nil Engagement", ^{
        
        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:nil delegate:mockDelegate];
        
        expect(rewardedAd).toNot.beNil();
        expect([rewardedAd.parameters isEqualToDictionary:@{}]).to.beTruthy();
    });
    
    it (@"can be created with an invalid Engagement", ^{
       
        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:engagement delegate:mockDelegate];
        
        expect(rewardedAd).toNot.beNil();
        expect([rewardedAd.parameters isEqualToDictionary:@{}]).to.beTruthy();
    });
    
    it(@"returns nil if not allowed to create", ^{
        
        [DDNAFakeSmartAds sharedInstance].allowRewarded = NO;
        
        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithDelegate:mockDelegate];
        expect(rewardedAd).to.beNil();
        
        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:engagement delegate:mockDelegate];
        expect(rewardedAd).to.beNil();
        
    });

});

SpecEnd
