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

@protocol DDNASmartAdsInterstitialDelegate;
@protocol DDNASmartAdsRewardedDelegate;

@interface DDNASmartAds : NSObject

@property (nonatomic, weak) id<DDNASmartAdsInterstitialDelegate> interstitialDelegate;
@property (nonatomic, weak) id<DDNASmartAdsRewardedDelegate> rewardedDelegate;

+ (instancetype)sharedInstance;

+ (NSString *)sdkVersion;

- (void)registerForAds;

- (BOOL)isInterstitialAdAvailable;

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController;

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController adPoint:(NSString *)adPoint;

- (BOOL)isRewardedAdAvailable;

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController;

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController adPoint:(NSString *)adPoint;

- (void)pause;

- (void)resume;

@end


@protocol DDNASmartAdsInterstitialDelegate <NSObject>

@optional

- (void)didRegisterForInterstitialAds;

- (void)didFailToRegisterForInterstitialAdsWithReason:(NSString *)reason;

- (void)didOpenInterstitialAd;

- (void)didFailToOpenInterstitialAd;

- (void)didCloseInterstitialAd;

@end

@protocol DDNASmartAdsRewardedDelegate <NSObject>

@optional

- (void)didRegisterForRewardedAds;

- (void)didFailToRegisterForRewardedAdsWithReason:(NSString *)reason;

- (void)didOpenRewardedAd;

- (void)didFailToOpenRewardedAd;

- (void)didCloseRewardedAdWithReward:(BOOL)reward;

@end
