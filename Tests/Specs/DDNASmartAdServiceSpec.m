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
#import "DDNAFakeEngageService.h"
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
    
    it(@"fails with error engage response", ^{
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:nil statusCode:-1 error:[NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:nil]];
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"Engage returned: The operation couldn’t be completed. (NSURLErrorDomain error -1009.)"];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"Engage returned: The operation couldn’t be completed. (NSURLErrorDomain error -1009.)"];
        
    });
    
    it(@"fails with empty engage response", ^{
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:@"{}" statusCode:200 error:nil];
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"Invalid Engage response, missing 'parameters' key."];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"Invalid Engage response, missing 'parameters' key."];
        
    });
    
    it(@"fails when 'asShowSession' is missing", ^{
        
        NSDictionary *response = @{
            @"parameters": @{
                
            }
        };
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:[NSString stringWithContentsOfDictionary:response]
                                                                             statusCode:200
                                                                                  error:nil];
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"Ads disabled for this session."];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"Ads disabled for this session."];
    });
    
    it(@"fails when 'adShowSession' is false", ^{
        
        NSDictionary *response = @{
            @"parameters": @{
                @"adShowSession": @NO
            }
        };
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:[NSString stringWithContentsOfDictionary:response]
                                                                             statusCode:200
                                                                                  error:nil];
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"Ads disabled for this session."];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"Ads disabled for this session."];
        
    });
    
    it(@"fails when missing 'adProviders' key", ^{
        
        NSDictionary *response = @{
            @"parameters": @{
                @"adShowSession": @YES
            }
        };
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:[NSString stringWithContentsOfDictionary:response]
                                                                             statusCode:200
                                                                                  error:nil];
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"No interstitial ad providers defined"];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"No rewarded ad providers defined"];
        
    });
    
    it(@"fails when no adapters are built", ^{
        
        NSDictionary *response = @{
            @"parameters": @{
                @"adShowSession": @YES,
                @"adProviders": @[@"UNKNOW"],
                @"adRewardedProviders": @[@"UNKNOWN"]
            }
        };
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:[NSString stringWithContentsOfDictionary:response]
                                                                             statusCode:200
                                                                                  error:nil];
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        NSString *responseJSON = [NSString stringWithContentsOfDictionary:response];
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:[NSString stringWithFormat:@"Failed to build interstitial waterfall from engage response %@", responseJSON]];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:[NSString stringWithFormat:@"Failed to build rewarded waterfall from engage response %@", responseJSON]];
        
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
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:[NSString stringWithContentsOfDictionary:response]
                                                                             statusCode:200
                                                                                  error:nil];
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
    });
    
});

