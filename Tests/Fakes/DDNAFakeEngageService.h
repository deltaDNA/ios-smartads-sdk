//
//  DDNAFakeEngageService.h
//  SmartAds
//
//  Created by David White on 16/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import <DeltaDNA/DDNAEngageService.h>

@interface DDNAFakeEngageService : DDNAEngageService

@property (nonatomic, copy) NSString *response;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSError *error;

- (instancetype)initWithResponse:(NSString *)response statusCode:(NSInteger)statusCode error: (NSError *)error;

@end
