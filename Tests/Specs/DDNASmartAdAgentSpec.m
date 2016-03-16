//
//  DDNASmartAdAgentSpec.m
//  SmartAds
//
//  Created by David White on 13/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
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
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        
        [[verify(delegate) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[0] requestTime:0];
        expect([agent hasLoadedAd]).to.beTruthy();
        expect(agent.currentAdapter).toNot.beNil();
        expect(agent.currentAdapter).to.equal(adapters[0]);
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
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];

        [[verifyCount(delegate, times(1)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[2] requestTime:0];
        expect([agent hasLoadedAd]).to.beTruthy();
        // AdAgent should still use the same adapter after a successfull load.
        expect(agent.currentAdapter).toNot.beNil();
        expect(agent.currentAdapter).to.equal(adapters[2]);
        
        // After closing the ad, the waterfall is reset to the beginning again.
        [(DDNASmartAdFakeAdapter *)agent.currentAdapter showAdFromViewController:nil];
        [(DDNASmartAdFakeAdapter *)agent.currentAdapter closeAd];
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        // This only works when not running in a thread!
        //[[verifyCount(delegate, times(2)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[2] requestTime:0];
        expect(agent.currentAdapter).toNot.beNil();
        expect(agent.currentAdapter).to.equal(adapters[2]);
    });
    
    it(@"shows ad",^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        [agent requestAd];
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([agent hasLoadedAd]).to.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        expect([agent isShowingAd]).to.beTruthy();
        
        [adapters[0] closeAd];
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
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
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];

        expect([agent hasLoadedAd]).to.beFalsy();
    });
    
    it(@"reports when an ad fails to open", ^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO failOpen:YES]
        ];
        
        DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:adapters demoteOnOptions:0 maxRequests:0];
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
        agent.delegate = delegate;
        
        [agent requestAd];
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([agent hasLoadedAd]).to.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([agent isShowingAd]).to.beFalsy();
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
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([agent hasLoadedAd]).to.beTruthy();
        
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
        
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
        
        expect([agent hasLoadedAd]).to.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController decisionPoint:@"testDecisionPoint"];
        
        expect([agent isShowingAd]).to.beTruthy();
        
        [adapters[0] clickAdAndLeaveApplication:YES];
        
        expect([agent adWasClicked]).to.beTruthy();
        expect([agent adLeftApplication]).to.beTruthy();
        
    });

    
});

SpecEnd
