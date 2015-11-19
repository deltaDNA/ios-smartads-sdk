//
//  DDNASmartAds.h
//  
//
//  Created by David White on 12/10/2015.
//
//

#import <Foundation/Foundation.h>

@protocol DDNASmartAdsDelegate;

@interface DDNASmartAds : NSObject

@property (nonatomic, weak) id<DDNASmartAdsDelegate> delegate;

+ (instancetype)sharedInstance;

+ (NSString *)sdkVersion;

- (void)registerForAds;

- (void)showAdFromRootViewController: (UIViewController *)viewController;

- (void)showAdFromRootViewController: (UIViewController *)viewController adPoint: (NSString *)adPoint;

@end


@protocol DDNASmartAdsDelegate <NSObject>

@optional

- (void)didRegisterForAds;

- (void)didFailToRegisterForAdsWithReason: (NSString *) reason;

- (void)didOpenAd;

- (void)didFailToOpenAd;

- (void)didCloseAd;

@end

