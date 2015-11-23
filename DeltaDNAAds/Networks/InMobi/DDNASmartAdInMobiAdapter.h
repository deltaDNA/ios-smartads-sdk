//
//  DDNASmartAdInMobiAdapter.h
//  
//
//  Created by David White on 09/11/2015.
//
//

#import <Foundation/Foundation.h>
#import <DeltaDNAAds/DDNASmartAdAdapter.h>

@interface DDNASmartAdInMobiAdapter : DDNASmartAdAdapter

@property (nonatomic, copy, readonly) NSString *accountId;
@property (nonatomic, assign, readonly) NSInteger placementId;

- (instancetype)initWithAccountId: (NSString *)accountId
                      placementId: (NSInteger)placementId
                             eCPM: (NSInteger)eCPM
                   waterfallIndex: (NSInteger)waterfallIndex;

@end
