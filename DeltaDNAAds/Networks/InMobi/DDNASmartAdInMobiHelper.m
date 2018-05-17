//
// Copyright (c) 2016 deltaDNA Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "DDNASmartAdInMobiHelper.h"
#import "DDNASmartAdPrivacy.h"
#import <DeltaDNA/DDNALog.h>
#import <InMobiSDK/InMobiSDK.h>


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

- (void)startWithAccountID:(NSString *)accountID privacy:(DDNASmartAdPrivacy *)privacy testMode:(BOOL)testMode
{
    if (!_started) {
        if (testMode) {
            [IMSdk setLogLevel:kIMSDKLogLevelDebug];
        }
        NSDictionary *consent = @{
            IM_GDPR_CONSENT_AVAILABLE: privacy.hasAdvertiserGdprUserConsent ? @"true" : @"false"
        };
        [IMSdk initWithAccountID:accountID consentDictionary:consent];
        self.accountID = accountID;
        self.started = YES;
    } else {
        if (![self.accountID isEqualToString:accountID]) {
            DDNALogWarn(@"InMobi already started with accountId='%@'", self.accountID);
        }
    }
}

- (NSString *)getVersion
{
    return [IMSdk getVersion];
}

@end
