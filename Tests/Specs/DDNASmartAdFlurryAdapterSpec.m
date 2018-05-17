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
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/Networks/Flurry/DDNASmartAdFlurryInterstitialAdapter.h>
#import <DeltaDNAAds/Networks/Flurry/DDNASmartAdFlurryRewardedAdapter.h>


SpecBegin(DDNASmartAdFlurryAdapter)

describe(@"Flurry interstitial adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY",
            @"apiKey": @"test-api-key",
            @"adSpace": @"test-ad-space",
            @"eCPM": @150
        };
        
        DDNASmartAdFlurryInterstitialAdapter *adapter = [[DDNASmartAdFlurryInterstitialAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.apiKey).to.equal(@"test-api-key");
        expect(adapter.adSpace).to.equal(@"test-ad-space");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY"
        };
        
        DDNASmartAdFlurryInterstitialAdapter *adapter = [[DDNASmartAdFlurryInterstitialAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY",
            @"apiKey": @"test-api-key",
            @"adSpace": @"test-ad-space",
            @"testMode": @YES
        };
        
        DDNASmartAdFlurryInterstitialAdapter *adapter = [[DDNASmartAdFlurryInterstitialAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.apiKey).to.equal(@"test-api-key");
        expect(adapter.adSpace).to.equal(@"test-ad-space");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
    });
    
    it(@"respects privacy settings", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY",
            @"apiKey": @"test-api-key",
            @"adSpace": @"test-ad-space",
            @"eCPM": @150
        };
        
        DDNASmartAdFlurryInterstitialAdapter *adapter = [[DDNASmartAdFlurryInterstitialAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.isGdprCompliant).to.beFalsy();
    });
    
});

describe(@"Flurry rewarded adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY-REWARDED",
            @"apiKey": @"test-api-key",
            @"adSpace": @"test-ad-space",
            @"eCPM": @150
        };
        
        DDNASmartAdFlurryRewardedAdapter *adapter = [[DDNASmartAdFlurryRewardedAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.apiKey).to.equal(@"test-api-key");
        expect(adapter.adSpace).to.equal(@"test-ad-space");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY-REWARDED"
        };
        
        DDNASmartAdFlurryRewardedAdapter *adapter = [[DDNASmartAdFlurryRewardedAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY-REWARDED",
            @"apiKey": @"test-api-key",
            @"adSpace": @"test-ad-space",
            @"testMode": @YES
        };
        
        DDNASmartAdFlurryRewardedAdapter *adapter = [[DDNASmartAdFlurryRewardedAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.apiKey).to.equal(@"test-api-key");
        expect(adapter.adSpace).to.equal(@"test-ad-space");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
    });
    
    it(@"respects privacy settings", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FLURRY-REWARDED",
            @"apiKey": @"test-api-key",
            @"adSpace": @"test-ad-space",
            @"eCPM": @150
        };
        
        DDNASmartAdFlurryRewardedAdapter *adapter = [[DDNASmartAdFlurryRewardedAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.isGdprCompliant).to.beFalsy();
    });
    
});


SpecEnd
