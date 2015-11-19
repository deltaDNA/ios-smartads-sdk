//
//  DDNASmartAdFlurryAdapter.m
//  
//
//  Created by David White on 06/11/2015.
//
//

#import "DDNASmartAdFlurryAdapter.h"
#import <Flurry.h>
#import <FlurryAdInterstitial.h>
#import <FlurryAdInterstitialDelegate.h>


@interface DDNASmartAdFlurryAdapter () <FlurryAdInterstitialDelegate>

@property (nonatomic, strong) FlurryAdInterstitial *interstitial;
@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *adSpace;
@property (nonatomic, assign) BOOL testMode;

@end

@implementation DDNASmartAdFlurryAdapter

- (instancetype)initWithApiKey:(NSString *)apiKey adSpace:(NSString *)adSpace testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"Flurry"
                            version:[Flurry getFlurryAgentVersion]
                               eCPM:eCPM waterfallIndex:waterfallIndex])) {
        
        self.apiKey = apiKey;
        self.adSpace = adSpace;
        self.testMode = testMode;
        
        [Flurry setEventLoggingEnabled:self.testMode];
        [Flurry startSession:self.apiKey];
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

/*!
 *  @brief Invoked when an ad is received for the specified @c interstitialAd object.
 *  @since 6.0.0
 *
 *  This method informs the app that an ad has been received and is available for display.
 *
 *  @see FlurryAdInterstitial#fetchAd for details on the method that will invoke this delegate.
 *
 *  @param interstitialAd The ad object that has successfully fetched an ad.
 */
- (void) adInterstitialDidFetchAd:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate adapterDidLoadAd:self];
}

/*!
 *  @brief Invoked when the interstitial ad is rendered.
 *  @since 6.0.0
 *
 *  This method informs the user an ad was retrieved, and successful in displaying to the user.
 *
 *  @see \n
 *  FlurryAdInterstitial#presentWithViewController: for details on the method that will invoke this delegate. \n
 *
 *  @param interstitialAd The ad object that rendered successfully.
 *
 */
- (void) adInterstitialDidRender:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate adapterIsShowingAd:self];
}

/*!
 *  @brief Invoked when a fullscreen associated with the specified ad will present on the screen.
 *  @since 6.0.0
 *
 *  @param interstitialAd The interstitial ad object that is associated with the full screen that will present.
 *
 */
- (void) adInterstitialWillPresent:(FlurryAdInterstitial*)interstitialAd
{
    
}


/*!
 *  @brief Invoked when the ad has been selected that will take the user out of the app.
 *  @since 6.0.0
 *
 *  This method informs the app that an ad has been clicked and the user is about to be taken outside the app.
 *
 *  @param interstitialAd The ad object that received the click.
 *
 */
- (void) adInterstitialWillLeaveApplication:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate adapterLeftApplication:self];
}

/*!
 *  @brief Invoked when a fullscreen associated with the specified ad will be removed.
 *  @since 6.0.0
 *
 *  @param interstitialAd The interstitial ad object that is associated with the full screen that will be dismissed.
 *
 */
- (void) adInterstitialWillDismiss:(FlurryAdInterstitial*)interstitialAd
{
    
}

/*!
 *  @brief Invoked when a fullscreen associated with the specified ad has been removed.
 *  @since 6.0.0
 *
 *  @param interstitialAd The interstitial ad object that is associated with the full screen that has been dismissed.
 *
 */
- (void) adInterstitialDidDismiss:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate adapterDidCloseAd:self];
}

/*!
 *  @brief Informational callback invoked when an ad is clicked for the specified @c interstitialAd object.
 *  @since 6.0.0
 *
 *  This method informs the app that an ad has been clicked. This should not be used to adjust state of an app. It is only intended for informational purposes.
 *
 *  @param interstitialAd The ad object that received the click.
 *
 */
- (void) adInterstitialDidReceiveClick:(FlurryAdInterstitial*)interstitialAd
{
    [self.delegate adapterWasClicked:self];
}

/*!
 *  @brief Invoked when a video finishes playing
 *  @since 6.0.0
 *
 *  This method informs the app that a video associated with this ad has finished playing.
 *
 *  @param interstitialAd The interstitial ad object that played the video and finished playing the video.
 *
 */
- (void) adInterstitialVideoDidFinish:(FlurryAdInterstitial*)interstitialAd
{
    
}

/*!
 *  @brief Informational callback invoked when there is an ad error
 *  @since 6.0
 *
 *  @see FlurryAdError for the possible error reasons.
 *
 *  @param interstitialAd The interstitial ad object associated with the error
 *  @param adError an enum that gives the reason for the error.
 *  @param errorDescription An error object that gives additional information on the cause of the ad error.
 *
 */
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
