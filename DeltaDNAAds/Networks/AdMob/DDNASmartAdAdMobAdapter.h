//
//  DDNASmartAdAdMobAdapter.h
//  
//
//  Created by David White on 12/10/2015.
//
//

#import <Foundation/Foundation.h>
#import "../../DDNASmartAdAdapter.h"

@interface DDNASmartAdAdMobAdapter : DDNASmartAdAdapter

@property (nonatomic, copy, readonly) NSString *adUnitId;
@property (nonatomic, assign, readonly, getter=isTestMode) BOOL testMode;

- (instancetype)initWithAdUnitId: (NSString *)adUnitId
                        testMode: (BOOL)testMode
                            eCPM: (NSInteger)eCPM
                  waterfallIndex: (NSInteger)waterfallIndex;

@end
