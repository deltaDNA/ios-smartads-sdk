//
//  DDNASmartAdFactory.h
//  
//
//  Created by David White on 12/10/2015.
//
//

#import <Foundation/Foundation.h>

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

- (DDNASmartAdService *)buildSmartAdServiceWithDelegate: (id<DDNASmartAdServiceDelegate>)delegate;

- (DDNASmartAdAgent *)buildSmartAdAgentWithWaterfall: (NSArray *)waterfall
                                            delegate: (id<DDNASmartAdAgentDelegate>)delegate;

- (NSArray *)buildAdapterWaterfallWithAdProviders: (NSArray *)adProviders floorPrice: (NSInteger)floorPrice;

@end
