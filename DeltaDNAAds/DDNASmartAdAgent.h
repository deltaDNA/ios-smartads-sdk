//
//  DDNASmartAdAgent.h
//  
//
//  Created by David White on 12/10/2015.
//
//

#import <Foundation/Foundation.h>
#import <DeltaDNAAds/DDNASmartAdAdapter.h>


typedef NS_ENUM(NSInteger, DDNASmartAdAgentState) {
    DDNASmartAdAgentStateReady,
    DDNASmartadAgentStateLoading,
    DDNASmartAdAgentStateLoaded,
    DDNASmartAdAgentStateShowing
};

@protocol DDNASmartAdAgentDelegate;

@interface DDNASmartAdAgent : NSObject

@property (nonatomic, weak) id<DDNASmartAdAgentDelegate> delegate;
@property (nonatomic, copy) NSString *adPoint;

@property (nonatomic, assign, readonly) DDNASmartAdAgentState state;
@property (nonatomic, assign, readonly) BOOL adWasClicked;
@property (nonatomic, assign, readonly) BOOL adLeftApplication;
@property (nonatomic, strong, readonly) DDNASmartAdAdapter * currentAdapter;
@property (nonatomic, assign, readonly) NSInteger adsShown;
@property (nonatomic, strong, readonly) NSDate *lastAdShownTime;


- (instancetype)initWithAdapters: (NSArray *)mediationAdapters;

- (void)requestAd;

- (BOOL)hasLoadedAd;

- (BOOL)isShowingAd;

- (void)showAdFromRootViewController:(UIViewController *)viewController adPoint: (NSString *)adPoint;

@end


@protocol DDNASmartAdAgentDelegate <NSObject>

@required

- (void)adAgent:(DDNASmartAdAgent *)adAgent didLoadAdWithAdapter:(DDNASmartAdAdapter *)adapter requestTime:(NSTimeInterval)requestTime;

- (void)adAgent:(DDNASmartAdAgent *)adAgent didFailToLoadAdWithAdapter:(DDNASmartAdAdapter *)adapter requestTime:(NSTimeInterval)requestTime requestResult:(DDNASmartAdRequestResult *)result;

- (void)adAgent:(DDNASmartAdAgent *)adAgent didOpenAdWithAdapter:(DDNASmartAdAdapter *)adapter;

- (void)adAgent:(DDNASmartAdAgent *)adAgent didFailToOpenAdWithAdapter:(DDNASmartAdAdapter *)adapter closedResult:(DDNASmartAdClosedResult *)result;

- (void)adAgent:(DDNASmartAdAgent *)adAgent didCloseAdWithAdapter:(DDNASmartAdAdapter *)adapter;

@end
