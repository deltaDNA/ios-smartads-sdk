//
//  DDNASmartAdFlurryAdapterSpec.m
//  SmartAds
//
//  Created by David White on 06/11/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/Networks/Flurry/DDNASmartAdFlurryInterstitialAdapter.h>
#import <DeltaDNAAds/Networks/Flurry/DDNASmartAdFlurryRewardedAdapter.h>


SpecBegin(DDNASmartAdFlurryAdapter)

describe(@"Flurry interstitial adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY",
            @"apiKey": @"test-api-key",
            @"adSpace": @"test-ad-space",
            @"eCPM": @150
        };
        
        DDNASmartAdFlurryInterstitialAdapter *adapter = [[DDNASmartAdFlurryInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                                             waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.apiKey).to.equal(@"test-api-key");
        expect(adapter.adSpace).to.equal(@"test-ad-space");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY"
        };
        
        DDNASmartAdFlurryInterstitialAdapter *adapter = [[DDNASmartAdFlurryInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                                             waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY",
            @"apiKey": @"test-api-key",
            @"adSpace": @"test-ad-space",
            @"testMode": @YES
        };
        
        DDNASmartAdFlurryInterstitialAdapter *adapter = [[DDNASmartAdFlurryInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                                             waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.apiKey).to.equal(@"test-api-key");
        expect(adapter.adSpace).to.equal(@"test-ad-space");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
    });
    
});

describe(@"Flurry rewarded adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY-REWARDED",
            @"apiKey": @"test-api-key",
            @"adSpace": @"test-ad-space",
            @"eCPM": @150
        };
        
        DDNASmartAdFlurryRewardedAdapter *adapter = [[DDNASmartAdFlurryRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                     waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.apiKey).to.equal(@"test-api-key");
        expect(adapter.adSpace).to.equal(@"test-ad-space");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY-REWARDED"
        };
        
        DDNASmartAdFlurryRewardedAdapter *adapter = [[DDNASmartAdFlurryRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                     waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY-REWARDED",
            @"apiKey": @"test-api-key",
            @"adSpace": @"test-ad-space",
            @"testMode": @YES
        };
        
        DDNASmartAdFlurryRewardedAdapter *adapter = [[DDNASmartAdFlurryRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                     waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.apiKey).to.equal(@"test-api-key");
        expect(adapter.adSpace).to.equal(@"test-ad-space");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
    });
    
});


SpecEnd