//
// Copyright (c) 2017 deltaDNA Ltd. All rights reserved.
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

#import <UIKit/UIKit.h>

@class ISPlacementInfo;
@class DDNASmartAdPrivacy;

@protocol DDNASmartAdIronSourceInterstitialDelegate;
@protocol DDNASmartAdIronSourceRewardedDelegate;

@interface DDNASmartAdIronSourceHelper : NSObject
NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, weak) id<DDNASmartAdIronSourceInterstitialDelegate> interstitialDelegate;
@property (nonatomic, weak) id<DDNASmartAdIronSourceRewardedDelegate> rewardedDelegate;

+ (instancetype)sharedInstance;

- (NSString *)getSDKVersion;

- (void)startWithAppKey:(NSString *)appKey privacy:(DDNASmartAdPrivacy *)privacy;

- (BOOL)hasRewardedVideo;

- (void)showRewardedVideoWithViewController:(UIViewController *)viewController placement:(nullable NSString *)placementName;

- (void)loadInterstitial;

- (BOOL)hasInterstitial;

- (void)showInterstitialWithViewController:(UIViewController *)viewController placement:(nullable NSString *)placementName;

- (int)resultCodeFromError:(NSError *)error;

NS_ASSUME_NONNULL_END
@end

@protocol DDNASmartAdIronSourceRewardedDelegate <NSObject>
NS_ASSUME_NONNULL_BEGIN

- (void)rewardedVideoHasChangedAvailability:(BOOL)available;

- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo;

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error;

- (void)rewardedVideoDidOpen;

- (void)rewardedVideoDidClose;

- (void)rewardedVideoDidStart;

- (void)rewardedVideoDidEnd;

- (void)didClickRewardedVideoForPlacement:(ISPlacementInfo *)placementInfo;

NS_ASSUME_NONNULL_END
@end

@protocol DDNASmartAdIronSourceInterstitialDelegate <NSObject>
NS_ASSUME_NONNULL_BEGIN

- (void)interstitialDidLoad;

- (void)interstitialDidShow;

- (void)interstitialDidFailToShowWithError:(NSError *)error;

- (void)didClickInterstitial;

- (void)interstitialDidClose;

- (void)interstitialDidOpen;

- (void)interstitialDidFailToLoadWithError:(NSError *)error;

NS_ASSUME_NONNULL_END
@end
