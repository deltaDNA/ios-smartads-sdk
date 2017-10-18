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

#import <DeltaDNAAds/Networks/AdMob/DDNASmartAdAdMobInterstitialAdapter.h>
#import <DeltaDNAAds/Networks/AdMob/DDNASmartAdAdMobRewardedAdapter.h>


SpecBegin(DDNASmartAdAdMobAdapter)

describe(@"AdMob interstitial adapter", ^{

    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"ADMOB",
            @"appId": @"test-app-id",
            @"adUnitId": @"test-ad-unit-id",
            @"eCPM": @150
        };
        
        DDNASmartAdAdMobInterstitialAdapter *adapter = [[DDNASmartAdAdMobInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                                           waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.appId).to.equal(@"test-app-id");
        expect(adapter.adUnitId).to.equal(@"test-ad-unit-id");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"ADMOB"
        };
        
        DDNASmartAdAdMobInterstitialAdapter *adapter = [[DDNASmartAdAdMobInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                   waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"ADMOB",
            @"appId": @"ignored-app-id",
            @"adUnitId": @"ignored-ad-unit-id",
            @"testMode": @YES
        };
        
        DDNASmartAdAdMobInterstitialAdapter *adapter = [[DDNASmartAdAdMobInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                   waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.appId).to.equal(@"ca-app-pub-3940256099942544~1458002511");
        expect(adapter.adUnitId).to.equal(@"ca-app-pub-3940256099942544/4411468910");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
});

describe(@"AdMob rewarded adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"ADMOB",
            @"appId": @"test-app-id",
            @"adUnitId": @"test-ad-unit-id",
            @"eCPM": @150
        };
        
        DDNASmartAdAdMobRewardedAdapter *adapter = [[DDNASmartAdAdMobRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                   waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.appId).to.equal(@"test-app-id");
        expect(adapter.adUnitId).to.equal(@"test-ad-unit-id");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"ADMOB"
        };
        
        DDNASmartAdAdMobRewardedAdapter *adapter = [[DDNASmartAdAdMobRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                   waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"ADMOB",
            @"appId": @"ignored-app-id",
            @"adUnitId": @"ignored-ad-unit-id",
            @"testMode": @YES
        };
        
        DDNASmartAdAdMobRewardedAdapter *adapter = [[DDNASmartAdAdMobRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                   waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.appId).to.equal(@"ca-app-pub-3940256099942544~1458002511");
        expect(adapter.adUnitId).to.equal(@"ca-app-pub-3940256099942544/1712485313");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
});


SpecEnd
