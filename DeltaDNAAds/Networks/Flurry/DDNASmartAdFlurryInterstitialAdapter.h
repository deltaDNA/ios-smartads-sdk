//
//  DDNASmartAdFlurryAdapter.h
//  
//
//  Created by David White on 06/11/2015.
//
//

#import <Foundation/Foundation.h>
#import <DeltaDNAAds/DDNASmartAdAdapter.h>

@interface DDNASmartAdFlurryInterstitialAdapter : DDNASmartAdAdapter

@property (nonatomic, copy, readonly) NSString *apiKey;
@property (nonatomic, copy, readonly) NSString *adSpace;
@property (nonatomic, assign, readonly, getter=isTestMode) BOOL testMode;

- (instancetype)initWithApiKey: (NSString *)apiKey
                       adSpace: (NSString *)adSpace
                      testMode: (BOOL)testMode
                          eCPM: (NSInteger)eCPM
                waterfallIndex: (NSInteger)waterfallIndex;

@end
