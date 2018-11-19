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

#import "DDNASmartAds.h"
#import "DDNASmartAdFactory.h"
#import "DDNASmartAdService.h"
#import "DDNADebugListener.h"
#import <DeltaDNA/DeltaDNA.h>
#import <DeltaDNA/DDNALog.h>
#import <DeltaDNA/NSString+DeltaDNA.h>
#import <AdSupport/AdSupport.h>



@interface DDNAEngagement(DeltaDNAAds)

@property (nonatomic, copy) NSString *flavour;

@end

@interface DDNASmartAds () <DDNASmartAdServiceDelegate>
{

}

@property (nonatomic, strong) DDNASmartAdFactory *factory;
@property (nonatomic, strong) DDNASmartAdService *adService;
@property (nonatomic, strong) DDNADebugListener *debugListener;
@property (nonatomic, strong) DDNASmartAdEngageFactory *engageFactory;
@property (nonatomic, strong) DDNASmartAdSettings *settings;

@end

@implementation DDNASmartAds

- (id)init
{
    if ((self = [super init])) {
        self.factory = [DDNASmartAdFactory sharedInstance];
        self.debugListener = [DDNADebugListener sharedInstance];
        #if !DDNA_DEBUG_NOTIFICATIONS
        [self.debugListener disableNotifications];
        #endif
        [self.debugListener registerListeners];

        __weak typeof(self) weakSelf = self;
        NSNotificationCenter * __weak center = [NSNotificationCenter defaultCenter];
        [center addObserverForName:@"DDNASDKSessionConfig" object:DDNASDK.sharedInstance queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            DDNALogDebug(@"SmartAds received updated session configuration.");
            NSDictionary *config = note.userInfo[@"config"];
            if (config) {
                [weakSelf registerForAdsInternalWithConfig:config];
            } else {
                DDNALogWarn(@"Config missing from session config notification.");
            }
        }];

        self.engageFactory = [[DDNASmartAdEngageFactory alloc] initWithDDNASDK:[DDNASDK sharedInstance]];
        self.settings = [[DDNASmartAdSettings alloc] init];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSString *)sdkVersion
{
    return @"SmartAds v1.10.1";
}

- (void)registerForAds
{

}

- (void)registerForAdsInternalWithConfig:(nonnull NSDictionary *)config
{
    @synchronized(self) {
        @try{
            self.adService = [self.factory buildSmartAdServiceWithDelegate:self];
            [self.adService beginSessionWithConfig:config
                                       userConsent:self.settings.advertiserGdprUserConsent
                                     ageRestricted:self.settings.advertiserGdprAgeRestrictedUser];
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error registering for ads: %@", exception);
        }
        @finally {
            if (!self.adService) {
                DDNALogWarn(@"Failed to register for ads.");
                [self.registrationDelegate didFailToRegisterForInterstitialAdsWithReason:@"Couldn't create ad service."];
                [self.registrationDelegate didFailToRegisterForRewardedAdsWithReason:@"Couldn't create ad service."];
            }
        }
    }
}

- (BOOL)isInterstitialAdAllowed:(DDNAEngagement *)engagement checkTime:(BOOL)checkTime
{
    @synchronized (self) {
        if (!self.adService) return NO;

        NSString *decisionPoint = engagement ? engagement.decisionPoint : nil;
        NSDictionary *parameters = engagement && engagement.json && engagement.json[@"parameters"] ? engagement.json[@"parameters"] : nil;
        
        return [self.adService isInterstitialAdAllowedForDecisionPoint:decisionPoint parameters:parameters checkTime:checkTime];
    }
}

