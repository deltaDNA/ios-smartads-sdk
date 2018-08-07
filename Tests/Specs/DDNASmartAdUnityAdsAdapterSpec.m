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

#import <DeltaDNAAds/Networks/UnityAds/DDNASmartAdUnityAdsAdapter.h>


SpecBegin(DDNASmartAdUnityAdsAdapter)

describe(@"UnityAds adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"UNITY",
            @"gameId": @"test-game-id",
            @"placementId": @"test-placement-id",
            @"eCPM": @150
        };
        
        DDNASmartAdUnityAdsAdapter *adapter = [[DDNASmartAdUnityAdsAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.gameId).to.equal(@"test-game-id");
        expect(adapter.placementId).to.equal(@"test-placement-id");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"UNITY"
        };
        
        DDNASmartAdUnityAdsAdapter *adapter = [[DDNASmartAdUnityAdsAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"UNITY",
            @"gameId": @"test-game-id",
            @"placementId": @"test-placement-id",
            @"testMode": @YES
        };
        
        DDNASmartAdUnityAdsAdapter *adapter = [[DDNASmartAdUnityAdsAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.gameId).to.equal(@"test-game-id");
        expect(adapter.placementId).to.equal(@"test-placement-id");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"respects privacy settings", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"UNITY",
            @"gameId": @"test-game-id",
            @"placementId": @"test-placement-id",
            @"eCPM": @150
        };
        
        DDNASmartAdUnityAdsAdapter *adapter = [[DDNASmartAdUnityAdsAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.isGdprCompliant).to.beTruthy();
        
    });
    
});

SpecEnd
