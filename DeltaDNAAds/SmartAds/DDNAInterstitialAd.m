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

@property (nonatomic, strong) NSDictionary *parameters;

@end

@implementation DDNAInterstitialAd

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

- (instancetype)init
{
    if ((self = [super init])) {
        if (![[DDNASmartAds sharedInstance] isInterstitialAdAllowed:nil]) return nil;
        
        self.parameters = [[NSDictionary alloc] init];
        [DDNASmartAds sharedInstance].interstitialDelegate = self;
    }
    return self;
}

- (instancetype)initWithEngagement:(DDNAEngagement *)engagement
{
    if ((self = [super init])) {        
        if (![[DDNASmartAds sharedInstance] isInterstitialAdAllowed:engagement]) return nil;
        self.parameters = [NSDictionary dictionaryWithDictionary:engagement.json[@"parameters"]];
        [DDNASmartAds sharedInstance].interstitialDelegate = self;
    }
    return self;
}

- (BOOL)isReady
{
    return [[DDNASmartAds sharedInstance] isInterstitialAdAvailable];
}

- (void)showFromRootViewController:(UIViewController *)viewController
{
    [[DDNASmartAds sharedInstance] showInterstitialAdFromRootViewController:viewController];
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