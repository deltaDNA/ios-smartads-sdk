//
//  DDNASmartAdService.h
//  
//
//  Created by David White on 12/10/2015.
//
//

#import <Foundation/Foundation.h>

@class DDNASmartAdFactory;

@protocol DDNASmartAdServiceDelegate;

@interface DDNASmartAdService : NSObject

@property (nonatomic, weak) id<DDNASmartAdServiceDelegate> delegate;
@property (nonatomic, strong) DDNASmartAdFactory *factory;

- (instancetype)init;

- (void)beginSessionWithDecisionPoint:(NSString *)decisionPoint;

- (BOOL)isInterstitialAdAvailable;

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController;

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController adPoint:(NSString *)adPoint;

- (BOOL)isShowingInterstitialAd;

- (BOOL)isRewardedAdAvailable;

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController;

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController adPoint:(NSString *)adPoint;

- (BOOL)isShowingRewardedAd;

- (void)pause;

- (void)resume;

@end


@protocol DDNASmartAdServiceDelegate <NSObject>

@required

- (void)didRegisterForInterstitialAds;

- (void)didFailToRegisterForInterstitialAdsWithReason:(NSString *)reason;

- (void)didOpenInterstitialAd;

- (void)didFailToOpenInterstitialAd;

- (void)didCloseInterstitialAd;

- (void)didRegisterForRewardedAds;

- (void)didFailToRegisterForRewardedAdsWithReason:(NSString *)reason;

- (void)didOpenRewardedAd;

- (void)didFailToOpenRewardedAd;

- (void)didCloseRewardedAdWithReward:(BOOL)reward;

- (void)recordEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters;

- (void)requestEngagementWithDecisionPoint:(NSString *)decisionPoint
                                   flavour:(NSString *)flavour
                                parameters:(NSDictionary *)parameters
                         completionHandler:(void (^)(NSString *response, NSInteger statusCode, NSError *connectionError))completionHandler;

@end