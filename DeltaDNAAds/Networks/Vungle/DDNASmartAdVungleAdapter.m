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

#import "DDNASmartAdVungleAdapter.h"
#import <VungleSDK/VungleSDK.h>

@interface DDNASmartAdVungleAdapter () <VungleSDKDelegate>

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) BOOL reward;

@end

@implementation DDNASmartAdVungleAdapter

- (instancetype)initWithAppId:(NSString *)appId placementId:(NSString *)placementId eCPM:(NSInteger)eCPM privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"VUNGLE" version:VungleSDKVersion eCPM:eCPM privacy:privacy waterfallIndex:waterfallIndex])) {
        self.appId = appId;
        self.placementId = placementId;
        self.started = NO;
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appId"] || !configuration[@"placementId"]) return nil;
    
    return [self initWithAppId:configuration[@"appId"] placementId:configuration[@"placementId"] eCPM:[configuration[@"eCPM"] integerValue] privacy:privacy waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (!self.started) {
        [[VungleSDK sharedSDK] updateConsentStatus:self.privacy.advertiserGdprUserConsent ? VungleConsentAccepted : VungleConsentDenied];
        [[VungleSDK sharedSDK] setDelegate:self];
        NSError *error;
        [[VungleSDK sharedSDK] startWithAppId:self.appId error:&error];
        if (error) {
            [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration errorDescription:error.localizedDescription]];
        }
    }
    else if ([[VungleSDK sharedSDK] isAdCachedForPlacementID:self.placementId]) {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([[VungleSDK sharedSDK] isAdCachedForPlacementID:self.placementId]) {
        NSError *error;
        [[VungleSDK sharedSDK] playAd:viewController options:nil placementID:self.placementId error:&error];
        if (error) {
            [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeError]];
        }
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeExpired]];
    }
}

- (BOOL)isGdprCompliant
{
    return YES;
}

#pragma mark - VungleSDKDelegate protocol

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID
{
    if ([placementID isEqualToString:self.placementId]) {
        if (isAdPlayable) {
            [self.delegate adapterDidLoadAd:self];
        }
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID
{
    if ([placementID isEqualToString:self.placementId]) {
        [self.delegate adapterIsShowingAd:self];
    }
}

- (void)vungleWillCloseAdWithViewInfo:(nonnull VungleViewInfo *)info placementID:(nonnull NSString *)placementID
{
    if ([placementID isEqualToString:self.placementId]) {
        self.reward = [info.completedView boolValue];
        
        if ([info.didDownload boolValue]) {
            [self.delegate adapterWasClicked:self];
        }
        
        [self.delegate adapterDidCloseAd:self canReward:self.reward];
    }
}

- (void)vungleSDKDidInitialize
{
    self.started = YES;
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error
{
    self.started = NO;
    [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration errorDescription:error.localizedDescription]];
}

@end
