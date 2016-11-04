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

#import "DDNASmartAdChartboostHelper.h"
#import <Chartboost/Chartboost.h>
#import <DeltaDNA/DDNALog.h>

@interface DDNASmartAdChartboostHelper () <ChartboostDelegate>

@property (nonatomic, assign) BOOL started;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appSignature;

@end

@implementation DDNASmartAdChartboostHelper

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
    return [Chartboost getSDKVersion];
}

- (void)startWithAppId:(NSString *)appId appSignature:(NSString *)appSignature
{
    @synchronized(self) {
        if (!self.started) {
            [Chartboost setAutoCacheAds:NO];
            [Chartboost startWithAppId:appId
                          appSignature:appSignature
                              delegate:self];
            self.started = YES;
            self.appId = appId;
            self.appSignature = appSignature;
        }
        else {
            if (![self.appId isEqualToString:appId]) {
                DDNALogWarn(@"Chartboost already started with appId='%@'", self.appId);
            }
            if (![self.appSignature isEqualToString:appSignature]) {
                DDNALogWarn(@"Chartboost already started with appSignature='%@", self.appSignature);
            }
        }
    }
}

- (void)cacheInterstitial:(CBLocation)location
{
    [Chartboost cacheInterstitial:location];
}

- (BOOL)hasInterstitial:(CBLocation)location
{
    return [Chartboost hasInterstitial:location];
}

- (void)showInterstitial:(CBLocation)location
{
    [Chartboost showInterstitial:location];
}

- (void)cacheRewardedVideo:(CBLocation)location
{
    [Chartboost cacheRewardedVideo:location];
}

- (BOOL)hasRewardedVideo:(CBLocation)location
{
    return [Chartboost hasRewardedVideo:location];
}

- (void)showRewardedVideo:(CBLocation)location
{
    [Chartboost showRewardedVideo:location];
}

#pragma mark - Interstitial Delegate

- (void)didDisplayInterstitial:(CBLocation)location
{
    // NB. this is called just before the interstitial displays
    [self.interstitialDelegate didDisplayInterstitial:location];
}

- (void)didCacheInterstitial:(CBLocation)location
{
    [self.interstitialDelegate didCacheInterstitial:location];
}

- (void)didFailToLoadInterstitial:(CBLocation)location withError:(CBLoadError)error
{
    [self.interstitialDelegate didFailToLoadInterstitial:location withError:error];
}

- (void)didFailToRecordClick:(CBLocation)location
                   withError:(CBClickError)error
{
    [self.interstitialDelegate didFailToRecordClick:location withError:error];
}

- (void)didDismissInterstitial:(CBLocation)location
{
    [self.interstitialDelegate didDismissInterstitial:location];
}

- (void)didCloseInterstitial:(CBLocation)location
{
    [self.interstitialDelegate didCloseInterstitial:location];
}

- (void)didClickInterstitial:(CBLocation)location
{
    [self.interstitialDelegate didClickInterstitial:location];
}

#pragma mark - Rewarded Video Delegate

- (void)didDisplayRewardedVideo:(CBLocation)location
{
    [self.rewardedDelegate didDisplayRewardedVideo:location];
}

- (void)didCacheRewardedVideo:(CBLocation)location
{
    [self.rewardedDelegate didCacheRewardedVideo:location];
}

- (void)didFailToLoadRewardedVideo:(CBLocation)location
                         withError:(CBLoadError)error
{
    [self.rewardedDelegate didFailToLoadRewardedVideo:location withError:error];
}

- (void)didDismissRewardedVideo:(CBLocation)location
{
    [self.rewardedDelegate didDismissRewardedVideo:location];
}

- (void)didCloseRewardedVideo:(CBLocation)location
{
    [self.rewardedDelegate didCloseRewardedVideo:location];
}

- (void)didClickRewardedVideo:(CBLocation)location
{
    [self.rewardedDelegate didClickRewardedVideo:location];
}

- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward
{
    [self.rewardedDelegate didCompleteRewardedVideo:location withReward:reward];
}

#pragma mark - General Delegate

- (void)willDisplayVideo:(CBLocation)location
{
    
}

@end
