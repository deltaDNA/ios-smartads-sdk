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

@protocol DDNASmartAdsRegistrationDelegate;
@protocol DDNASmartAdsInterstitialDelegate;
@protocol DDNASmartAdsRewardedDelegate;

/**
 @c DDNASmartAds provides a service for fetching and showing ads.  It supports showing interstitial and rewarded ad types.
 
 ## Registering For Ads
 
 To enable the service to begin requesting ads in the background you must first call @c -registerForAds.  This will ask our Engage service for an interstitial and a rewarded ad waterfall.  The potential waterfalls are then matched against the 3rd party ad networks built into your app.  The service will then request ads from these waterfalls.  Call @c -registerForAds early on in the app to ensure an ad has loaded by the time you wish to display it.
 
 ## Showing an Ad
 
 It's now intended to use the @c DDNAInterstitialAd and @c DDNARewardedAd classes to show ads.  However you can still call the SmartAds service directly to see if an ad has loaded and to show it.
 
 The Decision Point versions are now marked as deprecated since we want you to use the separate ad classes with Engage explicitly.  This approach allows for greater flexibility in choosing when and if you should show an ad to the player.
 */
@interface DDNASmartAds : NSObject

@property (nonatomic, weak) id<DDNASmartAdsRegistrationDelegate> registrationDelegate;
@property (nonatomic, weak) id<DDNASmartAdsInterstitialDelegate> interstitialDelegate;
@property (nonatomic, weak) id<DDNASmartAdsRewardedDelegate> rewardedDelegate;

/**
 Returns the singleton instance.
 */
+ (instancetype)sharedInstance;

/**
 Returns the version of the SmartAds SDK.
 
 @return The version of the SmartAds SDK.
 */
+ (NSString *)sdkVersion;

/**
 Registers for the SmartAds service.  On successful completion the service will being loading ads in the background.
 */
- (void)registerForAds;

/**
 Reports if an interstitial ad is available to display.
 
 @return If an interstitial ad is available.
 */
- (BOOL)isInterstitialAdAvailable;

/**
 Shows an interstitial ad.
 
 @param viewController The view controller to show the ad from.
 */
- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController;

/**
 Shows an interstitial ad using Engage.
 
 @param viewController The view controller to show the ad from.
 
 @param decisionPoint The decision point to ask Engage for.
 */
- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController decisionPoint:(NSString *)decisionPoint DEPRECATED_ATTRIBUTE;

/**
 Reports if a rewarded ad is available to display.
 
 @return If a rewarded ad is available.
 */
- (BOOL)isRewardedAdAvailable;

/**
 Shows a rewarded ad.
 
 @param viewController The view controller to show the ad from.
 */
- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController;

/**
 Shows a rewarded ad.
 
 @param viewController The view controller to show the ad from.
 
 @param decisionPoint The decision point to ask Engage for.
 */
- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController decisionPoint:(NSString *)decisionPoint DEPRECATED_ATTRIBUTE;

/**
 Pauses fetching ads in the background.
 */
- (void)pause;

/**
 Resumes fetching ads in the background.
 */
- (void)resume;

@end

/**
 `DDNASmartAdsRegistrationDelegate` reports when SmartAds have completed registration.
 */
@protocol DDNASmartAdsRegistrationDelegate <NSObject>

@optional

/**
 Called when the app receives a valid waterfall for interstitial ads.
 */
- (void)didRegisterForInterstitialAds;

/**
 Called when the app fails to receive a valid waterfall for interstitial ads.
 
 @param reason The reason why registration failed.
 */
- (void)didFailToRegisterForInterstitialAdsWithReason:(NSString *)reason;

/**
 Called when the app receives a valid waterfall for rewarded ads.
 */
- (void)didRegisterForRewardedAds;

/**
 Called when the app fails to receive a valid waterfall for rewarded ads.
 
 @param reason The reason why registration failed.
 */
- (void)didFailToRegisterForRewardedAdsWithReason:(NSString *)reason;

@end

/**
 @c DDNASmartAdsInterstitialDelegate reports when interstitial ads are shown and closed.
 */
@protocol DDNASmartAdsInterstitialDelegate <NSObject>

@optional

/**
 Called when an interstitial ad opens on screen.
 */
- (void)didOpenInterstitialAd;

/**
 Called when an interstitial ad fails to open on screen.
 
 @param reason The reason for not opening.
 */
- (void)didFailToOpenInterstitialAdWithReason:(NSString *)reason;

/**
 Called when the user closes an interstitial ad.
 */
- (void)didCloseInterstitialAd;

@end

/**
 @c DDNASmartAdsRewardedDelegate reports when rewarded ads are shown and closed.
 */
@protocol DDNASmartAdsRewardedDelegate <NSObject>

@optional

/**
 Called when a rewarded ad opens on screen.
 */
- (void)didOpenRewardedAd;

/**
 Called when a rewarded ad fails to open in screen.
 
 @param reason The reason for not opening.
 */
- (void)didFailToOpenRewardedAdWithReason:(NSString *)reason;

/**
 Called when the user closes a rewarded ad.
 
 @param reward If the video was sufficiently watches that you can reward the user.
 */
- (void)didCloseRewardedAdWithReward:(BOOL)reward;

@end
