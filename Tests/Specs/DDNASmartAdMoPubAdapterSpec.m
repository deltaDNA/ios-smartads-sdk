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

#import <DeltaDNAAds/Networks/MoPub/DDNASmartAdMoPubAdapter.h>


SpecBegin(DDNASmartAdMoPubAdapter)

describe(@"MoPub adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MOPUB",
            @"adUnitId": @"test-ad-unit-id",
            @"eCPM": @150
        };
        
        DDNASmartAdMoPubAdapter *adapter = [[DDNASmartAdMoPubAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
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
        
        DDNASmartAdMoPubAdapter *adapter = [[DDNASmartAdMoPubAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MOPUB",
            @"adUnitId": @"test-ad-unit-id",
            @"testMode": @YES
        };
        
        DDNASmartAdMoPubAdapter *adapter = [[DDNASmartAdMoPubAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.adUnitId).to.equal(@"test-ad-unit-id");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"respects privacy settings", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MOPUB",
            @"adUnitId": @"test-ad-unit-id",
            @"eCPM": @150
        };
        
        DDNASmartAdMoPubAdapter *adapter = [[DDNASmartAdMoPubAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.isGdprCompliant).to.beFalsy();
        
    });
    
});

SpecEnd
