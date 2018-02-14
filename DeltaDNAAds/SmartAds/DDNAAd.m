// Copyright (c) 2018 deltaDNA Ltd. All rights reserved.
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

#import "DDNAAd.h"
#import "DDNASmartAds.h"
#import <DeltaDNA/DDNAEngagement.h>


@interface DDNAAd ()

@property (nonatomic, strong) DDNAEngagement *engagement;

@end

@implementation DDNAAd

- (instancetype)initWithEngagement:(nullable DDNAEngagement *)engagement
{
    if ((self = [super init])) {
        if (engagement != nil && engagement.json != nil && engagement.json[@"parameters"] != nil) {
            self.engagement = engagement;
        }
    }
    return self;
}

- (BOOL)isReady
{
    [self doesNotRecognizeSelector:_cmd];
    return false;
}

- (void)showFromRootViewController:(UIViewController *)viewController
{
    [self doesNotRecognizeSelector:_cmd];
}

- (NSString *)decisionPoint
{
    return self.engagement ? self.engagement.decisionPoint : nil;
}

- (NSDictionary *)parameters
{
    if (self.engagement && self.engagement.json && self.engagement.json[@"parameters"]) {
        return self.engagement.json[@"parameters"];
    }
    return @{};
}

- (NSDate *)lastShown
{
    return self.decisionPoint ? [[DDNASmartAds sharedInstance] lastShownForDecisionPoint:self.decisionPoint] : nil;
}

- (NSInteger)showWaitSecs
{
    return [self parameters] ? [([self parameters][@"ddnaAdShowWaitSecs"]) integerValue] : 0;
}

- (NSInteger)sessionCount
{
    return self.decisionPoint ? [[DDNASmartAds sharedInstance] sessionCountForDecisionPoint:self.decisionPoint] : 0;
}

- (NSInteger)sessionLimit
{
    return [self parameters] ? [([self parameters][@"ddnaAdSessionCount"]) integerValue] : 0;
}

- (NSInteger)dailyCount
{
    return self.decisionPoint ? [[DDNASmartAds sharedInstance] dailyCountForDecisionPoint:self.decisionPoint] : 0;
}

- (NSInteger)dailyLimit
{
    return [self parameters] ? [([self parameters][@"ddnaAdDailyCount"]) integerValue] : 0;
}

@end
