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

#import <DeltaDNAAds/Networks/Chartboost/DDNASmartAdChartboostInterstitialAdapter.h>
#import <DeltaDNAAds/Networks/Chartboost/DDNASmartAdChartboostRewardedAdapter.h>


SpecBegin(DDNASmartAdChartboostAdapter)

describe(@"Chartboost interstitial adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"CHARTBOOST",
            @"appId": @"test-app-id",
            @"appSignature": @"test-app-signature",
            @"location": @"Startup",
            @"eCPM": @150
        };
        
        DDNASmartAdChartboostInterstitialAdapter *adapter = [[DDNASmartAdChartboostInterstitialAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.appId).to.equal(@"test-app-id");
        expect(adapter.appSignature).to.equal(@"test-app-signature");
        expect(adapter.location).to.equal(@"Startup");
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"CHARTBOOST"
        };
        
        DDNASmartAdChartboostInterstitialAdapter *adapter = [[DDNASmartAdChartboostInterstitialAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"respects privacy settings", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"CHARTBOOST",
            @"appId": @"test-app-id",
            @"appSignature": @"test-app-signature",
            @"location": @"Startup",
            @"eCPM": @150
        };
        
        DDNASmartAdChartboostInterstitialAdapter *adapter = [[DDNASmartAdChartboostInterstitialAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.isGdprCompliant).to.beTruthy();
    });
    
});

describe(@"Chartboost rewarded video adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"CHARTBOOST-REWARDED",
            @"appId": @"test-app-id",
            @"appSignature": @"test-app-signature",
            @"location": @"Startup",
            @"eCPM": @150
        };
        
        DDNASmartAdChartboostRewardedAdapter *adapter = [[DDNASmartAdChartboostRewardedAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.appId).to.equal(@"test-app-id");
        expect(adapter.appSignature).to.equal(@"test-app-signature");
        expect(adapter.location).to.equal(@"Startup");
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"CHARTBOOST-REWARDED"
        };
        
        DDNASmartAdChartboostRewardedAdapter *adapter = [[DDNASmartAdChartboostRewardedAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"respects privacy settings", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"CHARTBOOST-REWARDED",
            @"appId": @"test-app-id",
            @"appSignature": @"test-app-signature",
            @"location": @"Startup",
            @"eCPM": @150
        };
        
        DDNASmartAdChartboostRewardedAdapter *adapter = [[DDNASmartAdChartboostRewardedAdapter alloc] initWithConfiguration:configuration privacy:[[DDNASmartAdPrivacy alloc] init] waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.isGdprCompliant).to.beTruthy();
    });
});


SpecEnd
