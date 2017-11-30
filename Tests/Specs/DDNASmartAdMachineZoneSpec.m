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
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/Networks/MachineZone/DDNASmartAdMachineZoneInterstitialAdapter.h>
#import <DeltaDNAAds/Networks/MachineZone/DDNASmartAdMachineZoneRewardedAdapter.h>


SpecBegin(DDNASmartAdMachineZoneAdapter)

describe(@"MachineZone interstitial adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MACHINEZONE",
            @"adUnitId": @"test-ad-unit-id",
            @"eCPM": @150
        };
        
        DDNASmartAdMachineZoneInterstitialAdapter *adapter = [[DDNASmartAdMachineZoneInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                                                       waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.adUnitId).to.equal(@"test-ad-unit-id");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MACHINEZONE"
        };
        
        DDNASmartAdMachineZoneInterstitialAdapter *adapter = [[DDNASmartAdMachineZoneInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                                                       waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MACHINEZONE",
            @"adUnitId": @"ignored-ad-unit-id",
            @"testMode": @YES
        };
        
        DDNASmartAdMachineZoneInterstitialAdapter *adapter = [[DDNASmartAdMachineZoneInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                                                       waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.adUnitId).to.equal(@"ignored-ad-unit-id");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
});

describe(@"MachineZone rewarded adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MACHINEZONE",
            @"adUnitId": @"test-ad-unit-id",
            @"eCPM": @150
        };
        
        DDNASmartAdMachineZoneRewardedAdapter *adapter = [[DDNASmartAdMachineZoneRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                               waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.adUnitId).to.equal(@"test-ad-unit-id");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MACHINEZONE"
        };
        
        DDNASmartAdMachineZoneRewardedAdapter *adapter = [[DDNASmartAdMachineZoneRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                               waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"MACHINEZONE",
            @"adUnitId": @"ignored-ad-unit-id",
            @"testMode": @YES
        };
        
        DDNASmartAdMachineZoneRewardedAdapter *adapter = [[DDNASmartAdMachineZoneRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                               waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.adUnitId).to.equal(@"ignored-ad-unit-id");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
});

SpecEnd

