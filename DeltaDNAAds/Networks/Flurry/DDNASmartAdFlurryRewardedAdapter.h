//
//  DDNASmartAdFlurryRewardedAdapter.h
//  
//
//  Created by David White on 30/11/2015.
//
//

#import <Foundation/Foundation.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAdAdapter.h>

@interface DDNASmartAdFlurryRewardedAdapter : DDNASmartAdAdapter

@property (nonatomic, copy, readonly) NSString *apiKey;
@property (nonatomic, copy, readonly) NSString *adSpace;
@property (nonatomic, assign, readonly, getter=isTestMode) BOOL testMode;

- (instancetype)initWithApiKey: (NSString *)apiKey
                       adSpace: (NSString *)adSpace
                      testMode: (BOOL)testMode
                          eCPM: (NSInteger)eCPM
                waterfallIndex: (NSInteger)waterfallIndex;

@end
