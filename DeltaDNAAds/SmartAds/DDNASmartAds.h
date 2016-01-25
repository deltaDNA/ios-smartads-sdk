//
//  DDNASmartAds.h
//  
//
//  Created by David White on 12/10/2015.
//
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
