//
//  DDNASmartAdAmazonAdapterSpec.m
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

#import <DeltaDNAAds/Networks/Amazon/DDNASmartAdAmazonAdapter.h>


SpecBegin(DDNASmartAmazonAdapter)

describe(@"Amazon adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"AMAZON",
            @"appKey": @"test-app-key",
            @"eCPM": @150
        };
        
        DDNASmartAdAmazonAdapter *adapter = [[DDNASmartAdAmazonAdapter alloc] initWithConfiguration:configuration
                                                                                     waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.appKey).to.equal(@"test-app-key");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"AMAZON"
        };
        
        DDNASmartAdAmazonAdapter *adapter = [[DDNASmartAdAmazonAdapter alloc] initWithConfiguration:configuration
                                                                                     waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"AMAZON",
            @"appKey": @"test-app-key",
            @"testMode": @YES
        };
        
        DDNASmartAdAmazonAdapter *adapter = [[DDNASmartAdAmazonAdapter alloc] initWithConfiguration:configuration
                                                                                     waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.appKey).to.equal(@"test-app-key");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
});

SpecEnd