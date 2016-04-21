//
//  DDNASmartAdServiceSpec.m
//  SmartAds
//
//  Created by David White on 23/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/SmartAds/DDNASmartAdService.h>
#import "DDNAFakeSmartAdFactory.h"
#import "DDNAFakeSmartAdAgent.h"
#import <DeltaDNA/NSString+DeltaDNA.h>
#import <DeltaDNA/NSDictionary+DeltaDNA.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAds.h>


SpecBegin(DDNASmartAdService)

describe(@"registering for ads", ^{
    
    __block DDNASmartAdService *adService;
    __block id<DDNASmartAdServiceDelegate> mockDelegate;
    __block DDNAFakeSmartAdFactory *fakeFactory;
    
    beforeEach(^{
        
        mockDelegate = mockProtocol(@protocol(DDNASmartAdServiceDelegate));
        adService = [[DDNASmartAdService alloc] init];
        adService.delegate = mockDelegate;
        
        fakeFactory = [[DDNAFakeSmartAdFactory alloc] init];
        adService.factory = fakeFactory;
        
        
    });
    
    
    it(@"retries with connection error", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler(nil, -1, [NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:nil]);
        
        [verifyCount(mockDelegate, never()) didFailToRegisterForInterstitialAdsWithReason:@"Engage returned: -1 The operation couldn’t be completed. (NSURLErrorDomain error -1009.)"];
        [verifyCount(mockDelegate, never()) didFailToRegisterForRewardedAdsWithReason:@"Engage returned: -1 The operation couldn’t be completed. (NSURLErrorDomain error -1009.)"];
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        
    });
    
    it(@"fails with engage non 200 response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler(@"Unknown decision point", 400, nil);
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"Engage returned: 400 Unknown decision point"];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"Engage returned: 400 Unknown decision point"];
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        
    });
    
    it(@"fails with empty engage response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler(@"{}", 200, nil);
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"Invalid Engage response, missing 'parameters' key."];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"Invalid Engage response, missing 'parameters' key."];
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        
    });
    
    it(@"fails when 'asShowSession' is missing", ^{
        
        NSDictionary *response = @{
            @"parameters": @{
                
            }
        };
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"Ads disabled for this session."];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"Ads disabled for this session."];
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
    });
    
    it(@"fails when 'adShowSession' is false", ^{
        
        NSDictionary *response = @{
            @"parameters": @{
                @"adShowSession": @NO
            }
        };
        
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"Ads disabled for this session."];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"Ads disabled for this session."];
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        
    });
    
    it(@"fails when missing 'adProviders' key", ^{
        
        NSDictionary *response = @{
            @"parameters": @{
                @"adShowSession": @YES
            }
        };
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"No interstitial ad providers defined"];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"No rewarded ad providers defined"];
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        
    });
    
    it(@"fails when no adapters are built", ^{
        
        NSDictionary *response = @{
            @"parameters": @{
                @"adShowSession": @YES,
                @"adProviders": @[@"UNKNOW"],
                @"adRewardedProviders": @[@"UNKNOWN"]
            }
        };
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *responseJSON = [NSString stringWithContentsOfDictionary:response];
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:[NSString stringWithFormat:@"Failed to build interstitial waterfall from engage response %@", responseJSON]];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:[NSString stringWithFormat:@"Failed to build rewarded waterfall from engage response %@", responseJSON]];
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        
    });
    
    it(@"handles successful engage response", ^{
        
        NSDictionary *response = @{
            @"parameters": @{
                @"adShowSession": @YES,
                @"adProviders": @[
                    @{
                        @"adProvider": @"ADMOB",
                        @"adUnitId": @"test-ad-unit-id",
                        @"eCPM": @100
                    },
                    @{
                        @"adProvider": @"AMAZON",
                        @"appKey": @"test-app-key",
                        @"eCPM": @200
                    }
                ]
            }
        };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] init];
        
        [adService beginSessionWithDecisionPoint:@"advertising"];

        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        
    });
    
});

