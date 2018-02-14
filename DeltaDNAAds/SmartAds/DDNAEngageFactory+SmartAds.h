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

#import <Foundation/Foundation.h>
#import <DeltaDNA/DDNAEngageFactory.h>

@class DDNAInterstitialAd;
@class DDNARewardedAd;

NS_ASSUME_NONNULL_BEGIN

/**
 Extends the @c DDNAEngageFactory to create @InterstitialAd and @RewardedAd object with Engage.
 */
@interface DDNAEngageFactory (DDNASmartAds)

typedef void (^InterstitialAdHandler)(DDNAInterstitialAd * interstitialAd);
typedef void (^RewardedAdHandler)(DDNARewardedAd * rewardedAd);

/**
 Requests an @c InterstitialAd object from Engage.
 */
- (void)requestInterstitialAdForDecisionPoint:(NSString *)decisionPoint
                                      handler:(InterstitialAdHandler)handler;

/**
 Requests an @c InterstitialAd object from Engage with optional real-time parameters.
 */
- (void)requestInterstitialAdForDecisionPoint:(NSString *)decisionPoint
                                   parameters:(nullable DDNAParams *)parameters
                                      handler:(InterstitialAdHandler)handler;

/**
 Requests a @c RewardedAd object from Engage.
 */
- (void)requestRewardedAdForDecisionPoint:(NSString *)decisionPoint
                                  handler:(RewardedAdHandler)handler;

/**
 Requests a @c RewardedAd object from Engage with optional real-time parameters.
 */
- (void)requestRewardedAdForDecisionPoint:(NSString *)decisionPoint
                               parameters:(nullable DDNAParams *)parameters
                                  handler:(RewardedAdHandler)handler;

@end

NS_ASSUME_NONNULL_END
