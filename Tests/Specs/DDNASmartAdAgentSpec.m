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

#import <DeltaDNAAds/SmartAds/DDNASmartAdAgent.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAdWaterfall.h>
#import "DDNASmartAdFakeAdapter.h"

SpecBegin(DDNASmartAdAgent)

describe(@"ad agent", ^{
    
    __block id <DDNASmartAdAgentDelegate> delegate;
    __block UIViewController *mockViewController;
    __block dispatch_queue_t dispatchQueue;
    
    beforeEach(^{
        delegate = mockProtocol(@protocol(DDNASmartAdAgentDelegate));
        dispatchQueue = dispatch_get_main_queue(); 
        [given([delegate getDispatchQueue]) willReturn:dispatchQueue];
        mockViewController = mock([UIViewController class]);
    });
    
    it(@"with successful adapters returns first one", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"B" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"C" failRequest:NO]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        expect(agent.currentAdapter).toNot.beNil();
        expect(agent.currentAdapter).to.equal(adapters[0]);
        expect([agent hasLoadedAd]).to.beFalsy();
        
        [agent requestAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        expect(agent.currentAdapter).willNot.beNil();
        expect(agent.currentAdapter).will.equal(adapters[0]);
        
        [[verify(delegate) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[0] requestTime:0];
    });
    
    it(@"with failing adapters returns last one", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:YES],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"B" failRequest:YES],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"C" failRequest:NO]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        // Creating an AdAgent loads the first adapter from the waterfall.
        expect(agent.currentAdapter).toNot.beNil();
        expect(agent.currentAdapter).to.equal(adapters[0]);
        expect([agent hasLoadedAd]).to.beFalsy();
        
        [agent requestAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        // AdAgent should still use the same adapter after a successfull load.
        expect(agent.currentAdapter).willNot.beNil();
        expect(agent.currentAdapter).will.equal(adapters[2]);
        
        [[verifyCount(delegate, times(1)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[2] requestTime:0];
        
        
        // After closing the ad, the waterfall is reset to the beginning again.
        [(DDNASmartAdFakeAdapter *)agent.currentAdapter showAdFromViewController:nil];
        [(DDNASmartAdFakeAdapter *)agent.currentAdapter closeAd];

        // This only works when not running in a thread!
        expect([agent hasLoadedAd]).will.beTruthy();
        expect(agent.currentAdapter).willNot.beNil();
        expect(agent.currentAdapter).will.equal(adapters[2]);
        [[verifyCount(delegate, times(2)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[2] requestTime:0];
    });
    
    it(@"shows ad",^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        [agent requestAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        expect([agent isShowingAd]).to.beTruthy();
        
        [adapters[0] closeAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        expect([agent decisionPoint]).to.equal(@"testDecisionPoint");
        
        [[verifyCount(delegate, times(2)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[0] requestTime:0];
        [verifyCount(delegate, times(1)) adAgent:agent didCloseAdWithAdapter:adapters[0] canReward:YES];
    });
    
    it(@"fails with one adapter", ^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:YES]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        [agent requestAd];

        expect([agent hasLoadedAd]).will.beFalsy();
    });
    
    it(@"reports when an ad fails to open", ^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO failOpen:YES]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        [agent requestAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];

        expect([agent isShowingAd]).will.beFalsy();
        expect([agent hasLoadedAd]).will.beTruthy();
        expect(agent.currentAdapter).to.equal(adapters[0]);
        
        [[verifyCount(delegate, times(2)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[0] requestTime:0];
        [verifyCount(delegate, times(1)) adAgent:agent didFailToOpenAdWithAdapter:adapters[0] closedResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
    });
    
    it(@"reports when ad ad was clicked", ^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        [agent requestAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        expect([agent isShowingAd]).to.beTruthy();
        
        [adapters[0] clickAdAndLeaveApplication:NO];
        
        expect([agent adWasClicked]).to.beTruthy();
        expect([agent adLeftApplication]).to.beFalsy();

    });
    
    it(@"reports when ad ad left the app", ^{
        
        NSArray *adapters = @[
                              [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO]
                              ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        [agent requestAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        expect([agent isShowingAd]).to.beTruthy();
        
        [adapters[0] clickAdAndLeaveApplication:YES];
        
        expect([agent adWasClicked]).to.beTruthy();
        expect([agent adLeftApplication]).to.beTruthy();
        
    });

    
});

SpecEnd
