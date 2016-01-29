//
//  DDNASmartAdInMobiHelper.m
//  
//
//  Created by David White on 01/12/2015.
//
//

#import "DDNASmartAdInMobiHelper.h"
#import <DeltaDNA/DDNALog.h>
#import <InMobiSDK/IMSdk.h>
#import <InMobiSDK/IMCommonConstants.h>

@interface DDNASmartAdInMobiHelper ()

@property (nonatomic, assign) BOOL started;
@property (nonatomic, copy) NSString *accountID;

@end

@implementation DDNASmartAdInMobiHelper

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)startWithAccountID:(NSString *)accountID
{
    if (!_started) {
        [IMSdk setLogLevel:kIMSDKLogLevelDebug];
        [IMSdk initWithAccountID:accountID];
        self.accountID = accountID;
        self.started = YES;
    } else {
        if (![self.accountID isEqualToString:accountID]) {
            DDNALogWarn(@"Chartboost already started with appId='%@'", self.accountID);
        }
    }
}

- (NSString *)getVersion
{
    return [IMSdk getVersion];
}

@end
