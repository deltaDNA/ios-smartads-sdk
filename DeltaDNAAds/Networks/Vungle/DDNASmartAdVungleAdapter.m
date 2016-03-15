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
@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) BOOL reward;

@end

@implementation DDNASmartAdVungleAdapter

- (instancetype)initWithAppId:(NSString *)appId eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"VUNGLE" version:VungleSDKVersion eCPM:eCPM waterfallIndex:waterfallIndex])) {
        self.appId = appId;
        [[VungleSDK sharedSDK] setDelegate:self];
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appId"]) return nil;
    
    return [self initWithAppId:configuration[@"appId"] eCPM:[configuration[@"eCPM"] integerValue] waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (!self.started) {
        [[VungleSDK sharedSDK] startWithAppId:self.appId];
        self.started = YES;
    }
    
    if ([[VungleSDK sharedSDK] isAdPlayable]) {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([[VungleSDK sharedSDK] isAdPlayable]) {
        NSError *error;
        if (![[VungleSDK sharedSDK] playAd:viewController error:&error]) {
            [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
        }
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - VungleSDKDelegate protocol

- (void)vungleSDKAdPlayableChanged:(BOOL)isAdPlayable
{
    if (isAdPlayable) {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)vungleSDKwillShowAd
{
    [self.delegate adapterIsShowingAd:self];
}

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary*)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet
{
    self.reward = [viewInfo[@"completedView"] boolValue];
    
    if ([viewInfo[@"didDownload"] boolValue]) {
        [self.delegate adapterWasClicked:self];
    }
    
    if (!willPresentProductSheet) {
        [self.delegate adapterDidCloseAd:self canReward:self.reward];
        if ([[VungleSDK sharedSDK] isAdPlayable]) {
            [self.delegate adapterDidLoadAd:self];
        }
    }
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet
{
    [self.delegate adapterDidCloseAd:self canReward:self.reward];
    if ([[VungleSDK sharedSDK] isAdPlayable]) {
        [self.delegate adapterDidLoadAd:self];
    }
}


@end
