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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Chartboost/Chartboost.h>

@class DDNASmartAdPrivacy;
@protocol DDNASmartAdChartboostInterstitialDelegate;
@protocol DDNASmartAdChartboostRewardedDelegate;

@interface DDNASmartAdChartboostHelper : NSObject

@property (nonatomic, weak) id<DDNASmartAdChartboostInterstitialDelegate> interstitialDelegate;
@property (nonatomic, weak) id<DDNASmartAdChartboostRewardedDelegate> rewardedDelegate;

+ (instancetype)sharedInstance;

- (NSString *)getSDKVersion;

- (void)startWithAppId:(NSString *)appId appSignature:(NSString *)appSignature privacy:(DDNASmartAdPrivacy *)privacy;

- (void)cacheInterstitial:(CBLocation)location;

- (BOOL)hasInterstitial:(CBLocation)location;

- (void)showInterstitial:(CBLocation)location;

- (void)cacheRewardedVideo:(CBLocation)location;

- (BOOL)hasRewardedVideo:(CBLocation)location;

- (void)showRewardedVideo:(CBLocation)location;

@end

@protocol DDNASmartAdChartboostInterstitialDelegate <NSObject>

- (void)didDisplayInterstitial:(CBLocation)location;

- (void)didCacheInterstitial:(CBLocation)location;

- (void)didFailToLoadInterstitial:(CBLocation)location
                        withError:(CBLoadError)error;

- (void)didFailToRecordClick:(CBLocation)location
                   withError:(CBClickError)error;

- (void)didDismissInterstitial:(CBLocation)location;

- (void)didCloseInterstitial:(CBLocation)location;

- (void)didClickInterstitial:(CBLocation)location;

@end

@protocol DDNASmartAdChartboostRewardedDelegate <NSObject>

- (void)didDisplayRewardedVideo:(CBLocation)location;

- (void)didCacheRewardedVideo:(CBLocation)location;

- (void)didFailToLoadRewardedVideo:(CBLocation)location
                         withError:(CBLoadError)error;

- (void)didDismissRewardedVideo:(CBLocation)location;

- (void)didCloseRewardedVideo:(CBLocation)location;

- (void)didClickRewardedVideo:(CBLocation)location;

- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward;

@end
