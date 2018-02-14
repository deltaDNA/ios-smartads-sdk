//
// Copyright (c) 2018 deltaDNA Ltd. All rights reserved.
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
        // Clear persistant data between runs
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler(nil, -1, [NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:nil]);
        
        [verifyCount(mockDelegate, never()) didFailToRegisterForInterstitialAdsWithReason:@"Engage returned: -1 The operation couldn’t be completed. (NSURLErrorDomain error -1009.)"];
        [verifyCount(mockDelegate, never()) didFailToRegisterForRewardedAdsWithReason:@"Engage returned: -1 The operation couldn’t be completed. (NSURLErrorDomain error -1009.)"];
        expect([adService hasLoadedInterstitialAd]).to.beFalsy();
        expect([adService hasLoadedRewardedAd]).to.beFalsy();
        
    });
    
    it(@"no ad available with engage non 200 response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler(@"Unknown decision point", 400, nil);
        
        expect([adService hasLoadedInterstitialAd]).to.beFalsy();
        expect([adService hasLoadedRewardedAd]).to.beFalsy();
        
    });
    
    it(@"no ad available with empty engage response", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler(@"{}", 200, nil);
        
        expect([adService hasLoadedInterstitialAd]).to.beFalsy();
        expect([adService hasLoadedRewardedAd]).to.beFalsy();
        
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"Ads disabled for this session by Engage."];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"Ads disabled for this session by Engage."];
        expect([adService hasLoadedInterstitialAd]).to.beFalsy();
        expect([adService hasLoadedRewardedAd]).to.beFalsy();
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"Ads disabled for this session by Engage."];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"Ads disabled for this session by Engage."];
        expect([adService hasLoadedInterstitialAd]).to.beFalsy();
        expect([adService hasLoadedRewardedAd]).to.beFalsy();
        
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"No interstitial ad networks configured"];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"No rewarded ad networks configured"];
        expect([adService hasLoadedInterstitialAd]).to.beFalsy();
        expect([adService hasLoadedRewardedAd]).to.beFalsy();
        
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [verify(mockDelegate) didFailToRegisterForInterstitialAdsWithReason:@"No interstitial ad networks enabled"];
        [verify(mockDelegate) didFailToRegisterForRewardedAdsWithReason:@"No rewarded ad networks enabled"];
        expect([adService hasLoadedInterstitialAd]).to.beFalsy();
        expect([adService hasLoadedRewardedAd]).to.beFalsy();
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        [verify(mockDelegate) didRegisterForInterstitialAds];

        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        
    });
});
    
