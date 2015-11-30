//
//  DDNASmartAdChartboostAdapterSpec.m
//  DeltaDNA SmartAds Tests
//
//  Created by David White on 30/11/2015.
//
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
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
        
        DDNASmartAdChartboostInterstitialAdapter *adapter = [[DDNASmartAdChartboostInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                                                     waterfallIndex:1];
        
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
        
        DDNASmartAdChartboostInterstitialAdapter *adapter = [[DDNASmartAdChartboostInterstitialAdapter alloc] initWithConfiguration:configuration
                                                                                                                     waterfallIndex:1];
        
        expect(adapter).to.beNil();
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
        
        DDNASmartAdChartboostRewardedAdapter *adapter = [[DDNASmartAdChartboostRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                             waterfallIndex:1];
        
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
        
        DDNASmartAdChartboostRewardedAdapter *adapter = [[DDNASmartAdChartboostRewardedAdapter alloc] initWithConfiguration:configuration
                                                                                                             waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
});


SpecEnd