//
//  DDNARewardedAdSpec.m
//  DeltaDNA SmartAds Tests
//
//  Created by David White on 31/03/2016.
//
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/SmartAds/DDNARewardedAd.h>
#import <DeltaDNA/DDNAEngagement.h>

SpecBegin(DDNARewardedAd)

describe(@"rewarded ad", ^{

    __block id<DDNARewardedAdDelegate> mockDelegate;

    beforeEach(^{
        mockDelegate = mockProtocol(@protocol(DDNARewardedAdDelegate));
    });

    it(@"can be created without an Engagement", ^{

        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithDelegate:mockDelegate];
        expect(rewardedAd).toNot.beNil();
        expect([rewardedAd.parameters isEqualToDictionary:@{}]).to.beTruthy();
    });

    it(@"can be created with an Engagement", ^{

        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:engagement delegate:mockDelegate];

        expect(rewardedAd).toNot.beNil();
        expect([rewardedAd.parameters isEqualToDictionary:@{}]).to.beTruthy();
    });

    it(@"returns nil if adShowPoint is false", ^{

        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.raw = @"{ \"parameters\": { \"adShowPoint\" : false } }";

        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:engagement delegate:mockDelegate];

        expect(rewardedAd).to.beNil();
    });

    it(@"can be created if adShowPoint is true", ^{

        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.raw = @"{ \"parameters\": { \"adShowPoint\" : true } }";

        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:engagement delegate:mockDelegate];

        expect(rewardedAd).toNot.beNil();
        expect([rewardedAd.parameters isEqualToDictionary:@{@"adShowPoint":@YES}]);
    });

});

SpecEnd
