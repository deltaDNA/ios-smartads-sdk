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

#import <DeltaDNAAds/Networks/InMobi/DDNASmartAdInMobiInterstitialAdapter.h>
#import <DeltaDNAAds/Networks/InMobi/DDNASmartAdInMobiRewardedAdapter.h>


SpecBegin(DDNASmartAdInMobiAdapter)

describe(@"InMobi interstitial adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"INMOBI",
            @"accountId": @"test-account-id",
            @"placementId": @12345,
            @"eCPM": @150
        };
        
        DDNASmartAdInMobiInterstitialAdapter *adapter = [[DDNASmartAdInMobiInterstitialAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
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
        
        DDNASmartAdInMobiInterstitialAdapter *adapter = [[DDNASmartAdInMobiInterstitialAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"respects privacy settings", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"INMOBI",
            @"accountId": @"test-account-id",
            @"placementId": @12345,
            @"eCPM": @150
        };
        
        DDNASmartAdInMobiInterstitialAdapter *adapter = [[DDNASmartAdInMobiInterstitialAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.isGdprCompliant).to.beTruthy();
    });
    
});

describe(@"InMobi rewarded adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"INMOBI-REWARDED",
            @"accountId": @"test-account-id",
            @"placementId": @12345,
            @"eCPM": @150
        };
        
        DDNASmartAdInMobiRewardedAdapter *adapter = [[DDNASmartAdInMobiRewardedAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.accountId).to.equal(@"test-account-id");
        expect(adapter.placementId).to.equal(@12345);
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"INMOBI-REWARDED"
        };
        
        DDNASmartAdInMobiRewardedAdapter *adapter = [[DDNASmartAdInMobiRewardedAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"respects privacy settings", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"INMOBI-REWARDED",
            @"accountId": @"test-account-id",
            @"placementId": @12345,
            @"eCPM": @150
        };
        
        DDNASmartAdInMobiRewardedAdapter *adapter = [[DDNASmartAdInMobiRewardedAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.isGdprCompliant).to.beTruthy();
    });
    
});


SpecEnd
