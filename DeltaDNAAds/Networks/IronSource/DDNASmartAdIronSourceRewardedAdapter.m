//
//  DDNASmartAdIronSourceRewardedAdapter.m
//  
//
//  Created by David White on 03/04/2017.
//
//

#import "DDNASmartAdIronSourceRewardedAdapter.h"
#import "DDNASmartAdIronSourceHelper.h"

@interface DDNASmartAdIronSourceRewardedAdapter () <DDNASmartAdIronSourceRewardedDelegate>

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, assign) BOOL reward;

@end

@implementation DDNASmartAdIronSourceRewardedAdapter

- (instancetype)initWithAppKey:(NSString *)appKey
                         eCPM:(NSInteger)eCPM
               waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"IRONSOURCE" version:[[DDNASmartAdIronSourceHelper sharedInstance] getSDKVersion] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        [[DDNASmartAdIronSourceHelper sharedInstance] setRewardedDelegate:self];
        self.appKey = appKey;
        self.reward = NO;
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appKey"]) return nil;
    
    return [self initWithAppKey:configuration[@"appKey"]
                          eCPM:[configuration[@"eCPM"] integerValue]
                waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    self.reward = NO;
    [[DDNASmartAdIronSourceHelper sharedInstance] startWithAppKey:self.appKey];
    if ([[DDNASmartAdIronSourceHelper sharedInstance] hasRewardedVideo]) {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([[DDNASmartAdIronSourceHelper sharedInstance] hasRewardedVideo]) {
        [[DDNASmartAdIronSourceHelper sharedInstance] showRewardedVideoWithViewController:viewController placement:nil];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - DDNASmartAdIronSourceRewardedDelegate

- (void)rewardedVideoHasChangedAvailability:(BOOL)available
{
    if (available) {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo
{
    self.reward = YES;
}

- (void)rewardedVideoDidFailToShowWithError:(NSError *)error
{
    [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
}

- (void)rewardedVideoDidOpen
{
    [self.delegate adapterIsShowingAd:self];
}

- (void)rewardedVideoDidClose
{
    [self.delegate adapterDidCloseAd:self canReward:self.reward];
}

- (void)rewardedVideoDidStart
{
    
}

- (void)rewardedVideoDidEnd
{
    
}

@end

