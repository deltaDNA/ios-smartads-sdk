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
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler(nil, -1, [NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:nil]);
        
        [verifyCount(mockDelegate, never()) didFailToRegisterForInterstitialAdsWithReason:@"Engage returned: -1 The operation couldn’t be completed. (NSURLErrorDomain error -1009.)"];
        [verifyCount(mockDelegate, never()) didFailToRegisterForRewardedAdsWithReason:@"Engage returned: -1 The operation couldn’t be completed. (NSURLErrorDomain error -1009.)"];
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        
    });
    
    it(@"no ad available with engage non 200 response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler(@"Unknown decision point", 400, nil);
        
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        
    });
    
    it(@"no ad available with empty engage response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler(@"{}", 200, nil);
        
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        
    });
    
    it(@"fails when 'asShowSession' is missing", ^{
        
        NSDictionary *response = @{
            @"parameters": @{
                
            }
        };
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
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
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
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
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
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
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
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

        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [verify(mockDelegate) didRegisterForInterstitialAds];

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        
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
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] initWithAdLimit:@3];
        
        mockViewController = mock([UIViewController class]);
    });
    
    it(@"shows an interstitial ad without DecisionPoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [verifyCount(mockDelegate, times(1)) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController];
        
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verifyCount(mockDelegate, times(1)) didOpenInterstitialAd];
        
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isShowingInterstitialAd]).will.beFalsy();
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

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        
        [verifyCount(mockDelegate, times(2)) recordEventWithName:@"adRequest" parameters:anything()];

        
    });
    
    it(@"shows an interstitial ad with an DecisionPoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint"
                                                         flavour:@"advertising"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        completionHandler = argument.value;
        completionHandler(@"{}", 200, nil);
        
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenInterstitialAd];

        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isShowingInterstitialAd]).will.beFalsy();
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
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint"
                                                         flavour:@"advertising"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        completionHandler = argument.value;
        completionHandler(@"{\"parameters\":{\"adShowPoint\":false}}", 200, nil);
        
        expect([adService isShowingInterstitialAd]).will.beFalsy();
        expect([adService isInterstitialAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didFailToOpenInterstitialAdWithReason:@"Engage disallowed the ad"];
        
    });
    
    it(@"shows an interstitial ad when engage returns empty response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint"
                                                         flavour:@"advertising"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        completionHandler = argument.value;
        completionHandler(@"{}", 200, nil);
        
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenInterstitialAd];
        
    });
    
    it(@"shows an interstitial ad when engage returns invalid json", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint"
                                                         flavour:@"advertising"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        completionHandler = argument.value;
        completionHandler(@"{\"parameters:{\"adShowPoint\":false}}", 200, nil);
        
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenInterstitialAd];
        
    });
    
    it(@"shows an interstitial ad when engage connection fails", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint"
                                                         flavour:@"advertising"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        completionHandler = argument.value;
        completionHandler(@"", -1, [NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:nil]);
        
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        expect([adService isInterstitialAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenInterstitialAd];
        
    });
    
    it(@"stops showing ads once max ads per session is reached", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];

        // session limit should be reached
        expect([adService isInterstitialAdAvailable]).will.beFalsy();
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
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] initWithAdLimit:@3];
        
        mockViewController = mock([UIViewController class]);
    });
    
    it(@"shows a rewarded ad without DecisionPoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isRewardedAdAvailable]).will.beTruthy();
        [verifyCount(mockDelegate, times(1)) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController];
        
        expect([adService isShowingRewardedAd]).will.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verifyCount(mockDelegate, times(1)) didOpenRewardedAd];
        
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isShowingRewardedAd]).will.beFalsy();
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

        expect([adService isRewardedAdAvailable]).will.beTruthy();
        
        [verifyCount(mockDelegate, times(2)) recordEventWithName:@"adRequest" parameters:anything()];
        
        
    });
    
    it(@"shows a rewarded ad with an DecisionPoint", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isRewardedAdAvailable]).will.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint"
                                                         flavour:@"advertising"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        completionHandler = argument.value;
        completionHandler(@"{\"parameters\":{}}", 200, nil);
        
        expect([adService isShowingRewardedAd]).will.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenRewardedAd];
        
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isShowingRewardedAd]).will.beFalsy();
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
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isRewardedAdAvailable]).will.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint"
                                                         flavour:@"advertising"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        completionHandler = argument.value;
        completionHandler(@"{\"parameters\":{}}", 200, nil);
        
        expect([adService isShowingRewardedAd]).will.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenRewardedAd];
        
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAdWithReward:NO];
        
        expect([adService isShowingRewardedAd]).will.beFalsy();
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
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isRewardedAdAvailable]).will.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint"
                                                         flavour:@"advertising"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        completionHandler = argument.value;
        completionHandler(@"{\"parameters\":{\"adShowPoint\":false}}", 200, nil);
        
        expect([adService isShowingRewardedAd]).will.beFalsy();
        expect([adService isRewardedAdAvailable]).to.beTruthy();
        [verify(mockDelegate) didFailToOpenRewardedAdWithReason:@"Engage disallowed the ad"];
        
    });
    
    it(@"shows a rewarded ad when engage returns empty response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isRewardedAdAvailable]).will.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint"
                                                         flavour:@"advertising"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        completionHandler = argument.value;
        completionHandler(@"{}", 200, nil);
        
        expect([adService isShowingRewardedAd]).will.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenRewardedAd];
        
    });
    
    it(@"shows a rewarded ad when engage returns invalid json", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isRewardedAdAvailable]).will.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint"
                                                         flavour:@"advertising"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        completionHandler = argument.value;
        completionHandler(@"{\"parameters\":{\"adShowPoint\":false}", 200, nil);
        
        expect([adService isShowingRewardedAd]).will.beTruthy();
        expect([adService isRewardedAdAvailable]).to.beFalsy();
        [verify(mockDelegate) didOpenRewardedAd];
        
    });
    
    it(@"shows a rewarded ad when engage connection fails", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isRewardedAdAvailable]).will.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"testDecisionPoint"
                                                         flavour:@"advertising"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        completionHandler = argument.value;
        completionHandler(@"", -1, [NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:nil]);
        
        expect([adService isShowingRewardedAd]).will.beTruthy();
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
                @"adMinimumInterval": @2
            }
        };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] initWithAdLimit:@3];
        
        mockViewController = mock([UIViewController class]);
    });

    
    it(@"doesn't show an ad before the minimum interval", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];

        // too soon so fail
        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).will.beFalsy();
        [verifyCount(mockDelegate, times(1)) didFailToOpenInterstitialAdWithReason:@"Too soon"];

    });
    
    it(@"shows an ad after the minimum interval", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        
        expect([adService isInterstitialAdAllowed]).to.beFalsy();
        
        expect([adService isInterstitialAdAllowed]).after(2).to.beTruthy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [verifyCount(mockDelegate, times(2)) didOpenInterstitialAd];
        
    });
    
});