describe(@"interstitial ads", ^{
   
    __block DDNASmartAdService *adService;
    __block id<DDNASmartAdServiceDelegate> mockDelegate;
    __block DDNAFakeSmartAdFactory *fakeFactory;
    __block UIViewController *mockViewController;
    __block NSDictionary *response;
    
    beforeEach(^{
        
        // Clear persistant data between runs
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
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
    
    it(@"shows an interstitial ad using an Engagement", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        expect([adService hasLoadedInterstitialAd]).to.beFalsy();
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
    
    it(@"does not show an interstitial with an invalid Engagement", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = nil;
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        expect([adService isShowingInterstitialAd]).will.beFalsy();
        expect([adService hasLoadedInterstitialAd]).to.beTruthy();
        [verify(mockDelegate) didFailToOpenInterstitialAdWithReason:@"Invalid Engagement"];
        
    });
    
    it(@"does not show an interstitial with an Engagement when adShowPoint is false", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);

        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [verify(mockDelegate) didRegisterForInterstitialAds];
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"adShowPoint":@NO};
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        expect([adService isShowingInterstitialAd]).will.beFalsy();
        expect([adService hasLoadedInterstitialAd]).to.beTruthy();
        [verify(mockDelegate) didFailToOpenInterstitialAdWithReason:@"Engage disallowed the ad"];
        
    });
    
    it(@"stops showing interstitial ads when max session is reached", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        expect([adService isShowingInterstitialAd]).will.beFalsy();
        
        // session limit should be reached
        expect([adService hasLoadedInterstitialAd]).will.beFalsy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        [verifyCount(mockDelegate, times(3)) didOpenInterstitialAd];

    });
    
    it(@"stops showing interstitial ads when max session for decision point is reached", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"ddnaAdSessionCount":@2};
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        expect([adService isShowingInterstitialAd]).will.beFalsy();
        
        // session limit for decision point should be reached, but it still loads an
        // ad as global limit not reached
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beFalsy();
        
        [verifyCount(mockDelegate, times(2)) didOpenInterstitialAd];
        [verifyCount(mockDelegate, times(1)) didFailToOpenInterstitialAdWithReason:@"Session limit for decision point reached"];
    });
    
    it(@"stops showing interstitial ads when max daily for decision point is reached", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"ddnaAdDailyCount":@2};
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        // daily limit for decision point should be reached, but it still loads an
        // ad as session limit not reached
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beFalsy();
        
        [verifyCount(mockDelegate, times(2)) didOpenInterstitialAd];
        [verifyCount(mockDelegate, times(1)) didFailToOpenInterstitialAdWithReason:@"Daily limit for decision point reached"];
    });
    
    it(@"doesn't show an ad with an Engagement before the minimum interval for a decision point", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"ddnaAdShowWaitSecs":@4};
        
        expect([adService hasLoadedInterstitialAd]).after(3).beTruthy();    // wait longer than session timeout
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        // too soon so fail
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beFalsy();
        [verifyCount(mockDelegate, times(1)) didFailToOpenInterstitialAdWithReason:@"Minimum decision point time between ads not elapsed"];
    });
    
    it(@"shows an ad with an Engagement after the minimum interval for a decision point", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"ddnaAdShowWaitSecs":@4};
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        expect([adService isShowingInterstitialAd]).will.beFalsy();
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        
        expect([adService isInterstitialAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:YES]).to.beFalsy();
        
        expect([adService isInterstitialAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:YES]).after(4).to.beTruthy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [verifyCount(mockDelegate, times(2)) didOpenInterstitialAd];
    });
    
});

