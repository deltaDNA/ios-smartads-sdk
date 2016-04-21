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

@class DDNAEngagement;

@protocol DDNAInterstitialAdDelegate;

/**
 @c DDNAInterstitialAd manages showing an interstitial ad.  It can be created from a @c DDNAEngagement which will only allow the object to be successfully created if Engage hasn't disabled it.
 
 ## Showing the Ad
 
 Show the ad by calling @c -showFromRootViewController:.  If an ad opens @c -didOpenInterstitialAd will be called on it's delegate, else @c -didFailToOpenInterstitialAd:withReason will be called.  The @c -isReady method checks if an ad has loaded, but generally prefer to try and show an ad whenever one is desired so we can collect an accurate fill rate.  Interstitial ads must have successfully registered before showing an ad is possible.
 
 ## Closing the Ad
 
 When the player dismisses the ad, the delegate's @c -didCloseInterstitialAd: will be called.
 */
@interface DDNAInterstitialAd : NSObject

@property (nonatomic, weak) id<DDNAInterstitialAdDelegate> delegate;

/**
 If created by a @c DDNAEngagement it contains the custom parameters returned by the engagement.  Will be empty if the Engagement contained no parameters or was created without one.
 */
@property (nonatomic, strong, readonly) NSDictionary *parameters;

/**
 Creates and returns a @c DDNAInterstitialAd.
 
 @param delegate The delegate to use with this @c DDNAInterstitialAd.
 */
+ (instancetype)interstitialAdWithDelegate:(id<DDNAInterstitialAdDelegate>)delegate;

/**
 Creates and returns a @c DDNAInterstitialAd if the engagement doesn't disallow the ad for it's decision point, in which case nil is returned.
 
 @param engagement The engagement returned from an engage request.
 
 @param delegate The delegate to use with this @c DDNAInterstitialAd.
 */
+ (instancetype)interstitialAdWithEngagement:(DDNAEngagement *)engagement delegate:(id<DDNAInterstitialAdDelegate>)delegate;

/**
 Creates a @c DDNAInterstitialAd.
 */
- (instancetype)init;

/**
 Creates a @c DDNAInterstitialAd with an engagement.  If the engagement doesn't allow the ad for it's decision point nil is returned.
 
 @param engagement The engagement returned from an engage request.
 */
- (instancetype)initWithEngagement:(DDNAEngagement *)engagement;

/**
 Reports if the interstitial ad has loaded an ad and is ready to display it.
 
 @return If the interstitial ad is ready to display.
 */
- (BOOL)isReady;

/**
 Shows the interstitial ad on screen.
 
 @param viewController The view controller to add the interstitial ad to.
 */
- (void)showFromRootViewController:(UIViewController *)viewController;

@end

/**
 @c DDNAInterstitialAdDelegate reports when the ad is displaying on screen and when the user as closed it.
 */
@protocol DDNAInterstitialAdDelegate <NSObject>

@optional

/**
 Reports when the ad has started playing on screen.
 
 @param interstitialAd The interstitial ad.
 */
- (void)didOpenInterstitialAd:(DDNAInterstitialAd *)interstitialAd;

/**
 Reports when the ad fails to start playing on screen.
 
 @param interstitialAd The interstitial ad.
 
 @param reason The reason why the ad didn't play.
 */
- (void)didFailToOpenInterstitialAd:(DDNAInterstitialAd *)interstitialAd withReason:(NSString *)reason;

/**
 Reports when the ad has been dismissed by the user.
 
 @param interstitialAd The interstitial ad.
 */
- (void)didCloseInterstitialAd:(DDNAInterstitialAd *)interstitialAd;

@end
