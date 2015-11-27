//
//  DDNASmartAdService.m
//  
//
//  Created by David White on 12/10/2015.
//
//

#import "DDNASmartAdService.h"
#import <DeltaDNA/DDNALog.h>
#import <DeltaDNA/DDNAEngageService.h>
#import "DDNASmartAdFactory.h"
#import "DDNASmartAdAgent.h"
#import "DDNASmartAds.h"
#import <DeltaDNA/NSString+DeltaDNA.h>
#import <DeltaDNA/NSDictionary+DeltaDNA.h>
#import "DDNASmartAdStatus.h"

static NSString * const AD_TYPE_UNKNOWN = @"UNKNOWN";
static NSString * const AD_TYPE_INTERSTITIAL = @"INTERSTITIAL";

static const NSInteger REGISTER_FOR_ADS_RETRY_SECONDS = 60 * 15;

@interface DDNASmartAdService () <DDNASmartAdAgentDelegate>

@property (nonatomic, strong) DDNAEngageService *engageService;
@property (nonatomic, strong) NSDictionary *adConfiguration;
@property (nonatomic, strong) DDNASmartAdAgent *interstitialAgent;
@property (nonatomic, assign) BOOL adAvailable;
@property (nonatomic, assign) BOOL showingAd;
@property (nonatomic, assign) NSInteger maxAdsPerSession;
@property (nonatomic, assign) NSInteger adMinimumIntervalMs;
@property (nonatomic, assign) BOOL recordAdRequests;

@end

@implementation DDNASmartAdService

- (instancetype)init
{
    // TODO: should this be logged here or the level up?
    //DDNALogDebug(@"Building SmartAds %@", )
    
    if ((self = [super init])) {
        self.factory = [DDNASmartAdFactory sharedInstance];
    }
    return self;
}

- (void)beginSessionWithDecisionPoint:(NSString *)decisionPoint
{
    self.engageService = [self.factory buildEngageService];
    
    [self.engageService requestWithDecisionPoint:decisionPoint
                                         flavour:DDNADecisionPointFlavourInternal
                                      parameters:nil
                               completionHandler:^(NSString *response, NSInteger statusCode, NSError *connectionError){
                                   
        if (connectionError != nil || statusCode >= 400) {
            if (response == nil) {
                response = [connectionError localizedDescription];
            }
            [self.delegate didFailToRegisterForAdsWithReason:[NSString stringWithFormat:@"Engage returned: %@", response]];
            // TODO - schedule a retry?
            
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW,
                                                  REGISTER_FOR_ADS_RETRY_SECONDS*NSEC_PER_SEC);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self beginSessionWithDecisionPoint:decisionPoint];
            });
        }
        else {
            NSDictionary *responseDict = [NSDictionary dictionaryWithJSONString:response];
            
            if (!responseDict[@"parameters"]) {
                [self.delegate didFailToRegisterForAdsWithReason:@"Invalid Engage response, missing 'parameters' key."];
                return;
            }
            
            self.adConfiguration = responseDict[@"parameters"];
            
            if (!self.adConfiguration[@"adShowSession"] || (![self.adConfiguration[@"adShowSession"] boolValue])) {
                [self.delegate didFailToRegisterForAdsWithReason:@"Ads disabled for this session."];
                return;
            }
            
            if (!self.adConfiguration[@"adProviders"]) {
                [self.delegate didFailToRegisterForAdsWithReason:@"Invalid Engage response, missing 'adProviders' key."];
                return;
            }
            
            self.maxAdsPerSession = [self.adConfiguration[@"adMaxPerSession"] integerValue];
            self.adMinimumIntervalMs = [self.adConfiguration[@"adMinimumInterval"] integerValue];
            self.recordAdRequests = self.adConfiguration[@"adRecordAdRequests"] ? [self.adConfiguration[@"adRecordAdRequests"] boolValue] : YES;
            
            NSInteger floorPrice = [self.adConfiguration[@"adFloorPrice"] integerValue];
            NSArray *adProviders = self.adConfiguration[@"adProviders"];
            
            NSArray *adapterWaterfall = [self.factory buildInterstitialAdapterWaterfallWithAdProviders:adProviders floorPrice:floorPrice];
            if (adapterWaterfall == nil || adapterWaterfall.count == 0) {
                [self.delegate didFailToRegisterForAdsWithReason:[NSString stringWithFormat:@"Failed to build interstitial waterfall from engage response %@", response]];
                return;
            }
            
            self.interstitialAgent = [self.factory buildSmartAdAgentWithWaterfall:adapterWaterfall delegate:self];
            [self.interstitialAgent requestAd];
            
            [self.delegate didRegisterForAds];
        }
                                   
    }];
}

