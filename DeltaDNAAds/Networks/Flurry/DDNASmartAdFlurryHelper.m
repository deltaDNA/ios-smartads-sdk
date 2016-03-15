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
