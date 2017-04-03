//
//  DDNASmartAdIronSourceHelper.h
//  
//
//  Created by David White on 03/04/2017.
//
//

#import <UIKit/UIKit.h>

@class ISPlacementInfo;

@protocol DDNASmartAdIronSourceInterstitialDelegate;
@protocol DDNASmartAdIronSourceRewardedDelegate;

@interface DDNASmartAdIronSourceHelper : NSObject

@property (nonatomic, weak) id<DDNASmartAdIronSourceInterstitialDelegate> interstitialDelegate;
@property (nonatomic, weak) id<DDNASmartAdIronSourceRewardedDelegate> rewardedDelegate;

+ (instancetype)sharedInstance;

- (NSString *)getSDKVersion;

- (void)startWithAppKey:(NSString *)appKey;

- (BOOL)hasRewardedVideo;

- (void)showRewardedVideoWithViewController:(UIViewController *)viewController placement:(nullable NSString *)placementName;

- (BOOL)hasInterstitial;

- (void)showInterstitialWithViewController:(UIViewController *)viewController placement:(nullable NSString *)placementName;

@end

@protocol DDNASmartAdIronSourceRewardedDelegate <NSObject>

- (void)rewardedVideoHasChangedAvailability:(BOOL)available;

- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo;

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error;

- (void)rewardedVideoDidOpen;

- (void)rewardedVideoDidClose;

- (void)rewardedVideoDidStart;

- (void)rewardedVideoDidEnd;

@end

@protocol DDNASmartAdIronSourceInterstitialDelegate <NSObject>

- (void)interstitialDidLoad;

- (void)interstitialDidShow;

- (void)interstitialDidFailToShowWithError:(NSError *)error;

- (void)didClickInterstitial;

- (void)interstitialDidClose;

- (void)interstitialDidOpen;

- (void)interstitialDidFailToLoadWithError:(NSError *)error;

@end
