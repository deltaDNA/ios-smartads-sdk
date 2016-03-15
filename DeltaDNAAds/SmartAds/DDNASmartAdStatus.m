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
    return [DDNASmartAdRequestResult resultWith:code error:nil];
}

+ (instancetype)resultWith:(DDNASmartAdRequestResultCode)code error:(NSString *)error
{
    DDNASmartAdRequestResult *result = [[DDNASmartAdRequestResult alloc] init];
    result.code = code;
    result.desc = [DDNASmartAdRequestResult stringFromResultCode:code];
    result.error = error;
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
        case DDNASmartAdShowResultCodeNoAdAvailable:
            return @"No ad was available";
        case DDNASmartAdShowResultCodeAdShowPoint:
            return @"adShowPoint was false";
        case DDNASmartAdShowResultCodeAdSessionLimitReached:
            return @"Session limit reached";
        case DDNASmartAdShowResultCodeMinTimeNotElapsed:
            return @"adMinimumInterval not elapsed";
        case DDNASmartAdShowResultCodeNotReady:
            return @"Not ready";
        case DDNASmartAdShowResultCodeEngageFailed:
            return @"Enage hit failed, showing ad anyway";
        default:
            return nil;
    }
}

@end

@interface DDNASmartAdClosedResult ()

@property (nonatomic, assign) DDNASmartAdClosedResultCode code;
@property (nonatomic, copy) NSString *desc;

@end

@implementation DDNASmartAdClosedResult

+ (instancetype)resultWith:(DDNASmartAdClosedResultCode)code
{
    DDNASmartAdClosedResult *result = [[DDNASmartAdClosedResult alloc] init];
    result.code = code;
    result.desc = [DDNASmartAdClosedResult stringFromResultCode:code];
    return result;
}

+ (NSString *)stringFromResultCode: (DDNASmartAdClosedResultCode)resultCode
{
    switch (resultCode) {
        case DDNASmartAdClosedResultCodeSuccess:
            return @"Success";
        case DDNASmartAdClosedResultCodeExpired:
            return @"Expired";
        case DDNASmartAdClosedResultCodeError:
            return @"Error";
        case DDNASmartAdClosedResultCodeNotReady:
            return @"Not Ready";
        default:
            return nil;
    }
}

- (BOOL)isEqualToClosedResult:(DDNASmartAdClosedResult *)closedResult
{
    if (!closedResult) return NO;
    
    BOOL haveEqualCodes = self.code == closedResult.code;
    
    return haveEqualCodes;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) return YES;
    
    if (![object isKindOfClass:[DDNASmartAdClosedResult class]]) return NO;
    
    return [self isEqualToClosedResult:(DDNASmartAdClosedResult *)object];
}

- (NSUInteger)hash
{
    return [self.desc hash];
}



@end