describe(@"interstitial ads", ^{
   
    __block DDNASmartAdService *adService;
    __block id<DDNASmartAdServiceDelegate> mockDelegate;
    __block DDNAFakeSmartAdFactory *fakeFactory;
    __block UIViewController *mockViewController;
    __block NSDictionary *response;
    
    beforeEach(^{
        
        mockDelegate = mockProtocol(@protocol(DDNASmartAdServiceDelegate));
        adService = [[DDNASmartAdService alloc] init];
        adService.delegate = mockDelegate;
        
        fakeFactory = [[DDNAFakeSmartAdFactory alloc] init];
        adService.factory = fakeFactory;
        
        response = @{
            @"parameters": @{
                @"adShowSession": @YES,
                @"adProviders": @[
                    @{
                        @"adProvider": @"ADMOB",
                        @"adUnitId": @"test-ad-unit-id",
                        @"eCPM": @100
                    },
                    @{
                        @"adProvider": @"AMAZON",
                        @"appKey": @"test-app-key",
                        @"eCPM": @200
                    }
                ],
                @"adMaxPerSession": @3
            }
        };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] init];
        
        mockViewController = mock([UIViewController class]);
    });
    
    it(@"shows an interstitial ad without DecisionPoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verifyCount(mockDelegate, times(1)) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController];
        
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verifyCount(mockDelegate, times(1)) didOpenInterstitialAd];
        
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isShowingInterstitialAd]).to.beFalsy();
        [verify(mockDelegate) didCloseInterstitialAd];
        
        NSDictionary *adClosedParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adClicked": [NSNumber numberWithBool:NO],
            @"adLeftApplication": [NSNumber numberWithBool:NO],
            @"adEcpm": [NSNumber numberWithLong:100],
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adStatus": @"Success"
        };
        
        HCArgumentCaptor *adClosedArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adClosed" parameters:(id)adClosedArg];
        expect([adClosedArg.value isEqualToDictionary:adClosedParams]).to.beTruthy();
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        [verifyCount(mockDelegate, times(2)) recordEventWithName:@"adRequest" parameters:anything()];

        
    });
    
    it(@"shows an interstitial ad with an DecisionPoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint" flavour:@"advertising" parameters:nil completionHandler:[captor capture]];
        
        completionHandler = [captor value];
        completionHandler(@"{}", 200, nil);
        
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenInterstitialAd];
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };

        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isShowingInterstitialAd]).to.beFalsy();
        [verify(mockDelegate) didCloseInterstitialAd];
        
        NSDictionary *adClosedParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adClicked": @NO,
            @"adLeftApplication": @NO,
            @"adEcpm": @100,
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adStatus": @"Success"
        };
        
        HCArgumentCaptor *adClosedArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adClosed" parameters:(id)adClosedArg];
        expect([adClosedArg.value isEqualToDictionary:adClosedParams]).to.beTruthy();
        
    });
    
    it(@"does not show an interstitial ad when adShowPoint is false", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint" flavour:@"advertising" parameters:nil completionHandler:[captor capture]];
        
        completionHandler = [captor value];
        completionHandler(@"{\"parameters\":{\"adShowPoint\":false}}", 200, nil);
        
        expect([adService isShowingInterstitialAd]).to.beFalsy();
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didFailToOpenInterstitialAdWithReason:@"Engage disallowed the ad"];
        
    });
    
    it(@"shows an interstitial ad when engage returns empty response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint" flavour:@"advertising" parameters:nil completionHandler:[captor capture]];
        
        completionHandler = [captor value];
        completionHandler(@"{}", 200, nil);
        
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenInterstitialAd];
        
    });
    
    it(@"shows an interstitial ad when engage returns invalid json", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint" flavour:@"advertising" parameters:nil completionHandler:[captor capture]];
        
        completionHandler = [captor value];
        completionHandler(@"{\"parameters:{\"adShowPoint\":false}}", 200, nil);
        
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenInterstitialAd];
        
    });
    
    it(@"shows an interstitial ad when engage connection fails", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint" flavour:@"advertising" parameters:nil completionHandler:[captor capture]];
        
        completionHandler = [captor value];
        completionHandler(@"", -1, [NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:nil]);
        
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenInterstitialAd];
        
    });
    
    it(@"stops showing ads once max ads per session is reached", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        // session limit should be reached
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        [verifyCount(mockDelegate, times(3)) didOpenInterstitialAd];

    });
    
});

