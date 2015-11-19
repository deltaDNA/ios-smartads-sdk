//
//  DDNASmartAdAdapter.h
//  
//
//  Created by David White on 09/10/2015.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DDNASmartAdStatus.h"


@protocol DDNASmartAdAdapterDelegate;

@interface DDNASmartAdAdapter : NSObject

@property (nonatomic, weak) id<DDNASmartAdAdapterDelegate> delegate;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *version;
@property (nonatomic, assign, readonly) NSInteger eCPM;
@property (nonatomic, assign, readonly) NSInteger waterfallIndex;

- (instancetype)initWithName: (NSString *)name
                     version: (NSString *)version
                        eCPM: (NSInteger)eCPM
              waterfallIndex: (NSInteger)waterfallIndex;

- (instancetype)initWithConfiguration: (NSDictionary *)configuration waterfallIndex: (NSInteger)waterfallIndex; // abstract
- (void)requestAd;  // abstract
- (void)showAdFromViewController:(UIViewController *)viewController; // abstract

@end

@protocol DDNASmartAdAdapterDelegate <NSObject>

@required

- (void)adapterDidLoadAd: (DDNASmartAdAdapter *)adapter;
- (void)adapterDidFailToLoadAd: (DDNASmartAdAdapter *)adapter withResult: (DDNASmartAdRequestResult *)result;
- (void)adapterIsShowingAd: (DDNASmartAdAdapter *)adapter;
- (void)adapterDidFailToShowAd: (DDNASmartAdAdapter *)adapter withResult: (DDNASmartAdClosedResult *)result;
- (void)adapterWasClicked:(DDNASmartAdAdapter *)adapter;
- (void)adapterLeftApplication:(DDNASmartAdAdapter *)adapter;
- (void)adapterDidCloseAd: (DDNASmartAdAdapter *)adapter;

@end