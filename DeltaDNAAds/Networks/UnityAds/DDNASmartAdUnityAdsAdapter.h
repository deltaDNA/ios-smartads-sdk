//
//  DDNASmartAdUnityAdsAdapter.h
//  
//
//  Created by David White on 01/12/2015.
//
//

#import <Foundation/Foundation.h>
#import <DeltaDNAAds/DDNASmartAdAdapter.h>

@interface DDNASmartAdUnityAdsAdapter : DDNASmartAdAdapter

@property (nonatomic, copy, readonly) NSString *gameId;
@property (nonatomic, copy, readonly) NSString *zoneId;
@property (nonatomic, assign, readonly, getter=isTestMode) BOOL testMode;

- (instancetype)initWithGameId:(NSString *)gameId
                          zoneId:(NSString *)zoneId
                      testMode:(BOOL)testMode
                         eCPM:(NSInteger)eCPM
               waterfallIndex:(NSInteger)waterfallIndex;

@end
