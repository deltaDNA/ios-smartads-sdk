//
//  DDNASmartAdUnityAdsAdapterSpec.m
//  DeltaDNA SmartAds Tests
//
//  Created by David White on 01/12/2015.
//
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/Networks/UnityAds/DDNASmartAdUnityAdsAdapter.h>

// The UnityAds library looks for this symbol to do some jailbreak testing.
// But main isn't defined for unity test builds!
int main(int argc, char *argv[])
{
    return 0;
}

SpecBegin(DDNASmartAdUnityAdsAdapter)

describe(@"UnityAds adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"UNITY",
            @"gameId": @"test-game-id",
            @"zoneId": @"test-zone-id",
            @"eCPM": @150
        };
        
        DDNASmartAdUnityAdsAdapter *adapter = [[DDNASmartAdUnityAdsAdapter alloc] initWithConfiguration:configuration
                                                                                         waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.gameId).to.equal(@"test-game-id");
        expect(adapter.zoneId).to.equal(@"test-zone-id");
        expect(adapter.testMode).to.beFalsy();
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"UNITY"
        };
        
        DDNASmartAdUnityAdsAdapter *adapter = [[DDNASmartAdUnityAdsAdapter alloc] initWithConfiguration:configuration
                                                                                         waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"UNITY",
            @"gameId": @"test-game-id",
            @"zoneId": @"test-zone-id",
            @"testMode": @YES
        };
        
        DDNASmartAdUnityAdsAdapter *adapter = [[DDNASmartAdUnityAdsAdapter alloc] initWithConfiguration:configuration
                                                                                         waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.gameId).to.equal(@"test-game-id");
        expect(adapter.zoneId).to.equal(@"test-zone-id");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
});

SpecEnd
