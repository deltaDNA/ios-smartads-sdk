//
// Copyright (c) 2016 deltaDNA Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
                      privacy:(DDNASmartAdPrivacy *)privacy
               waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"CHARTBOOST" version:[[DDNASmartAdChartboostHelper sharedInstance] getSDKVersion] eCPM:eCPM privacy:privacy waterfallIndex:waterfallIndex])) {
        [[DDNASmartAdChartboostHelper sharedInstance] setRewardedDelegate:self];
        self.appId = appId;
        self.appSignature = appSignature;
        self.location = location;
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appId"] && !configuration[@"appSignature"]) return nil;
    
    NSString *location = configuration[@"location"] ? configuration[@"location"] : CBLocationDefault;
    
    return [self initWithAppId:configuration[@"appId"]
                  appSignature:configuration[@"appSignature"]
                      location:location
                          eCPM:[configuration[@"eCPM"] integerValue]
                       privacy:privacy
                waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    [[DDNASmartAdChartboostHelper sharedInstance] startWithAppId:self.appId appSignature:self.appSignature privacy:self.privacy];
    [[DDNASmartAdChartboostHelper sharedInstance] cacheRewardedVideo:self.location];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([[DDNASmartAdChartboostHelper sharedInstance] hasRewardedVideo:self.location]) {
        [[DDNASmartAdChartboostHelper sharedInstance] showRewardedVideo:self.location];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeExpired]];
    }
}

- (BOOL)isGdprCompliant
{
    return YES;
}

#pragma mark - DDNASmartAdChartboostHelperRewardedDelegate

- (void)didDisplayRewardedVideo:(CBLocation)location
{
    [self.delegate adapterIsShowingAd:self];
}

- (void)didCacheRewardedVideo:(CBLocation)location
{
    [self.delegate adapterDidLoadAd:self];
}

- (void)didFailToLoadRewardedVideo:(CBLocation)location withError:(CBLoadError)error
{
    DDNASmartAdRequestResult *result;
    
    switch (error) {
            /*!  No ad received. */
        case CBLoadErrorNoAdFound: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
            break;
        }
            /*! Network is currently unavailable. */
        case CBLoadErrorInternetUnavailable: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
            break;
        }
            /*! Network request failed. */
        case CBLoadErrorNetworkFailure: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
            break;
        }
            /*! Unknown internal error. */
        case CBLoadErrorInternal: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        }
                       /*! Too many requests are pending for that location.  */
        case CBLoadErrorTooManyConnections: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        }
            /*! Interstitial loaded with wrong orientation. */
        case CBLoadErrorWrongOrientation: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        }
            /*! Interstitial disabled, first session. */
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        }
            /*! Session not started. */
        case CBLoadErrorSessionNotStarted: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        }
            /*! User manually cancelled the impression. */
        case CBLoadErrorUserCancellation: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        }
            /*! No location detected. */
        case CBLoadErrorNoLocationFound: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        }
            /*! Video Prefetching is not finished */
        case CBLoadErrorPrefetchingIncomplete: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        }
            /*! There is an impression already visible.*/
        case CBLoadErrorImpressionAlreadyVisible: {
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
        }
        default:
            result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
            break;
    }
    result.errorDescription = [NSString stringWithFormat:@"CBLoadError %lu", (unsigned long)error];
    
    [self.delegate adapterDidFailToLoadAd:self withResult:result];
}

- (void)didDismissRewardedVideo:(CBLocation)location
{

}

- (void)didCloseRewardedVideo:(CBLocation)location
{
    [self.delegate adapterDidCloseAd:self canReward:self.reward];
}

- (void)didClickRewardedVideo:(CBLocation)location
{
    [self.delegate adapterWasClicked:self];
}

- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward
{
    self.reward = YES;
}

@end