describe(@"rewarded ads", ^{
    
    __block DDNASmartAdService *adService;
    __block id<DDNASmartAdServiceDelegate> mockDelegate;
    __block DDNAFakeSmartAdFactory *fakeFactory;
    __block UIViewController *mockViewController;
    __block NSDictionary *response;
    
    beforeEach(^{
        
        // Clear persistant data between runs
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
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
    
    it(@"shows a rewarded ad using an Engagement", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        [verify(mockDelegate) didLoadRewardedAd];
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        expect([adService isShowingRewardedAd]).will.beTruthy();
        expect([adService hasLoadedRewardedAd]).to.beFalsy();
        [verify(mockDelegate) didOpenRewardedAdForDecisionPoint:@"testDecisionPoint"];
        
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
    
    it(@"does not show a rewarded ad with an invalid Engagement", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        [verify(mockDelegate) didLoadRewardedAd];
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = nil;
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        expect([adService isShowingRewardedAd]).will.beFalsy();
        expect([adService hasLoadedRewardedAd]).to.beTruthy();
        [verify(mockDelegate) didFailToOpenRewardedAdWithReason:@"Invalid Engagement"];
        
    });
    
    it(@"does not show a rewarded ad with an Engagement when adShowPoint is false", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didRegisterForRewardedAds];
        [verify(mockDelegate) didLoadRewardedAd];
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"adShowPoint": @NO};
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        expect([adService isShowingRewardedAd]).will.beFalsy();
        expect([adService hasLoadedRewardedAd]).to.beTruthy();
        [verify(mockDelegate) didFailToOpenRewardedAdWithReason:@"Engage disallowed the ad"];
        
    });
    
    it(@"stops showing rewarded ads when max session is reached", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        expect([adService isShowingRewardedAd]).will.beFalsy();
        
        // session limit should be reached
        expect([adService hasLoadedRewardedAd]).will.beFalsy();
        [verifyCount(mockDelegate, never()) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        [verifyCount(mockDelegate, times(3)) didOpenRewardedAdForDecisionPoint:@"testDecisionPoint"];
        
    });
    
    it(@"stops showing rewarded ads when max session for decision point is reached", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"ddnaAdSessionCount":@2};
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        expect([adService isShowingRewardedAd]).will.beFalsy();
        
        // session limit for decision point should be reached, but it still loads an
        // ad as global limit not reached
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beFalsy();
        
        [verifyCount(mockDelegate, times(2)) didOpenRewardedAdForDecisionPoint:@"testDecisionPoint"];
        [verifyCount(mockDelegate, times(1)) didFailToOpenRewardedAdWithReason:@"Session limit for decision point reached"];
    });
    
    it(@"stops showing rewarded ads when max daily for decision point is reached", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"ddnaAdDailyCount": @2};
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        // daily limit for decision point should be reached, but it still loads an
        // ad as session limit not reached
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beFalsy();
        
        [verifyCount(mockDelegate, times(2)) didOpenRewardedAdForDecisionPoint:@"testDecisionPoint"];
        [verifyCount(mockDelegate, times(1)) didFailToOpenRewardedAdWithReason:@"Daily limit for decision point reached"];
    });
    
    it(@"doesn't show a rewarded ad with an Engagement before the minimum interval for a decision point", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"ddnaAdShowWaitSecs":@4};
        
        expect([adService hasLoadedRewardedAd]).after(3).beTruthy();    // wait longer than session timeout
        [verify(mockDelegate) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        // too soon so fail
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beFalsy();
        [verifyCount(mockDelegate, times(1)) didFailToOpenRewardedAdWithReason:@"Minimum decision point time between ads not elapsed"];
    });
    
    it(@"shows a rewarded ad with an Engagement after the minimum interval for a decision point", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"ddnaAdShowWaitSecs":@4};
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didLoadRewardedAd];
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        expect([adService isShowingRewardedAd]).will.beFalsy();
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [verify(mockDelegate) didLoadRewardedAd];
        
        // So we're now allowed to show an ad (in the future)
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beTruthy();
        // The ad is not ready to be shown
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:YES]).to.beFalsy();
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:YES]).after(4).to.beTruthy();
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [verifyCount(mockDelegate, times(2)) didOpenRewardedAdForDecisionPoint:@"testDecisionPoint"];
    });

});

describe(@"interstitial ads respect session minimum ad interval", ^{
    
    __block DDNASmartAdService *adService;
    __block id<DDNASmartAdServiceDelegate> mockDelegate;
    __block DDNAFakeSmartAdFactory *fakeFactory;
    __block UIViewController *mockViewController;
    __block NSDictionary *response;
    
    beforeAll(^{
        // All asynchronous matching using `will` and `willNot`
        // will have a timeout of 2.0 seconds
        [Expecta setAsynchronousTestTimeout:2];
    });
    
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

    it(@"doesn't show an interstitial ad with an Engagement before the minimum interval", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        // too soon so fail
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beFalsy();
        [verifyCount(mockDelegate, times(1)) didFailToOpenInterstitialAdWithReason:@"Minimum environment time between ads not elapsed"];
    });
    
    it(@"shows an interstitial ad with an Engagement after the minimum interval", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        
        expect([adService isInterstitialAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:YES]).to.beFalsy();
        
        expect([adService isInterstitialAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:YES]).after(2).to.beTruthy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [verifyCount(mockDelegate, times(2)) didOpenInterstitialAd];
    });
});

