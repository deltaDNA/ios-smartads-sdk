//
//  DDNASmartAdVungleAdapterSpec.m
//  DeltaDNA SmartAds Tests
//
//  Created by David White on 01/12/2015.
//
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/Networks/Vungle/DDNASmartAdVungleAdapter.h>


SpecBegin(DDNASmartAdVungleAdapter)

describe(@"Vungle adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"VUNGLE",
            @"appId": @"test-app-id",
            @"eCPM": @150
        };
        
        DDNASmartAdVungleAdapter *adapter = [[DDNASmartAdVungleAdapter alloc] initWithConfiguration:configuration
                                                                                     waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.appId).to.equal(@"test-app-id");
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"VUNGLE"
        };
        
        DDNASmartAdVungleAdapter *adapter = [[DDNASmartAdVungleAdapter alloc] initWithConfiguration:configuration
                                                                                     waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
});

SpecEnd
