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
    __block UIViewController *mockViewController;

    beforeEach(^{
        mockDelegate = mockProtocol(@protocol(DDNARewardedAdDelegate));
        mockViewController = mock([UIViewController class]);
        
        [[DDNAFakeSmartAds sharedInstance] reset];
        [DDNAFakeSmartAds sharedInstance].allowRewarded = YES;
    });

    it(@"can be created without an Engagement", ^{
        
        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithDelegate:mockDelegate];
        expect(rewardedAd).toNot.beNil();
        expect([rewardedAd.parameters isEqualToDictionary:@{}]).to.beTruthy();
        expect(rewardedAd.sessionCount).to.equal(0);
        expect(rewardedAd.sessionLimit).to.equal(0);
        expect(rewardedAd.dailyCount).to.equal(0);
        expect(rewardedAd.dailyLimit).to.equal(0);
        expect(rewardedAd.lastShown).to.beNil();
        expect(rewardedAd.showWaitSecs).to.equal(0);
        expect(rewardedAd.rewardType).to.beNil();
        expect(rewardedAd.rewardAmount).to.equal(0);
    });

    it(@"can be created with a valid Engagement", ^{

        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.json = @{ @"parameters":
                                 @{@"customParam":@5,
                                   @"ddnaAdSessionCount":@4,
                                   @"ddnaAdDailyCount":@6,
                                   @"ddnaAdShowWaitSecs":@2,
                                   @"ddnaAdRewardType":@"SILVER",
                                   @"ddnaAdRewardAmount":@100
                                   }};
        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:engagement delegate:mockDelegate];

        expect(rewardedAd).toNot.beNil();
        expect([rewardedAd.parameters isEqualToDictionary:@{@"customParam": @5,
                                                            @"ddnaAdSessionCount":@4,
                                                            @"ddnaAdDailyCount":@6,
                                                            @"ddnaAdShowWaitSecs":@2,
                                                            @"ddnaAdRewardType":@"SILVER",
                                                            @"ddnaAdRewardAmount":@100
                                                            }]).to.beTruthy();
        expect(rewardedAd.decisionPoint).to.equal(@"testDecisionPoint");
        expect(rewardedAd.engagement).to.equal(engagement);
        expect(rewardedAd.sessionCount).to.equal(0);
        expect(rewardedAd.sessionLimit).to.equal(4);
        expect(rewardedAd.dailyCount).to.equal(0);
        expect(rewardedAd.dailyLimit).to.equal(6);
        expect(rewardedAd.lastShown).to.beNil();
        expect(rewardedAd.showWaitSecs).to.equal(2);
        expect(rewardedAd.rewardType).to.equal(@"SILVER");
        expect(rewardedAd.rewardAmount).to.equal(100);
        
        expect(rewardedAd.isReady).will.beFalsy();
        
        [[DDNAFakeSmartAds sharedInstance] loadRewardedAd];
        
        expect(rewardedAd.isReady).will.beTruthy();
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd];
        
        [[DDNAFakeSmartAds sharedInstance] showRewardedAdWithDecisionPoint:@"testDecisionPoint"];
        
        [rewardedAd showFromRootViewController:mockViewController];
        
        [verifyCount(mockDelegate, times(1)) didOpenRewardedAd:rewardedAd];
        
        [[DDNAFakeSmartAds sharedInstance] closeRewardedAdWithReward:YES atDecisionPoint:@"testDecisionPoint"];
        
        [verifyCount(mockDelegate, times(1)) didCloseRewardedAd:rewardedAd withReward:YES];
        
        expect(rewardedAd.isReady).will.beFalsy();
        
        [[DDNAFakeSmartAds sharedInstance] loadRewardedAd];
        
        expect(rewardedAd.isReady).after(2).beTruthy();
        
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd];
        
        
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
    
    it(@"returns nil if not allowed to create with an Engagement", ^{
        
        [DDNAFakeSmartAds sharedInstance].allowRewarded = NO;
        
        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.statusCode = 200;
        engagement.raw = @"{\"parameters\":{\"adShowPoint\":false}}";
        
        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:engagement delegate:mockDelegate];
        expect(rewardedAd).to.beNil();
    });
    
    it(@"multiple ads can coexist", ^{
        
        DDNAEngagement *engagement1 = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint1"];
        engagement1.json = @{ @"parameters": @{} };
        DDNARewardedAd *rewardedAd1 = [DDNARewardedAd rewardedAdWithEngagement:engagement1 delegate:mockDelegate];
        expect(rewardedAd1).toNot.beNil();
        expect([rewardedAd1.parameters isEqualToDictionary:@{}]).to.beTruthy();
        expect(rewardedAd1.decisionPoint).to.equal(@"testDecisionPoint1");
        expect(rewardedAd1.isReady).will.beFalsy();
        
        DDNAEngagement *engagement2 = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint2"];
        engagement2.json = @{ @"parameters": @{} };
        DDNARewardedAd *rewardedAd2 = [DDNARewardedAd rewardedAdWithEngagement:engagement2 delegate:mockDelegate];
        expect(rewardedAd2).toNot.beNil();
        expect([rewardedAd2.parameters isEqualToDictionary:@{}]).to.beTruthy();
        expect(rewardedAd2.decisionPoint).to.equal(@"testDecisionPoint2");
        expect(rewardedAd2.isReady).will.beFalsy();
        
        [[DDNAFakeSmartAds sharedInstance] loadRewardedAd];
        
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd1];
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd2];
        
        expect(rewardedAd1.isReady).will.beTruthy();
        expect(rewardedAd2.isReady).will.beTruthy();
        
        [[DDNAFakeSmartAds sharedInstance] showRewardedAdWithDecisionPoint:@"testDecisionPoint1"];

        [rewardedAd1 showFromRootViewController:mockViewController];

        [verifyCount(mockDelegate, times(1)) didOpenRewardedAd:rewardedAd1];
        [verifyCount(mockDelegate, times(1)) didExpireRewardedAd:rewardedAd2];
        [verifyCount(mockDelegate, never()) didExpireRewardedAd:rewardedAd1];
        expect(rewardedAd2.isReady).will.beFalsy();
        
        [[DDNAFakeSmartAds sharedInstance] closeRewardedAdWithReward:YES atDecisionPoint:@"testDecisionPoint1"];

        [verifyCount(mockDelegate, times(1)) didCloseRewardedAd:rewardedAd1 withReward:YES];
        expect(rewardedAd1.isReady).will.beFalsy();

        [[DDNAFakeSmartAds sharedInstance] loadRewardedAd];

        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd1];
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd2];

        expect(rewardedAd1.isReady).will.beTruthy();
        expect(rewardedAd2.isReady).will.beTruthy();
        
        [[DDNAFakeSmartAds sharedInstance] showRewardedAdWithDecisionPoint:@"testDecisionPoint2"];
        
        [rewardedAd2 showFromRootViewController:mockViewController];
        
        [verifyCount(mockDelegate, times(1)) didOpenRewardedAd:rewardedAd2];
        [verifyCount(mockDelegate, times(1)) didExpireRewardedAd:rewardedAd1];
        [verifyCount(mockDelegate, never()) didExpireRewardedAd:rewardedAd2];
        expect(rewardedAd1.isReady).will.beFalsy();
        
        [[DDNAFakeSmartAds sharedInstance] closeRewardedAdWithReward:YES atDecisionPoint:@"testDecisionPoint2"];
        
        [verifyCount(mockDelegate, times(1)) didCloseRewardedAd:rewardedAd2 withReward:YES];
        expect(rewardedAd2.isReady).will.beFalsy();
        
        [[DDNAFakeSmartAds sharedInstance] loadRewardedAd];
        
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd1];
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd2];
        
        expect(rewardedAd1.isReady).will.beTruthy();
        expect(rewardedAd2.isReady).will.beTruthy();
    });
    
    it(@"reports loaded after wait time", ^{
        
        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.json = @{ @"parameters": @{@"ddnaAdShowWaitSecs": @4} };
        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:engagement delegate:mockDelegate];
        
        expect(rewardedAd).toNot.beNil();
        expect([rewardedAd.parameters isEqualToDictionary:@{@"ddnaAdShowWaitSecs": @4}]).to.beTruthy();
        expect(rewardedAd.decisionPoint).to.equal(@"testDecisionPoint");
        
        expect(rewardedAd.isReady).will.beFalsy();
        
        [[DDNAFakeSmartAds sharedInstance] loadRewardedAd];
        
        expect(rewardedAd.isReady).will.beTruthy();
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd];
        
        [[DDNAFakeSmartAds sharedInstance] showRewardedAdWithDecisionPoint:@"testDecisionPoint"];
        
        [rewardedAd showFromRootViewController:mockViewController];
        
        [verifyCount(mockDelegate, times(1)) didOpenRewardedAd:rewardedAd];
        
        [[DDNAFakeSmartAds sharedInstance] closeRewardedAdWithReward:YES atDecisionPoint:@"testDecisionPoint"];
        
        [verifyCount(mockDelegate, times(1)) didCloseRewardedAd:rewardedAd withReward:YES];
        
        expect(rewardedAd.isReady).will.beFalsy();
        
        [[DDNAFakeSmartAds sharedInstance] loadRewardedAd];
        
        expect(rewardedAd.isReady).will.beFalsy();
        
        expect(rewardedAd.isReady).after(4).will.beTruthy();
        
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd];
        
        
    });
    
    it(@"multiple ads can coexist with wait times", ^{
        
        DDNAEngagement *engagement1 = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint1"];
        engagement1.json = @{ @"parameters": @{@"ddnaAdShowWaitSecs": @2} };
        DDNARewardedAd *rewardedAd1 = [DDNARewardedAd rewardedAdWithEngagement:engagement1 delegate:mockDelegate];
        expect(rewardedAd1).toNot.beNil();
        expect([rewardedAd1.parameters isEqualToDictionary:@{@"ddnaAdShowWaitSecs": @2}]).to.beTruthy();
        expect(rewardedAd1.decisionPoint).to.equal(@"testDecisionPoint1");
        expect(rewardedAd1.isReady).will.beFalsy();
        
        DDNAEngagement *engagement2 = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint2"];
        engagement2.json = @{ @"parameters": @{@"ddnaAdShowWaitSecs": @4} };
        DDNARewardedAd *rewardedAd2 = [DDNARewardedAd rewardedAdWithEngagement:engagement2 delegate:mockDelegate];
        expect(rewardedAd2).toNot.beNil();
        expect([rewardedAd2.parameters isEqualToDictionary:@{@"ddnaAdShowWaitSecs": @4}]).to.beTruthy();
        expect(rewardedAd2.decisionPoint).to.equal(@"testDecisionPoint2");
        expect(rewardedAd2.isReady).will.beFalsy();
        
        [[DDNAFakeSmartAds sharedInstance] loadRewardedAd];
        
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd1];
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd2];
        
        expect(rewardedAd1.isReady).will.beTruthy();
        expect(rewardedAd2.isReady).will.beTruthy();
        
        [[DDNAFakeSmartAds sharedInstance] showRewardedAdWithDecisionPoint:@"testDecisionPoint1"];
        
        [rewardedAd1 showFromRootViewController:mockViewController];
        
        [verifyCount(mockDelegate, times(1)) didOpenRewardedAd:rewardedAd1];
        [verifyCount(mockDelegate, times(1)) didExpireRewardedAd:rewardedAd2];
        [verifyCount(mockDelegate, never()) didExpireRewardedAd:rewardedAd1];
        expect(rewardedAd2.isReady).will.beFalsy();
        
        [[DDNAFakeSmartAds sharedInstance] closeRewardedAdWithReward:YES atDecisionPoint:@"testDecisionPoint1"];
        
        [verifyCount(mockDelegate, times(1)) didCloseRewardedAd:rewardedAd1 withReward:YES];
        expect(rewardedAd1.isReady).will.beFalsy();
        expect(rewardedAd2.isReady).will.beFalsy();
        
        [[DDNAFakeSmartAds sharedInstance] loadRewardedAd];
        
        // need to wait so still not ready
        expect(rewardedAd1.isReady).will.beFalsy();
        // but rewarded 2 will be fine as we haven't shown it yet
        expect(rewardedAd2.isReady).will.beTruthy();
        
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd2];
        expect(rewardedAd1.isReady).will.beFalsy();
        [verifyCount(mockDelegate, never()) didLoadRewardedAd:rewardedAd1];

        [[DDNAFakeSmartAds sharedInstance] showRewardedAdWithDecisionPoint:@"testDecisionPoint2"];

        [rewardedAd2 showFromRootViewController:mockViewController];

        [verifyCount(mockDelegate, times(1)) didOpenRewardedAd:rewardedAd2];

        // shouldn't expire, because it never loaded yet
        expect(rewardedAd1.isReady).will.beFalsy();
        [verifyCount(mockDelegate, never()) didExpireRewardedAd:rewardedAd1];

        // it should still be false after another 2 seconds because no ad is now available, it's showing
        [verifyCount(mockDelegate, never()) didLoadRewardedAd:rewardedAd1];

        [[DDNAFakeSmartAds sharedInstance] closeRewardedAdWithReward:YES atDecisionPoint:@"testDecisionPoint2"];
        [verifyCount(mockDelegate, times(1)) didCloseRewardedAd:rewardedAd2 withReward:YES];
        expect(rewardedAd2.isReady).will.beFalsy();

        [[DDNAFakeSmartAds sharedInstance] loadRewardedAd];
        
        expect(rewardedAd1.isReady).after(2).will.beFalsy();
        [verifyCount(mockDelegate, never()) didLoadRewardedAd:rewardedAd1];

        // it's been long enough for rewarded ad 1 to load immediately
        expect(rewardedAd1.isReady).after(2).will.beTruthy();
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd1];
        // but rewarded ad 2 should wait another 2 seconds
        expect(rewardedAd2.isReady).will.beFalsy();
        [verifyCount(mockDelegate, never()) didLoadRewardedAd:rewardedAd2];

        [[DDNAFakeSmartAds sharedInstance] showRewardedAdWithDecisionPoint:@"testDecisionPoint1"];

        [rewardedAd1 showFromRootViewController:mockViewController];

        [verifyCount(mockDelegate, times(1)) didOpenRewardedAd:rewardedAd1];
        [verifyCount(mockDelegate, never()) didExpireRewardedAd:rewardedAd1];
        [verifyCount(mockDelegate, never()) didExpireRewardedAd:rewardedAd2];
        expect(rewardedAd1.isReady).will.beFalsy();
        expect(rewardedAd2.isReady).will.beFalsy();

        // will still be false because other ad is showing
        [verifyCount(mockDelegate, never()) didLoadRewardedAd:rewardedAd2];

        [[DDNAFakeSmartAds sharedInstance] closeRewardedAdWithReward:YES atDecisionPoint:@"testDecisionPoint1"];

        [verifyCount(mockDelegate, times(1)) didCloseRewardedAd:rewardedAd1 withReward:YES];
        expect(rewardedAd1.isReady).will.beFalsy();
        expect(rewardedAd2.isReady).will.beFalsy();

        [[DDNAFakeSmartAds sharedInstance] loadRewardedAd];
        
        [verifyCount(mockDelegate, never()) didLoadRewardedAd:rewardedAd1];
        [verifyCount(mockDelegate, never()) didLoadRewardedAd:rewardedAd2];

        expect(rewardedAd1.isReady).after(2).will.beTruthy();
        expect(rewardedAd2.isReady).after(4).will.beTruthy();

        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd1];
        [verifyCount(mockDelegate, times(1)) didLoadRewardedAd:rewardedAd2];

        expect(rewardedAd1.isReady).will.beTruthy();
        expect(rewardedAd2.isReady).will.beTruthy();
    });

});

SpecEnd
