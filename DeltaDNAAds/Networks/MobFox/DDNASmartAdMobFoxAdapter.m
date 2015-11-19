//
//  DDNASmartAdMobFoxAdapter.m
//  
//
//  Created by David White on 10/11/2015.
//
//

#import "DDNASmartAdMobFoxAdapter.h"
#import <MobFoxSDKCore/MobFoxSDKCore.h>
#import <DeltaDNA/DDNALog.h>

@interface DDNASmartAdMobFoxAdapter () <MobFoxInterstitialAdDelegate>

@property (nonatomic, strong) MobFoxInterstitialAd *interstitial;

@property (nonatomic, copy) NSString *publicationId;

@end

@implementation DDNASmartAdMobFoxAdapter

- (instancetype)initWithPublicationId:(NSString *)publicationId eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"MobFox"
                            version:@"N/A"
                               eCPM:eCPM
                     waterfallIndex:waterfallIndex])) {
        
        self.publicationId = publicationId;
    }
    return self;
}

- (MobFoxInterstitialAd *)createAndLoadInterstitial
{
    MobFoxInterstitialAd *interstitial = [[MobFoxInterstitialAd alloc] init:self.publicationId];
    interstitial.delegate = self;
    
    [interstitial loadAd];
    
    return interstitial;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"publicationId"]) return nil;
    
    return [self initWithPublicationId:configuration[@"publicationId"]
                                  eCPM:[configuration[@"eCPM"] integerValue]
                        waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    // TODO: put this a level up
//    @try {
        self.interstitial = [self createAndLoadInterstitial];
//    }
//    @catch (NSException *exception) {
//        [self.delegate adapterDidFailToLoadAd:self withStatus:[DDNASmartAdStatus statusWithStatusCode:DDNASmartAdStatusCodeInternalError]];
//    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.interstitial.ready) {
        self.interstitial.rootViewController = viewController;
        [self.interstitial show];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self
                                   withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - MobFoxInterstitialDelegate

//called when ad is displayed
- (void)MobFoxInterstitialAdDidLoad:(MobFoxInterstitialAd *)interstitial
{
    [self.delegate adapterDidLoadAd:self];
}

//called when an ad cannot be displayed
- (void)MobFoxInterstitialAdDidFailToReceiveAdWithError:(NSError *)error
{
    DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeInvalid];
    
    if ([error.description containsString:@"no ad returned"]) {
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
    }
    result.error = error.description;
    
    [self.delegate adapterDidFailToLoadAd:self withResult:result];
}

- (void)MobFoxInterstitialAdWillShow:(MobFoxInterstitialAd *)interstitial
{
    [self.delegate adapterIsShowingAd:self];
}

//called when ad is closed/skipped
- (void)MobFoxInterstitialAdClosed
{
    [self.delegate adapterDidCloseAd:self];
}

//called w mobfoxInterAd.delegate = self;hen ad is clicked
- (void)MobFoxInterstitialAdClicked
{
    [self.delegate adapterWasClicked:self];
}

//called when if the ad is a video ad and it has finished playing
- (void)MobFoxInterstitialAdFinished
{
    
}

@end