describe(@"rewarded ads respect session minimum ad interval", ^{
    
    __block DDNASmartAdService *adService;
    __block id<DDNASmartAdServiceDelegate> mockDelegate;
    __block DDNAFakeSmartAdFactory *fakeFactory;
    __block UIViewController *mockViewController;
    __block NSDictionary *response;
    
    beforeAll(^{
        // All asynchronous matching using `will` and `willNot`
        // will have a timeout of 2.0 seconds
        [Expecta setAsynchronousTestTimeout:2];
    });
    
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
                @"adMaxPerSession": @3,
                @"adMinimumInterval": @2
            }
        };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] initWithAdLimit:@3];
        
        mockViewController = mock([UIViewController class]);
    });
    
    it(@"doesn't show a rewarded ad with an Engagement before the minimum interval", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        // too soon so fail
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beFalsy();
        [verifyCount(mockDelegate, times(1)) didFailToOpenRewardedAdWithReason:@"Minimum environment time between ads not elapsed"];
    });
    
    it(@"shows a rewarded ad with an Engagement after the minimum interval", ^{
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beTruthy();
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:YES]).to.beFalsy();
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:YES]).after(2).to.beTruthy();
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [verifyCount(mockDelegate, times(2)) didOpenRewardedAdForDecisionPoint:@"testDecisionPoint"];
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};

        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
    });
    
    it(@"doesn't allow interstitial if engagement disables", ^{
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"adShowPoint":@NO};
        
        expect([adService isInterstitialAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beFalsy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"adShowPoint was false",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        // Check AdShow not called on allowed anymore
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
    });
    
    it(@"doesn't allow interstitial if shown more than max for session", ^{
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService isInterstitialAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beTruthy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        
        expect([adService isInterstitialAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beTruthy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedInterstitialAd]).will.beFalsy();
        
        expect([adService isInterstitialAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beFalsy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"Session limit reached",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
    });
    
    it(@"doesn't allow interstitial if shown quicker than minimum time", ^{
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService isInterstitialAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beTruthy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        expect([adService isShowingInterstitialAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedInterstitialAd]).will.beTruthy();
        expect([adService isInterstitialAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:YES]).will.beFalsy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"Minimum time between ads not elapsed",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        expect([adService isInterstitialAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:YES]).after(2).to.beTruthy();
        
        [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"INTERSTITIAL",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
    });

    
    it(@"doesn't allow rewarded if engagement disables", ^{
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"adShowPoint":@NO};
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beFalsy();
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
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
    });
    
    it(@"doesn't allow rewarded if shown more than max for session", ^{
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beTruthy();
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beTruthy();
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedRewardedAd]).will.beFalsy();
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beFalsy();
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Session limit reached",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
    });
    
    it(@"doesn't allow rewarded if shown quicker than minimum time", ^{
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beTruthy();
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        
        NSDictionary *adShowParams = @{
            @"adProvider": @"DUMMY",
            @"adProviderVersion": @"1.0.0",
            @"adType": @"REWARDED",
            @"adStatus": @"Fulfilled",
            @"adSdkVersion": [DDNASmartAds sdkVersion],
            @"adPoint": @"testDecisionPoint"
        };
        
        HCArgumentCaptor *adShowArg = [[HCArgumentCaptor alloc] init];
        [verifyCount(mockDelegate, times(1)) recordEventWithName:@"adShow" parameters:(id)adShowArg];
        expect([adShowArg.value isEqualToDictionary:adShowParams]).to.beTruthy();
        
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).will.to.beTruthy();
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:YES]).after(1.5).to.beFalsy();
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:YES]).after(2).to.beTruthy();
    });
    
});

