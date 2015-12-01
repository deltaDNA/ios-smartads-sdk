//
//  DDNASmartAdFactory.m
//  
//
//  Created by David White on 12/10/2015.
//
//

#import "DDNASmartAdFactory.h"
#import "DDNASmartAdAdapter.h"
#import "DDNASmartAdService.h"
#import "DDNASmartAdAgent.h"
#import <DeltaDNA/DDNALog.h>
#import <DeltaDNA/DDNANetworkRequest.h>
#import <DeltaDNA/DDNAEngageService.h>
#import "DDNASDK.h"
#import "DDNASettings.h"
#import "DDNAClientInfo.h"
#import "NSString+DeltaDNA.h"

// TODO: This would be better to derive the class name from the tag sent
// over the wire
static NSString *const AD_NETWORK_DUMMY = @"DUMMY";
static NSString *const AD_NETWORK_DUMMY_CLASS = @"DDNASmartAdDummyAdapter";
static NSString *const AD_NETWORK_ADMOB = @"ADMOB";
static NSString *const AD_NETWORK_ADMOB_CLASS = @"DDNASmartAdAdMobAdapter";
static NSString *const AD_NETWORK_AMAZON = @"AMAZON";
static NSString *const AD_NETWORK_AMAZON_CLASS = @"DDNASmartAdAmazonAdapter";
static NSString *const AD_NETWORK_MOPUB = @"MOPUB";
static NSString *const AD_NETWORK_MOPUB_CLASS = @"DDNASmartAdMoPubAdapter";
static NSString *const AD_NETWORK_FLURRY = @"FLURRY";
static NSString *const AD_NETWORK_FLURRY_CLASS = @"DDNASmartAdFlurryInterstitialAdapter";
static NSString *const AD_NETWORK_FLURRY_REWARDED = @"FLURRY-REWARDED";
static NSString *const AD_NETWORK_FLURRY_REWARDED_CLASS = @"DDNASmartAdFlurryRewardedAdapter";
static NSString *const AD_NETWORK_INMOBI = @"INMOBI";
static NSString *const AD_NETWORK_INMOBI_CLASS = @"DDNASmartAdInMobiInterstitialAdapter";
static NSString *const AD_NETWORK_INMOBI_REWARDED = @"INMOBI-REWARDED";
static NSString *const AD_NETWORK_INMOBI_REWARDED_CLASS = @"DDNASmartAdInMobiRewardedAdapter";
static NSString *const AD_NETWORK_MOBFOX = @"MOBFOX";
static NSString *const AD_NETWORK_MOBFOX_CLASS = @"DDNASmartAdMobFoxAdapter";
static NSString *const AD_NETWORK_CHARTBOOST = @"CHARTBOOST";
static NSString *const AD_NETWORK_CHARTBOOST_CLASS = @"DDNASmartAdChartboostInterstitialAdapter";
static NSString *const AD_NETWORK_CHARTBOOST_REWARDED = @"CHARTBOOST-REWARDED";
static NSString *const AD_NETWORK_CHARTBOOST_REWARDED_CLASS = @"DDNASmartAdChartboostRewardedAdapter";
static NSString *const AD_NETWORK_ADCOLONY = @"ADCOLONY";
static NSString *const AD_NETWORK_ADCOLONY_CLASS = @"DDNASmartAdAdColonyAdapter";
static NSString *const AD_NETWORK_VUNGLE = @"VUNGLE";
static NSString *const AD_NETWORK_VUNGLE_CLASS = @"DDNASmartAdVungleAdapter";

@implementation DDNASmartAdFactory

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (DDNANetworkRequest *)buildNetworkRequestWithURL: (NSURL *)URL jsonPayload: (NSString *)jsonPayload delegate:(id<DDNANetworkRequestDelegate>)delegate
{
    DDNANetworkRequest *networkRequest = [[DDNANetworkRequest alloc] initWithURL:URL jsonPayload:jsonPayload];
    networkRequest.delegate = delegate;
    
    return networkRequest;
}

- (DDNAEngageService *)buildEngageService
{
    DDNASDK *ddnasdk = [DDNASDK sharedInstance];
    DDNAClientInfo *ddnaci = [DDNAClientInfo sharedInstance];
    
    DDNAEngageService *engageService = [[DDNAEngageService alloc] initWithEndpoint:ddnasdk.engageURL
                                                                    environmentKey:ddnasdk.environmentKey
                                                                        hashSecret:ddnasdk.hashSecret
                                                                            userID:ddnasdk.userID
                                                                         sessionID:ddnasdk.sessionID
                                                                           version:DDNA_ENGAGE_API_VERSION
                                                                        sdkVersion:DDNA_SDK_VERSION
                                                                          platform:ddnaci.platform
                                                                    timezoneOffset:ddnaci.timezoneOffset
                                                                      manufacturer:ddnaci.manufacturer
                                                            operatingSystemVersion:ddnaci.operatingSystemVersion];
    
    return engageService;
}