- (void)showAdFromRootViewController:(UIViewController *)viewController
{
    @try {
        
        self.interstitialAgent.adPoint = nil;
        
        if ([[NSDate date] timeIntervalSinceDate:self.interstitialAgent.lastAdShownTime] * 1000 < self.adMinimumIntervalMs) {
            // TODO: Post ad show event with didn't show etc.
            DDNALogDebug(@"showAd called before minimum interval %ld ms between ads elasped", (long)self.adMinimumIntervalMs);
            [self postAdShowEvent:self.interstitialAgent
                          adapter:self.interstitialAgent.currentAdapter
                           result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeMinTimeNotElapsed]];
            
            [self.delegate didFailToOpenAd];
            
            return;
        }
        
        if (self.interstitialAgent.adsShown >= self.maxAdsPerSession) {
            // TODO: Post ad show event with didn't show etc.
            DDNALogDebug(@"Max ad per session count od %ld reached", (long)self.maxAdsPerSession);
            [self postAdShowEvent:self.interstitialAgent
                          adapter:self.interstitialAgent.currentAdapter
                           result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeAdSessionLimitReached]];
            
            [self.delegate didFailToOpenAd];
            return;
        }
        
        if (self.interstitialAgent.hasLoadedAd) {
            [self postAdShowEvent:self.interstitialAgent
                          adapter:self.interstitialAgent.currentAdapter
                           result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeFulfilled]];
            
            [self.interstitialAgent showAdFromRootViewController:viewController adPoint:nil];
        }
        else {
            [self postAdShowEvent:self.interstitialAgent
                          adapter:self.interstitialAgent.currentAdapter
                           result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeNotReady]];
        }
        
    }
    @catch (NSException *exception) {
        DDNALogWarn(@"ShowAd raised exception: %@", exception);
        [self.delegate didFailToOpenAd];
    }
}

