//
//  DDNASmartAdIronSourceInterstitialAdapter.m
//  
//
//  Created by David White on 03/04/2017.
//
//

#import "DDNASmartAdIronSourceInterstitialAdapter.h"
#import "DDNASmartAdIronSourceHelper.h"

@interface DDNASmartAdIronSourceInterstitialAdapter () <DDNASmartAdIronSourceInterstitialDelegate>

@property (nonatomic, copy) NSString *appKey;

@end

@implementation DDNASmartAdIronSourceInterstitialAdapter

- (instancetype)initWithAppKey:(NSString *)appKey
                          eCPM:(NSInteger)eCPM
                waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"IRONSOURCE" version:[[DDNASmartAdIronSourceHelper sharedInstance] getSDKVersion] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        [[DDNASmartAdIronSourceHelper sharedInstance] setInterstitialDelegate:self];
        self.appKey = appKey;
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
    [[DDNASmartAdIronSourceHelper sharedInstance] startWithAppKey:self.appKey];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([[DDNASmartAdIronSourceHelper sharedInstance] hasInterstitial]) {
        [[DDNASmartAdIronSourceHelper sharedInstance] showInterstitialWithViewController:viewController placement:nil];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - DDNASmartAdIronSourceInterstitialDelegate

- (void)interstitialDidLoad
{
    [self.delegate adapterDidLoadAd:self];
}

- (void)interstitialDidShow
{
    [self.delegate adapterIsShowingAd:self];
}

- (void)interstitialDidFailToShowWithError:(NSError *)error
{
    [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
}

- (void)didClickInterstitial
{
    [self.delegate adapterWasClicked:self];
}

- (void)interstitialDidClose
{
    [self.delegate adapterDidCloseAd:self canReward:YES];
}

- (void)interstitialDidOpen
{

}

- (void)interstitialDidFailToLoadWithError:(NSError *)error
{
    DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
    result.errorDescription = error.localizedDescription;
    
    [self.delegate adapterDidFailToLoadAd:self withResult:result];
}

@end
