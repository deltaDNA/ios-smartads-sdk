//
//  DDNASmartAdVungleAdapter.h
//  
//
//  Created by David White on 01/12/2015.
//
//

#import <Foundation/Foundation.h>
#import <DeltaDNAAds/DDNASmartAdAdapter.h>

@interface DDNASmartAdVungleAdapter : DDNASmartAdAdapter

@property (nonatomic, copy, readonly) NSString *appId;

- (instancetype)initWithAppId:(NSString *)appId
                         eCPM:(NSInteger)eCPM
               waterfallIndex:(NSInteger)waterfallIndex;

@end
