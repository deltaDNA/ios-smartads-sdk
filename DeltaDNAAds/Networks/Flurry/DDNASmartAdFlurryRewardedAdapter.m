//
//  DDNASmartAdFlurryRewardedAdapter.m
//  
//
//  Created by David White on 30/11/2015.
//
//

#import "DDNASmartAdFlurryRewardedAdapter.h"
#import "DDNASmartAdFlurryHelper.h"
#import <FlurryAdInterstitial.h>
#import <FlurryAdInterstitialDelegate.h>


@interface DDNASmartAdFlurryRewardedAdapter () <FlurryAdInterstitialDelegate>

@property (nonatomic, strong) FlurryAdInterstitial *interstitial;
@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *adSpace;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, assign) BOOL reward;

@end

@implementation DDNASmartAdFlurryRewardedAdapter

- (instancetype)initWithApiKey:(NSString *)apiKey adSpace:(NSString *)adSpace testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"FLURRY-REWARDED"
                            version:[[DDNASmartAdFlurryHelper sharedInstance] getFlurryAgentVersion]
                               eCPM:eCPM
                     waterfallIndex:waterfallIndex])) {
        
        self.apiKey = apiKey;
        self.adSpace = adSpace;
        self.testMode = testMode;
    }
    return self;
}

- (FlurryAdInterstitial *)createAndLoadInterstitial
{
    FlurryAdInterstitial *interstitial = [[FlurryAdInterstitial alloc]  initWithSpace:self.adSpace];
    interstitial.adDelegate = self;
    
    [interstitial fetchAd];
    
    return interstitial;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"apiKey"] || !configuration[@"adSpace"]) return nil;
    
    return [self initWithApiKey:configuration[@"apiKey"]
                        adSpace:configuration[@"adSpace"]
                       testMode:[configuration[@"testMode"] boolValue]
                           eCPM:[configuration[@"eCPM"] integerValue]
                 waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    [[DDNASmartAdFlurryHelper sharedInstance] startSessionWithApiKey:self.apiKey testMode:self.testMode];
    
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.interstitial.ready) {
        [self.interstitial presentWithViewController:viewController];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - FlurryAdInterstitialDelegage

- (void) adInterstitialDidFetchAd:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate adapterDidLoadAd:self];
}

- (void) adInterstitialDidRender:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate adapterIsShowingAd:self];
}

- (void) adInterstitialWillPresent:(FlurryAdInterstitial*)interstitialAd
{
    
}

- (void) adInterstitialWillLeaveApplication:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate adapterLeftApplication:self];
}

- (void) adInterstitialWillDismiss:(FlurryAdInterstitial*)interstitialAd
{
    
}

- (void) adInterstitialDidDismiss:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate adapterDidCloseAd:self canReward:self.reward];
}

- (void) adInterstitialDidReceiveClick:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate adapterWasClicked:self];
}

- (void) adInterstitialVideoDidFinish:(FlurryAdInterstitial*)interstitialAd
{
    self.reward = YES;
}

- (void) adInterstitial:(FlurryAdInterstitial*) interstitialAd adError:(FlurryAdError) adError errorDescription:(NSError*) errorDescription
{
    // FIXME: This can be called at any point in the lifecycle.  Error description probably gives more info about
    // why fetch ad failed.  Need to find out what no fill error is like.
    
    switch (adError) {
        case FLURRY_AD_ERROR_DID_FAIL_TO_RENDER: {
            [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
            break;
        }
        case FLURRY_AD_ERROR_DID_FAIL_TO_FETCH_AD: {
            [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill error:errorDescription.description]];
            break;
        }
        case FLURRY_AD_ERROR_CLICK_ACTION_FAILED:
            break;
            
        default:
            break;
    }
}

@end
