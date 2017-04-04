//
// Copyright (c) 2017 deltaDNA Ltd. All rights reserved.
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

#import <DeltaDNAAds/Networks/IronSource/DDNASmartAdIronSourceInterstitialAdapter.h>
#import <DeltaDNAAds/Networks/IronSource/DDNASmartAdIronSourceRewardedAdapter.h>

SpecBegin(DDNASmartAdIronSourceAdapter)

describe(@"IronSource interstitial adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"IRONSOURCE",
            @"appKey": @"test-app-key",
            @"eCPM": @150
        };
        
        DDNASmartAdIronSourceInterstitialAdapter *adapter = [[DDNASmartAdIronSourceInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                                                     waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.appKey).to.equal(@"test-app-key");
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"IRONSOURCE"
        };
        
        DDNASmartAdIronSourceInterstitialAdapter *adapter = [[DDNASmartAdIronSourceInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                                                     waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
});

describe(@"IronSource rewarded adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"IRONSOURCE",
            @"appKey": @"test-app-key",
            @"eCPM": @150
        };
        
        DDNASmartAdIronSourceRewardedAdapter *adapter = [[DDNASmartAdIronSourceRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                             waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.appKey).to.equal(@"test-app-key");
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"IRONSOURCE"
        };
        
        DDNASmartAdIronSourceRewardedAdapter *adapter = [[DDNASmartAdIronSourceRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                             waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
});


SpecEnd
