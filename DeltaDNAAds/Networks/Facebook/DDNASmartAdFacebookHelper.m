//
// Copyright (c) 2017 deltaDNA Ltd. All rights reserved.
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

#import "DDNASmartAdFacebookHelper.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface DDNASmartAdFacebookHelper ()

@property (nonatomic, assign) BOOL testMode;

@end

@implementation DDNASmartAdFacebookHelper

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

    
- (NSString *)getSDKVersion
{
    return FB_AD_SDK_VERSION;
}
    
- (void)setTestMode:(BOOL)enable
{
    if (enable && !_testMode) {
        [FBAdSettings setLogLevel:FBAdLogLevelVerbose];
        [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
    }
    else if (!enable && _testMode) {
        [FBAdSettings setLogLevel:FBAdLogLevelNone];
        [FBAdSettings clearTestDevice:[FBAdSettings testDeviceHash]];
    }
}
    
- (DDNASmartAdRequestResultCode)resultCodeFromError:(NSError *)error
{
    switch (error.code) {
        case 1000: return DDNASmartAdRequestResultCodeNetwork;
        case 1001: return DDNASmartAdRequestResultCodeNoFill;
        case 1002: return DDNASmartAdRequestResultCodeMaxRequests;
        default: return DDNASmartAdRequestResultCodeError;
    }
}
    
@end
