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
@property (nonatomic, assign, readonly, getter=isAdAvailable) BOOL adAvailable;
@property (nonatomic, assign, readonly, getter=isShowingAd) BOOL showingAd;

- (instancetype)init;

- (void)beginSessionWithDecisionPoint: (NSString *)decisionPoint;

- (void)showAdFromRootViewController: (UIViewController *)viewController;

- (void)showAdFromRootViewController: (UIViewController *)viewController adPoint: (NSString *)adPoint ;

@end


@protocol DDNASmartAdServiceDelegate <NSObject>

@required

- (void)didRegisterForAds;

- (void)didFailToRegisterForAdsWithReason: (NSString *)reason;

- (void)didOpenAd;

- (void)didFailToOpenAd;

- (void)didCloseAd;

- (void)recordEventWithName: (NSString *)eventName andParamJson: (NSString *)paramJson;

@end
