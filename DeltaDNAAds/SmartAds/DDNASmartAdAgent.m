//
//  DDNASmartAdAgent.m
//  
//
//  Created by David White on 12/10/2015.
//
//

#import "DDNASmartAdAgent.h"
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

@property (nonatomic, strong) NSMutableArray *mediationAdapters;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) NSInteger adapterIndex;

@end

@implementation DDNASmartAdAgent

- (instancetype)initWithAdapters:(NSArray *)mediationAdapters
{
    if ((self = [super self])) {
        self.mediationAdapters = [NSMutableArray arrayWithArray:mediationAdapters];
        self.currentAdapter = [self getFirstAdapter];
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
    
    [self requestNextAd];
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
    DDNALogDebug(@"Agent loaded ad from %@", adapter.name);
    
    if (adapter == self.currentAdapter && self.state == DDNASmartadAgentStateLoading) {
        self.state = DDNASmartAdAgentStateLoaded;
        [self.delegate adAgent:self didLoadAdWithAdapter:adapter requestTime:[self lastRequestTimeMs]];
    }
}

- (void)adapterDidFailToLoadAd:(DDNASmartAdAdapter *)adapter withResult:(DDNASmartAdRequestResult *)result
{
    DDNALogDebug(@"Agent failed to load ad from %@: %@ (%@)", adapter.name, result.desc, result.error);
    
    if (adapter == self.currentAdapter) {
        if (self.state != DDNASmartadAgentStateLoading) return; // Prevent adapters calling this multiple times.
        
        [self.delegate adAgent:self didFailToLoadAdWithAdapter:adapter requestTime:[self lastRequestTimeMs] requestResult:result];
        
        self.state = DDNASmartAdAgentStateReady;
        
        if (result.code == DDNASmartAdRequestResultCodeConfiguration) {
            self.currentAdapter = [self disableAdapter:adapter];
        }
        else {
            self.currentAdapter = [self getNextAdapter];
        }
        
        // FIXME: This is not good, if all networks fails we keep cycling, no back off.
        // Think the waterfall is wrong anyway, we should give other networks a chance
        // to give us an ad.
        if (self.currentAdapter) {
            [self requestNextAd];
        }
        else {
            self.currentAdapter = [self getFirstAdapter];
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW,
                                                  AD_WATERFALL_RESTART_DELAY_SECONDS*NSEC_PER_SEC);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self requestNextAd];
            });
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
    DDNALogDebug(@"Agent failed to show ad from %@: %@", adapter.name, result.desc);
    
    if (adapter == self.currentAdapter) {
        [self.delegate adAgent:self didFailToOpenAdWithAdapter:adapter closedResult:result];
        self.state = DDNASmartAdAgentStateReady;
        [self requestNextAd];
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
        self.currentAdapter = [self getFirstAdapter];
        [self requestNextAd];
    }
}


#pragma mark - Private Methods

- (void)requestNextAd
{
    if (self.state == DDNASmartAdAgentStateReady) {
        self.state = DDNASmartadAgentStateLoading;
        self.lastRequestTime = [NSDate date];
        [self.currentAdapter requestAd];
    }
}

- (DDNASmartAdAdapter *)getFirstAdapter
{
    self.adapterIndex = 0;
    if (self.mediationAdapters.count > 0) {
        DDNASmartAdAdapter * adapter = self.mediationAdapters[0];
        adapter.delegate = self;
        return adapter;
    }
    return nil;
}

- (DDNASmartAdAdapter *)getNextAdapter
{
    self.adapterIndex++;
    
    if (self.mediationAdapters.count > self.adapterIndex) {
        DDNASmartAdAdapter * adapter = self.mediationAdapters[self.adapterIndex];
        adapter.delegate = self;
        return adapter;
    }
    return nil;
}

- (DDNASmartAdAdapter *)disableAdapter: (DDNASmartAdAdapter *)adapter
{
    adapter.delegate = nil;
    [self.mediationAdapters removeObject:adapter];
    if (self.mediationAdapters.count > self.adapterIndex) {
        DDNASmartAdAdapter * adapter = self.mediationAdapters[self.adapterIndex];
        adapter.delegate = self;
        return adapter;
    }
    return nil;
}

- (NSTimeInterval)lastRequestTimeMs
{
    return [[NSDate date] timeIntervalSinceDate:self.lastRequestTime] * 1000;
}

@end
