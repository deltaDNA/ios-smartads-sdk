//
//  DDNAFakeEngageService.m
//  SmartAds
//
//  Created by David White on 16/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "DDNAFakeEngageService.h"


@implementation DDNAFakeEngageService

- (instancetype)initWithResponse:(NSString *)response statusCode:(NSInteger)statusCode error: (NSError *)error
{
    if ((self = [super init])) {
        self.response = response;
        self.statusCode = statusCode;
        self.error = error;
    }
    return self;
}

- (void)requestWithDecisionPoint:(NSString *)decisionPoint flavour:(DDNADecisionPointFlavour)flavour parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSString *, NSInteger, NSError *))handler
{
    handler(self.response, self.statusCode, self.error);
}

@end
