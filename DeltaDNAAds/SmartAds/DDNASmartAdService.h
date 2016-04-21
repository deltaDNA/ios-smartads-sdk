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

#import <Foundation/Foundation.h>

@class DDNASmartAdFactory;

@protocol DDNASmartAdServiceDelegate;

@interface DDNASmartAdService : NSObject

@property (nonatomic, weak) id<DDNASmartAdServiceDelegate> delegate;
@property (nonatomic, strong) DDNASmartAdFactory *factory;

- (instancetype)init;

- (void)beginSessionWithDecisionPoint:(NSString *)decisionPoint;

- (BOOL)isInterstitialAdAvailable;

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController;

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController decisionPoint:(NSString *)decisionPoint;

- (BOOL)isShowingInterstitialAd;

- (BOOL)isRewardedAdAvailable;

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController;

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController decisionPoint:(NSString *)decisionPoint;

- (BOOL)isShowingRewardedAd;

- (void)pause;

- (void)resume;

@end


@protocol DDNASmartAdServiceDelegate <NSObject>

@required

- (void)didRegisterForInterstitialAds;

- (void)didFailToRegisterForInterstitialAdsWithReason:(NSString *)reason;

- (void)didOpenInterstitialAd;

- (void)didFailToOpenInterstitialAdWithReason:(NSString *)reason;

- (void)didCloseInterstitialAd;

- (void)didRegisterForRewardedAds;

- (void)didFailToRegisterForRewardedAdsWithReason:(NSString *)reason;

- (void)didOpenRewardedAd;

- (void)didFailToOpenRewardedAdWithReason:(NSString *)reason;

- (void)didCloseRewardedAdWithReward:(BOOL)reward;

- (void)recordEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters;

- (void)requestEngagementWithDecisionPoint:(NSString *)decisionPoint
                                   flavour:(NSString *)flavour
                                parameters:(NSDictionary *)parameters
                         completionHandler:(void (^)(NSString *response, NSInteger statusCode, NSError *connectionError))completionHandler;

@end