- (BOOL)hasLoadedInterstitialAd
{
    @synchronized(self) {
        if (self.adService) {
            return [self.adService hasLoadedInterstitialAd];
        }
        return NO;
    }
}

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController engagement:(DDNAEngagement *)engagement
{
    @synchronized(self) {
        @try {
            if (self.adService) {
                NSString *decisionPoint = engagement ? engagement.decisionPoint : nil;
                NSDictionary *parameters = engagement && engagement.json && engagement.json[@"parameters"] ? engagement.json[@"parameters"] : nil;
                [self.adService showInterstitialAdFromRootViewController:viewController decisionPoint:decisionPoint parameters:parameters];
            } else {
                DDNALogWarn(@"RegisterForAds must be called before showing ads will work.");
                [self.interstitialDelegate didFailToOpenInterstitialAdWithReason:@"Not configured for interstitial ads"];
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error showing ad: %@", exception);
            [self.interstitialDelegate didFailToOpenInterstitialAdWithReason:exception.reason];
        }
    }
}

- (BOOL)isRewardedAdAllowed:(DDNAEngagement *)engagement checkTime:(BOOL)checkTime
{
    @synchronized (self) {
        if (!self.adService) return NO;
        
        NSString *decisionPoint = engagement ? engagement.decisionPoint : nil;
        NSDictionary *parameters = engagement && engagement.json && engagement.json[@"parameters"] ? engagement.json[@"parameters"] : nil;
        
        return [self.adService isRewardedAdAllowedForDecisionPoint:decisionPoint parameters:parameters checkTime:checkTime];
    }
}

- (NSTimeInterval)timeUntilRewardedAdAllowedForEngagement:(DDNAEngagement *)engagement
{
    @synchronized (self) {
        if (!self.adService) return NO;
        
        NSString *decisionPoint = engagement ? engagement.decisionPoint : nil;
        NSDictionary *parameters = engagement && engagement.json && engagement.json[@"parameters"] ? engagement.json[@"parameters"] : nil;
        
        return [self.adService timeUntilRewardedAdAllowedForDecisionPoint:decisionPoint parameters:parameters];
    }
}

- (BOOL)hasLoadedRewardedAd
{
    @synchronized(self) {
        if (self.adService) {
            return [self.adService hasLoadedRewardedAd];
        }
        return NO;
    }
}

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController engagement:(DDNAEngagement *)engagement
{
    @synchronized(self) {
        @try {
            if (self.adService) {
                NSString *decisionPoint = engagement ? engagement.decisionPoint : nil;
                NSDictionary *parameters = engagement && engagement.json && engagement.json[@"parameters"] ? engagement.json[@"parameters"] : nil;
                [self.adService showRewardedAdFromRootViewController:viewController decisionPoint:decisionPoint parameters:parameters];
            } else {
                DDNALogWarn(@"RegisterForAds must be called before showing ads will work.");
                [self.rewardedDelegate didFailToOpenRewardedAdWithReason:@"Not registered"];
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error showing ad: %@", exception);
            [self.rewardedDelegate didFailToOpenRewardedAdWithReason:exception.reason];
        }
    }
}

- (NSDate *)lastShownForDecisionPoint:(NSString *)decisionPoint
{
    return [self.adService lastShownForDecisionPoint:decisionPoint];
}

- (NSInteger)sessionCountForDecisionPoint:(NSString *)decisionPoint
{
    return [self.adService sessionCountForDecisionPoint:decisionPoint];
}

- (NSInteger)dailyCountForDecisionPoint:(NSString *)decisionPoint
{
    return [self.adService dailyCountForDecisionPoint:decisionPoint];
}


- (void)pause
{
    [self.adService pause];
}

- (void)resume
{
    [self.adService resume];
}


#pragma mark - DDNASmartAdServiceDelegate

- (void)didRegisterForInterstitialAds
{
    DDNALogDebug(@"Registered for interstitial ads.");
    [self recordIdfa];
    if ([self.registrationDelegate respondsToSelector:@selector(didRegisterForInterstitialAds)]) {
        [self.registrationDelegate didRegisterForInterstitialAds];
    }
}

- (void)didFailToRegisterForInterstitialAdsWithReason:(NSString *)reason
{
    DDNALogDebug(@"Failed to register for interstitial ads: %@.", reason);
    if ([self.registrationDelegate respondsToSelector:@selector(didFailToRegisterForRewardedAdsWithReason:)]) {
        [self.registrationDelegate didFailToRegisterForInterstitialAdsWithReason:reason];
    }
}

- (void)recordEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    [[DDNASDK sharedInstance] recordEventWithName:eventName eventParams:parameters];
}

- (void)requestEngagementWithDecisionPoint:(NSString *)decisionPoint flavour:(NSString *)flavour parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSString *, NSInteger, NSError *))completionHandler
{
    DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:decisionPoint];
    engagement.flavour = flavour;
    for (NSString *key in parameters) {
        [engagement setParam:parameters[key] forKey:key];
    }

    [[DDNASDK sharedInstance] requestEngagement:engagement completionHandler:^(NSDictionary *parameters, NSInteger statusCode, NSError *error) {
        completionHandler([NSString stringWithContentsOfDictionary:parameters], statusCode, error);
    }];
}

