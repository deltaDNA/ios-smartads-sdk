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

@protocol DDNASmartAdsRegistrationDelegate;
@protocol DDNASmartAdsInterstitialDelegate;
@protocol DDNASmartAdsRewardedDelegate;

@class DDNAEngagement;
@class DDNASmartAdEngageFactory;

/**
 @c DDNASmartAds provides a service for fetching and showing ads.  It supports showing interstitial and rewarded ad types.
 
 ## Registering For Ads
 
 To enable the service to begin requesting ads in the background you must first call @c -registerForAds.  This will ask our Engage service for an interstitial and a rewarded ad waterfall.  The potential waterfalls are then matched against the 3rd party ad networks built into your app.  The service will then request ads from these waterfalls.  Call @c -registerForAds early on in the app to ensure an ad has loaded by the time you wish to display it.
 
 ## Showing an Ad
 
 It's now intended to use the @c DDNAInterstitialAd and @c DDNARewardedAd classes to show ads.  However you can still call the SmartAds service directly to see if an ad has loaded and to show it.
 
 The Decision Point versions are now marked as deprecated since we want you to use the separate ad classes with Engage explicitly.  This approach allows for greater flexibility in choosing when and if you should show an ad to the player.
 */
NS_ASSUME_NONNULL_BEGIN
@interface DDNASmartAds : NSObject

@property (nonatomic, weak, nullable) id<DDNASmartAdsRegistrationDelegate> registrationDelegate;
@property (nonatomic, weak, nullable) id<DDNASmartAdsInterstitialDelegate> interstitialDelegate;
@property (nonatomic, weak, nullable) id<DDNASmartAdsRewardedDelegate> rewardedDelegate;

/// The @c DDNASmartAdEngageFactory  helps making Engage requests.
@property (nonatomic, strong, readonly) DDNASmartAdEngageFactory *engageFactory;

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
 
 @deprecated in version 1.8, in favour of automatic registration
 */
- (void)registerForAds __attribute__((deprecated));

/**
 Checks if an interstitial ad can be shown.  This method looks for 'adShowPoint'=false in the Engagement, and checks the ads shown and time between ads limits for this session.  Pass nil for the engagement if just checking session and time limits.
 
 @param engagement The engagement to test.
 
 @return True if the engagement doesn't prevent an ad from showing.
 */

- (BOOL)isInterstitialAdAllowed:(nullable DDNAEngagement *)engagement checkTime:(BOOL)checkTime;

/**
 Reports if an interstitial ad has loaded and is available to display.
 
 @return If an interstitial ad is ready to display.
 */
- (BOOL)hasLoadedInterstitialAd;

/**
 Shows an interstitial ad.  This is a helper for InterstitialAd and shouldn't be called directly.
 
 @param viewController The view controller to show the ad from.
 
 @param engagement The completed engagement that will control if the ad can be shown now or not.
 
 */
- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController engagement:(nullable DDNAEngagement *)engagement;

/**
 Checks if a rewarded ad can be shown.  This method looks for 'adShowPoint'=false in the Engagement, and checks the ads shown and time between ads limits for this session.  Pass nil for the Engagement if just checking for session and time limits.
 
 @param engagement The engagement to test..
 
 @return True if the engagement doesn't prevent the ad from showing.
 */

- (BOOL)isRewardedAdAllowed:(nullable DDNAEngagement *)engagement checkTime:(BOOL)checkTime;

- (NSTimeInterval)timeUntilRewardedAdAllowedForEngagement:(DDNAEngagement *)engagement;

/**
 Reports if a rewarded ad has loaded and is available to display.
 
 @return If a rewarded ad is ready to display.
 */
- (BOOL)hasLoadedRewardedAd;

/**
 Shows a rewarded ad.  This is a helper for RewardedAd and shouldn't be called directly.
 
 @param viewController The view controller to show the ad from.
 
 @param engagement The completed engagement which configures how the ad is shown.
 */
- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController engagement:(nullable DDNAEngagement *)engagement;

- (nullable NSDate *)lastShownForDecisionPoint:(NSString *)decisionPoint;

- (NSInteger)sessionCountForDecisionPoint:(NSString *)decisionPoint;

- (NSInteger)dailyCountForDecisionPoint:(NSString *)decisionPoint;

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
NS_ASSUME_NONNULL_END

