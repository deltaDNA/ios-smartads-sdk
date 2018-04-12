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

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, DDNASmartAdRequestResultCode) {
    DDNASmartAdRequestResultCodeLoaded          = 0,
    DDNASmartAdRequestResultCodeNoFill          = 1 << 0,
    DDNASmartAdRequestResultCodeNetwork         = 1 << 1,
    DDNASmartAdRequestResultCodeTimeout         = 1 << 2,
    DDNASmartAdRequestResultCodeMaxRequests     = 1 << 3,
    DDNASmartAdRequestResultCodeConfiguration   = 1 << 4,
    DDNASmartAdRequestResultCodeError           = 1 << 5
};

@interface DDNASmartAdRequestResult : NSObject

@property (nonatomic, assign, readonly) DDNASmartAdRequestResultCode code;
@property (nonatomic, copy, readonly) NSString *desc;
@property (nonatomic, copy) NSString *errorDescription;

+ (instancetype)resultWith:(DDNASmartAdRequestResultCode)code;
+ (instancetype)resultWith:(DDNASmartAdRequestResultCode)code errorDescription:(NSString *)errorDescription;

@end

typedef NS_ENUM(NSInteger, DDNASmartAdShowResultCode) {
    DDNASmartAdShowResultCodeFulfilled,
    DDNASmartAdShowResultCodeAdShowPoint,
    DDNASmartAdShowResultCodeAdSessionLimitReached,
    DDNASmartAdShowResultCodeAdSessionDecisionPointLimitReached,
    DDNASmartAdShowResultCodeAdDailyDecisionPointLimitReached,
    DDNASmartAdShowResultCodeMinTimeNotElapsed,
    DDNASmartAdShowResultCodeMinTimeDecisionPointNotElapsed,
    DDNASmartAdShowResultCodeEngageFailed,
    DDNASmartAdShowResultCodeNotLoaded,
    DDNASmartAdShowResultCodeExpired,
    DDNASmartAdShowResultCodeError
};

@interface DDNASmartAdShowResult : NSObject

@property (nonatomic, assign, readonly) DDNASmartAdShowResultCode code;
@property (nonatomic, copy, readonly) NSString *desc;

+ (instancetype)resultWith:(DDNASmartAdShowResultCode)code;

@end


