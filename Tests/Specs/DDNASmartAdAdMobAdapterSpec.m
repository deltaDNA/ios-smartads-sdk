//
//  DDNASmartAdAdMobAdapterSpec.m
//  SmartAds
//
//  Created by David White on 04/11/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/Networks/AdMob/DDNASmartAdAdMobAdapter.h>


SpecBegin(DDNASmartAdAdMobAdapter)

describe(@"AdMob adapter", ^{

    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"ADMOB",
            @"adUnitId": @"test-ad-unit-id",
            @"eCPM": @150
        };
        
        DDNASmartAdAdMobAdapter *adapter = [[DDNASmartAdAdMobAdapter alloc] initWithConfiguration:configuration
                                                                                   waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.adUnitId).to.equal(@"test-ad-unit-id");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"ADMOB"
        };
        
        DDNASmartAdAdMobAdapter *adapter = [[DDNASmartAdAdMobAdapter alloc] initWithConfiguration:configuration
                                                                                   waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"ADMOB",
            @"adUnitId": @"test-ad-unit-id",
            @"testMode": @YES
        };
        
        DDNASmartAdAdMobAdapter *adapter = [[DDNASmartAdAdMobAdapter alloc] initWithConfiguration:configuration
                                                                                   waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.adUnitId).to.equal(@"test-ad-unit-id");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
});

SpecEnd