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

#import "DDNASmartAdIronSourceInterstitialAdapter.h"
#import "DDNASmartAdIronSourceHelper.h"

@interface DDNASmartAdIronSourceInterstitialAdapter () <DDNASmartAdIronSourceInterstitialDelegate>

@property (nonatomic, copy) NSString *appKey;

@end

@implementation DDNASmartAdIronSourceInterstitialAdapter

- (instancetype)initWithAppKey:(NSString *)appKey
                          eCPM:(NSInteger)eCPM
                waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"IRONSOURCE" version:[[DDNASmartAdIronSourceHelper sharedInstance] getSDKVersion] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        [[DDNASmartAdIronSourceHelper sharedInstance] setInterstitialDelegate:self];
        self.appKey = appKey;
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appKey"]) return nil;
    
    return [self initWithAppKey:configuration[@"appKey"]
                           eCPM:[configuration[@"eCPM"] integerValue]
                 waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    [[DDNASmartAdIronSourceHelper sharedInstance] startWithAppKey:self.appKey];
    [[DDNASmartAdIronSourceHelper sharedInstance] loadInterstitial];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([[DDNASmartAdIronSourceHelper sharedInstance] hasInterstitial]) {
        [[DDNASmartAdIronSourceHelper sharedInstance] showInterstitialWithViewController:viewController placement:nil];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - DDNASmartAdIronSourceInterstitialDelegate

- (void)interstitialDidLoad
{
    [self.delegate adapterDidLoadAd:self];
}

- (void)interstitialDidShow
{
    [self.delegate adapterIsShowingAd:self];
}

- (void)interstitialDidFailToShowWithError:(NSError *)error
{
    [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
}

- (void)didClickInterstitial
{
    [self.delegate adapterWasClicked:self];
}

- (void)interstitialDidClose
{
    [self.delegate adapterDidCloseAd:self canReward:YES];
}

- (void)interstitialDidOpen
{

}

- (void)interstitialDidFailToLoadWithError:(NSError *)error
{
    DDNASmartAdRequestResultCode resultCode = [[DDNASmartAdIronSourceHelper sharedInstance] resultCodeFromError:error];
    DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:resultCode];
    result.errorDescription = error.localizedDescription;
    
    [self.delegate adapterDidFailToLoadAd:self withResult:result];
}

@end
