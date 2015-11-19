//
//  DDNASmartAdMobFoxAdapterSpec.m
//  SmartAds
//
//  Created by David White on 10/11/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/Networks/MobFox/DDNASmartAdMobFoxAdapter.h>


SpecBegin(DDNASmartAdMobFoxAdapter)

describe(@"MobFox adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MOBFOX",
            @"publicationId": @"test-publication-id",
            @"eCPM": @150
        };
        
        DDNASmartAdMobFoxAdapter *adapter = [[DDNASmartAdMobFoxAdapter alloc] initWithConfiguration:configuration
                                                                                     waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.publicationId).to.equal(@"test-publication-id");
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MOBFOX"
        };
        
        DDNASmartAdMobFoxAdapter *adapter = [[DDNASmartAdMobFoxAdapter alloc] initWithConfiguration:configuration
                                                                                     waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
});

SpecEnd