describe(@"respects adRequest flag", ^{
    
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
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] initWithAdLimit:@3];
        
        mockViewController = mock([UIViewController class]);
    });
    
    
    it(@"doesn't post adRequest when disabled", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        [verifyCount(mockDelegate, never()) recordEventWithName:@"adRequest" parameters:anything()];
        
    });
    
});

describe(@"allowed to show interstitial", ^{
    
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
                @"adMaxPerSession": @2,
                @"adMinimumInterval": @0,
                @"adRecordAdRequests": @NO
            }
        };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] initWithAdLimit:@2];
        
        mockViewController = mock([UIViewController class]);
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
    });
    
    it(@"doesn't allow interstitial if engagement disables", ^{
        
        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        
        expect([adService isInterstitialAdAllowedForDecisionPoint:@"testDecisionPoint" engagementParameters:@{@"adShowPoint": @NO}]).to.beFalsy();
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"adShowPoint was false",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
    });
    
    it(@"doesn't allow interstitial if shown more than max for session", ^{
        
        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        
        expect([adService isInterstitialAdAllowed]).to.beTruthy();
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        
        expect([adService isInterstitialAdAllowed]).to.beTruthy();
        
        adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isInterstitialAdAvailable]).will.beFalsy();
        
        expect([adService isInterstitialAdAllowed]).to.beFalsy();
        
        adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"Session limit reached",
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
    });
});

describe(@"allowed to show interstitial minimal time", ^{
    
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
                             @"adMaxPerSession": @2,
                             @"adMinimumInterval": @2,
                             @"adRecordAdRequests": @NO
                             }
                     };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] initWithAdLimit:@2];
        
        mockViewController = mock([UIViewController class]);
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
    });
    
    it(@"doesn't allow interstitial if shown quicker than minimum time", ^{
        
        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        
        expect([adService isInterstitialAdAllowed]).to.beTruthy();
        
        NSDictionary *adShowParams = @{
                                       @"adProvider": @"DUMMY",
                                       @"adProviderVersion": @"1.0.0",
                                       @"adType": @"INTERSTITIAL",
                                       @"adStatus": @"Fulfilled",
                                       @"adSdkVersion": [DDNASmartAds sdkVersion]
                                       };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isInterstitialAdAllowed]).after(1.5).to.beFalsy();
        
        adShowParams = @{
                         @"adProvider": @"DUMMY",
                         @"adProviderVersion": @"1.0.0",
                         @"adType": @"INTERSTITIAL",
                         @"adStatus": @"adMinimumInterval not elapsed",
                         @"adSdkVersion": [DDNASmartAds sdkVersion]
                         };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        expect([adService isInterstitialAdAvailable]).will.beTruthy();
        
        expect([adService isInterstitialAdAllowed]).to.beFalsy();
                
        expect([adService isInterstitialAdAllowed]).after(2).to.beTruthy();
        
        adShowParams = @{
                         @"adProvider": @"DUMMY",
                         @"adProviderVersion": @"1.0.0",
                         @"adType": @"INTERSTITIAL",
                         @"adStatus": @"Fulfilled",
                         @"adSdkVersion": [DDNASmartAds sdkVersion]
                         };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, atLeastOnce()) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
    });
});


