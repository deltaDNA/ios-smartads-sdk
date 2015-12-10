//
//  DDNASmartAdMoPubAdapter.h
//  
//
//  Created by David White on 06/11/2015.
//
//

#import <Foundation/Foundation.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAdAdapter.h>

@interface DDNASmartAdMoPubAdapter : DDNASmartAdAdapter

@property (nonatomic, copy, readonly) NSString *adUnitId;
@property (nonatomic, assign, readonly, getter=isTestMode) BOOL testMode;

- (instancetype)initWithAdUnitId: (NSString *)adUnitId
                        testMode: (BOOL)testMode
                            eCPM: (NSInteger)eCPM
                  waterfallIndex: (NSInteger)waterfallIndex;

@end