describe(@"respects adShowSession for a session", ^{
    
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        // The session won't have started, so no ads are being fetched.  We don't log anything in that case.
        
        expect([adService hasLoadedRewardedAd]).will.beFalsy();
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beFalsy();

        [verifyCount(mockDelegate, never()) recordEventWithName:@"adShow" parameters:anything()];
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beFalsy();
        
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
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        for (int i = 0; i < 100; ++i) {
        
            expect([adService hasLoadedInterstitialAd]).will.beTruthy();
            NSString *decisionPoint = @"testDecisionPoint";
            NSDictionary *engageParams = @{};
            [adService showInterstitialAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
            expect([adService isShowingInterstitialAd]).will.beTruthy();
            [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        }
        
        // session limit should never be reached
        [verifyCount(mockDelegate, times(100)) didOpenInterstitialAd];
        
    });
    
});

describe(@"time until ad is allowed", ^{
    
    __block DDNASmartAdService *adService;
    __block id<DDNASmartAdServiceDelegate> mockDelegate;
    __block DDNAFakeSmartAdFactory *fakeFactory;
    __block UIViewController *mockViewController;
    __block NSDictionary *response;
    
    beforeEach(^{
        
        // Clear persistant data between runs
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
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
                ]
            }
        };
        
        fakeFactory.fakeSmartAdAgent = [[DDNAFakeSmartAdAgent alloc] init];
        
        mockViewController = mock([UIViewController class]);
    });
    
    it(@"reports the remaining session time", ^{
        
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
                @"adMinimumInterval": @2,
            }
        };
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beTruthy();
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        expect([adService isShowingRewardedAd]).will.beFalsy();
        [verify(mockDelegate) didCloseRewardedAdWithReward:YES];
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        
        expect([adService timeUntilRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams]).to.equal(2);
        
        expect([adService timeUntilRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams]).after(2).to.equal(0);
        
    });
    
    it(@"reports the remaining decision point time", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"ddnaAdShowWaitSecs":@3};
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beTruthy();
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        expect([adService isShowingRewardedAd]).will.beFalsy();
        [verify(mockDelegate) didCloseRewardedAdWithReward:YES];
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        
        expect([adService timeUntilRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams]).to.equal(3);
        
        expect([adService timeUntilRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams]).after(3).to.equal(0);
        
    });
    
    it(@"reports the largest wait time", ^{
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
                @"adMinimumInterval": @2,
            }
        };
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{@"ddnaAdShowWaitSecs":@3};
        
        expect([adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams checkTime:NO]).to.beTruthy();
        
        [adService showRewardedAdFromRootViewController:mockViewController decisionPoint:decisionPoint parameters:engageParams];
        expect([adService isShowingRewardedAd]).will.beTruthy();
        [(DDNAFakeSmartAdAgent *)fakeFactory.fakeSmartAdAgent closeAd];
        expect([adService isShowingRewardedAd]).will.beFalsy();
        [verify(mockDelegate) didCloseRewardedAdWithReward:YES];
        
        expect([adService hasLoadedRewardedAd]).will.beTruthy();
        
        expect([adService timeUntilRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams]).to.equal(3);
        
        expect([adService timeUntilRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams]).after(3).to.equal(0);
        
    });
    
    it(@"reports when no wait time", ^{
        
        [adService beginSessionWithDecisionPoint:@"advertising"];
        
        HCArgumentCaptor *argument = [[HCArgumentCaptor alloc] init];
        [verify(mockDelegate) requestEngagementWithDecisionPoint:@"advertising"
                                                         flavour:@"internal"
                                                      parameters:@{@"adSdkVersion":[DDNASmartAds sdkVersion]}
                                               completionHandler:(id)argument];
        
        void (^completionHandler)(NSString *response, NSInteger statusCode, NSError *connectionError) = argument.value;
        completionHandler([NSString stringWithContentsOfDictionary:response], 200, nil);
        
        NSString *decisionPoint = @"testDecisionPoint";
        NSDictionary *engageParams = @{};
        
        expect([adService timeUntilRewardedAdAllowedForDecisionPoint:decisionPoint parameters:engageParams]).to.equal(0);
    });
});

SpecEnd