- (DDNASmartAdService *)buildSmartAdServiceWithDelegate:(id<DDNASmartAdServiceDelegate>)delegate
{
    DDNASmartAdService *adService = [[DDNASmartAdService alloc] init];
    adService.delegate = delegate;
    return adService;
}

- (DDNASmartAdAgent *)buildSmartAdAgentWithWaterfall:(NSArray *)waterfall delegate:(id<DDNASmartAdAgentDelegate>)delegate
{
    DDNASmartAdAgent *adAgent = [[DDNASmartAdAgent alloc] initWithAdapters:waterfall];
    adAgent.delegate = delegate;
    return adAgent;
}

- (DDNASmartAdAdapter *)instantiateAdapterForKlass:(NSString *)klassName
                                     configuration: (NSDictionary *)configuration
                                    waterfallIndex: (NSInteger)waterfallIndex {
    DDNASmartAdAdapter * adapter = nil;
    Class klass = NSClassFromString(klassName);
    if (klass != nil /*&& [klass respondsToSelector:@selector(initWithConfiguration:waterfallIndex:)]*/ /*&& [klass superclass] == [DDNASmartAdAdapter class]*/) {
        adapter = [[klass alloc] initWithConfiguration:configuration waterfallIndex:waterfallIndex];
        // optionally call create here if you need to do more, i.e. pass config in
    } else {
        DDNALogWarn(@"Ad network %@ not available", configuration[@"adProvider"]);
    }
    return adapter;
}

- (NSArray *)buildAdapterWaterfallWithAdProviders: (NSArray *)adProviders floorPrice: (NSInteger)floorPrice
{
    if (![adProviders isKindOfClass:[NSArray class]]) return nil;
    
    NSMutableArray *adapters = [NSMutableArray arrayWithCapacity:adProviders.count];
    
    for (int i = 0; i < adProviders.count; i++) {
        NSDictionary *configuration = adProviders[i];
        if (![configuration isKindOfClass:[NSDictionary class]]) {
            DDNALogWarn(@"Failed to build adapter for ad provider at index %d - invalid format.", i);
            continue;
        }
        NSString *adProvider = configuration[@"adProvider"];
        if ([NSString stringIsNilOrEmpty:adProvider]) {
            DDNALogWarn(@"Failed to build adapter for ad provider at index %d - missing adProvider key.", i);
            continue;
        }
        
        @try {
            DDNASmartAdAdapter * adapter = nil;
            NSInteger ecpm = [configuration[@"eCPM"] integerValue];
            
            if (ecpm > floorPrice) {
                if ([adProvider isEqualToString:AD_NETWORK_ADMOB]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_ADMOB_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider isEqualToString:AD_NETWORK_AMAZON]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_AMAZON_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider isEqualToString:AD_NETWORK_DUMMY]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_DUMMY_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider isEqualToString:AD_NETWORK_MOPUB]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_MOPUB_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider isEqualToString:AD_NETWORK_FLURRY]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_FLURRY_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider isEqualToString:AD_NETWORK_FLURRY_REWARDED]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_FLURRY_REWARDED_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider isEqualToString:AD_NETWORK_INMOBI]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_INMOBI_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider isEqualToString:AD_NETWORK_INMOBI_REWARDED]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_INMOBI_REWARDED_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }

                else if ([adProvider isEqualToString:AD_NETWORK_MOBFOX]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_MOBFOX_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider isEqualToString:AD_NETWORK_CHARTBOOST]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_CHARTBOOST_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider isEqualToString:AD_NETWORK_CHARTBOOST_REWARDED]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_CHARTBOOST_REWARDED_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider isEqualToString:AD_NETWORK_ADCOLONY]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_ADCOLONY_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider isEqualToString:AD_NETWORK_VUNGLE]) {
                    adapter = [self instantiateAdapterForKlass:AD_NETWORK_VUNGLE_CLASS
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else {
                    DDNALogWarn(@"Ad network %@ is unknown.", adProvider);
                }
                
                if (adapter) {
                    [adapters addObject:adapter];
                }
                else {
                    DDNALogWarn(@"Failed to build adapter for %@ - missing configuration.", adProvider);
                }
            }
            else {
                DDNALogDebug(@"Skipping %@ - eCPM %ld below %ld.", adProvider, (long)ecpm, (long)floorPrice);
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Failed to build adapter for %@: %@.", adProvider, exception);
        }
    }
    
    return adapters;
}

@end
