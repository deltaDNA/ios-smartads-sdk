//
//  DDNASmartAdInMobiRewardedAdapter.m
//  
//
//  Created by David White on 01/12/2015.
//
//

#import "DDNASmartAdInMobiRewardedAdapter.h"
#import "DDNASmartAdInMobiHelper.h"
#import <DeltaDNA/DDNALog.h>
#import <InMobi/IMInterstitial.h>

@interface DDNASmartAdInMobiRewardedAdapter () <IMInterstitialDelegate>

@property (nonatomic, strong) IMInterstitial *interstitial;

@property (nonatomic, copy) NSString *accountId;
@property (nonatomic, assign) NSInteger placementId;
@property (nonatomic, assign) BOOL reward;

@end

@implementation DDNASmartAdInMobiRewardedAdapter

- (instancetype)initWithAccountId:(NSString *)accountId placementId:(NSInteger)placementId eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"INMOBI"
                            version:[[DDNASmartAdInMobiHelper sharedInstance] getVersion]
                               eCPM:eCPM
                     waterfallIndex:waterfallIndex])) {
        
        self.accountId = accountId;
        self.placementId = placementId;
    }
    return self;
}

- (IMInterstitial *)createAndLoadInterstitial
{
    IMInterstitial *interstitial = [[IMInterstitial alloc] initWithPlacementId:self.placementId];
    interstitial.delegate = self;
    
    [interstitial load];
    
    return interstitial;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"accountId"] || !configuration[@"placementId"]) return nil;
    
    return [self initWithAccountId:configuration[@"accountId"]
                       placementId:[configuration[@"placementId"] integerValue]
                              eCPM:[configuration[@"eCPM"] integerValue]
                    waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    [[DDNASmartAdInMobiHelper sharedInstance] startWithAccountID:self.accountId];
    
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.interstitial.isReady) {
        [self.interstitial showFromViewController:viewController];
    }
    else {
        [self.delegate adapterDidFailToShowAd:self
                                   withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - IMInterstitialDelegate

/*Indicates that the interstitial has received an ad. */
- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial
{
    [self.delegate adapterDidLoadAd:self];
}

/* Indicates that the interstitial has failed to receive an ad */
- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error
{
    DDNALogDebug(@"Interstitial failed to load ad with error: %@", error.description);
    
    DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration];
    
    switch (error.code) {
        case kIMStatusCodeNetworkUnReachable:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
            break;
        case kIMStatusCodeNoFill:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
            break;
        case kIMStatusCodeRequestInvalid:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        case kIMStatusCodeRequestPending:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        case kIMStatusCodeRequestTimedOut:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
            break;
        case kIMStatusCodeInternalError:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        case kIMStatusCodeServerError:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        case kIMStatusCodeAdActive:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        case kIMStatusCodeEarlyRefreshRequest:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        default:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
    }
    result.error = error.description;
    
    [self.delegate adapterDidFailToLoadAd:self withResult:result];
}

/* Indicates that the interstitial has failed to present itself. */
- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error
{
    DDNALogDebug(@"Interstitial didFailToPresentWithError: %@", error.description);
    
    [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
}

/* indicates that the interstitial is going to present itself. */
- (void)interstitialWillPresent:(IMInterstitial *)interstitial
{
    
}

/* Indicates that the interstitial has presented itself */
- (void)interstitialDidPresent:(IMInterstitial *)interstitial
{
    [self.delegate adapterIsShowingAd:self];
}

/* Indicates that the interstitial is going to dismiss itself. */
- (void)interstitialWillDismiss:(IMInterstitial *)interstitial
{
    
}

/* Indicates that the interstitial has dismissed itself. */
- (void)interstitialDidDismiss:(IMInterstitial *)interstitial
{
    [self.delegate adapterDidCloseAd:self canReward:self.reward];
}

/* Indicates that the user will leave the app. */
- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial *)interstitial
{
    [self.delegate adapterLeftApplication:self];
}

/* Indicates that a reward action is completed */
- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards
{
    DDNALogDebug(@"IncentActionCompleted Publisher Callback successfully received: %@", rewards);
    self.reward = YES;
}

/* interstitial:didInteractWithParams: Indicates that the interstitial was interacted with. */
- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params
{
    [self.delegate adapterWasClicked:self];
}

@end
