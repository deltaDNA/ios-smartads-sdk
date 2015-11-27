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

#import <DeltaDNAAds/DDNASmartAdAgent.h>
#import "DDNASmartAdFakeAdapter.h"

SpecBegin(DDNASmartAdAgent)

describe(@"ad agent", ^{
    
    __block id <DDNASmartAdAgentDelegate> delegate;
    __block UIViewController *mockViewController;
    
    beforeEach(^{
        delegate = mockProtocol(@protocol(DDNASmartAdAgentDelegate));
        mockViewController = mock([UIViewController class]);
    });
    
    it(@"with successful adapters returns first one", ^{
        
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"B" failRequest:NO],
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"C" failRequest:NO]
        ];
        
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithAdapters:adapters];
        agent.delegate = delegate;
        
        expect(agent.currentAdapter).toNot.beNil();
        expect(agent.currentAdapter).to.equal(adapters[0]);
        expect([agent hasLoadedAd]).to.beFalsy();
        
        [agent requestAd];
        
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
        
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithAdapters:adapters];
        agent.delegate = delegate;
        
        // Creating an AdAgent loads the first adapter from the waterfall.
        expect(agent.currentAdapter).toNot.beNil();
        expect(agent.currentAdapter).to.equal(adapters[0]);
        expect([agent hasLoadedAd]).to.beFalsy();
        
        [agent requestAd];

        [[verifyCount(delegate, times(1)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[2] requestTime:0];
        expect([agent hasLoadedAd]).to.beTruthy();
        // AdAgent should still use the same adapter after a successfull load.
        expect(agent.currentAdapter).toNot.beNil();
        expect(agent.currentAdapter).to.equal(adapters[2]);
        
        // After closing the ad, the waterfall is reset to the beginning again.
        [(DDNASmartAdFakeAdapter *)agent.currentAdapter showAdFromViewController:nil];
        [(DDNASmartAdFakeAdapter *)agent.currentAdapter closeAd];
        
        [[verifyCount(delegate, times(2)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[2] requestTime:0];
        expect(agent.currentAdapter).toNot.beNil();
        expect(agent.currentAdapter).to.equal(adapters[2]);
    });
    
    it(@"shows ad",^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO]
        ];
        
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithAdapters:adapters];
        agent.delegate = delegate;
        
        [agent requestAd];
        
        expect([agent hasLoadedAd]).to.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([agent isShowingAd]).to.beTruthy();
        
        [adapters[0] closeAd];
        
        expect([agent adPoint]).to.equal(@"testAdPoint");
        
        [[verifyCount(delegate, times(2)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[0] requestTime:0];
        [verifyCount(delegate, times(1)) adAgent:agent didCloseAdWithAdapter:adapters[0] canReward:YES];
    });
    
    it(@"fails with one adapter", ^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:YES]
        ];
        
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithAdapters:adapters];
        agent.delegate = delegate;
        
        [agent requestAd];

        expect([agent hasLoadedAd]).to.beFalsy();
    });
    
    it(@"reports when an ad fails to open", ^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO failOpen:YES]
        ];
        
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithAdapters:adapters];
        agent.delegate = delegate;
        
        [agent requestAd];
        
        expect([agent hasLoadedAd]).to.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([agent isShowingAd]).to.beFalsy();
        expect(agent.currentAdapter).to.equal(adapters[0]);
        
        [[verifyCount(delegate, times(2)) withMatcher:anything() forArgument:2] adAgent:agent didLoadAdWithAdapter:adapters[0] requestTime:0];
        [verifyCount(delegate, times(1)) adAgent:agent didFailToOpenAdWithAdapter:adapters[0] closedResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
    });
    
    it(@"reports when ad ad was clicked", ^{
       
        NSArray *adapters = @[
            [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO]
        ];
        
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithAdapters:adapters];
        agent.delegate = delegate;
        
        [agent requestAd];
        
        expect([agent hasLoadedAd]).to.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([agent isShowingAd]).to.beTruthy();
        
        [adapters[0] clickAdAndLeaveApplication:NO];
        
        expect([agent adWasClicked]).to.beTruthy();
        expect([agent adLeftApplication]).to.beFalsy();

    });
    
    it(@"reports when ad ad left the app", ^{
        
        NSArray *adapters = @[
                              [[DDNASmartAdFakeAdapter alloc] initWithName:@"A" failRequest:NO]
                              ];
        
        DDNASmartAdAgent *agent = [[DDNASmartAdAgent alloc] initWithAdapters:adapters];
        agent.delegate = delegate;
        
        [agent requestAd];
        
        expect([agent hasLoadedAd]).to.beTruthy();
        
        [agent showAdFromRootViewController:mockViewController adPoint:@"testAdPoint"];
        
        expect([agent isShowingAd]).to.beTruthy();
        
        [adapters[0] clickAdAndLeaveApplication:YES];
        
        expect([agent adWasClicked]).to.beTruthy();
        expect([agent adLeftApplication]).to.beTruthy();
        
    });

    
});

SpecEnd
