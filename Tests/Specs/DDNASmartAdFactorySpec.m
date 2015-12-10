//
//  DDNASmartAdFactorySpec.m
//  SmartAds
//
//  Created by David White on 14/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/SmartAds/DDNASmartAdFactory.h>
#import <DeltaDNAAds/Networks/Dummy/DDNASmartAdDummyAdapter.h>
#import <DeltaDNAAds/Networks/AdMob/DDNASmartAdAdMobAdapter.h>
#import <DeltaDNAAds/Networks/Amazon/DDNASmartAdAmazonAdapter.h>


SpecBegin(DDNASmartAdFactory)

describe(@"factory waterfall", ^{
    
    it(@"builds a set from configuration", ^{
        
        NSArray *adProviders = @[
            @{
                @"adProvider": @"ADMOB",
                @"eCPM": @100,
                @"adUnitId": @"test-ad-unit-id"
            },
            @{
                @"adProvider": @"AMAZON",
                @"eCPM": @200,
                @"appKey": @"test-app-key"
            },
            @{
                @"adProvider": @"DUMMY",
                @"eCPM": @300
            }
        ];
        
        NSArray *adapters = [[DDNASmartAdFactory sharedInstance] buildAdapterWaterfallWithAdProviders:adProviders floorPrice:0];
        
        expect(adapters).toNot.beNil();
        expect(adapters.count).to.equal(3);
        // InstanceOf doesn't work, neither does comparing the class names, must convert to strings and compare.
        expect(NSStringFromClass([adapters[0] class])).to.equal(NSStringFromClass([DDNASmartAdAdMobAdapter class]));
        expect(NSStringFromClass([adapters[1] class])).to.equal(NSStringFromClass([DDNASmartAdAmazonAdapter class]));
        expect(NSStringFromClass([adapters[2] class])).to.equal(NSStringFromClass([DDNASmartAdDummyAdapter class]));
        
    });
    
    it(@"builds a set without adapters below floor price", ^{
        
        NSArray *adProviders = @[
            @{
                @"adProvider": @"ADMOB",
                @"eCPM": @100,
                @"adUnitId": @"test-ad-unit-id"
            },
            @{
                @"adProvider": @"AMAZON",
                @"eCPM": @200,
                @"appKey": @"test-app-key"
            },
            @{
                @"adProvider": @"DUMMY",
                @"eCPM": @300
            }
        ];
        
        NSArray *adapters = [[DDNASmartAdFactory sharedInstance] buildAdapterWaterfallWithAdProviders:adProviders floorPrice:250];
        
        expect(adapters).toNot.beNil();
        expect(adapters.count).to.equal(1);
        expect(NSStringFromClass([adapters[0] class])).to.equal(NSStringFromClass([DDNASmartAdDummyAdapter class]));
        
    });
    
    it(@"handles invalid configuration",^{
        
        NSArray *adProviders = @[
            @{
                @"adProvider": @"ADMOB",
                @"eCPM": @100
            },
            @{
                @"adProvider": @"AMAZON",
                @"eCPM": @200,
                @"appKey": @"test-app-key"
            },
            @{
                @"adProvider": @"DUMMY",
                @"eCPM": @300
            }
        ];
        
        NSArray *adapters = [[DDNASmartAdFactory sharedInstance] buildAdapterWaterfallWithAdProviders:adProviders floorPrice:0];
        
        expect(adapters).toNot.beNil();
        expect(adapters.count).to.equal(2);

        expect(NSStringFromClass([adapters[0] class])).to.equal(NSStringFromClass([DDNASmartAdAmazonAdapter class]));
        expect(NSStringFromClass([adapters[1] class])).to.equal(NSStringFromClass([DDNASmartAdDummyAdapter class]));
        
    });
    
    it(@"returns empty list when no valid networks", ^{
        
        NSArray *adProviders = @[];
        
        NSArray *adapters = [[DDNASmartAdFactory sharedInstance] buildAdapterWaterfallWithAdProviders:adProviders floorPrice:0];
        
        expect(adapters).toNot.beNil();
        expect(adapters.count).to.equal(0);
    });
});

SpecEnd