describe(@"allowed to show rewarded", ^{
    
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
                @"adMaxPerSession": @2,
                @"adMinimumInterval": @0,
                @"adRecordAdRequests": @NO
            }
        };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] initWithAdLimit:@2];
        
        mockViewController = mock([UIViewController class]);
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
    });

    
    it(@"doesn't allow rewarded if engagement disables", ^{
        
        expect([adService isRewardedAdAvailable]).will.beTruthy();
        
        expect([adService isRewardedAdAllowedForDecisionPoint:@"testDecisionPoint" engagementParameters:@{@"adShowPoint": @NO}]).to.beFalsy();
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"adShowPoint was false",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        NSLog(@"%@", adShowArg.value);
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
    });
    
    it(@"doesn't allow rewarded if shown more than max for session", ^{
        
        expect([adService isRewardedAdAvailable]).will.beTruthy();
        
        expect([adService isRewardedAdAllowed]).to.beTruthy();
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [adService showRewardedAdFromRootViewController:mockViewController];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isRewardedAdAvailable]).will.beTruthy();
        
        expect([adService isRewardedAdAllowed]).to.beTruthy();
        
        adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [adService showRewardedAdFromRootViewController:mockViewController];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isRewardedAdAvailable]).will.beFalsy();
        
        expect([adService isRewardedAdAllowed]).to.beFalsy();
        
        adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Session limit reached",
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
    });
    
});

describe(@"allowed to show rewarded minimal time", ^{
    
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
                @"adMaxPerSession": @2,
                @"adMinimumInterval": @2,
                @"adRecordAdRequests": @NO
            }
        };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] initWithAdLimit:@2];
        
        mockViewController = mock([UIViewController class]);
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
    });
    
    it(@"doesn't allow rewarded if shown quicker than minimum time", ^{
        
        expect([adService isRewardedAdAvailable]).will.beTruthy();
        
        expect([adService isRewardedAdAllowed]).to.beTruthy();
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        [adService showRewardedAdFromRootViewController:mockViewController];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService isRewardedAdAvailable]).will.beTruthy();
        
        expect([adService isRewardedAdAllowed]).after(1.5).to.beFalsy();
        
        adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"adMinimumInterval not elapsed",
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
    
        expect([adService isRewardedAdAvailable]).will.beTruthy();
        
        expect([adService isRewardedAdAllowed]).to.beFalsy();
        
        expect([adService isRewardedAdAllowed]).after(2).to.beTruthy();
        
        adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, atLeastOnce()) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
    });
    
});

describe(@"respects adShowPoint and adShowSession for a session", ^{
    
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
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] initWithAdLimit:@2];
        
        mockViewController = mock([UIViewController class]);
        
    });
    
    it(@"doesn't allow engagements if adShowPoint is false", ^{
        
        response = @{
            @"parameters": @{
                @"adShowSession": @YES,
                @"adShowPoint": @NO,
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
                @"adMaxPerSession": @2,
                @"adMinimumInterval": @2,
                @"adRecordAdRequests": @NO
            }
        };
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService isRewardedAdAvailable]).will.beTruthy();
        
        expect([adService isRewardedAdAllowedForDecisionPoint:@"testDecisionPoint" engagementParameters:@{}]).to.beFalsy();
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"adShowPoint was false",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        expect([adService isRewardedAdAllowed]).to.beTruthy();
        
        NSDictionary *adShowParams2 = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion]
        };
        
        HCArgumentCaptor *adShowArg2 = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg2];
        expect([adShowArg2.value isEqualToDictionary:adShowParams2]).to.beTruthy();
        
    });
    
    it(@"doesn't allow adShowSession is false", ^{
        
        response = @{
            @"parameters": @{
                @"adShowSession": @NO,
                @"adShowPoint": @YES,
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
                @"adMaxPerSession": @2,
                @"adMinimumInterval": @2,
                @"adRecordAdRequests": @NO
            }
        };
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        // The session won't have started, so no ads are being fetched.  We don't log anything in that case.
        
        expect([adService isRewardedAdAvailable]).will.beFalsy();
        
        expect([adService isRewardedAdAllowedForDecisionPoint:@"testDecisionPoint" engagementParameters:@{}]).to.beFalsy();

        [verifyCount(mockDelegate, never()) recordEventWithName:@"adShow" parameters:anything()];
        
        expect([adService isRewardedAdAllowed]).to.beFalsy();
        
        [verifyCount(mockDelegate, never()) recordEventWithName:@"adShow" parameters:anything()];
        
    });

});

describe(@"respect null session and time limits", ^{
    
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
                                     ]
                             }
                     };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] init];
        
        mockViewController = mock([UIViewController class]);
    });
    
    it(@"doesn't stop showing ads when no session limit", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:nil
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        for (int i = 0; i < 100; ++i) {
        
            expect([adService isInterstitialAdAvailable]).will.beTruthy();
            [adService showInterstitialAdFromRootViewController:mockViewController];
            expect([adService isShowingInterstitialAd]).will.beTruthy();
            [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        }
        
        // session limit should never be reached
        [verifyCount(mockDelegate, times(100)) didOpenInterstitialAd];
        
    });
    
});


SpecEnd
