//
//  DDNASmartAdMobFoxAdapter.h
//  
//
//  Created by David White on 10/11/2015.
//
//

#import <Foundation/Foundation.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAdAdapter.h>

@interface DDNASmartAdMobFoxAdapter : DDNASmartAdAdapter

@property (nonatomic, copy, readonly) NSString *publicationId;

- (instancetype)initWithPublicationId: (NSString *)publicationId
                                 eCPM: (NSInteger)eCPM
                       waterfallIndex: (NSInteger)waterfallIndex;

@end
