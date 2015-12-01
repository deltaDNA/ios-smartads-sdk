//
//  DDNASmartAdFactory.h
//  
//
//  Created by David White on 12/10/2015.
//
//

#import <Foundation/Foundation.h>

@class DDNANetworkRequest;
@protocol DDNANetworkRequestDelegate;

@class DDNAEngageService;

@class DDNASmartAdService;
@protocol DDNASmartAdServiceDelegate;

@class DDNASmartAdAgent;
@protocol DDNASmartAdAgentDelegate;

@protocol DDNASmartAdAdapter;

/**
 *  Factory creates components for smart ad library.
 */
@interface DDNASmartAdFactory : NSObject

+ (instancetype)sharedInstance;

- (DDNANetworkRequest *)buildNetworkRequestWithURL: (NSURL *)URL
                                       jsonPayload: (NSString *)jsonPayload
                                          delegate: (id<DDNANetworkRequestDelegate>)delegate;

- (DDNAEngageService *)buildEngageService;

- (DDNASmartAdService *)buildSmartAdServiceWithDelegate: (id<DDNASmartAdServiceDelegate>)delegate;

- (DDNASmartAdAgent *)buildSmartAdAgentWithWaterfall: (NSArray *)waterfall
                                            delegate: (id<DDNASmartAdAgentDelegate>)delegate;

- (NSArray *)buildAdapterWaterfallWithAdProviders: (NSArray *)adProviders floorPrice: (NSInteger)floorPrice;

@end
