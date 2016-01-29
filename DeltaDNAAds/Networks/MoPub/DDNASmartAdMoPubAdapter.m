//
//  DDNASmartAdMoPubAdapter.m
//  
//
//  Created by David White on 06/11/2015.
//
//

#import "DDNASmartAdMoPubAdapter.h"
#import <MoPub.h>

@interface DDNASmartAdMoPubAdapter () <MPInterstitialAdControllerDelegate>

@property (nonatomic, strong) MPInterstitialAdController *interstitial;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, assign) BOOL testMode;

@end

@implementation DDNASmartAdMoPubAdapter

- (instancetype)initWithAdUnitId:(NSString *)adUnitId testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"MOPUB"
                            version:[MoPub sharedInstance].version
                               eCPM:eCPM
                     waterfallIndex:waterfallIndex])) {
        self.adUnitId = adUnitId;
        self.testMode = testMode;
    }
    return self;
}

- (MPInterstitialAdController *)createAndLoadInterstitial
{
    MPInterstitialAdController *interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:self.adUnitId];
    interstitial.delegate = self;
    
    interstitial.testing = self.testMode;
    
    [interstitial loadAd];
    return interstitial;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex: (NSInteger)waterfallIndex
{
    if (!configuration[@"adUnitId"]) return nil;
    
    return [self initWithAdUnitId:configuration[@"adUnitId"]
                         testMode:[configuration[@"testMode"] boolValue]
                             eCPM:[configuration[@"eCPM"] integerValue]
                   waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.interstitial.ready) {
        [self.interstitial showFromViewController:viewController];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self
                                   withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - MPInterstitialAdControllerDelegate

/** @name Detecting When an Interstitial Ad is Loaded */

/**
 * Sent when an interstitial ad object successfully loads an ad.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    [self.delegate adapterDidLoadAd:self];
}

/**
 * Sent when an interstitial ad object fails to load an ad.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    // FIXME: Don't appear to get any error information back
    [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError]];
}

/** @name Detecting When an Interstitial Ad is Presented */

/**
 * Sent immediately before an interstitial ad object is presented on the screen.
 *
 * Your implementation of this method should pause any application activity that requires user
 * interaction.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial
{
    
}

/**
 * Sent after an interstitial ad object has been presented on the screen.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial
{
    [self.delegate adapterIsShowingAd:self];
}

/** @name Detecting When an Interstitial Ad is Dismissed */

/**
 * Sent immediately before an interstitial ad object will be dismissed from the screen.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial
{
    
}

/**
 * Sent after an interstitial ad object has been dismissed from the screen, returning control
 * to your application.
 *
 * Your implementation of this method should resume any application activity that was paused
 * prior to the interstitial being presented on-screen.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
    [self.delegate adapterDidCloseAd:self canReward:YES];
}

/** @name Detecting When an Interstitial Ad Expires */

/**
 * Sent when a loaded interstitial ad is no longer eligible to be displayed.
 *
 * Interstitial ads from certain networks (such as iAd) may expire their content at any time,
 * even if the content is currently on-screen. This method notifies you when the currently-
 * loaded interstitial has expired and is no longer eligible for display.
 *
 * If the ad was on-screen when it expired, you can expect that the ad will already have been
 * dismissed by the time this message is sent.
 *
 * Your implementation may include a call to `loadAd` to fetch a new ad, if desired.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    self.interstitial = [self createAndLoadInterstitial];
}

/**
 * Sent when the user taps the interstitial ad and the ad is about to perform its target action.
 *
 * This action may include displaying a modal or leaving your application. Certain ad networks
 * may not expose a "tapped" callback so you should not rely on this callback to perform
 * critical tasks.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidReceiveTapEvent:(MPInterstitialAdController *)interstitial
{
    [self.delegate adapterWasClicked:self];
}

@end
