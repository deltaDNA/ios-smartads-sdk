//
//  DDNASmartAds.m
//
//
//  Created by David White on 12/10/2015.
//
//

#import "DDNASmartAds.h"
#import "DeltaDNAAds/DDNASmartAdFactory.h"
#import "DeltaDNAAds/DDNASmartAdService.h"
#import <DeltaDNA/DeltaDNA.h>
#import <DeltaDNA/DDNALog.h>
#import <DeltaDNA/NSString+DeltaDNA.h>



@interface DDNAEngagement(DeltaDNAAds)

@property (nonatomic, copy) NSString *flavour;

@end

@interface DDNASmartAds () <DDNASmartAdServiceDelegate>
{

}

@property (nonatomic, strong) DDNASmartAdFactory *factory;
@property (nonatomic, strong) DDNASmartAdService *adService;

@end

@implementation DDNASmartAds

- (id)init
{
    if ((self = [super init])) {
        self.factory = [DDNASmartAdFactory sharedInstance];
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

+ (NSString *)sdkVersion
{
    return @"SmartAds v1.0.0";
}

- (void)registerForAds
{
    @synchronized(self) {
        @try{
            self.adService = [self.factory buildSmartAdServiceWithDelegate:self];
            [self.adService beginSessionWithDecisionPoint:@"advertising"];
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error registering for ads: %@", exception);
        }
        @finally {
            if (!self.adService) {
                DDNALogWarn(@"Failed to register for ads.");
                [self.interstitialDelegate didFailToRegisterForInterstitialAdsWithReason:@"Couldn't create ad service."];
                [self.rewardedDelegate didFailToRegisterForRewardedAdsWithReason:@"Couldn't create ad service."];
            }
        }
    }
}

- (BOOL)isInterstitialAdAvailable
{
    @synchronized(self) {
        if (self.adService) {
            return [self.adService isInterstitialAdAvailable];
        }
        return NO;
    }
}

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController
{
    @synchronized(self) {
        @try {
            if (self.adService) {
                [self.adService showInterstitialAdFromRootViewController:viewController];
            } else {
                DDNALogWarn(@"RegisterForAds must be called before showing ads will work.");
                [self.interstitialDelegate didFailToOpenInterstitialAd];
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error showing ad: %@", exception);
            [self.interstitialDelegate didFailToOpenInterstitialAd];
        }
    }
}

- (void)showInterstitialAdFromRootViewController:(UIViewController *)viewController adPoint:(NSString *)adPoint
{
    @synchronized(self) {
        @try {
            if (self.adService) {
                [self.adService showInterstitialAdFromRootViewController:viewController adPoint:adPoint];
            } else {
                DDNALogWarn(@"RegisterForAds must be called before showing ads will work.");
                [self.interstitialDelegate didFailToOpenInterstitialAd];
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error showing ad: %@", exception);
            [self.interstitialDelegate didFailToOpenInterstitialAd];
        }
    }
}

- (BOOL)isRewardedAdAvailable
{
    @synchronized(self) {
        if (self.adService) {
            return [self.adService isRewardedAdAvailable];
        }
        return NO;
    }
}

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController
{
    @synchronized(self) {
        @try {
            if (self.adService) {
                [self.adService showRewardedAdFromRootViewController:viewController];
            } else {
                DDNALogWarn(@"RegisterForAds must be called before showing ads will work.");
                [self.rewardedDelegate didFailToOpenRewardedAd];
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error showing ad: %@", exception);
            [self.rewardedDelegate didFailToOpenRewardedAd];
        }
    }
}

- (void)showRewardedAdFromRootViewController:(UIViewController *)viewController adPoint:(NSString *)adPoint
{
    @synchronized(self) {
        @try {
            if (self.adService) {
                [self.adService showRewardedAdFromRootViewController:viewController adPoint:adPoint];
            } else {
                DDNALogWarn(@"RegisterForAds must be called before showing ads will work.");
                [self.rewardedDelegate didFailToOpenRewardedAd];
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error showing ad: %@", exception);
            [self.rewardedDelegate didFailToOpenRewardedAd];
        }
    }
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
    [self.interstitialDelegate didRegisterForInterstitialAds];
}

- (void)didFailToRegisterForInterstitialAdsWithReason:(NSString *)reason
{
    DDNALogDebug(@"Failed to register for interstitial ads: %@.", reason);
    [self.interstitialDelegate didFailToRegisterForInterstitialAdsWithReason:reason];
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

- (void)didFailToOpenInterstitialAd
{
    DDNALogDebug(@"Failed to open interstitial ad.");
    [self.interstitialDelegate didFailToOpenInterstitialAd];
}

- (void)didOpenInterstitialAd
{
    DDNALogDebug(@"Opened interstitial ad.");
    [self.interstitialDelegate didOpenInterstitialAd];
}

- (void)didCloseInterstitialAd
{
    DDNALogDebug(@"Closed interstitial ad.");
    [self.interstitialDelegate didCloseInterstitialAd];
}

- (void)didRegisterForRewardedAds
{
    DDNALogDebug(@"Registered for rewarded ads.");
    [self.rewardedDelegate didRegisterForRewardedAds];
}

- (void)didFailToRegisterForRewardedAdsWithReason:(NSString *)reason
{
    DDNALogDebug(@"Failed to register for rewarded ads: %@.", reason);
    [self.rewardedDelegate didFailToRegisterForRewardedAdsWithReason:reason];
}


- (void)didFailToOpenRewardedAd
{
    DDNALogDebug(@"Failed to open rewarded ad.");
    [self.rewardedDelegate didFailToOpenRewardedAd];
}

- (void)didOpenRewardedAd
{
    DDNALogDebug(@"Opened rewarded ad.");
    [self.rewardedDelegate didOpenRewardedAd];
}

- (void)didCloseRewardedAdWithReward:(BOOL)reward
{
    DDNALogDebug(@"Closed rewarded ad with reward %@", reward ? @"YES" : @"NO");
    [self.rewardedDelegate didCloseRewardedAdWithReward:reward];
}

@end
