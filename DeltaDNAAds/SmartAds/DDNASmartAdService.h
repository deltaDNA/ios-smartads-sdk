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
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DDNASmartAdFactory;
@class DDNAEngagement;

@protocol DDNASmartAdServiceDelegate;

extern NSString * const AD_TYPE_UNKNOWN;
extern NSString * const AD_TYPE_INTERSTITIAL;
extern NSString * const AD_TYPE_REWARDED;

// NSNotifcation keys
extern NSString * const kDDNAAdsDisabledEngage;
extern NSString * const kDDNAAdsDisabledNoNetworks;
extern NSString * const kDDNALoadedAd;
extern NSString * const kDDNAShowingAd;
extern NSString * const kDDNAClosedAd;
extern NSString * const kDDNAAdType;
extern NSString * const kDDNAAdPoint;
extern NSString * const kDDNAAdNetwork;
extern NSString * const kDDNARequestTime;
extern NSString * const kDDNAFullyWatched;

@interface DDNASmartAdService : NSObject

@property (nonatomic, weak) id<DDNASmartAdServiceDelegate> delegate;
@property (nonatomic, strong) DDNASmartAdFactory *factory;

- (instancetype)init;

- (void)beginSessionWithDecisionPoint:(nonnull NSString *)decisionPoint;

- (BOOL)isInterstitialAdAllowedForDecisionPoint:(nullable NSString *)decisionPoint
                                     parameters:(nullable NSDictionary *)parameters
                                      checkTime:(BOOL)checkTime;

- (BOOL)hasLoadedInterstitialAd;

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController
                                   decisionPoint:(nullable NSString *)decisionPoint
                                      parameters:(nullable NSDictionary *)parameters;

- (BOOL)isShowingInterstitialAd;

- (BOOL)isRewardedAdAllowedForDecisionPoint:(nullable NSString *)decisionPoint
                                 parameters:(nullable NSDictionary *)parameters
                                  checkTime:(BOOL)checkTime;

- (NSTimeInterval)timeUntilRewardedAdAllowedForDecisionPoint:(nullable NSString *)decisionPoint
                                                  parameters:(nullable NSDictionary *)parameters;

- (BOOL)hasLoadedRewardedAd;

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController
                               decisionPoint:(nullable NSString *)decisionPoint
                                  parameters:(nullable NSDictionary *)parameters;

- (BOOL)isShowingRewardedAd;

- (nullable NSDate *)lastShownForDecisionPoint:(NSString *)decisionPoint;

- (NSInteger)sessionCountForDecisionPoint:(NSString *)decisionPoint;

- (NSInteger)dailyCountForDecisionPoint:(NSString *)decisionPoint;

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

- (void)didLoadRewardedAd;

- (void)didOpenRewardedAdForDecisionPoint:(nullable NSString *)decisionPoint;

- (void)didFailToOpenRewardedAdWithReason:(NSString *)reason;

- (void)didCloseRewardedAdWithReward:(BOOL)reward;

- (void)recordEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters;

- (void)requestEngagementWithDecisionPoint:(NSString *)decisionPoint
                                   flavour:(NSString *)flavour
                                parameters:(NSDictionary *)parameters
                         completionHandler:(void (^)(NSString *response, NSInteger statusCode, NSError *connectionError))completionHandler;

@end

NS_ASSUME_NONNULL_END

