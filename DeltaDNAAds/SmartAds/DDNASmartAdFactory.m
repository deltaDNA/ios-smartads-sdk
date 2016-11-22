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

#import "DDNASmartAdFactory.h"
#import "DDNASmartAdAdapter.h"
#import "DDNASmartAdService.h"
#import "DDNASmartAdAgent.h"
#import "DDNASmartAdWaterfall.h"
#import <DeltaDNA/DDNALog.h>
#import "DDNASDK.h"
#import "DDNASettings.h"
#import "DDNAClientInfo.h"
#import "NSString+DeltaDNA.h"


typedef NS_ENUM(NSInteger, DDNASmartAdAdapterType) {
    DDNASmartAdAdapterTypeInterstitial,
    DDNASmartAdAdapterTypeRewarded
};

@implementation NSString (DeltaDNAAds)

- (BOOL)caseInsensitiveContains:(NSString *)string
{
    return ([self rangeOfString:string
                      options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location
            != NSNotFound);
}

@end

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

- (DDNASmartAdService *)buildSmartAdServiceWithDelegate:(id<DDNASmartAdServiceDelegate>)delegate
{
    DDNASmartAdService *adService = [[DDNASmartAdService alloc] init];
    adService.delegate = delegate;
    return adService;
}

- (DDNASmartAdAgent *)buildSmartAdAgentWithWaterfall:(DDNASmartAdWaterfall *)waterfall delegate:(id<DDNASmartAdAgentDelegate>)delegate
{
    DDNASmartAdAgent *adAgent = [[DDNASmartAdAgent alloc] initWithWaterfall:waterfall];
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

- (NSArray *)buildInterstitialAdapterWaterfallWithAdProviders:(NSArray *)adProviders floorPrice:(NSInteger)floorPrice
{
    return [self buildAdapterWaterfallWithAdProviders:adProviders type:DDNASmartAdAdapterTypeInterstitial floorPrice:floorPrice];
}

- (NSArray *)buildRewardedAdapterWaterfallWithAdProviders:(NSArray *)adProviders floorPrice:(NSInteger)floorPrice
{
    return [self buildAdapterWaterfallWithAdProviders:adProviders type:DDNASmartAdAdapterTypeRewarded floorPrice:floorPrice];
}

- (NSArray *)buildAdapterWaterfallWithAdProviders:(NSArray *)adProviders type:(DDNASmartAdAdapterType)type floorPrice:(NSInteger)floorPrice
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
                
                if ([adProvider caseInsensitiveContains:@"ADMOB"]) {
                    adapter = [self instantiateAdapterForKlass:@"DDNASmartAdAdMobAdapter"
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider caseInsensitiveContains:@"AMAZON"]) {
                    adapter = [self instantiateAdapterForKlass:@"DDNASmartAdAmazonAdapter"
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider caseInsensitiveContains:@"DUMMY"]) {
                    adapter = [self instantiateAdapterForKlass:@"DDNASmartAdDummyAdapter"
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider caseInsensitiveContains:@"MOPUB"]) {
                    adapter = [self instantiateAdapterForKlass:@"DDNASmartAdMoPubAdapter"
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider caseInsensitiveContains:@"FLURRY"]) {
                    if (type == DDNASmartAdAdapterTypeInterstitial) {
                        adapter = [self instantiateAdapterForKlass:@"DDNASmartAdFlurryInterstitialAdapter"
                                                     configuration:configuration
                                                    waterfallIndex:i];
                    } else {
                        adapter = [self instantiateAdapterForKlass:@"DDNASmartAdFlurryRewardedAdapter"
                                                     configuration:configuration
                                                    waterfallIndex:i];
                    }
                }
                else if ([adProvider caseInsensitiveContains:@"INMOBI"]) {
                    if (type == DDNASmartAdAdapterTypeInterstitial) {
                        adapter = [self instantiateAdapterForKlass:@"DDNASmartAdInMobiInterstitialAdapter"
                                                     configuration:configuration
                                                    waterfallIndex:i];
                    } else {
                        adapter = [self instantiateAdapterForKlass:@"DDNASmartAdInMobiRewardedAdapter"
                                                     configuration:configuration
                                                    waterfallIndex:i];
                    }
                }
                else if ([adProvider caseInsensitiveContains:@"MOBFOX"]) {
                    adapter = [self instantiateAdapterForKlass:@"DDNASmartAdMobFoxAdapter"
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider caseInsensitiveContains:@"CHARTBOOST"]) {
                    if (type == DDNASmartAdAdapterTypeInterstitial) {
                        adapter = [self instantiateAdapterForKlass:@"DDNASmartAdChartboostInterstitialAdapter"
                                                     configuration:configuration
                                                    waterfallIndex:i];
                    } else {
                        adapter = [self instantiateAdapterForKlass:@"DDNASmartAdChartboostRewardedAdapter"
                                                     configuration:configuration
                                                    waterfallIndex:i];
                    }
                }
                else if ([adProvider caseInsensitiveContains:@"ADCOLONY"]) {
                    adapter = [self instantiateAdapterForKlass:@"DDNASmartAdAdColonyAdapter"
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider caseInsensitiveContains:@"VUNGLE"]) {
                    adapter = [self instantiateAdapterForKlass:@"DDNASmartAdVungleAdapter"
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider caseInsensitiveContains:@"UNITY"]) {
                    adapter = [self instantiateAdapterForKlass:@"DDNASmartAdUnityAdsAdapter"
                                                 configuration:configuration
                                                waterfallIndex:i];
                }
                else if ([adProvider caseInsensitiveContains:@"APPLOVIN"]) {
                    if (type == DDNASmartAdAdapterTypeInterstitial) {
                        adapter = [self instantiateAdapterForKlass:@"DDNASmartAdAppLovinAdapter"
                                                     configuration:configuration
                                                    waterfallIndex:i];
                    }
                }
                else {
                    DDNALogWarn(@"Ad network %@ for %@ ads is not supported.",
                                adProvider,
                                type == DDNASmartAdAdapterTypeInterstitial ? @"interstitial" : @"rewarded");
                }
                
                if (adapter) {
                    [adapters addObject:adapter];
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
