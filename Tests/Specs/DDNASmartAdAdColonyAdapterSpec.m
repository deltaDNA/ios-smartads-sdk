//
//  DDNASmartAdAdColonyAdapterSpec.m
//  DeltaDNA SmartAds Tests
//
//  Created by David White on 27/11/2015.
//
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/Networks/AdColony/DDNASmartAdAdColonyAdapter.h>


SpecBegin(DDNASmartAdAdColonyAdapter)

describe(@"AdColony adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"ADCOLONY",
            @"appId": @"test-app-id",
            @"zoneId": @"test-zone-id",
            @"eCPM": @150
        };
        
        DDNASmartAdAdColonyAdapter *adapter = [[DDNASmartAdAdColonyAdapter alloc] initWithConfiguration:configuration
                                                                                         waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.appId).to.equal(@"test-app-id");
        expect(adapter.zoneId).to.equal(@"test-zone-id");
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"ADCOLONY"
        };
        
        DDNASmartAdAdColonyAdapter *adapter = [[DDNASmartAdAdColonyAdapter alloc] initWithConfiguration:configuration
                                                                                         waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
});

SpecEnd
