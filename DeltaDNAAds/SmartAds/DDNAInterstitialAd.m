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

#import "DDNAInterstitialAd.h"
#import <DeltaDNA/DDNAEngagement.h>
#import "DDNASmartAds.h"
#import <DeltaDNA/DDNALog.h>

@interface DDNAInterstitialAd () <DDNASmartAdsInterstitialDelegate>

@property (nonatomic, strong) DDNAEngagement *engagement;

@end

@implementation DDNAInterstitialAd

@synthesize engagement;

+ (instancetype)interstitialAdWithDelegate:(id<DDNAInterstitialAdDelegate>)delegate
{
    DDNAInterstitialAd *interstitialAd = [[DDNAInterstitialAd alloc] init];
    if (interstitialAd) {
        interstitialAd.delegate = delegate;
    }
    return interstitialAd;
}

+ (instancetype)interstitialAdWithEngagement:(DDNAEngagement *)engagement delegate:(id<DDNAInterstitialAdDelegate>)delegate
{
    DDNAInterstitialAd *interstitialAd = [[DDNAInterstitialAd alloc] initWithEngagement:engagement];
    if (interstitialAd) {
        interstitialAd.delegate = delegate;
    }
    return interstitialAd;
}

+ (instancetype)interstitialAdWithUncheckedEngagement:(DDNAEngagement *)engagement delegate:(id<DDNAInterstitialAdDelegate>)delegate
{
    DDNAInterstitialAd *interstitialAd = [[DDNAInterstitialAd alloc] init];
    if (interstitialAd) {
        interstitialAd.delegate = delegate;
        if (engagement != nil && engagement.json != nil && engagement.json[@"parameters"] != nil) {
            interstitialAd.engagement = engagement;
        }
    }
    return interstitialAd;
}

- (instancetype)init
{
    if ((self = [super initWithEngagement:nil])) {
        if (![[DDNASmartAds sharedInstance] isInterstitialAdAllowed:nil checkTime:NO]) return nil;
        [DDNASmartAds sharedInstance].interstitialDelegate = self;
    }
    return self;
}

- (instancetype)initWithEngagement:(DDNAEngagement *)engagement
{
    if ((self = [super initWithEngagement:engagement])) {        
        if (![[DDNASmartAds sharedInstance] isInterstitialAdAllowed:engagement checkTime:NO]) return nil;
        [DDNASmartAds sharedInstance].interstitialDelegate = self;
    }
    return self;
}

- (BOOL)isReady
{
    if (self.engagement) {
        return [[DDNASmartAds sharedInstance] isInterstitialAdAllowed:self.engagement checkTime:YES] && [[DDNASmartAds sharedInstance] hasLoadedInterstitialAd];
    } else {
        return [[DDNASmartAds sharedInstance] hasLoadedInterstitialAd];
    }
}

- (void)showFromRootViewController:(UIViewController *)viewController
{
    if (self.engagement) {
        [[DDNASmartAds sharedInstance] showInterstitialAdFromRootViewController:viewController engagement:self.engagement];
    } else {
        DDNALogWarn(@"Prefer showing ads with Engagements");
        [[DDNASmartAds sharedInstance] showInterstitialAdFromRootViewController:viewController engagement:nil];
    }
}

#pragma mark - DDNASmartAdsInterstitialDelegate

- (void)didOpenInterstitialAd
{
    if ([self.delegate respondsToSelector:@selector(didOpenInterstitialAd:)]) {
        [self.delegate didOpenInterstitialAd:self];
    }
}

- (void)didFailToOpenInterstitialAdWithReason:(NSString *)reason
{
    if ([self.delegate respondsToSelector:@selector(didFailToOpenInterstitialAd:withReason:)]) {
        [self.delegate didFailToOpenInterstitialAd:self withReason:reason];
    }
}

- (void)didCloseInterstitialAd
{
    if ([self.delegate respondsToSelector:@selector(didCloseInterstitialAd:)]) {
        [self.delegate didCloseInterstitialAd:self];
    }
}

@end
