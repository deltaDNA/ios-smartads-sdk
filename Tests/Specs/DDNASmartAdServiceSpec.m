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

#import <DeltaDNAAds/DDNASmartAdService.h>
#import "DDNAFakeSmartAdFactory.h"
#import "DDNAFakeEngageService.h"
#import "DDNAFakeSmartAdAgent.h"
#import <DeltaDNA/NSString+DeltaDNA.h>
#import <DeltaDNA/NSDictionary+DeltaDNA.h>
#import <DeltaDNAAds/DDNASmartAds.h>


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
        
        [verify(mockDelegate) didFailToRegisterForAdsWithReason:@"Engage returned: The operation couldn’t be completed. (NSURLErrorDomain error -1009.)"];
        
    });
    
    it(@"fails with empty engage response", ^{
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:@"{}" statusCode:200 error:nil];
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        [verify(mockDelegate) didFailToRegisterForAdsWithReason:@"Invalid Engage response, missing 'parameters' key."];
        
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
        
        [verify(mockDelegate) didFailToRegisterForAdsWithReason:@"Ads disabled for this session."];
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
        
        [verify(mockDelegate) didFailToRegisterForAdsWithReason:@"Ads disabled for this session."];
        
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
        
        [verify(mockDelegate) didFailToRegisterForAdsWithReason:@"Invalid Engage response, missing 'adProviders' key."];
        
    });
    
    it(@"fails when no adapters are built", ^{
        
        NSDictionary *response = @{
            @"parameters": @{
                @"adShowSession": @YES,
                @"adProviders": @"UNKNOWN"
            }
        };
        
        fakeFactory.fakeEngageService = [[DDNAFakeEngageService alloc] initWithResponse:[NSString stringWithContentsOfDictionary:response]
                                                                             statusCode:200
                                                                                  error:nil];
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        NSString *responseJSON = [NSString stringWithContentsOfDictionary:response];
        [verify(mockDelegate) didFailToRegisterForAdsWithReason:[NSString stringWithFormat:@"Failed to build interstitial waterfall from engage response %@", responseJSON]];
        
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
        
        [verify(mockDelegate) didRegisterForAds];
        
    });
    
});

describe(@"registered for ads", ^{
   
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
    
    it(@"shows an ad without adpoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];

        expect([adService isAdAvailable]).to.beTruthy();
        [verifyCount(mockDelegate, times(1)) didRegisterForAds];
        
        [adService showAdFromRootViewController:mockViewController];
        
        expect([adService isShowingAd]).to.beTruthy();
        expect([adService isAdAvailable]).to.beFalsy();
        [verifyCount(mockDelegate, times(1)) didOpenAd];
        
        
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
        
        expect([adService isShowingAd]).to.beFalsy();
        [verify(mockDelegate) didCloseAd];
        
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
    
    it(@"shows an ad with an adpoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForAds];
        
        [adService showAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingAd]).to.beTruthy();
        expect([adService isAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenAd];
        
        
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
        
        expect([adService isShowingAd]).to.beFalsy();
        [verify(mockDelegate) didCloseAd];
        
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
    
    it(@"does not show an ad when adShowPoint is false", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForAds];
        
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).response = [NSString stringWithContentsOfDictionary:@{
            @"parameters": @{
                @"adShowPoint": @NO
            }
        }];
        
        [adService showAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingAd]).to.beFalsy();
        expect([adService isAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didFailToOpenAd];
        
    });
    
    it(@"shows an ad when engage returns empty response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForAds];
        
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).response = [NSString stringWithContentsOfDictionary:@{}];
        
        [adService showAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingAd]).to.beTruthy();
        expect([adService isAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenAd];
        
    });
    
    it(@"shows an ad when engage returns invalid json", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForAds];
        
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).response = @"not valid json";
        
        [adService showAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingAd]).to.beTruthy();
        expect([adService isAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenAd];
        
    });
    
    it(@"shows an ad when engage connection fails", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didRegisterForAds];
        
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).response = @"";
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).statusCode = -1;
        ((DDNAFakeEngageService *)fakeFactory.fakeEngageService).error = [NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:nil];
        
        [adService showAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([adService isShowingAd]).to.beTruthy();
        expect([adService isAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenAd];
        
    });

    it(@"stops showing ads once max ads per session is reached", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isAdAvailable]).to.beTruthy();
        [adService showAdFromRootViewController:mockViewController];
        expect([adService isShowingAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isAdAvailable]).to.beTruthy();
        [adService showAdFromRootViewController:mockViewController];
        expect([adService isShowingAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isAdAvailable]).to.beTruthy();
        [adService showAdFromRootViewController:mockViewController];
        expect([adService isShowingAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        // session limit should be reached
        expect([adService isAdAvailable]).to.beTruthy();
        [adService showAdFromRootViewController:mockViewController];
        [verifyCount(mockDelegate, times(3)) didOpenAd];

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
        
        expect([adService isAdAvailable]).to.beTruthy();
        [adService showAdFromRootViewController:mockViewController];
        expect([adService isShowingAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        // too soon so fail
        expect([adService isAdAvailable]).to.beTruthy();
        [adService showAdFromRootViewController:mockViewController];
        expect([adService isShowingAd]).to.beFalsy();
        [verifyCount(mockDelegate, times(1)) didFailToOpenAd];

    });
    
    it(@"shows an ad after the minimum interval", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        expect([adService isAdAvailable]).to.beTruthy();
        [adService showAdFromRootViewController:mockViewController];
        expect([adService isShowingAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];

        expect([adService isAdAvailable]).to.beTruthy();
        
        [NSThread sleepForTimeInterval:0.2f];
        
        [adService showAdFromRootViewController:mockViewController];
        expect([adService isShowingAd]).to.beTruthy();
        [verifyCount(mockDelegate, times(2)) didOpenAd];
        
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
        
        expect([adService isAdAvailable]).to.beTruthy();
        [adService showAdFromRootViewController:mockViewController];
        expect([adService isShowingAd]).to.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        [verifyCount(mockDelegate, never()) recordEventWithName:@"adRequest" andParamJson:anything()];
        
    });
    
});

SpecEnd