//
//  DDNASmartAdChartboostHelper.h
//  
//
//  Created by David White on 30/11/2015.
//
//

#import <Foundation/Foundation.h>
#import <Chartboost/Chartboost.h>

@protocol DDNASmartAdChartboostInterstitialDelegate;
@protocol DDNASmartAdChartboostRewardedDelegate;

@interface DDNASmartAdChartboostHelper : NSObject

@property (nonatomic, weak) id<DDNASmartAdChartboostInterstitialDelegate> interstitialDelegate;
@property (nonatomic, weak) id<DDNASmartAdChartboostRewardedDelegate> rewardedDelegate;

+ (instancetype)sharedInstance;

- (void)startWithAppId:(NSString *)appId appSignature:(NSString *)appSignature;

- (void)cacheInterstitial:(CBLocation)location;

- (BOOL)hasInterstitial:(CBLocation)location;

- (void)showInterstitial:(CBLocation)location;

- (void)cacheRewardedVideo:(CBLocation)location;

- (BOOL)hasRewardedVideo:(CBLocation)location;

- (void)showRewardedVideo:(CBLocation)location;

@end

@protocol DDNASmartAdChartboostInterstitialDelegate <NSObject>

- (void)didDisplayInterstitial:(CBLocation)location;

- (void)didCacheInterstitial:(CBLocation)location;

- (void)didFailToLoadInterstitial:(CBLocation)location
                        withError:(CBLoadError)error;

- (void)didFailToRecordClick:(CBLocation)location
                   withError:(CBClickError)error;

- (void)didDismissInterstitial:(CBLocation)location;

- (void)didCloseInterstitial:(CBLocation)location;

- (void)didClickInterstitial:(CBLocation)location;

@end

@protocol DDNASmartAdChartboostRewardedDelegate <NSObject>

- (void)didDisplayRewardedVideo:(CBLocation)location;

- (void)didCacheRewardedVideo:(CBLocation)location;

- (void)didFailToLoadRewardedVideo:(CBLocation)location
                         withError:(CBLoadError)error;

- (void)didDismissRewardedVideo:(CBLocation)location;

- (void)didCloseRewardedVideo:(CBLocation)location;

- (void)didClickRewardedVideo:(CBLocation)location;

- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward;

@end