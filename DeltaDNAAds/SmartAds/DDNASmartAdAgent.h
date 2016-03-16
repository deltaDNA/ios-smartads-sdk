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
#import <DeltaDNAAds/SmartAds/DDNASmartAdAdapter.h>


typedef NS_ENUM(NSInteger, DDNASmartAdAgentState) {
    DDNASmartAdAgentStateReady,
    DDNASmartAdAgentStateLoading,
    DDNASmartAdAgentStateLoaded,
    DDNASmartAdAgentStateShowing
};

@protocol DDNASmartAdAgentDelegate;
@class DDNASmartAdWaterfall;

@interface DDNASmartAdAgent : NSObject

@property (nonatomic, weak) id<DDNASmartAdAgentDelegate> delegate;
@property (nonatomic, copy) NSString *decisionPoint;

@property (nonatomic, assign, readonly) DDNASmartAdAgentState state;
@property (nonatomic, assign, readonly) BOOL adWasClicked;
@property (nonatomic, assign, readonly) BOOL adLeftApplication;
@property (nonatomic, strong, readonly) DDNASmartAdAdapter * currentAdapter;
@property (nonatomic, assign, readonly) NSInteger adsShown;
@property (nonatomic, strong, readonly) NSDate *lastAdShownTime;


- (instancetype)initWithWaterfall:(DDNASmartAdWaterfall *)waterfall;

- (void)requestAd;

- (BOOL)hasLoadedAd;

- (BOOL)isShowingAd;

- (void)showAdFromRootViewController:(UIViewController *)viewController decisionPoint: (NSString *)decisionPoint;

@end


@protocol DDNASmartAdAgentDelegate <NSObject>

@required

- (void)adAgent:(DDNASmartAdAgent *)adAgent didLoadAdWithAdapter:(DDNASmartAdAdapter *)adapter requestTime:(NSTimeInterval)requestTime;

- (void)adAgent:(DDNASmartAdAgent *)adAgent didFailToLoadAdWithAdapter:(DDNASmartAdAdapter *)adapter requestTime:(NSTimeInterval)requestTime requestResult:(DDNASmartAdRequestResult *)result;

- (void)adAgent:(DDNASmartAdAgent *)adAgent didOpenAdWithAdapter:(DDNASmartAdAdapter *)adapter;

- (void)adAgent:(DDNASmartAdAgent *)adAgent didFailToOpenAdWithAdapter:(DDNASmartAdAdapter *)adapter closedResult:(DDNASmartAdClosedResult *)result;

- (void)adAgent:(DDNASmartAdAgent *)adAgent didCloseAdWithAdapter:(DDNASmartAdAdapter *)adapter canReward:(BOOL)canReward;

- (dispatch_queue_t)getDispatchQueue;

@end
