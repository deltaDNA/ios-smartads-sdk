//
//  DDNASmartAdWaterfall.h
//  
//
//  Created by David White on 29/02/2016.
//
//

#import <Foundation/Foundation.h>
#import "DDNASmartAdStatus.h"

@class DDNASmartAdAdapter;

@interface DDNASmartAdWaterfall : NSObject

- (instancetype)initWithAdapters:(NSArray *)adapters
                 demoteOnOptions:(DDNASmartAdRequestResultCode)options
                     maxRequests:(NSInteger)maxRequests;

- (DDNASmartAdAdapter *)resetWaterfall;

- (DDNASmartAdAdapter *)getNextAdapter;

- (void)scoreAdapter:(DDNASmartAdAdapter *)adapter
     withRequestCode:(DDNASmartAdRequestResultCode)requestCode;

- (void)removeAdapter:(DDNASmartAdAdapter *)adapter;

- (NSArray *)getAdapters;

@end
