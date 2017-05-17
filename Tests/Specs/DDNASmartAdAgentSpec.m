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
        dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); /*dispatch_get_main_queue();*/
        [given([delegate getDispatchQueue]) willReturn:dispatchQueue];
        mockViewController = mock([UIViewController class]);
    });
    
    it(@"with successful adapters returns first one", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A"],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"B"],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"C"]
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
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" resultCode:DDNASmartAdRequestResultCodeNoFill],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"B" resultCode:DDNASmartAdRequestResultCodeNoFill],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"C" resultCode:DDNASmartAdRequestResultCodeLoaded]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        // Creating an AdAgent loads the first adapter from the waterfall.
        expect(agent.currentAdapter).toNot.beNil();
        expect(agent.currentAdapter).to.equal(adapters[0]);
        expect([agent hasLoadedAd]).to.beFalsy();
        
        [agent requestAd];

        // It should load from the 3rd adapter
        expect([agent hasLoadedAd]).will.beTruthy();
        expect(agent.currentAdapter).willNot.beNil();
        expect(agent.currentAdapter).will.equal(adapters[2]);
        
        [[verifyCount(delegate, times(1)) withMatcher:anything() forArgument:2] adAgent:agent didFailToLoadAdWithAdapter:adapters[0] requestTime:0 requestResult:anything()];
        
        [[verifyCount(delegate, times(1)) withMatcher:anything() forArgument:2] adAgent:agent didFailToLoadAdWithAdapter:adapters[1] requestTime:0 requestResult:anything()];
        
        [[verifyCount(delegate, times(1)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[2] requestTime:0];
        
        
        // After closing the ad, the waterfall is reset to the beginning again.
        [(DDNASmartAdFakeAdapter *)agent.currentAdapter showAdFromViewController:nil];
        [(DDNASmartAdFakeAdapter *)agent.currentAdapter closeAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        expect(agent.currentAdapter).willNot.beNil();
        expect(agent.currentAdapter).will.equal(adapters[0]);
        [[verifyCount(delegate, times(1)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[0] requestTime:0];
    });
    
    it(@"shows ad",^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A"]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        [agent requestAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        expect([agent isShowingAd]).will.beTruthy();
        
        [adapters[0] closeAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        expect([agent decisionPoint]).to.equal(@"testDecisionPoint");
        
        [[verifyCount(delegate, times(2)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[0] requestTime:0];
        [verifyCount(delegate, times(1)) adAgent:agent didCloseAdWithAdapter:adapters[0] canReward:YES];
    });
    
    it(@"fails with one adapter", ^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" resultCode:DDNASmartAdRequestResultCodeTimeout]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        [agent requestAd];

        expect([agent hasLoadedAd]).will.beFalsy();
    });
    
    it(@"reports when an ad fails to open", ^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failToShow:YES],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"B"]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        [agent requestAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        
        [[verifyCount(delegate, times(1)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[0] requestTime:0];
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];

        // adapter should have been removed from waterfall.
        expect(waterfall.getAdapters.count).will.equal(1);
        expect([agent isShowingAd]).will.beFalsy();
        expect([agent hasLoadedAd]).will.beTruthy();
        expect(agent.currentAdapter).to.equal(adapters[1]);
        
        [[verifyCount(delegate, times(1)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[1] requestTime:0];
        [verifyCount(delegate, times(1)) adAgent:agent didFailToOpenAdWithAdapter:adapters[0] closedResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
    });
    
    it(@"reports when ad ad was clicked", ^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A"]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        [agent requestAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        expect([agent isShowingAd]).will.beTruthy();
        
        [adapters[0] clickAdAndLeaveApplication:NO];
        
        expect([agent adWasClicked]).to.beTruthy();
        expect([agent adLeftApplication]).to.beFalsy();

    });
    
    it(@"reports when ad ad left the app", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A"]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        [agent requestAd];

        expect([agent hasLoadedAd]).will.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        expect([agent isShowingAd]).will.beTruthy();
        
        [adapters[0] clickAdAndLeaveApplication:YES];
        
        expect([agent adWasClicked]).to.beTruthy();
        expect([agent adLeftApplication]).to.beTruthy();
        
    });

    it(@"respects ad request limit", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A"]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall adLimit:@5];
        agent.delegate = delegate;
        
        for (int i = 0; i < 5; ++i) {
            [agent requestAd];
            expect([agent hasLoadedAd]).will.beTruthy();
            [agent showAdFromRootViewController:mockViewController decisionPoint:nil];
            expect([agent isShowingAd]).will.beTruthy();
            [adapters[0] closeAd];
        }
        
        [agent requestAd];
        expect([agent hasLoadedAd]).will.beFalsy();
    });
    
    it(@"continues to request ads if no ad limit", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A"]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall adLimit:nil];
        agent.delegate = delegate;
        
        for (int i = 0; i < 5; ++i) {
            [agent requestAd];
            expect([agent hasLoadedAd]).will.beTruthy();
            [agent showAdFromRootViewController:mockViewController decisionPoint:nil];
            expect([agent isShowingAd]).will.beTruthy();
            [adapters[0] closeAd];
        }
        
        [agent requestAd];
        expect([agent hasLoadedAd]).will.beTruthy();
    });
    
    it(@"requests no ads if ad limit is 0", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A"]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall adLimit:@0];
        agent.delegate = delegate;
        
        [agent requestAd];
        expect([agent hasLoadedAd]).will.beFalsy();
    });
    
    it(@"cascades through waterfall with demote on no fill and two networks", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" resultCode:DDNASmartAdRequestResultCodeNoFill],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"B" resultCode:DDNASmartAdRequestResultCodeLoaded]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters
                                                                         demoteOnOptions:DDNASmartAdRequestResultCodeNoFill
                                                                             maxRequests:0];
        
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall adLimit:nil];
        agent.delegate = delegate;
        
        expect(agent.currentAdapter).to.equal(adapters[0]);
        [agent requestAd];
        expect([agent hasLoadedAd]).will.beTruthy();
        expect(agent.currentAdapter).to.equal(adapters[1]);
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        expect([agent isShowingAd]).will.beTruthy();
        
        [adapters[1] closeAd];
        expect(agent.currentAdapter).to.equal(adapters[1]);
        expect(waterfall.getAdapters).to.equal(@[adapters[1], adapters[0]]);

    });

        
    it(@"waits before restarting waterfall", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" resultCodes:@[
                [NSNumber numberWithUnsignedInteger:DDNASmartAdRequestResultCodeNoFill],
                [NSNumber numberWithUnsignedInteger:DDNASmartAdRequestResultCodeNoFill]]],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"B" resultCodes:@[
                [NSNumber numberWithUnsignedInteger:DDNASmartAdRequestResultCodeNoFill],
                [NSNumber numberWithUnsignedInteger:DDNASmartAdRequestResultCodeLoaded]]]
        ];
        
        const int kWaterfallDelay = 5;
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters
                                                                         demoteOnOptions:DDNASmartAdRequestResultCodeNoFill
                                                                             maxRequests:0];
        
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall adLimit:nil];
        agent.delegate = delegate;
        agent.adWaterfallRestartDelaySeconds = kWaterfallDelay;
        
        expect(agent.currentAdapter).to.equal(adapters[0]);
        
        [agent requestAd];

        // this will fail and it will run out of adapters.
        expect(agent.currentAdapter).will.beNil();
        
        [[verify(delegate) withMatcher:anything() forArgument:2] adAgent:agent didFailToLoadAdWithAdapter:adapters[0] requestTime:0 requestResult:anything()];

        [[verify(delegate) withMatcher:anything() forArgument:2] adAgent:agent didFailToLoadAdWithAdapter:adapters[1] requestTime:0 requestResult:anything()];

        // then it will load an ad from the second adapter
        expect(agent.currentAdapter).after(kWaterfallDelay).will.equal(adapters[1]);
        expect(agent.hasLoadedAd).will.beTruthy();
        
        [[verifyCount(delegate, times(2)) withMatcher:anything() forArgument:2] adAgent:agent didFailToLoadAdWithAdapter:adapters[0] requestTime:0 requestResult:anything()];
        
        [[verify(delegate) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[1] requestTime:0];
        
    });
    
    it(@"waits and removes failed adapters", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" resultCodes:@[
                [NSNumber numberWithUnsignedInteger:DDNASmartAdRequestResultCodeError],
                [NSNumber numberWithUnsignedInteger:DDNASmartAdRequestResultCodeNoFill]]],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"B" resultCodes:@[
                [NSNumber numberWithUnsignedInteger:DDNASmartAdRequestResultCodeNoFill],
                [NSNumber numberWithUnsignedInteger:DDNASmartAdRequestResultCodeLoaded]]]
        ];
        
        const int kWaterfallDelay = 5;
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters
                                                                         demoteOnOptions:DDNASmartAdRequestResultCodeNoFill
                                                                             maxRequests:0];
        
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall adLimit:nil];
        agent.delegate = delegate;
        agent.adWaterfallRestartDelaySeconds = kWaterfallDelay;
        
        expect(agent.currentAdapter).to.equal(adapters[0]);
        
        [agent requestAd];
        
        // this will fail and it will run out of adapters.
        expect(agent.currentAdapter).will.beNil();
        
        [[verify(delegate) withMatcher:anything() forArgument:2] adAgent:agent didFailToLoadAdWithAdapter:adapters[0] requestTime:0 requestResult:anything()];
        
        [[verify(delegate) withMatcher:anything() forArgument:2] adAgent:agent didFailToLoadAdWithAdapter:adapters[1] requestTime:0 requestResult:anything()];
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:nil];
        
        
        // then it will load an ad from the first adapter
        expect(agent.currentAdapter).after(kWaterfallDelay).will.equal(adapters[1]);
        expect(agent.hasLoadedAd).will.beTruthy();
        // and the waterfall will only have that adapter in it
        expect(waterfall.getAdapters).to.equal(@[adapters[1]]);
        
        [[verify(delegate) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[1] requestTime:0];
        
        // confirm got the failed to open callback when we tried to show an ad
        MKTArgumentCaptor *captor = [MKTArgumentCaptor new];
        [verify(delegate) adAgent:agent didFailToOpenAdWithAdapter:nilValue() closedResult:[captor capture]];
        DDNASmartAdClosedResult *result = captor.value;
        expect(result.code).to.equal(DDNASmartAdClosedResultCodeNotReady);
        
    });
    
});

SpecEnd