describe(@"rewarded ads", ^{
    
    __block DDNASmartAdService *adService;
    __block id<DDNASmartAdServiceDelegate> mockDelegate;
    __block DDNAFakeSmartAdFactory *fakeFactory;
    __block UIViewController *mockViewController;
    __block NSDictionary *response;
    
    beforeEach(^{
        
        mockDelegate = mockProtocol(@protocol(DDNASmartAdServiceDelegate));
        adService = [[DDNASmartAdService alloc] init];
        adService.delegate = mockDelegate;
        
        fakeFactory = [[DDNAFakeSmartAdFactory alloc] init];
        adService.factory = fakeFactory;
        
        response = @{
            @"parameters": @{
                @"adShowSession": @YES,
                @"adRewardedProviders": @[
                    @{
                        @"adProvider": @"ADMOB",
                        @"adUnitId": @"test-ad-unit-id",
                        @"eCPM": @100
                    },
                    @{
                        @"adProvider": @"AMAZON",
                        @"appKey": @"test-app-key",
                        @"eCPM": @200
                    }
                ],
                @"adMaxPerSession": @3
            }
        };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] init];
        
        mockViewController = mock([UIViewController class]);
    });
    
    it(@"shows a rewarded ad without DecisionPoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verifyCount(mockDelegate, times(1)) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController];
        
        expect([adService isShowingRewardedAd]).to.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verifyCount(mockDelegate, times(1)) didOpenRewardedAd];
        
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isShowingRewardedAd]).to.beFalsy();
        [verify(mockDelegate) didCloseRewardedAdWithReward:YES];
        
        NSDictionary *adClosedParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adClicked": [NSNumber numberWithBool:NO],
            @"adLeftApplication": [NSNumber numberWithBool:NO],
            @"adEcpm": [NSNumber numberWithLong:100],
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adStatus": @"Success"
        };
        
        HCArgumentCaptor *adClosedArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adClosed" parameters:(id)adClosedArg];
        expect([adClosedArg.value isEqualToDictionary:adClosedParams]).to.beTruthy();
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        [verifyCount(mockDelegate, times(2)) recordEventWithName:@"adRequest" parameters:anything()];
        
        
    });
    
    it(@"shows a rewarded ad with an DecisionPoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint" flavour:@"advertising" parameters:nil completionHandler:[captor capture]];
        
        completionHandler = [captor value];
        completionHandler(@"{\"parameters\":{}}", 200, nil);
        
        expect([adService isShowingRewardedAd]).to.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenRewardedAd];
        
        
        // TODO: Bit fragile testing the parameters coming back since the key order changes
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };

        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isShowingRewardedAd]).to.beFalsy();
        [verify(mockDelegate) didCloseRewardedAdWithReward:YES];
        
        NSDictionary *adClosedParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adClicked": @NO,
            @"adLeftApplication": @NO,
            @"adEcpm": @100,
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adStatus": @"Success"
        };
        
        HCArgumentCaptor *adClosedArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adClosed" parameters:(id)adClosedArg];
        expect([adClosedArg.value isEqualToDictionary:adClosedParams]).to.beTruthy();
        
    });
    
    it(@"shows a rewarded ad with an DecisionPoint that wasn't rewarded", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint" flavour:@"advertising" parameters:nil completionHandler:[captor capture]];
        
        completionHandler = [captor value];
        completionHandler(@"{\"parameters\":{}}", 200, nil);
        
        expect([adService isShowingRewardedAd]).to.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenRewardedAd];
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAdWithReward:NO];
        
        expect([adService isShowingRewardedAd]).to.beFalsy();
        [verify(mockDelegate) didCloseRewardedAdWithReward:NO];
        
        NSDictionary *adClosedParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adClicked": @NO,
            @"adLeftApplication": @NO,
            @"adEcpm": @100,
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adStatus": @"Success"
        };
        
        HCArgumentCaptor *adClosedArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adClosed" parameters:(id)adClosedArg];
        expect([adClosedArg.value isEqualToDictionary:adClosedParams]).to.beTruthy();
        
    });
    
    
    it(@"does not show a rewarded ad when adShowPoint is false", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint" flavour:@"advertising" parameters:nil completionHandler:[captor capture]];
        
        completionHandler = [captor value];
        completionHandler(@"{\"parameters\":{\"adShowPoint\":false}}", 200, nil);
        
        expect([adService isShowingRewardedAd]).to.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didFailToOpenRewardedAdWithReason:@"Engage disallowed the ad"];
        
    });
    
    it(@"shows a rewarded ad when engage returns empty response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint" flavour:@"advertising" parameters:nil completionHandler:[captor capture]];
        
        completionHandler = [captor value];
        completionHandler(@"{}", 200, nil);
        
        expect([adService isShowingRewardedAd]).to.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenRewardedAd];
        
    });
    
    it(@"shows a rewarded ad when engage returns invalid json", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint" flavour:@"advertising" parameters:nil completionHandler:[captor capture]];
        
        completionHandler = [captor value];
        completionHandler(@"{\"parameters\":{\"adShowPoint\":false}", 200, nil);
        
        expect([adService isShowingRewardedAd]).to.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenRewardedAd];
        
    });
    
    it(@"shows a rewarded ad when engage connection fails", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint" flavour:@"advertising" parameters:nil completionHandler:[captor capture]];
        
        completionHandler = [captor value];
        completionHandler(@"", -1, [NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:nil]);
        
        expect([adService isShowingRewardedAd]).to.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenRewardedAd];
        
    });

});

