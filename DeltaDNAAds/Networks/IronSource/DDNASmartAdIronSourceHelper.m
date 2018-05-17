//
// Copyright (c) 2017 deltaDNA Ltd. All rights reserved.
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

#import "DDNASmartAdIronSourceHelper.h"
#import "DDNASmartAdStatus.h"
#import "DDNASmartAdPrivacy.h"
#import <IronSource/IronSource.h>
#import <DeltaDNA/DDNALog.h>

@interface DDNASmartAdIronSourceHelper () <ISInterstitialDelegate, ISRewardedVideoDelegate>

@property (nonatomic, assign) BOOL started;
@property (nonatomic, copy) NSString *appKey;

@end

@implementation DDNASmartAdIronSourceHelper

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (NSString *)getSDKVersion
{
    return [IronSource sdkVersion];
}

- (void)startWithAppKey:(NSString *)appKey privacy:(nonnull DDNASmartAdPrivacy *)privacy
{
    @synchronized(self) {
        if (!self.started) {
            [IronSource setConsent:privacy.hasAdvertiserGdprUserConsent];
            [IronSource setInterstitialDelegate:self];
            [IronSource setRewardedVideoDelegate:self];
            [IronSource setMediationType:@"DeltaDNA"];
            [IronSource initWithAppKey:appKey adUnits:@[IS_REWARDED_VIDEO, IS_INTERSTITIAL]];
            self.started = YES;
            self.appKey = appKey;
        }
        else {
            if (![self.appKey isEqualToString:appKey]) {
                DDNALogWarn(@"IronSource already started with appKey='%@'", self.appKey);
            }
        }
    }
}

- (BOOL)hasRewardedVideo
{
    return [IronSource hasRewardedVideo];
}

- (void)showRewardedVideoWithViewController:(UIViewController *)viewController placement:(nullable NSString *)placementName
{
    [IronSource showRewardedVideoWithViewController:viewController placement:placementName];
}

- (void)loadInterstitial
{
    [IronSource loadInterstitial];
}

- (BOOL)hasInterstitial
{
    return [IronSource hasInterstitial];
}

- (void)showInterstitialWithViewController:(UIViewController *)viewController placement:(nullable NSString *)placementName
{
    [IronSource showInterstitialWithViewController:viewController placement:placementName];
}

- (int)resultCodeFromError:(NSError *)error
{
    switch (error.code) {
        case 501: return DDNASmartAdRequestResultCodeConfiguration;
        case 506: return DDNASmartAdRequestResultCodeConfiguration;
        case 509: return DDNASmartAdRequestResultCodeNoFill;
        case 520: return DDNASmartAdRequestResultCodeNetwork;
        default: return DDNASmartAdRequestResultCodeError;
    }
}

#pragma mark - ISRewardedVideoDelegate
//Called after a rewarded video has changed its availability.
//@param available The new rewarded video availability. YES if available //and ready to be shown, NO otherwise.
- (void)rewardedVideoHasChangedAvailability:(BOOL)available {
    [self.rewardedDelegate rewardedVideoHasChangedAvailability:available];
    
}
//Called after a rewarded video has been viewed completely and the user is //eligible for reward.@param placementInfo An object that contains the //placement's reward name and amount.
- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {
    [self.rewardedDelegate didReceiveRewardForPlacement:placementInfo];
}
//Called after a rewarded video has attempted to show but failed.
//@param error The reason for the error
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error {
    [self.rewardedDelegate rewardedVideoDidFailToShowWithError:error];
}
//Called after a rewarded video has been opened.
- (void)rewardedVideoDidOpen {
    [self.rewardedDelegate rewardedVideoDidOpen];
}
//Called after a rewarded video has been dismissed.
- (void)rewardedVideoDidClose {
    [self.rewardedDelegate rewardedVideoDidClose];
}
//Note: the events below are not available for all supported rewarded video ad networks. Check which events are available per ad network you choose //to include in your build.
//We recommend only using events which register to ALL ad networks you //include in your build.
//Called after a rewarded video has started playing.
- (void)rewardedVideoDidStart {
    [self.rewardedDelegate rewardedVideoDidStart];
}
//Called after a rewarded video has finished playing.
- (void)rewardedVideoDidEnd {
    [self.rewardedDelegate rewardedVideoDidEnd];
}
/**
 Called after a video has been clicked.
 */
- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo
{
    [self.rewardedDelegate didClickRewardedVideoForPlacement:placementInfo];
}

#pragma mark - ISInterstitialDelegate
//Invoked when Interstitial Ad is ready to be shown after load function was //called.
-(void)interstitialDidLoad
{
    [self.interstitialDelegate interstitialDidLoad];
}
//Called each time the Interstitial window has opened successfully.
-(void)interstitialDidShow
{
    [self.interstitialDelegate interstitialDidShow];
}
// Called if showing the Interstitial for the user has failed.
//You can learn about the reason by examining the ‘error’ value
-(void)interstitialDidFailToShowWithError:(NSError *)error
{
    [self.interstitialDelegate interstitialDidFailToShowWithError:error];
}
//Called each time the end user has clicked on the Interstitial ad.
-(void)didClickInterstitial
{
    [self.interstitialDelegate didClickInterstitial];
}
//Called each time the Interstitial window is about to close
-(void)interstitialDidClose
{
    [self.interstitialDelegate interstitialDidClose];
}
//Called each time the Interstitial window is about to open
-(void)interstitialDidOpen
{
    [self.interstitialDelegate interstitialDidOpen];
}
//Invoked when there is no Interstitial Ad available after calling load //function. @param error - will contain the failure code and description.
-(void)interstitialDidFailToLoadWithError:(NSError *)error
{
    [self.interstitialDelegate interstitialDidFailToLoadWithError:error];
}

@end
