//
//  DDNASmartAdAmazonAdapter.m
//  
//
//  Created by David White on 12/10/2015.
//
//

#import "DDNASmartAdAmazonAdapter.h"
#import <AmazonAd/AmazonAdInterstitial.h>
#import <AmazonAd/AmazonAdOptions.h>
#import <AmazonAd/AmazonAdRegistration.h>
#import <AmazonAd/AmazonAdError.h>

@interface DDNASmartAdAmazonAdapter () <AmazonAdInterstitialDelegate>

@property (nonatomic, strong) AmazonAdInterstitial *interstitial;
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, assign) BOOL testMode;

@end

@implementation DDNASmartAdAmazonAdapter

- (instancetype)initWithAppKey:(NSString *)appKey testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"AMAZON"
                            version:[AmazonAdRegistration sharedRegistration].sdkVersion
                               eCPM:eCPM
                     waterfallIndex:waterfallIndex])) {
        
        self.appKey = appKey;
        self.testMode = testMode;
        
        [[AmazonAdRegistration sharedRegistration] setAppKey:self.appKey];
        [[AmazonAdRegistration sharedRegistration] setLogging:self.testMode];
    }
    return self;
}

- (AmazonAdInterstitial *)createAndLoadInterstitial {
    AmazonAdInterstitial *interstitial = [AmazonAdInterstitial amazonAdInterstitial];
    interstitial.delegate = self;
    
    // Set the adOptions.
    AmazonAdOptions *options = [AmazonAdOptions options];
    
    // Turn on isTestRequest to load a test interstitial
    options.isTestRequest = self.testMode;
    
    // Load an interstitial
    [interstitial load:options];
    
    return interstitial;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appKey"]) return nil;
    
    return [self initWithAppKey:configuration[@"appKey"]
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
    // Present the interstitial on screen
    if (self.interstitial.isReady) {
        [self.interstitial presentFromViewController:viewController];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - AmazonAdInterstitial protocol

// Sent when load has succeeded and the interstitial isReady for display at the appropriate moment.
- (void)interstitialDidLoad:(AmazonAdInterstitial *)interstitial
{
    [self.delegate adapterDidLoadAd:self];
}

// Sent when load has failed, typically because of network failure, an application configuration error or lack of interstitial inventory
- (void)interstitialDidFailToLoad:(AmazonAdInterstitial *)interstitial withError:(AmazonAdError *)error
{
    DDNASmartAdRequestResult *result;
    switch (error.errorCode) {
        case AmazonAdErrorInternalServer:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        case AmazonAdErrorNetworkConnection:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
            break;
        case AmazonAdErrorNoFill:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
            break;
        case AmazonAdErrorRequest:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration];
            break;
        case AmazonAdErrorReserved:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
            
        default:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
            break;
    }
    result.error = error.description;
    
    [self.delegate adapterDidFailToLoadAd:self withResult:result];
}

// Sent immediately before interstitial is presented on the screen. At this point you should pause any animations, timers or other
// activities that assume user interaction and save app state. User may press Home or touch links to other apps like iTunes within the
// interstitial, leaving your app.
- (void)interstitialWillPresent:(AmazonAdInterstitial *)interstitial {
    
}

// Sent when interstitial has been presented on the screen.
- (void)interstitialDidPresent:(AmazonAdInterstitial *)interstitial {
    [self.delegate adapterIsShowingAd:self];
}

// Sent immediately before interstitial leaves the screen, restoring your app and your view controller used for presentAdFromViewController:.
// At this point you should restart any foreground activities paused as part of interstitialWillPresent:.
- (void)interstitialWillDismiss:(AmazonAdInterstitial *)interstitial {
    
}

// Sent when the user has dismissed interstitial and it has left the screen.
- (void)interstitialDidDismiss:(AmazonAdInterstitial *)interstitial {
    [self.delegate adapterDidCloseAd:self canReward:YES];
}

@end
