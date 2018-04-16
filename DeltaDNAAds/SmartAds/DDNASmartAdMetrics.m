//
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

#import "DDNASmartAdMetrics.h"

NSString * const kDDNALastShown = @"LastShown";
NSString * const kDDNASessionCount = @"SessionCount";
NSString * const kDDNADailyCount = @"DailyCount";
NSString * const kDDNACollectedDecisionPoints = @"com.deltadna.ads.metrics.CollectedDecisionPoints";

@interface DDNASmartAdMetrics()

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSMutableDictionary *metrics;
@property (nonatomic, assign) BOOL newDay;

@end

@implementation DDNASmartAdMetrics

- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    if ((self = [super init])) {
        self.userDefaults = userDefaults;
    }
    return self;
}

- (NSDate *)lastShownAtDecisionPoint:(NSString *)decisionPoint
{
    [self validateDecisionPoint:decisionPoint];
    return [self objectForDecisionPoint:decisionPoint withKey:kDDNALastShown];
}

- (NSInteger)sessionCountAtDecisionPoint:(NSString *)decisionPoint
{
    [self validateDecisionPoint:decisionPoint];
    return [[self objectForDecisionPoint:decisionPoint withKey:kDDNASessionCount] integerValue];
}

- (NSInteger)dailyCountAtDecisionPoint:(NSString *)decisionPoint
{
    [self validateDecisionPoint:decisionPoint];
    return [[self objectForDecisionPoint:decisionPoint withKey:kDDNADailyCount] integerValue];
}

- (NSArray<NSString *> *)collectedDecisionPoints
{
    return [self.userDefaults stringArrayForKey:kDDNACollectedDecisionPoints];
}

- (void)recordAdShownAtDecisionPoint:(NSString *)decisionPoint withDate:(NSDate *)date
{
    @synchronized(self)
    {
        [self validateDecisionPoint:decisionPoint];
        
        NSString *internalDecisionPoint = [self internalDecisionPoint:decisionPoint];
        NSDictionary *metrics = [self.userDefaults dictionaryForKey:internalDecisionPoint];
        
        NSInteger sessionCount = 1;
        NSInteger dailyCount = 1;
        
        if (metrics != nil) {
            sessionCount += [metrics[kDDNASessionCount] integerValue];
            dailyCount += [metrics[kDDNADailyCount] integerValue];
        }
        
        if ([self newDayStartedWithPreviousDate:metrics[kDDNALastShown] newDate:date]) {
            self.newDay = YES;
        }
        
        NSDictionary *newMetrics = @{
            kDDNALastShown: date,
            kDDNASessionCount: [NSNumber numberWithInteger:sessionCount],
            kDDNADailyCount: [NSNumber numberWithInteger:dailyCount]
        };
        
        [self.userDefaults setObject:newMetrics forKey:internalDecisionPoint];
        [self recordDecisionPoint:decisionPoint];
    }
}

- (void)newSessionWithDate:(NSDate *)date
{
    @synchronized(self)
    {
        NSArray<NSString *> *collectedDecisionPoints = [self.userDefaults stringArrayForKey:kDDNACollectedDecisionPoints];
        for (NSString *decisionPoint in collectedDecisionPoints) {
            NSString *internalDecisionPoint = [self internalDecisionPoint:decisionPoint];
            NSDictionary *metrics = [self.userDefaults dictionaryForKey:internalDecisionPoint];
            BOOL resetDailyCount = [self newDayStartedWithPreviousDate:metrics[kDDNALastShown] newDate:date] || self.newDay;
            NSDictionary *newMetrics = @{
                kDDNALastShown: metrics[kDDNALastShown],
                kDDNASessionCount: @0,
                kDDNADailyCount: resetDailyCount ? @0 : metrics[kDDNADailyCount]
            };
            [self.userDefaults setObject:newMetrics forKey:internalDecisionPoint];
        }
        
        self.newDay = NO;
    }
}

#pragma - private helpers

- (void)validateDecisionPoint:(NSString *)decisionPoint
{
    if (decisionPoint == nil || decisionPoint.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"Decision Point cannot be nil or empty" userInfo:nil]);
    }
}

- (NSString *)internalDecisionPoint:(NSString *)decisionPoint
{
    return [NSString stringWithFormat:@"com.deltadna.ads.metrics.%@", decisionPoint];
}

- (BOOL)newDayStartedWithPreviousDate:(NSDate *)previousDate newDate:(NSDate *)newDate
{
    if ([previousDate laterDate:newDate] == newDate) {
        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [currentCalendar components:NSCalendarUnitDay fromDate:previousDate toDate:newDate options:0];
        NSInteger days = [components day];
        
        if (days < 1) {
            NSInteger previousHour = 0;
            [currentCalendar getHour:&previousHour minute:NULL second:NULL nanosecond:NULL fromDate:previousDate];
            NSInteger newHour = 0;
            [currentCalendar getHour:&newHour minute:NULL second:NULL nanosecond:NULL fromDate:newDate];
            
            if (newHour < previousHour) {
                return true;
            }
            return false;
        }
        return true;
    }
    return false;
}

- (id)objectForDecisionPoint:(NSString *)decisionPoint withKey:(NSString *)key
{
    @synchronized(self)
    {
        NSDictionary *metrics = [self.userDefaults dictionaryForKey:[self internalDecisionPoint:decisionPoint]];
        if (metrics != nil) {
            return metrics[key];
        }
        return nil;
    }
}

- (void)recordDecisionPoint:(NSString *)decisionPoint
{
    NSArray<NSString *> *collectedDecisionPoints = [self.userDefaults stringArrayForKey:kDDNACollectedDecisionPoints];
    if (![collectedDecisionPoints containsObject:decisionPoint]) {
        NSMutableArray *mutableCollectedDecisionPoints = [NSMutableArray arrayWithArray:collectedDecisionPoints];
        [mutableCollectedDecisionPoints addObject:decisionPoint];
        [self.userDefaults setObject:mutableCollectedDecisionPoints forKey:kDDNACollectedDecisionPoints];
    }
}

@end
