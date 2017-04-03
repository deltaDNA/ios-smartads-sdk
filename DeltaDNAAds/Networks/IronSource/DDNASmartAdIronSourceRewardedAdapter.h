//
//  DDNASmartAdIronSourceRewardedAdapter.h
//  
//
//  Created by David White on 03/04/2017.
//
//

#import <UIKit/UIKit.h>
#import "DeltaDNAAds/SmartAds/DDNASmartAdAdapter.h"

@interface DDNASmartAdIronSourceRewardedAdapter : DDNASmartAdAdapter

@property (nonatomic, copy, readonly) NSString *appKey;

- (instancetype)initWithAppKey:(NSString *)appKey
                         eCPM:(NSInteger)eCPM
               waterfallIndex:(NSInteger)waterfallIndex;
@end
