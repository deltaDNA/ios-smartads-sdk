//
//  DDNAInterstitialAdSpec.m
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

#import <DeltaDNAAds/SmartAds/DDNAInterstitialAd.h>
#import <DeltaDNA/DDNAEngagement.h>

SpecBegin(DDNAInterstitialAd)

describe(@"interstitial ad", ^{

    __block id<DDNAInterstitialAdDelegate> mockDelegate;

    beforeEach(^{
        mockDelegate = mockProtocol(@protocol(DDNAInterstitialAdDelegate));
    });

    it(@"can be created without an Engagement", ^{

        DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithDelegate:mockDelegate];
        expect(interstitialAd).toNot.beNil();
        expect([interstitialAd.parameters isEqualToDictionary:@{}]).to.beTruthy();
    });

    it(@"can be created with an Engagement", ^{

        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithEngagement:engagement delegate:mockDelegate];

        expect(interstitialAd).toNot.beNil();
        expect([interstitialAd.parameters isEqualToDictionary:@{}]).to.beTruthy();
    });

    it(@"returns nil if adShowPoint is false", ^{

        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.raw = @"{ \"parameters\": { \"adShowPoint\" : false } }";

        DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithEngagement:engagement delegate:mockDelegate];

        expect(interstitialAd).to.beNil();
    });

    it(@"can be created if adShowPoint is true", ^{

        DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"testDecisionPoint"];
        engagement.raw = @"{ \"parameters\": { \"adShowPoint\" : true } }";

        DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithEngagement:engagement delegate:mockDelegate];

        expect(interstitialAd).toNot.beNil();
        expect([interstitialAd.parameters isEqualToDictionary:@{@"adShowPoint":@YES}]);
    });

});

SpecEnd
