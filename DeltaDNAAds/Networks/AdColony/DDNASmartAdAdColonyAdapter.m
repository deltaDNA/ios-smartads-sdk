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

#import "DDNASmartAdAdColonyAdapter.h"
#import <AdColony/AdColony.h>
#import <DeltaDNA/DDNALog.h>
#import <DeltaDNAAds/DDNASmartAds.h>

@interface DDNASmartAdAdColonyAdapter ()

@property (nonatomic, copy, readwrite) NSString *appId;
@property (nonatomic, copy, readwrite) NSString *zoneId;
@property (nonatomic, assign, readwrite) BOOL testMode;

@property (atomic, assign) BOOL configured;
@property (nonatomic, assign) BOOL watchedVideo;
@property (nonatomic, strong) AdColonyInterstitial *ad;
@property (nonatomic, strong) AdColonyZone *zone;
@property (atomic, assign) BOOL requestPostConfigure;
@property (nonatomic, assign) BOOL rewardCallbackTriggered;
@property (nonatomic, assign) BOOL closedCallbackTriggered;

@end

@implementation DDNASmartAdAdColonyAdapter

- (instancetype)initWithAppId:(NSString *)appId
                       zoneId:(NSString *)zoneId
                     testMode:(BOOL)testMode
                         eCPM:(NSInteger)eCPM
               waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"ADCOLONY" version:[AdColony getSDKVersion] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        self.appId = appId;
        self.zoneId = zoneId;
        self.testMode = testMode;
        self.requestPostConfigure = NO;
        self.rewardCallbackTriggered = NO;
        self.closedCallbackTriggered = NO;
        
        AdColonyAppOptions *options = [[AdColonyAppOptions alloc] init];
        options.testMode = testMode;
        options.disableLogging = !testMode;
        options.mediationNetwork = @"DeltaDNA";
        options.mediationNetworkVersion = [DDNASmartAds sdkVersion];
        options.adOrientation = AdColonyOrientationAll;
        
        [AdColony configureWithAppID:self.appId zoneIDs:@[self.zoneId] options:options completion:^(NSArray<AdColonyZone*>* zones) {
            AdColonyZone* zone = [zones firstObject];
            
            /* Set the zone's reward handler block */
            zone.reward = ^(BOOL success, NSString* name, int amount) {
                self.watchedVideo = success;

                if (self.closedCallbackTriggered) {
                    [self.delegate adapterDidCloseAd:self canReward:self.watchedVideo];
                } else {
                    self.rewardCallbackTriggered = YES;
                }
            };
            
            self.zone = zone;
            self.configured = YES;
            if (self.requestPostConfigure) {
                [self requestAd];
            }
        }];
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appId"] || !configuration[@"zoneId"]) return nil;
    
    return [self initWithAppId:configuration[@"appId"]
                        zoneId:configuration[@"zoneId"]
                      testMode:[configuration[@"testMode"] boolValue]
                          eCPM:[configuration[@"eCPM"] integerValue]
                waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (!self.configured) {
        self.requestPostConfigure = YES;
        return;
    }
    else {
        self.ad = nil;
        self.rewardCallbackTriggered = NO;
        self.closedCallbackTriggered = NO;
        
        [AdColony requestInterstitialInZone:self.zoneId options:nil
            success:^(AdColonyInterstitial* ad) {
                [ad setOpen:^{
                    [self.delegate adapterIsShowingAd:self];
                }];
                [ad setClose:^{
                    if (self.rewardCallbackTriggered) {
                        [self.delegate adapterDidCloseAd:self canReward:self.watchedVideo];
                    } else {
                        self.closedCallbackTriggered = YES;
                    }
                }];
                [ad setLeftApplication:^{
                    [self.delegate adapterLeftApplication:self];
                }];
                [ad setClick:^{
                    [self.delegate adapterWasClicked:self];
                }];
                [ad setExpire:^{
                    [self requestAd];
                }];

                self.watchedVideo = NO;
                self.ad = ad;
                [self.delegate adapterDidLoadAd:self];
            }
            failure:^(AdColonyAdRequestError* error) {
                DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:[self resultCodeFromError:error] errorDescription:[error localizedDescription]];
                [self.delegate adapterDidFailToLoadAd:self withResult:result];
            }
        ];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.ad != nil && !self.ad.expired) {
        [self.ad showWithPresentingViewController:viewController];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeExpired]];
    }
}

- (int)resultCodeFromError:(NSError *)error
{
    switch (error.code) {
        /** An invalid app id or zone id was specified by the developer or an invalid configuration was received from the server (unlikely). */
        case AdColonyRequestErrorInvalidRequest: return DDNASmartAdRequestResultCodeConfiguration;
        /** The ad was skipped due to the skip interval setting on the control panel. */
        case AdColonyRequestErrorSkippedRequest: return DDNASmartAdRequestResultCodeError;
        /** The current zone has no ad fill. */
        case AdColonyRequestErrorNoFillForRequest: return DDNASmartAdRequestResultCodeNoFill;
        /** Either AdColony has not been configured, is still in the process of configuring, is still downloading assets, or is already showing an ad. */
        case AdColonyRequestErrorUnready: return DDNASmartAdRequestResultCodeConfiguration;
        default: return DDNASmartAdRequestResultCodeError;
    }
}


@end
