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

@interface DDNASmartAdAdColonyAdapter ()

@property (nonatomic, copy, readwrite) NSString *appId;
@property (nonatomic, copy, readwrite) NSString *zoneId;

@property (nonatomic, assign) BOOL configured;
@property (nonatomic, assign) BOOL watchedVideo;
@property (nonatomic, strong) AdColonyInterstitial *ad;
@property (nonatomic, strong) AdColonyZone *zone;
@property (nonatomic, assign) BOOL requestPostConfigure;

@end

@implementation DDNASmartAdAdColonyAdapter

- (instancetype)initWithAppId:(NSString *)appId
                       zoneId:(NSString *)zoneId
                         eCPM:(NSInteger)eCPM
               waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"ADCOLONY" version:[AdColony getSDKVersion] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        self.appId = appId;
        self.zoneId = zoneId;
        self.requestPostConfigure = NO;
        
        AdColonyAppOptions *options = [[AdColonyAppOptions alloc] init];
        options.disableLogging = NO;
        options.adOrientation = AdColonyOrientationAll;
        
        [AdColony configureWithAppID:self.appId zoneIDs:@[self.zoneId] options:options completion:^(NSArray<AdColonyZone*>* zones) {
            AdColonyZone* zone = [zones firstObject];
            
            /* Set the zone's reward handler block */
            zone.reward = ^(BOOL success, NSString* name, int amount) {
                DDNALogDebug(@"AdColony zone.reward success=%@ name=%@ amount=%d %@", success ? @"YES" : @"NO", name, amount, [NSThread currentThread]);
                self.watchedVideo = success;
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
        [AdColony requestInterstitialInZone:self.zoneId options:nil
            success:^(AdColonyInterstitial* ad) {
                ad.open = ^{
                    [self.delegate adapterIsShowingAd:self];
                };
                ad.close = ^{
                    DDNALogDebug(@"AdColony ad.close %@", [NSThread currentThread]);
                    self.ad = nil;
                    [self.delegate adapterDidCloseAd:self canReward:self.watchedVideo];
                };
                ad.leftApplication = ^{
                    [self.delegate adapterLeftApplication:self];
                };
                ad.click = ^{
                    [self.delegate adapterWasClicked:self];
                };

                self.ad = ad;
                [self.delegate adapterDidLoadAd:self];
            }
            failure:^(AdColonyAdRequestError* error) {
                DDNALogDebug(@"AdColony request failed with error: %@", [error localizedDescription]);
                self.ad = nil;
                   
                DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError errorDescription:[error localizedDescription]];
                [self.delegate adapterDidFailToLoadAd:self withResult:result];
            }
        ];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.ad != nil) {
        if (!self.ad.expired) {
            [self.ad showWithPresentingViewController:viewController];
        } else {
            [self.delegate adapterDidFailToShowAd:self
                                       withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeExpired]];
        }
    } else {
        [self.delegate adapterDidFailToShowAd:self
                                   withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
    
}

@end