describe(@"respects minimum ad interval", ^{
    
    __block DDNASmartAdService *adService;
    __block id<DDNASmartAdServiceDelegate> mockDelegate;
    __block DDNAFakeSmartAdFactory *fakeFactory;
    __block UIViewController *mockViewController;
    __block NSDictionary *response;
    
    beforeEach(^{
        
        mockDelegate = mockProtocol(@protocol(DDNASmartAdServiceDelegate));
        adService = [[DDNASmartAdService alloc] init];
        adService.delegate = mockDelegate;
        
        fakeFactory = [[DDNAFakeSmartAdFactory alloc] init];
        adService.factory = fakeFactory;
        
        response = @{
            @"parameters": @{
                @"adShowSession": @YES,
                @"adProviders": @[
                    @{
                        @"adProvider": @"ADMOB",
                        @"adUnitId": @"test-ad-unit-id",
                        @"eCPM": @100
                    },
                    @{
                        @"adProvider": @"AMAZON",
                        @"appKey": @"test-app-key",
                        @"eCPM": @200
                    }
                ],
                @"adMaxPerSession": @3,
                @"adMinimumInterval": @200
            }
        };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] init];
        
        mockViewController = mock([UIViewController class]);
    });

    
    it(@"doesn't show an ad before the minimum interval", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        // too soon so fail
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beFalsy();
        [verifyCount(mockDelegate, times(1)) didFailToOpenInterstitialAdWithReason:@"Too soon"];

    });
    
    it(@"shows an ad after the minimum interval", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];

        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        
        [NSThread sleepForTimeInterval:0.2f];
        
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [verifyCount(mockDelegate, times(2)) didOpenInterstitialAd];
        
    });
    
});

describe(@"respects minimum ad interval", ^{
    
    __block DDNASmartAdService *adService;
    __block id<DDNASmartAdServiceDelegate> mockDelegate;
    __block DDNAFakeSmartAdFactory *fakeFactory;
    __block UIViewController *mockViewController;
    __block NSDictionary *response;
    
    beforeEach(^{
        
        mockDelegate = mockProtocol(@protocol(DDNASmartAdServiceDelegate));
        adService = [[DDNASmartAdService alloc] init];
        adService.delegate = mockDelegate;
        
        fakeFactory = [[DDNAFakeSmartAdFactory alloc] init];
        adService.factory = fakeFactory;
        
        response = @{
            @"parameters": @{
                @"adShowSession": @YES,
                @"adProviders": @[
                    @{
                        @"adProvider": @"ADMOB",
                        @"adUnitId": @"test-ad-unit-id",
                        @"eCPM": @100
                    },
                    @{
                        @"adProvider": @"AMAZON",
                        @"appKey": @"test-app-key",
                        @"eCPM": @200
                    }
                ],
                @"adMaxPerSession": @3,
                @"adMinimumInterval": @0,
                @"adRecordAdRequests": @NO
            }
        };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] init];
        
        mockViewController = mock([UIViewController class]);
    });
    
    
    it(@"doesn't post adRequest when disabled", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising" flavour:@"internal" parameters:nil completionHandler:[captor capture]];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = [captor value];
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        [verifyCount(mockDelegate, never()) recordEventWithName:@"adRequest" parameters:anything()];
        
    });
    
});

SpecEnd