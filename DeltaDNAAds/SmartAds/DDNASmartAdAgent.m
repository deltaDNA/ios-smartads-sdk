//
//  DDNASmartAdAgent.m
//  
//
//  Created by David White on 12/10/2015.
//
//

#import "DDNASmartAdAgent.h"
#import "DDNASmartAdWaterfall.h"
#import <DeltaDNA/DDNALog.h>

static long const AD_WATERFALL_RESTART_DELAY_SECONDS = 60;

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

- (void)showAdFromRootViewController:(UIViewController *)viewController adPoint:(NSString *)adPoint
{
    self.adPoint = adPoint;
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
    if (adapter == self.currentAdapter && self.state == DDNASmartadAgentStateLoading) {
        self.state = DDNASmartAdAgentStateLoaded;
        [self.delegate adAgent:self didLoadAdWithAdapter:adapter requestTime:[self lastRequestTimeMs]];
        [self.waterfall scoreAdapter:adapter withRequestCode:DDNASmartAdRequestResultCodeLoaded];
    }
}

- (void)adapterDidFailToLoadAd:(DDNASmartAdAdapter *)adapter withResult:(DDNASmartAdRequestResult *)result
{
    if (adapter == self.currentAdapter) {
        if (self.state != DDNASmartadAgentStateLoading) return; // Prevent adapters calling this multiple times.
        
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

- (void)adapterIsShowingAd: (DDNASmartAdAdapter *)adapter
{
    if (adapter == self.currentAdapter) {
        self.state = DDNASmartAdAgentStateShowing;
        self.adsShown += 1;
        self.lastAdShownTime = [NSDate date];
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
        self.state = DDNASmartadAgentStateLoading;
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
