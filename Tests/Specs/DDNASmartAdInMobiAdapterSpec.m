//
//  DDNASmartAdInMobiAdapterSpec.m
//  SmartAds
//
//  Created by David White on 09/11/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/Networks/InMobi/DDNASmartAdInMobiAdapter.h>


SpecBegin(DDNASmartAdInMobiAdapter)

describe(@"InMobi adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"INMOBI",
            @"accountId": @"test-account-id",
            @"placementId": @12345,
            @"eCPM": @150
        };
        
        DDNASmartAdInMobiAdapter *adapter = [[DDNASmartAdInMobiAdapter alloc] initWithConfiguration:configuration
                                                                                     waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.accountId).to.equal(@"test-account-id");
        expect(adapter.placementId).to.equal(@12345);
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"INMOBI"
        };
        
        DDNASmartAdInMobiAdapter *adapter = [[DDNASmartAdInMobiAdapter alloc] initWithConfiguration:configuration
                                                                                     waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
});

SpecEnd