//
// Copyright (c) 2018 deltaDNA Ltd. All rights reserved.
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

#import "DDNASmartAdEngageFactory.h"
#import "DDNAEngagement.h"
#import "DDNAParams.h"
#import "DDNASDK.h"
#import "DDNAInterstitialAd.h"
#import "DDNARewardedAd.h"
#import "DDNASmartAds.h"

@interface DDNASmartAdEngageFactory ()

@property (nonatomic, weak) DDNASDK *sdk;

@end

@implementation DDNASmartAdEngageFactory

- (instancetype)initWithDDNASDK:(id)sdk
{
    if ((self = [super init])) {
        self.sdk = sdk;
    }
    return self;
}

- (void)requestInterstitialAdForDecisionPoint:(NSString *)decisionPoint
                                      handler:(InterstitialAdHandler)handler
{
    [self requestInterstitialAdForDecisionPoint:decisionPoint parameters:nil handler:handler];
}

- (void)requestInterstitialAdForDecisionPoint:(NSString *)decisionPoint
                                   parameters:(nullable DDNAParams *)parameters
                                      handler:(InterstitialAdHandler)handler
{
    DDNAEngagement *engagement = [self buildEngagementWithDecisionPoint:decisionPoint parameters:parameters];
    [self addRealTimeParametersToEngagement:engagement];
    
    [[DDNASDK sharedInstance] requestEngagement:engagement engagementHandler:^(DDNAEngagement *response) {
        DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithUncheckedEngagement:response delegate:nil];
        handler(interstitialAd);
    }];
}

- (void)requestRewardedAdForDecisionPoint:(NSString *)decisionPoint
                                  handler:(RewardedAdHandler)handler
{
    [self requestRewardedAdForDecisionPoint:decisionPoint parameters:nil handler:handler];
}

- (void)requestRewardedAdForDecisionPoint:(NSString *)decisionPoint
                               parameters:(DDNAParams *)parameters
                                  handler:(RewardedAdHandler)handler
{
    DDNAEngagement *engagement = [self buildEngagementWithDecisionPoint:decisionPoint parameters:parameters];
    [self addRealTimeParametersToEngagement:engagement];
    
    [[DDNASDK sharedInstance] requestEngagement:engagement engagementHandler:^(DDNAEngagement *response) {
        DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithUncheckedEngagement:engagement delegate:nil];
        handler(rewardedAd);
    }];
}

#pragma mark - Private Methods

- (DDNAEngagement *)buildEngagementWithDecisionPoint:(NSString *)decisionPoint parameters:(nullable DDNAParams *)parameters
{
    if (decisionPoint == nil || decisionPoint.length == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"decisionPoint cannot be nil or empty" userInfo:nil]);
    }
    
    DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:decisionPoint];
    NSDictionary *paramsCopy = [[NSDictionary alloc] initWithDictionary:parameters.dictionary copyItems:YES];
    for (NSString *key in paramsCopy) {
        [engagement setParam:[parameters.dictionary valueForKey:key] forKey:key];
    }
    
    return engagement;
}

- (void)addRealTimeParametersToEngagement:(DDNAEngagement *)engagement
{
    NSInteger sessionCount = [[DDNASmartAds sharedInstance] sessionCountForDecisionPoint:engagement.decisionPoint];
    NSInteger dailyCount = [[DDNASmartAds sharedInstance] dailyCountForDecisionPoint:engagement.decisionPoint];
    NSDate *lastShown = [[DDNASmartAds sharedInstance] lastShownForDecisionPoint:engagement.decisionPoint];
    
    [engagement setParam:[NSNumber numberWithInteger:sessionCount] forKey:@"ddnaAdSessionCount"];
    [engagement setParam:[NSNumber numberWithInteger:dailyCount] forKey:@"ddnaAdDailyCount"];
    if (lastShown) {
        [engagement setParam:lastShown forKey:@"ddnaAdLastShownTime"];
    }
}

@end
