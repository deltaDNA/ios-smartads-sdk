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
#import <UIKit/UIKit.h>
#import "DDNAAd.h"


@protocol DDNARewardedAdDelegate;

/**
 @c DDNARewardedAd manages showing a rewarded ad.  It can be created from a @c DDNAEngagement which will only allow the object to be successfully created if Engage hasn't disabled it.

 ## Showing the Ad

 Show the ad by calling @c -showFromRootViewController:.  If an ad opens @c -didOpenRewardedAd will be called on it's delegate, else @c -didFailToOpenRewardedAd:withReason will be called.  The @c -isReady method checks if an ad has loaded, but generally prefer to try and show an ad whenever one is desired so we can collect an accurate fill rate.  Rewarded ads must have successfully registered before showing an ad is possible.

 ## Closing the Ad

 When the player dismisses the ad, the delegate's @c -didCloseRewardedAd:withReward will be called.  The reward flag indicates if the ad was watched sufficiently that you can reward the player.

 */
@interface DDNARewardedAd : DDNAAd

@property (nonatomic, weak) id<DDNARewardedAdDelegate> delegate;

/**
 The type of reward returned by this ad.
 */
@property (nonatomic, copy, readonly) NSString *rewardType;

/**
 The amount of reward returned by this ad.
 */
@property (nonatomic, assign, readonly) NSInteger rewardAmount;

/**
 Creates and returns a @c DDNARewardedAd.

 @param delegate The delegate to use with this @c DDNARewardedAd.
 */
+ (instancetype)rewardedAdWithDelegate:(id<DDNARewardedAdDelegate>)delegate;

/**
 Creates and returns a @c DDNARewardedAd if the engagement doesn't disallow the ad for it's decision point, in which case nil is returned.  If an ad is not allowed to be shown, either because of session or time limits, or an ad hasn't loaded yet, nil is returned.

 @param engagement The engagement returned from an engage request.

 @param delgate The delegate to use with this @c DDNARewardedAd.
 */
+ (instancetype)rewardedAdWithEngagement:(DDNAEngagement *)engagement delegate:(id<DDNARewardedAdDelegate>)delgate;

/**
 Creates and returns a @c DDNARewardedAd.  The Engagement controls whether the add will be allowed to show in the future.  The difference to the checked engagement, is that an object is always created and @c -isReady can be used to test it.
 
 @param engagement The engagement returned from an engage request.
 
 @param delegate The delegate to use with this @c DDNARewardedAd.
 */
+ (instancetype)rewardedAdWithUncheckedEngagement:(DDNAEngagement *)engagement delegate:(id<DDNARewardedAdDelegate>)delegate;

/**
 Creates a @c DDNARewardedAd without using Engage.  Ads can be shown as soon as one has loaded.
 */
- (instancetype)init;

/**
 Creates a @c DDNARewardedAd with an engagement.  If the engagement doesn't allow the ad for it's decision point nil is returned.  If an ad is not allowed to be shown, either because of session or time limits, or an ad hasn't loaded yet, nil is returned.

 @param engagement The engagement returned from an engage request.
 */
- (instancetype)initWithEngagement:(DDNAEngagement *)engagement;

/**
 Reports if the rewarded ad has loaded an ad and is ready to display it.

 @return If the rewarded ad is ready to display.
 */
- (BOOL)isReady;

/**
 Shows the rewarded ad on screen.

 @param viewController The view controller to add the rewarded ad to.
 */
- (void)showFromRootViewController:(UIViewController *)viewController;

@end

/**
 @c DDNARewardedAdDelegate reports when the ad is displaying on screen and when the user has closed it.
 */
@protocol DDNARewardedAdDelegate <NSObject>

@optional

/**
 Reports when an ad has been loaded and is ready to show.
 
 @param rewardedAd The rewarded ad.
 */
- (void)didLoadRewardedAd:(DDNARewardedAd *)rewardedAd;

/**
 Reports when an ad is not longer available to show.
 
 @param rewardedAd The rewarded ad.
 */
- (void)didExpireRewardedAd:(DDNARewardedAd *)rewardedAd;

/**
 Reports when the ad has started playing on screen.

 @param rewardedAd The rewarded ad.
 */
- (void)didOpenRewardedAd:(DDNARewardedAd *)rewardedAd;

/**
 Reports when the ad fails to start playing on screen.

 @param rewardedAd The rewarded ad.

 @param reason The reason why the ad didn't play.
 */
- (void)didFailToOpenRewardedAd:(DDNARewardedAd *)rewardedAd withReason:(NSString *)reason;

/**
 Reports when the ad has been dismissed by the user.

 @param rewardedAd The rewarded ad.

 @param reward A flag to indicate if the ad was watched sufficiently that you can reward the user.
 */
- (void)didCloseRewardedAd:(DDNARewardedAd *)rewardedAd withReward:(BOOL)reward;

@end
