//
//  DDNASmartAdFlurryHelper.m
//  
//
//  Created by David White on 30/11/2015.
//
//

#import "DDNASmartAdFlurryHelper.h"
#import <Flurry.h>
#import <FlurryAds.h>
#import <DeltaDNA/DDNALog.h>

@interface DDNASmartAdFlurryHelper ()

@property (nonatomic, assign) BOOL started;
@property (nonatomic, copy) NSString *apiKey;

@end

@implementation DDNASmartAdFlurryHelper

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)startSessionWithApiKey:(NSString *)apiKey testMode:(BOOL)testMode
{
    if (!self.started) {
        [Flurry setEventLoggingEnabled:testMode];
        [Flurry startSession:apiKey];
        self.apiKey = apiKey;
        self.started = YES;
    } else {
        if (![self.apiKey isEqualToString:apiKey]) {
            DDNALogWarn(@"Flurry already started with apiKey='%@'", self.apiKey);
        }
    }
}

- (NSString *)getFlurryAgentVersion
{
    return [Flurry getFlurryAgentVersion];
}

@end
