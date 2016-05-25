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

#import "DDNASmartAdAgent.h"
#import "DDNASmartAdWaterfall.h"
#import <DeltaDNA/DDNALog.h>

static long const AD_WATERFALL_RESTART_DELAY_SECONDS = 60;
static long const AD_NETWORK_TIMEOUT_SECONDS = 15;

@interface DDNASmartAdAgent () <DDNASmartAdAdapterDelegate>

@property (nonatomic, assign) DDNASmartAdAgentState state;
@property (nonatomic, assign) BOOL adWasClicked;
@property (nonatomic, assign) BOOL adLeftApplication;
@property (nonatomic, strong) DDNASmartAdAdapter *currentAdapter;
@property (nonatomic, assign) NSInteger adsShown;
@property (nonatomic, strong) NSDate *lastAdShownTime;
@property (nonatomic, strong) NSDate *lastRequestTime;

@property (nonatomic, strong) DDNASmartAdWaterfall *waterfall;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) NSInteger adapterIndex;

@end

@implementation DDNASmartAdAgent

- (instancetype)initWithWaterfall:(DDNASmartAdWaterfall *)waterfall
{
    if ((self = [super self])) {
        self.waterfall = waterfall;
        [self getNextAdapterAndReset:YES];
        if (!self.currentAdapter) {
            DDNALogWarn(@"At least one ad provider must be defined, ads will not be available!");
        }
        self.state = DDNASmartAdAgentStateReady;
    }
    return self;
}

- (void)requestAd
{
    if (!self.currentAdapter) return;
    
    self.adWasClicked = NO;
    self.adLeftApplication = NO;
    
    [self requestNextAdWithDelaySeconds:0];
}

- (BOOL)hasLoadedAd
{
    return self.state == DDNASmartAdAgentStateLoaded;
}

- (BOOL)isShowingAd
{
    return self.state == DDNASmartAdAgentStateShowing;
}

- (void)showAdFromRootViewController:(UIViewController *)viewController decisionPoint:(NSString *)decisionPoint
{
    self.decisionPoint = decisionPoint;
    self.viewController = viewController;
    
    if (self.state == DDNASmartAdAgentStateLoaded) {
        [self.currentAdapter showAdFromViewController:self.viewController];
    } else {
        [self.delegate adAgent:self didFailToOpenAdWithAdapter:self.currentAdapter
                  closedResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - DDNASmartAdAdapterDelegate

- (void)adapterDidLoadAd: (DDNASmartAdAdapter *)adapter
{
    @synchronized(self)
    {
        if (adapter == self.currentAdapter && self.state == DDNASmartAdAgentStateLoading) {
            self.state = DDNASmartAdAgentStateLoaded;
            [self.delegate adAgent:self didLoadAdWithAdapter:adapter requestTime:[self lastRequestTimeMs]];
            [self.waterfall scoreAdapter:adapter withRequestCode:DDNASmartAdRequestResultCodeLoaded];
        }
    }
}

- (void)adapterDidFailToLoadAd:(DDNASmartAdAdapter *)adapter withResult:(DDNASmartAdRequestResult *)result
{
    @synchronized(self)
    {
        if (adapter == self.currentAdapter) {
            if (self.state != DDNASmartAdAgentStateLoading) return; // Prevent adapters calling this multiple times.
            
            [self.delegate adAgent:self didFailToLoadAdWithAdapter:adapter requestTime:[self lastRequestTimeMs] requestResult:result];
            
            self.state = DDNASmartAdAgentStateReady;
            
            [self.waterfall scoreAdapter:adapter withRequestCode:result.code];
            [self getNextAdapterAndReset:NO];
            
            if (self.currentAdapter) {
                [self requestNextAdWithDelaySeconds:0];
            }
            else {
                [self getNextAdapterAndReset:YES];
                if (self.currentAdapter) {
                    [self requestNextAdWithDelaySeconds:AD_WATERFALL_RESTART_DELAY_SECONDS];
                } else {
                    DDNALogWarn(@"No more ad networks available for ads.");
                }
            }
        }
    }
}

- (void)adapterIsShowingAd: (DDNASmartAdAdapter *)adapter
{
    if (adapter == self.currentAdapter) {
        self.state = DDNASmartAdAgentStateShowing;
        self.adsShown += 1;
        [self.delegate adAgent:self didOpenAdWithAdapter:adapter];
    }
}

- (void)adapterDidFailToShowAd: (DDNASmartAdAdapter *)adapter withResult:(DDNASmartAdClosedResult *)result
{
    if (adapter == self.currentAdapter) {
        [self.delegate adAgent:self didFailToOpenAdWithAdapter:adapter closedResult:result];
        self.state = DDNASmartAdAgentStateReady;
        [self requestNextAdWithDelaySeconds:0];
    }
}

- (void)adapterWasClicked:(DDNASmartAdAdapter *)adapter
{
    if (adapter == self.currentAdapter) {
        self.adWasClicked = YES;
    }
}

- (void)adapterLeftApplication:(DDNASmartAdAdapter *)adapter
{
    if (adapter == self.currentAdapter) {
        self.adLeftApplication = YES;
    }
}

- (void)adapterDidCloseAd: (DDNASmartAdAdapter *)adapter canReward:(BOOL)canReward
{
    if (adapter == self.currentAdapter) {
        self.lastAdShownTime = [NSDate date];
        [self.delegate adAgent:self didCloseAdWithAdapter:adapter canReward:canReward];
        self.state = DDNASmartAdAgentStateReady;
        [self getNextAdapterAndReset:YES];
        if (self.currentAdapter) {
            [self requestNextAdWithDelaySeconds:0];
        } else {
            DDNALogWarn(@"No more ad networks available for ads.");
        }
    }
}


#pragma mark - Private Methods

- (void)requestNextAdWithDelaySeconds:(NSUInteger)delaySeconds
{
    if (self.state == DDNASmartAdAgentStateReady) {
        self.state = DDNASmartAdAgentStateLoading;
        self.lastRequestTime = [NSDate date];
        
        // Dispatching to our own queue allows the requests to
        // be easily suspended/resumed.  The ad networks must
        // request ads from the main thread.
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW,
                                              delaySeconds*NSEC_PER_SEC);
        dispatch_after(delay, self.delegate.getDispatchQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.currentAdapter requestAd];
            });
            // if after timeout no ad loaded yet, mark it as failed
            dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, AD_NETWORK_TIMEOUT_SECONDS*NSEC_PER_SEC);
            dispatch_after(timeout, self.delegate.getDispatchQueue, ^{
                if (self.state == DDNASmartAdAgentStateLoading) {
                    DDNASmartAdRequestResult * requestResult = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeTimeout];
                    [self adapterDidFailToLoadAd:self.currentAdapter withResult:requestResult];
                }
            });
        });
    }
}

- (void)getNextAdapterAndReset:(BOOL)reset
{
    if (self.currentAdapter) {
        self.currentAdapter.delegate = nil;
    }
    self.currentAdapter = reset ? [self.waterfall resetWaterfall] : [self.waterfall getNextAdapter];
    if (self.currentAdapter) {
        self.currentAdapter.delegate = self;
    }
}

- (NSTimeInterval)lastRequestTimeMs
{
    return [[NSDate date] timeIntervalSinceDate:self.lastRequestTime] * 1000;
}

@end
