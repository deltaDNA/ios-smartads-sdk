//
//  DDNASmartAdMoPubAdapterSpec.m
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

#import <DeltaDNAAds/Networks/MoPub/DDNASmartAdMoPubAdapter.h>


SpecBegin(DDNASmartAdMoPubAdapter)

describe(@"MoPub adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MOPUB",
            @"adUnitId": @"test-ad-unit-id",
            @"eCPM": @150
        };
        
        DDNASmartAdMoPubAdapter *adapter = [[DDNASmartAdMoPubAdapter alloc] initWithConfiguration:configuration
                                                                                   waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.adUnitId).to.equal(@"test-ad-unit-id");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MOPUB"
        };
        
        DDNASmartAdMoPubAdapter *adapter = [[DDNASmartAdMoPubAdapter alloc] initWithConfiguration:configuration
                                                                                   waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MOPUB",
            @"adUnitId": @"test-ad-unit-id",
            @"testMode": @YES
        };
        
        DDNASmartAdMoPubAdapter *adapter = [[DDNASmartAdMoPubAdapter alloc] initWithConfiguration:configuration
                                                                                   waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.adUnitId).to.equal(@"test-ad-unit-id");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
});

SpecEnd