- (void)showAdFromRootViewController:(UIViewController *)viewController adPoint:(NSString *)adPoint
{
    @try {
        
        // FIXME: Agent doesn't want to know about adPoint anymore, it's reported at the service level
        self.interstitialAgent.adPoint = adPoint;
        
        if ([[NSDate date] timeIntervalSinceDate:self.interstitialAgent.lastAdShownTime] * 1000 < self.adMinimumIntervalMs) {
            // TODO: Post ad show event with didn't show etc.
            DDNALogDebug(@"showAd called before minimum interval %ld ms between ads elasped", (long)self.adMinimumIntervalMs);
            [self postAdShowEvent:self.interstitialAgent
                          adapter:self.interstitialAgent.currentAdapter
                           result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeMinTimeNotElapsed]];
            
            [self.delegate didFailToOpenAd];
            return;
        }
        
        if (self.interstitialAgent.adsShown >= self.maxAdsPerSession) {
            // TODO: Post ad show event with didn't show etc.
            DDNALogDebug(@"Max ad per session count od %ld reached", (long)self.maxAdsPerSession);
            [self postAdShowEvent:self.interstitialAgent
                          adapter:self.interstitialAgent.currentAdapter
                           result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeAdSessionLimitReached]];
            
            [self.delegate didFailToOpenAd];
            return;
        }
        
        if (!self.adConfiguration[@"adShowPoint"] || [self.adConfiguration[@"adShowPoint"] boolValue]) {
            
            [self.engageService requestWithDecisionPoint:adPoint
                                                 flavour:DDNADecisionPointFlavourAdvertising
                                              parameters:nil
                                       completionHandler:^(NSString *response, NSInteger statusCode, NSError *connectionError) {
                                           
                if (connectionError != nil || statusCode >= 400) {
                    // Couldn't get a response from Engage, show ad anyway
                    // TODO - maybe change the default timeout so this is faster?
                    DDNALogDebug(@"Engage request failed: %@: showing ad anyway at %@", response, adPoint);
                    if (self.interstitialAgent.hasLoadedAd) {
                        [self postAdShowEvent:self.interstitialAgent
                                      adapter:self.interstitialAgent.currentAdapter
                                       result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeEngageFailed]];
                        
                        [self.interstitialAgent showAdFromRootViewController:viewController adPoint:nil];
                    }
                    else {
                        [self postAdShowEvent:self.interstitialAgent
                                      adapter:self.interstitialAgent.currentAdapter
                                       result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeNotReady]];
                    }
                }
                else {
                    NSDictionary *responseDict = [NSDictionary dictionaryWithJSONString:response][@"parameters"];
                    if (!responseDict[@"adShowPoint"] || [responseDict[@"adShowPoint"] boolValue]) {
                        DDNALogDebug(@"Engage allowing interstitial ad at %@", adPoint);
                        if (self.interstitialAgent.hasLoadedAd) {
                            [self postAdShowEvent:self.interstitialAgent
                                          adapter:self.interstitialAgent.currentAdapter
                                           result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeFulfilled]];
                            
                            [self.interstitialAgent showAdFromRootViewController:viewController adPoint:adPoint];
                        }
                        else {
                            [self postAdShowEvent:self.interstitialAgent
                                          adapter:self.interstitialAgent.currentAdapter
                                           result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeNotReady]];
                        }
                    }
                    else {
                        DDNALogDebug(@"Engage prevented interstitial ad from opening at %@", adPoint);
                        self.interstitialAgent.adPoint = adPoint;
                        [self postAdShowEvent:self.interstitialAgent
                                      adapter:self.interstitialAgent.currentAdapter
                                       result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeAdShowPoint]];
                        
                        [self.delegate didFailToOpenAd];
                    }
                }
                                           
            }];
            
        }
        else {
            self.interstitialAgent.adPoint = adPoint;
            [self postAdShowEvent:self.interstitialAgent
                          adapter:self.interstitialAgent.currentAdapter
                           result:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeAdShowPoint]];
        }
    }
    @catch (NSException *exception) {
        DDNALogWarn(@"ShowAdWithAdPoint:%@ raised exception: %@", adPoint, exception);
        [self.delegate didFailToOpenAd];
    }
}

#pragma mark - DDNASmartAdAgent

