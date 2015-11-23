//
//  DDNASmartAdAmazonAdapter.h
//  
//
//  Created by David White on 12/10/2015.
//
//

#import <Foundation/Foundation.h>
#import <DeltaDNAAds/DDNASmartAdAdapter.h>

@interface DDNASmartAdAmazonAdapter : DDNASmartAdAdapter

@property (nonatomic, copy, readonly) NSString *appKey;
@property (nonatomic, assign, getter=isTestMode, readonly) BOOL testMode;

- (instancetype)initWithAppKey: (NSString *)appKey
                      testMode: (BOOL)testMode
                          eCPM: (NSInteger)eCPM
                waterfallIndex: (NSInteger)waterfallIndex;

@end