- (void)didFailToOpenInterstitialAdWithReason:(NSString *)reason
{
    if ([self.interstitialDelegate respondsToSelector:@selector(didFailToOpenInterstitialAdWithReason:)]) {
        [self.interstitialDelegate didFailToOpenInterstitialAdWithReason:reason];
    }
}

- (void)didOpenInterstitialAd
{
    if ([self.interstitialDelegate respondsToSelector:@selector(didOpenInterstitialAd)]) {
        [self.interstitialDelegate didOpenInterstitialAd];
    }
}

- (void)didCloseInterstitialAd
{
    if ([self.interstitialDelegate respondsToSelector:@selector(didCloseInterstitialAd)]) {
        [self.interstitialDelegate didCloseInterstitialAd];
    }
}

- (void)didRegisterForRewardedAds
{
    DDNALogDebug(@"Registered for rewarded ads.");
    [self recordIdfa];
    if ([self.registrationDelegate respondsToSelector:@selector(didRegisterForRewardedAds)]) {
        [self.registrationDelegate didRegisterForRewardedAds];
    }
}

- (void)didFailToRegisterForRewardedAdsWithReason:(NSString *)reason
{
    DDNALogDebug(@"Failed to register for rewarded ads: %@.", reason);
    if ([self.registrationDelegate respondsToSelector:@selector(didFailToRegisterForRewardedAdsWithReason:)]) {
        [self.registrationDelegate didFailToRegisterForRewardedAdsWithReason:reason];
    }
}

- (void)didLoadRewardedAd
{
    
}

- (void)didFailToOpenRewardedAdWithReason:(NSString *)reason
{
    DDNALogDebug(@"Failed to open rewarded ad: %@", reason);
    if ([self.rewardedDelegate respondsToSelector:@selector(didFailToOpenRewardedAdWithReason:)]) {
        [self.rewardedDelegate didFailToOpenRewardedAdWithReason:reason];
    }
}

- (void)didOpenRewardedAdForDecisionPoint:(NSString *)decisionPoint
{
    DDNALogDebug(@"Opened rewarded ad %@.", decisionPoint);
    if ([self.rewardedDelegate respondsToSelector:@selector(didOpenRewardedAd)]) {
        [self.rewardedDelegate didOpenRewardedAd];
    }
}

- (void)didCloseRewardedAdWithReward:(BOOL)reward
{
    DDNALogDebug(@"Closed rewarded ad with reward %@", reward ? @"YES" : @"NO");
    if ([self.rewardedDelegate respondsToSelector:@selector(didCloseRewardedAdWithReward:)]) {
        [self.rewardedDelegate didCloseRewardedAdWithReward:reward];
    }
}

- (void)recordIdfa
{
    if ([ASIdentifierManager sharedManager].advertisingTrackingEnabled) {
        [[NSUserDefaults standardUserDefaults] setObject:[ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString forKey:@"com.deltadna.advertisingId"];
    }
}

@end
