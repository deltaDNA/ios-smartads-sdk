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

#import "DDNASmartAdStatus.h"


@interface DDNASmartAdRequestResult ()

@property (nonatomic, assign) DDNASmartAdRequestResultCode code;
@property (nonatomic, copy) NSString *desc;

@end

@implementation DDNASmartAdRequestResult

+ (instancetype)resultWith:(DDNASmartAdRequestResultCode)code
{
    return [DDNASmartAdRequestResult resultWith:code errorDescription:nil];
}

+ (instancetype)resultWith:(DDNASmartAdRequestResultCode)code errorDescription:(NSString *)errorDescription
{
    DDNASmartAdRequestResult *result = [[DDNASmartAdRequestResult alloc] init];
    result.code = code;
    result.desc = [DDNASmartAdRequestResult stringFromResultCode:code];
    result.errorDescription = errorDescription;
    return result;
}

+ (NSString *)stringFromResultCode:(DDNASmartAdRequestResultCode)resultCode
{
    switch (resultCode) {
        case DDNASmartAdRequestResultCodeLoaded:
            return @"Loaded";
        case DDNASmartAdRequestResultCodeNoFill:
            return @"NoFill";
        case DDNASmartAdRequestResultCodeNetwork:
            return @"Network";
        case DDNASmartAdRequestResultCodeTimeout:
            return @"Timeout";
        case DDNASmartAdRequestResultCodeMaxRequests:
            return @"MaxRequests";
        case DDNASmartAdRequestResultCodeConfiguration:
            return @"Configuration";
        case DDNASmartAdRequestResultCodeError:
            return @"Error";
        default:
            return @"Unknown";
    }
}

@end

@interface DDNASmartAdShowResult ()

@property (nonatomic, assign) DDNASmartAdShowResultCode code;
@property (nonatomic, copy) NSString *desc;

@end

@implementation DDNASmartAdShowResult

+ (instancetype)resultWith:(DDNASmartAdShowResultCode)code
{
    DDNASmartAdShowResult *result = [[DDNASmartAdShowResult alloc] init];
    result.code = code;
    result.desc = [DDNASmartAdShowResult stringFromResultCode:code];
    return result;
}

+ (NSString *)stringFromResultCode: (DDNASmartAdShowResultCode)resultCode
{
    switch (resultCode) {
        case DDNASmartAdShowResultCodeFulfilled:
            return @"Fulfilled";
        case DDNASmartAdShowResultCodeAdShowPoint:
            return @"Engage disallowed the ad";
        case DDNASmartAdShowResultCodeAdSessionLimitReached:
            return @"Session limit reached";
        case DDNASmartAdShowResultCodeAdSessionDecisionPointLimitReached:
            return @"Session decision point limit reached";
        case DDNASmartAdShowResultCodeAdDailyDecisionPointLimitReached:
            return @"Daily decision point limit reached";
        case DDNASmartAdShowResultCodeMinTimeNotElapsed:
            return @"Minimum time not elapsed";
        case DDNASmartAdShowResultCodeMinTimeDecisionPointNotElapsed:
            return @"Minimum decision point time not elapsed";
        case DDNASmartAdShowResultCodeEngageFailed:
            return @"Engage failed";
        case DDNASmartAdShowResultCodeNotLoaded:
            return @"Not loaded";
        case DDNASmartAdShowResultCodeExpired:
            return @"Expired";
        case DDNASmartAdShowResultCodeError:
            return @"Error";
        default:
            return nil;
    }
}

@end


