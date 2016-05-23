//
// Copyright (c) 2016 deltaDNA Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
        
        NSArray *adapters = [[DDNASmartAdFactory sharedInstance] buildInterstitialAdapterWaterfallWithAdProviders:adProviders floorPrice:0];
        
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
        
        NSArray *adapters = [[DDNASmartAdFactory sharedInstance] buildInterstitialAdapterWaterfallWithAdProviders:adProviders floorPrice:250];
        
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
        
        NSArray *adapters = [[DDNASmartAdFactory sharedInstance] buildInterstitialAdapterWaterfallWithAdProviders:adProviders floorPrice:0];
        
        expect(adapters).toNot.beNil();
        expect(adapters.count).to.equal(2);

        expect(NSStringFromClass([adapters[0] class])).to.equal(NSStringFromClass([DDNASmartAdAmazonAdapter class]));
        expect(NSStringFromClass([adapters[1] class])).to.equal(NSStringFromClass([DDNASmartAdDummyAdapter class]));
        
    });
    
    it(@"returns empty list when no valid networks", ^{
        
        NSArray *adProviders = @[];
        
        NSArray *adapters = [[DDNASmartAdFactory sharedInstance] buildInterstitialAdapterWaterfallWithAdProviders:adProviders floorPrice:0];
        
        expect(adapters).toNot.beNil();
        expect(adapters.count).to.equal(0);
    });
});

SpecEnd