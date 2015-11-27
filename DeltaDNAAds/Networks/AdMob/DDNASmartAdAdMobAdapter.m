//
//  DDNASmartAdAdMobAdapter.m
//  
//
//  Created by David White on 12/10/2015.
//
//

#import "DDNASmartAdAdMobAdapter.h"
#import <GoogleMobileAds/GADInterstitial.h>

@interface DDNASmartAdAdMobAdapter () <GADInterstitialDelegate>

@property (nonatomic, strong) GADInterstitial *interstitial;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, assign) BOOL testMode;

@end

@implementation DDNASmartAdAdMobAdapter

- (instancetype)initWithAdUnitId:(NSString *)adUnitId testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"AdMob"
                            version:[GADRequest sdkVersion]
                               eCPM:eCPM
                     waterfallIndex:waterfallIndex])) {
        
        self.adUnitId = adUnitId;
        self.testMode = testMode;
    }
    return self;
}

- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.adUnitId];
    interstitial.delegate = self;
    
    GADRequest *request = [GADRequest request];
    if (self.testMode) {
        // Requests test ads on test devices.  We could expand this to list of known devices
        // to run test ads on them too.
        request.testDevices = @[kGADSimulatorID];
    }
    [interstitial loadRequest:request];
    return interstitial;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
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
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:viewController];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - GADInterstitialDelegate protocol

/// Called when an interstitial ad request succeeded. Show it at the next transition point in your
/// application such as when transitioning between view controllers.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [self.delegate adapterDidLoadAd:self];
}

/// Called when an interstitial ad request completed without an interstitial to
/// show. This is common since interstitials are shown sparingly to users.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    DDNASmartAdRequestResult *result;
    
    switch (error.code) {
        case kGADErrorInvalidRequest:
            
            /// The ad request is invalid. The localizedFailureReason error description will have more
            /// details. Typically this is because the ad did not have the ad unit ID or root view
            /// controller set.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeInvalid];
            break;
            
        case kGADErrorNoFill:
            /// The ad request was successful, but no ad was returned.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
            break;
            
        case kGADErrorNetworkError:
            /// There was an error loading data from the network.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
            break;
            
        case kGADErrorServerError:
            /// The ad server experienced a failure processing the request.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        case kGADErrorOSVersionTooLow:
            /// The current device's OS is below the minimum required version.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration];
            break;
            
        case kGADErrorTimeout:
            /// The request was unable to be loaded before being timed out.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
            break;
            
        case kGADErrorInterstitialAlreadyUsed:
            /// Will not send request because the interstitial object has already been used.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        case kGADErrorMediationDataError:
            /// The mediation response was invalid.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        case kGADErrorMediationAdapterError:
            /// Error finding or creating a mediation ad network adapter.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        case kGADErrorMediationNoFill:
            /// The mediation request was successful, but no ad was returned from any ad networks.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
            break;
            
        case kGADErrorMediationInvalidAdSize:
            /// Attempting to pass an invalid ad size to an adapter.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration];
            break;
            
        case kGADErrorInternalError:
            /// Internal error.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        case kGADErrorInvalidArgument:
            /// Invalid argument error.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeInvalid];
            break;
            
        case kGADErrorReceivedInvalidResponse:
            /// Received invalid response.
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeInvalid];
            break;
            
        default:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
            break;
    }
    result.error = error.description;
    
    [self.delegate adapterDidFailToLoadAd:self withResult:result];
}

/// Called just before presenting an interstitial. After this method finishes the interstitial will
/// animate onto the screen. Use this opportunity to stop animations and save the state of your
/// application in case the user leaves while the interstitial is on screen (e.g. to visit the App
/// Store from a link on the interstitial).
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
    [self.delegate adapterIsShowingAd:self];
}

/// Called before the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    
}

/// Called just after dismissing an interstitial and it has animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    [self.delegate adapterDidCloseAd:self canReward:YES];
}

/// Called just before the application will background or terminate because the user clicked on an
/// ad that will launch another application (such as the App Store). The normal
/// UIApplicationDelegate methods, like applicationDidEnterBackground:, will be called immediately
/// before this.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    [self.delegate adapterLeftApplication:self];
}

@end
