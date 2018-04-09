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

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/SmartAds/DDNASmartAdMetrics.h>

SpecBegin(DDNASmartAdMetrics)

NSString * const SUITE_NAME = @"com.deltadna.test.SmartAdMetrics";

describe(@"SmartAd metrics", ^{
    
    __block NSUserDefaults *userDefaults;
    __block DDNASmartAdMetrics *metrics;
    
    beforeEach(^{
        [[[NSUserDefaults alloc] init] removePersistentDomainForName:SUITE_NAME];
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:SUITE_NAME];
        metrics = [[DDNASmartAdMetrics alloc] initWithUserDefaults:userDefaults];
    });
    
    it(@"record showing an", ^{

        NSDate *testDate = [NSDate date];
        NSString *decisionPoint = @"testDecisionPoint";
        
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.beNil();
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(0);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(0);
        
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:testDate];
        
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).toNot.beNil();
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(testDate);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(1);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(1);
        expect([[metrics collectedDecisionPoints] count]).to.equal(1);
        expect([[metrics collectedDecisionPoints] containsObject:decisionPoint]).to.beTruthy();
        
        NSDate *testDate2 = [NSDate date];
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:testDate2];
        
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(testDate2);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(2);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(2);
        expect([[metrics collectedDecisionPoints] count]).to.equal(1);
        expect([[metrics collectedDecisionPoints] containsObject:decisionPoint]).to.beTruthy();
        
        NSDate *testDate3 = [NSDate date];
        NSString *decisionPoint2 = @"testDecisionPoint2";
        [metrics recordAdShownAtDecisionPoint:decisionPoint2 withDate:testDate3];
        
        expect([metrics lastShownAtDecisionPoint:decisionPoint2]).toNot.beNil();
        expect([metrics lastShownAtDecisionPoint:decisionPoint2]).to.equal(testDate3);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint2]).to.equal(1);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint2]).to.equal(1);
        expect([[metrics collectedDecisionPoints] count]).to.equal(2);
        expect([[metrics collectedDecisionPoints] containsObject:decisionPoint2]).to.beTruthy();
        
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(testDate2);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(2);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(2);
        
    });
    
    it(@"resets session counts", ^{
        NSDate *testDate = [NSDate date];
        NSString *decisionPoint = @"testDecisionPoint";
        
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:testDate];
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:testDate];
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(testDate);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(2);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(2);
        
        [metrics newSessionWithDate:testDate];
        
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(testDate);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(0);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(2);
        
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:testDate];
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:testDate];
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:testDate];
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:testDate];
        
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(testDate);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(4);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(6);
        
        [metrics newSessionWithDate:testDate];
        
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(testDate);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(0);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(6);
        
    });
    
    it(@"reset daily counts when next day is a new session", ^{
        NSDate *testDate = [NSDate date];
        NSString *decisionPoint = @"testDecisionPoint";
        
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:testDate];
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:testDate];
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(testDate);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(2);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(2);
        
        // Next date
        NSDate *nextDay = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:testDate options:0];
        
        // New session started
        [metrics newSessionWithDate:nextDay];
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(testDate);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(0);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(0);
        
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:nextDay];
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(nextDay);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(1);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(1);
    });
    
    it(@"reset daily counts when next day is same session", ^{
        NSDate *testDate = [NSDate date];
        NSString *decisionPoint = @"testDecisionPoint";
        
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:testDate];
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:testDate];
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(testDate);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(2);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(2);
        
        NSDate *nextDay = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:testDate options:0];
        
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:nextDay];
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(nextDay);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(3);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(3);
        
        // Later on a new session happens
        [metrics newSessionWithDate:nextDay];
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(nextDay);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(0);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(0);
        
        [metrics recordAdShownAtDecisionPoint:decisionPoint withDate:nextDay];
        expect([metrics lastShownAtDecisionPoint:decisionPoint]).to.equal(nextDay);
        expect([metrics sessionCountAtDecisionPoint:decisionPoint]).to.equal(1);
        expect([metrics dailyCountAtDecisionPoint:decisionPoint]).to.equal(1);
    });
});

SpecEnd