describe(@"interstitial ads", ^{
   
    __block DDNASmartAdService *adService;
    __block id<DDNASmartAdServiceDelegate> mockDelegate;
    __block DDNAFakeSmartAdFactory *fakeFactory;
    __block UIViewController *mockViewController;
    
    beforeEach(^{
        
        mockDelegate = mockProtocol(@protocol(DDNASmartAdServiceDelegate));
        adService = [[DDNASmartAdService alloc] init];
        adService.delegate = mockDelegate;
        
        fakeFactory = [[DDNAFakeSmartAdFactory alloc] init];
        adService.factory = fakeFactory;
        
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
                ],
                @"adMaxPerSession": @3
            }
        };
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:[NSString stringWithContentsOfDictionary:response]
                                                                             statusCode:200
                                                                                  error:nil];
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] init];
        
        mockViewController = mock([UIViewController class]);
    });
    
    it(@"shows an interstitial ad without adpoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];

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
        
        HCArgumentCaptor *adShowJSONArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" andParamJson:(id)adShowJSONArg];
        NSDictionary *jsonDict = [NSDictionary dictionaryWithJSONString:adShowJSONArg.value];
        
        expect([jsonDict isEqualToDictionary:adShowParams]).to.beTruthy();
        
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
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        HCArgumentCaptor *adClosedJSONArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adClosed" andParamJson:(id)adClosedJSONArg];
        jsonDict = [NSDictionary dictionaryWithJSONString:adClosedJSONArg.value];
        
        // TODO: dictionaries don't equal although they contain same values.  Test is fragile.
        //expect([jsonDict isEqualToDictionary:adClosedParams]).to.beTruthy();
        
//        HCArgumentCaptor *adRequestJSONArg = [[HCArgumentCaptor alloc] init];
//        [verify(mockDelegate) recordEventWithName:@"adRequest" andParamJson:(id)adRequestJSONArg];
//        jsonDict = [NSDictionary dictionaryWithJSONString:adRequestJSONArg.allValues[0]];
//        
//        NSLog(@"adRequest: %@", jsonDict);
//        
//        jsonDict = [NSDictionary dictionaryWithJSONString:adRequestJSONArg.allValues[1]];
//        
//        NSLog(@"adRequest: %@", jsonDict);
        
        [verifyCount(mockDelegate, times(2)) recordEventWithName:@"adRequest" andParamJson:anything()];

        
    });
    
    it(@"shows an interstitial ad with an adpoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenInterstitialAd];
        
        
        // TODO: Bit fragile testing the parameters coming back since the key order changes
                NSDictionary *adShowParams = @{
                    @"adProvider": @"DUMMY",
                    @"adProviderVersion": @"1.0.0",
                    @"adType": @"INTERSTITIAL",
                    @"adStatus": @"Fulfilled",
                    @"adSdkVersion": [DDNASmartAds sdkVersion],
                    @"adPoint": @"testAdPoint"
                };
        //
        //        NSString *adShowParamsJSON = [NSString stringWithContentsOfDictionary:adShowParams];
        
        HCArgumentCaptor *adShowJSONArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" andParamJson:(id)adShowJSONArg];
        NSDictionary *jsonDict = [NSDictionary dictionaryWithJSONString:adShowJSONArg.value];
        
        expect([jsonDict isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isShowingInterstitialAd]).to.beFalsy();
        [verify(mockDelegate) didCloseInterstitialAd];
        
        //        NSDictionary *adClosedParams = @{
        //            @"adProvider": @"DUMMY",
        //            @"adProviderVersion": @"1.0.0",
        //            @"adType": @"INTERSTITIAL",
        //            @"adClicked": @NO,
        //            @"adLeftApplication": @NO,
        //            @"adEcpm": @100,
        //            @"adSdkVersion": @"1.0.0"
        //        };
        
        [verify(mockDelegate) recordEventWithName:@"adClosed" andParamJson:anything()];
        
    });
    
    it(@"does not show an interstitial ad when adShowPoint is false", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).response = [NSString stringWithContentsOfDictionary:@{
            @"parameters": @{
                @"adShowPoint": @NO
            }
        }];
        
        [adService showInterstitialAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingInterstitialAd]).to.beFalsy();
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didFailToOpenInterstitialAd];
        
    });
    
    it(@"shows an interstitial ad when engage returns empty response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).response = [NSString stringWithContentsOfDictionary:@{}];
        
        [adService showInterstitialAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenInterstitialAd];
        
    });
    
    it(@"shows an interstitial ad when engage returns invalid json", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).response = @"not valid json";
        
        [adService showInterstitialAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenInterstitialAd];
        
    });
    
    it(@"shows an interstitial ad when engage connection fails", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).response = @"";
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).statusCode = -1;
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).error = [NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:nil];
        
        [adService showInterstitialAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenInterstitialAd];
        
    });
    
    it(@"stops showing ads once max ads per session is reached", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
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
    
    beforeEach(^{
        
        mockDelegate = mockProtocol(@protocol(DDNASmartAdServiceDelegate));
        adService = [[DDNASmartAdService alloc] init];
        adService.delegate = mockDelegate;
        
        fakeFactory = [[DDNAFakeSmartAdFactory alloc] init];
        adService.factory = fakeFactory;
        
        NSDictionary *response = @{
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
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:[NSString stringWithContentsOfDictionary:response]
                                                                             statusCode:200
                                                                                  error:nil];
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] init];
        
        mockViewController = mock([UIViewController class]);
    });
    
    it(@"shows a rewarded ad without adpoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
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
        
        HCArgumentCaptor *adShowJSONArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" andParamJson:(id)adShowJSONArg];
        NSDictionary *jsonDict = [NSDictionary dictionaryWithJSONString:adShowJSONArg.value];
        
        expect([jsonDict isEqualToDictionary:adShowParams]).to.beTruthy();
        
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
                                         @"adSdkVersion": [DDNASmartAds sdkVersion]
                                         };
        
        HCArgumentCaptor *adClosedJSONArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adClosed" andParamJson:(id)adClosedJSONArg];
        jsonDict = [NSDictionary dictionaryWithJSONString:adClosedJSONArg.value];
        
        // TODO: dictionaries don't equal although they contain same values.  Test is fragile.
        //expect([jsonDict isEqualToDictionary:adClosedParams]).to.beTruthy();
        
        //        HCArgumentCaptor *adRequestJSONArg = [[HCArgumentCaptor alloc] init];
        //        [verify(mockDelegate) recordEventWithName:@"adRequest" andParamJson:(id)adRequestJSONArg];
        //        jsonDict = [NSDictionary dictionaryWithJSONString:adRequestJSONArg.allValues[0]];
        //
        //        NSLog(@"adRequest: %@", jsonDict);
        //
        //        jsonDict = [NSDictionary dictionaryWithJSONString:adRequestJSONArg.allValues[1]];
        //
        //        NSLog(@"adRequest: %@", jsonDict);
        
        [verifyCount(mockDelegate, times(2)) recordEventWithName:@"adRequest" andParamJson:anything()];
        
        
    });
    
    it(@"shows a rewarded ad with an adpoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
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
                                       @"adPoint": @"testAdPoint"
                                       };
        //
        //        NSString *adShowParamsJSON = [NSString stringWithContentsOfDictionary:adShowParams];
        
        HCArgumentCaptor *adShowJSONArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" andParamJson:(id)adShowJSONArg];
        NSDictionary *jsonDict = [NSDictionary dictionaryWithJSONString:adShowJSONArg.value];
        
        expect([jsonDict isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isShowingRewardedAd]).to.beFalsy();
        [verify(mockDelegate) didCloseRewardedAdWithReward:YES];
        
        //        NSDictionary *adClosedParams = @{
        //            @"adProvider": @"DUMMY",
        //            @"adProviderVersion": @"1.0.0",
        //            @"adType": @"INTERSTITIAL",
        //            @"adClicked": @NO,
        //            @"adLeftApplication": @NO,
        //            @"adEcpm": @100,
        //            @"adSdkVersion": @"1.0.0"
        //        };
        
        [verify(mockDelegate) recordEventWithName:@"adClosed" andParamJson:anything()];
        
    });
    
    it(@"shows a rewarded ad with an adpoint that wasn't rewarded", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
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
                                       @"adPoint": @"testAdPoint"
                                       };
        //
        //        NSString *adShowParamsJSON = [NSString stringWithContentsOfDictionary:adShowParams];
        
        HCArgumentCaptor *adShowJSONArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" andParamJson:(id)adShowJSONArg];
        NSDictionary *jsonDict = [NSDictionary dictionaryWithJSONString:adShowJSONArg.value];
        
        expect([jsonDict isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAdWithReward:NO];
        
        expect([adService isShowingRewardedAd]).to.beFalsy();
        [verify(mockDelegate) didCloseRewardedAdWithReward:NO];
        
        //        NSDictionary *adClosedParams = @{
        //            @"adProvider": @"DUMMY",
        //            @"adProviderVersion": @"1.0.0",
        //            @"adType": @"INTERSTITIAL",
        //            @"adClicked": @NO,
        //            @"adLeftApplication": @NO,
        //            @"adEcpm": @100,
        //            @"adSdkVersion": @"1.0.0"
        //        };
        
        [verify(mockDelegate) recordEventWithName:@"adClosed" andParamJson:anything()];
        
    });
    
    
    it(@"does not show a rewarded ad when adShowPoint is false", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).response = [NSString stringWithContentsOfDictionary:@{
                                                                                                                       @"parameters": @{
                                                                                                                               @"adShowPoint": @NO
                                                                                                                               }
                                                                                                                       }];
        
        [adService showRewardedAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingRewardedAd]).to.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didFailToOpenRewardedAd];
        
    });
    
    it(@"shows a rewarded ad when engage returns empty response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).response = [NSString stringWithContentsOfDictionary:@{}];
        
        [adService showRewardedAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingRewardedAd]).to.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenRewardedAd];
        
    });
    
    it(@"shows a rewarded ad when engage returns invalid json", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).response = @"not valid json";
        
        [adService showRewardedAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingRewardedAd]).to.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenRewardedAd];
        
    });
    
    it(@"shows a rewarded ad when engage connection fails", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).response = @"";
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).statusCode = -1;
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).error = [NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:nil];
        
        [adService showRewardedAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
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
    
    beforeEach(^{
        
        mockDelegate = mockProtocol(@protocol(DDNASmartAdServiceDelegate));
        adService = [[DDNASmartAdService alloc] init];
        adService.delegate = mockDelegate;
        
        fakeFactory = [[DDNAFakeSmartAdFactory alloc] init];
        adService.factory = fakeFactory;
        
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
                ],
                @"adMaxPerSession": @3,
                @"adMinimumInterval": @200
            }
        };
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:[NSString stringWithContentsOfDictionary:response]
                                                                             statusCode:200
                                                                                  error:nil];
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] init];
        
        mockViewController = mock([UIViewController class]);
    });

    
    it(@"doesn't show an ad before the minimum interval", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        // too soon so fail
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beFalsy();
        [verifyCount(mockDelegate, times(1)) didFailToOpenInterstitialAd];

    });
    
    it(@"shows an ad after the minimum interval", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];

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
    
    beforeEach(^{
        
        mockDelegate = mockProtocol(@protocol(DDNASmartAdServiceDelegate));
        adService = [[DDNASmartAdService alloc] init];
        adService.delegate = mockDelegate;
        
        fakeFactory = [[DDNAFakeSmartAdFactory alloc] init];
        adService.factory = fakeFactory;
        
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
                ],
                @"adMaxPerSession": @3,
                @"adMinimumInterval": @0,
                @"adRecordAdRequests": @NO
            }
        };
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:[NSString stringWithContentsOfDictionary:response]
                                                                             statusCode:200
                                                                                  error:nil];
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] init];
        
        mockViewController = mock([UIViewController class]);
    });
    
    
    it(@"doesn't post adRequest when disabled", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        [verifyCount(mockDelegate, never()) recordEventWithName:@"adRequest" andParamJson:anything()];
        
    });
    
});

SpecEnd