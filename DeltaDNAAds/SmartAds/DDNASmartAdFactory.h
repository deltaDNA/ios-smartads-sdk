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

#import <Foundation/Foundation.h>

@class DDNASmartAdService;
@protocol DDNASmartAdServiceDelegate;

@class DDNASmartAdAgent;
@protocol DDNASmartAdAgentDelegate;

@protocol DDNASmartAdAdapter;

@class DDNASmartAdWaterfall;
@class DDNASmartAdPrivacy;

/**
 *  Factory creates components for smart ad library.
 */
@interface DDNASmartAdFactory : NSObject

+ (instancetype)sharedInstance;

- (DDNASmartAdService *)buildSmartAdServiceWithDelegate:(id<DDNASmartAdServiceDelegate>)delegate;

- (DDNASmartAdAgent *)buildSmartAdAgentWithWaterfall:(DDNASmartAdWaterfall *)waterfall
                                             adLimit:(NSNumber *)adLimit
                                            delegate:(id<DDNASmartAdAgentDelegate>)delegate;

- (NSArray *)buildInterstitialAdapterWaterfallWithAdProviders:(NSArray *)adProviders
                                                   floorPrice:(NSInteger)floorPrice
                                                      privacy:(DDNASmartAdPrivacy *)privacy;

- (NSArray *)buildRewardedAdapterWaterfallWithAdProviders:(NSArray *)adProviders
                                               floorPrice:(NSInteger)floorPrice
                                                  privacy:(DDNASmartAdPrivacy *)privacy;

@end
