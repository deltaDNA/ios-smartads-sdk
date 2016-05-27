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

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/SmartAds/DDNASmartAdWaterfall.h>
#import "DDNASmartAdFakeAdapter.h"


SpecBegin(DDNASmartAdWaterfall)

describe(@"Waterfall", ^{
    
    it(@"with no options and no score", ^{
    
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"B" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"C" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"D" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"E" failRequest:NO]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        
        expect([waterfall resetWaterfall]).to.equal(adapters[0]);
        expect([waterfall getNextAdapter]).to.equal(adapters[1]);
        expect([waterfall getNextAdapter]).to.equal(adapters[2]);
        expect([waterfall getNextAdapter]).to.equal(adapters[3]);
        expect([waterfall getNextAdapter]).to.equal(adapters[4]);
        expect([waterfall getNextAdapter]).to.beNil();
        
        // resetting and repeating should be the same since score not changed
        expect([waterfall resetWaterfall]).to.equal(adapters[0]);
        expect([waterfall getNextAdapter]).to.equal(adapters[1]);
        expect([waterfall getNextAdapter]).to.equal(adapters[2]);
        expect([waterfall getNextAdapter]).to.equal(adapters[3]);
        expect([waterfall getNextAdapter]).to.equal(adapters[4]);
        expect([waterfall getNextAdapter]).to.beNil();
        
    });
    
    it(@"reorders from result code", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"B" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"C" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"D" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"E" failRequest:NO]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:DDNASmartAdRequestResultCodeNoFill | DDNASmartAdRequestResultCodeTimeout maxRequests:0];
        
        DDNASmartAdAdapter *currentAdapter = [waterfall resetWaterfall];
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeNoFill];
        expect(currentAdapter.score).to.equal(-1);
        
        currentAdapter = [waterfall getNextAdapter];
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeTimeout];
        expect(currentAdapter.score).to.equal(-1);
        
        currentAdapter = [waterfall getNextAdapter];
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeError];
        expect(currentAdapter.score).to.equal(0);
        
        currentAdapter = [waterfall getNextAdapter];
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeLoaded];
        expect(currentAdapter.score).to.equal(0);
        
        currentAdapter = [waterfall getNextAdapter];
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeConfiguration];
        expect(currentAdapter.score).to.equal(0);
        
        // reset //
        currentAdapter = [waterfall resetWaterfall];
        expect(waterfall.getAdapters).to.equal(@[adapters[3],adapters[0],adapters[1]]);
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeTimeout];
        expect(currentAdapter.score).to.equal(-1);
        
        currentAdapter = [waterfall getNextAdapter];
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeNoFill];
        expect(currentAdapter.score).to.equal(-1);
        
        currentAdapter = [waterfall getNextAdapter];
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeLoaded];
        expect(currentAdapter.score).to.equal(0);

        // reset //
        currentAdapter = [waterfall resetWaterfall];
        expect(waterfall.getAdapters).to.equal(@[adapters[1],adapters[3],adapters[0]]);
        
    });
    
    it(@"removes adapters", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"B" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"C" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"D" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"E" failRequest:NO]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:DDNASmartAdRequestResultCodeNoFill | DDNASmartAdRequestResultCodeTimeout maxRequests:0];
        
        expect(waterfall.getAdapters).to.equal(@[adapters[0],adapters[1],adapters[2],adapters[3],adapters[4]]);
        expect(((DDNASmartAdAdapter *)adapters[0]).waterfallIndex).to.equal(0);
        expect(((DDNASmartAdAdapter *)adapters[1]).waterfallIndex).to.equal(1);
        expect(((DDNASmartAdAdapter *)adapters[2]).waterfallIndex).to.equal(2);
        expect(((DDNASmartAdAdapter *)adapters[3]).waterfallIndex).to.equal(3);
        expect(((DDNASmartAdAdapter *)adapters[4]).waterfallIndex).to.equal(4);
        
        [waterfall removeAdapter:adapters[1]];
        [waterfall resetWaterfall];
        
        expect(waterfall.getAdapters).to.equal(@[adapters[0],adapters[2],adapters[3],adapters[4]]);
        expect(((DDNASmartAdAdapter *)adapters[0]).waterfallIndex).to.equal(0);
        expect(((DDNASmartAdAdapter *)adapters[2]).waterfallIndex).to.equal(1);
        expect(((DDNASmartAdAdapter *)adapters[3]).waterfallIndex).to.equal(2);
        expect(((DDNASmartAdAdapter *)adapters[4]).waterfallIndex).to.equal(3);
        
    });
    
    it(@"demotes adapters with max requests", ^{
        
        NSArray *adapters = @[
                              [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO],
                              [[DDNASmartAdFakeAdapter alloc] initWithName:@"B" failRequest:NO],
                              [[DDNASmartAdFakeAdapter alloc] initWithName:@"C" failRequest:NO],
                              [[DDNASmartAdFakeAdapter alloc] initWithName:@"D" failRequest:NO],
                              [[DDNASmartAdFakeAdapter alloc] initWithName:@"E" failRequest:NO]
                              ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:2];
        
        DDNASmartAdAdapter *currentAdapter = [waterfall resetWaterfall];
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeLoaded];
        expect(currentAdapter.score).to.equal(0);
        
        currentAdapter = [waterfall getNextAdapter];
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeLoaded];
        currentAdapter.score = 0;
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeLoaded];
        expect(currentAdapter.score).to.equal(-1);
        
        currentAdapter = [waterfall getNextAdapter];
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeLoaded];
        currentAdapter.score = 0;
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeLoaded];
        currentAdapter.score = 0;
        [waterfall scoreAdapter:currentAdapter withRequestCode:DDNASmartAdRequestResultCodeLoaded];
        expect(currentAdapter.score).to.equal(-1);
        
    });
    
    it(@"removes the last adapter", ^{
        
        NSArray *adapters = @[[[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO]];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:DDNASmartAdRequestResultCodeNoFill | DDNASmartAdRequestResultCodeTimeout maxRequests:0];
        
        expect(waterfall.getAdapters).to.equal(@[adapters[0]]);
        expect(((DDNASmartAdAdapter *)adapters[0]).waterfallIndex).to.equal(0);
        
        [waterfall removeAdapter:adapters[0]];
        expect([waterfall getNextAdapter]).to.beNil();
        [waterfall resetWaterfall];
        expect([waterfall getNextAdapter]).to.beNil();
    });

    
});

SpecEnd
