//
//  DDNASmartAdAdColonyAdapter.h
//  
//
//  Created by David White on 27/11/2015.
//
//

#import <Foundation/Foundation.h>
#import <DeltaDNAAds/DDNASmartAdAdapter.h>

@interface DDNASmartAdAdColonyAdapter : DDNASmartAdAdapter

@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, readonly) NSString *zoneId;

- (instancetype)initWithAppId: (NSString *)appId
                       zoneId: (NSString *)zoneId
                         eCPM: (NSInteger)eCPM
               waterfallIndex: (NSInteger)waterfallIndex;

@end
