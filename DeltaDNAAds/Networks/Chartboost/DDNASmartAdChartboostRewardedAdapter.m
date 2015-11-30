//
//  DDNASmartAdChartboostRewardedAdapter.m
//  
//
//  Created by David White on 30/11/2015.
//
//

#import "DDNASmartAdChartboostRewardedAdapter.h"
#import "DDNASmartAdChartboostHelper.h"
#import <DeltaDNA/DDNALog.h>

@interface DDNASmartAdChartboostRewardedAdapter () <DDNASmartAdChartboostRewardedDelegate>

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appSignature;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, assign) BOOL reward;

@end

@implementation DDNASmartAdChartboostRewardedAdapter

- (instancetype)initWithAppId:(NSString *)appId
                 appSignature:(NSString *)appSignature
                     location:(NSString *)location
                         eCPM:(NSInteger)eCPM
               waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"CHARTBOOST-REWARDED" version:@"6.x" eCPM:eCPM waterfallIndex:waterfallIndex])) {
        [[DDNASmartAdChartboostHelper sharedInstance] setRewardedDelegate:self];
        self.appId = appId;
        self.appSignature = appSignature;
        self.location = location;
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appId"] && !configuration[@"appSignature"]) return nil;
    
    NSString *location = configuration[@"location"] ? configuration[@"location"] : CBLocationDefault;
    
    return [self initWithAppId:configuration[@"appId"]
                  appSignature:configuration[@"appSignature"]
                      location:location
                          eCPM:[configuration[@"eCPM"] integerValue]
                waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    [[DDNASmartAdChartboostHelper sharedInstance] startWithAppId:self.appId appSignature:self.appSignature];
    [[DDNASmartAdChartboostHelper sharedInstance] cacheRewardedVideo:self.location];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([[DDNASmartAdChartboostHelper sharedInstance] hasRewardedVideo:self.location]) {
        [[DDNASmartAdChartboostHelper sharedInstance] showRewardedVideo:self.location];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - DDNASmartAdChartboostHelperRewardedDelegate

- (void)didDisplayRewardedVideo:(CBLocation)location
{
    DDNALogDebug(@"Chartboost did display rewarded video at %@", location);
    [self.delegate adapterIsShowingAd:self];
}

- (void)didCacheRewardedVideo:(CBLocation)location
{
    DDNALogDebug(@"Chartboost did cache rewarded video at %@", location);
    [self.delegate adapterDidLoadAd:self];
}

- (void)didFailToLoadRewardedVideo:(CBLocation)location withError:(CBLoadError)error
{
    NSLog(@"Chartboost did fail to load rewarded video at %@ with error %lu", location, (unsigned long)error);
    
    DDNASmartAdRequestResult *result;
    
    switch (error) {
            /*! Unknown internal error. */
        case CBLoadErrorInternal: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        }
            /*! Network is currently unavailable. */
        case CBLoadErrorInternetUnavailable: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
            break;
        }
            /*! Too many requests are pending for that location.  */
        case CBLoadErrorTooManyConnections: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeInvalid];
            break;
        }
            /*! Interstitial loaded with wrong orientation. */
        case CBLoadErrorWrongOrientation: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeInvalid];
            break;
        }
            /*! Interstitial disabled, first session. */
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeInvalid];
            break;
        }
            /*! Network request failed. */
        case CBLoadErrorNetworkFailure: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
            break;
        }
            /*!  No ad received. */
        case CBLoadErrorNoAdFound: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
            break;
        }
            /*! Session not started. */
        case CBLoadErrorSessionNotStarted: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeInvalid];
            break;
        }
            /*! User manually cancelled the impression. */
        case CBLoadErrorUserCancellation: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeInvalid];
            break;
        }
            /*! No location detected. */
        case CBLoadErrorNoLocationFound: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeInvalid];
            break;
        }
            /*! Video Prefetching is not finished */
        case CBLoadErrorPrefetchingIncomplete: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeInvalid];
            break;
        }
            /*! There is an impression already visible.*/
        case CBLoadErrorImpressionAlreadyVisible: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeInvalid];
            break;
        }
        default:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
    }
    
    [self.delegate adapterDidFailToLoadAd:self withResult:result];
}

- (void)didDismissRewardedVideo:(CBLocation)location
{
    DDNALogDebug(@"Chartboost did dismiss rewarded video at %@", location);
}

- (void)didCloseRewardedVideo:(CBLocation)location
{
    DDNALogDebug(@"Chartboost did close rewarded video at %@", location);
    [self.delegate adapterDidCloseAd:self canReward:self.reward];
}

- (void)didClickRewardedVideo:(CBLocation)location
{
    DDNALogDebug(@"Chartboost did click rewarded video at %@", location);
    [self.delegate adapterWasClicked:self];
}

- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward
{
    DDNALogDebug(@"Chartboost did complete rewarded video %@ with reward %d", location, reward);
    self.reward = YES;
}

@end