- (void)adAgent:(DDNASmartAdAgent *)adAgent didLoadAdWithAdapter:(DDNASmartAdAdapter *)adapter requestTime:(NSTimeInterval)requestTime
{
    if (adAgent == self.interstitialAgent) {
        DDNALogDebug(@"Interstitial ad loaded.");
        self.adAvailable = YES;
        [self postAdRequestEvent:adAgent
                         adapter:adapter
                 requestDuration:requestTime
                          result:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeLoaded]];
    }
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didFailToLoadAdWithAdapter:(DDNASmartAdAdapter *)adapter requestTime:(NSTimeInterval)requestTime requestResult:(DDNASmartAdRequestResult *)result
{
    if (adAgent == self.interstitialAgent ) {
        [self postAdRequestEvent:adAgent adapter:adapter requestDuration:requestTime result:result];
    }
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didOpenAdWithAdapter:(DDNASmartAdAdapter *)adapter
{
    if (adAgent == self.interstitialAgent) {
        DDNALogDebug(@"Interstitial ad opened.");
        self.showingAd = YES;
        self.adAvailable = NO;
        [self.delegate didOpenAd];
    }
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didFailToOpenAdWithAdapter:(DDNASmartAdAdapter *)adapter closedResult:(DDNASmartAdClosedResult *)result
{
    if (adAgent == self.interstitialAgent) {
        self.adAvailable = NO;
        [self postAdClosedEvent:adAgent adapter:adapter result:result];
    }
}

- (void)adAgent:(DDNASmartAdAgent *)adAgent didCloseAdWithAdapter:(DDNASmartAdAdapter *)adapter canReward:(BOOL)canReward
{
    if (adAgent == self.interstitialAgent) {
        DDNALogDebug(@"Interstitial ad closed.");
        self.showingAd = NO;
        [self postAdClosedEvent:adAgent adapter:adapter result:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeSuccess]];
        [self.delegate didCloseAd];
    }
    
}

#pragma mark - Private

- (void)postAdShowEvent:(DDNASmartAdAgent *)agent adapter:(DDNASmartAdAdapter *)adapter result:(DDNASmartAdShowResult *)result
{
    NSString *adType = AD_TYPE_UNKNOWN;
    if (agent == self.interstitialAgent) {
        adType = AD_TYPE_INTERSTITIAL;
    }
        
    NSMutableDictionary *eventParams = [[NSMutableDictionary alloc] initWithCapacity:10];
    eventParams[@"adProvider"] = [adapter name];
    eventParams[@"adProviderVersion"] = [adapter version];
    eventParams[@"adType"] = adType;
    eventParams[@"adStatus"] = result.desc;
    eventParams[@"adSdkVersion"] = [DDNASmartAds sdkVersion];
    if ([agent adPoint] != nil) {
        eventParams[@"adPoint"] = [agent adPoint];
    }
    
    NSString *eventParamsJSON = [NSString stringWithContentsOfDictionary:eventParams];
    DDNALogDebug(@"Posting adShow event: %@", eventParamsJSON);
    [self.delegate recordEventWithName:@"adShow" andParamJson:eventParamsJSON];
}

- (void)postAdClosedEvent:(DDNASmartAdAgent *)agent adapter:(DDNASmartAdAdapter *)adapter result:(DDNASmartAdClosedResult *)result
{
    NSString *adType = AD_TYPE_UNKNOWN;
    if (agent == self.interstitialAgent) {
        adType = AD_TYPE_INTERSTITIAL;
    }
    
    NSMutableDictionary *eventParams = [[NSMutableDictionary alloc] initWithCapacity:7];
    eventParams[@"adProvider"] = adapter.name;
    eventParams[@"adProvderVersion"] = adapter.version;
    eventParams[@"adType"] = adType;
    eventParams[@"adClicked"] = [NSNumber numberWithBool:[agent adWasClicked]];
    eventParams[@"adLeftApplication"] = [NSNumber numberWithBool:[agent adLeftApplication]];
    eventParams[@"adEcpm"] = [NSNumber numberWithInteger:adapter.eCPM];
    eventParams[@"adSdkVersion"] = [DDNASmartAds sdkVersion];
    eventParams[@"adStatus"] = result.desc;
    
    NSString *eventParamsJSON = [NSString stringWithContentsOfDictionary:eventParams];
    DDNALogDebug(@"Posting adClosed event: %@", eventParamsJSON);
    [self.delegate recordEventWithName:@"adClosed" andParamJson:eventParamsJSON];
}

- (void)postAdRequestEvent:(DDNASmartAdAgent *)agent adapter:(DDNASmartAdAdapter *)adapter requestDuration:(NSTimeInterval)requestDuration result:(DDNASmartAdRequestResult *)result
{
    if (self.recordAdRequests) {
        
        NSString *adType = AD_TYPE_UNKNOWN;
        if (agent == self.interstitialAgent) {
            adType = AD_TYPE_INTERSTITIAL;
        }
        
        NSMutableDictionary *eventParams = [[NSMutableDictionary alloc] initWithCapacity:8];
        eventParams[@"adProvider"] = adapter.name;
        eventParams[@"adProviderVersion"] = adapter.version;
        eventParams[@"adType"] = adType;
        eventParams[@"adSdkVersion"] = [DDNASmartAds sdkVersion];
        eventParams[@"adRequestTimeMs"] = [NSNumber numberWithInteger:(int)requestDuration];
        eventParams[@"adWaterfallIndex"] = [NSNumber numberWithInteger:adapter.waterfallIndex];
        eventParams[@"adStatus"] = result.desc;
        if (result.error) {
            eventParams[@"adProviderError"] = result.error;
        }
        
        NSString *eventParamsJSON = [NSString stringWithContentsOfDictionary:eventParams];
        DDNALogDebug(@"Posting adRequest event: %@", eventParamsJSON);
        [self.delegate recordEventWithName:@"adRequest" andParamJson:eventParamsJSON];
    }
}

@end
