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
#import <UIKit/UIKit.h>
#import "DDNASmartAdStatus.h"
#import "DDNASmartAdPrivacy.h"


@protocol DDNASmartAdAdapterDelegate;

@interface DDNASmartAdAdapter : NSObject

@property (nonatomic, weak) id<DDNASmartAdAdapterDelegate> delegate;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *version;
@property (nonatomic, assign, readonly) NSInteger eCPM;
@property (nonatomic, strong, readonly) DDNASmartAdPrivacy *privacy;

@property (nonatomic, assign) NSInteger waterfallIndex;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger requestCount;

/**
 Constructor called from @c initWithConfiguration:privacy:waterfallIndex:.  Don't start the ad network
 sdk in this constructor, that should be done on the first call to @c requestAd.
 */
- (instancetype)initWithName: (NSString *)name
                     version: (NSString *)version
                        eCPM: (NSInteger)eCPM
                     privacy: (DDNASmartAdPrivacy *)privacy
              waterfallIndex: (NSInteger)waterfallIndex;

/**
 Constructor called from the SmartAdFactory
 */
- (instancetype)initWithConfiguration: (NSDictionary *)configuration
                              privacy: (DDNASmartAdPrivacy *)privacy
                       waterfallIndex: (NSInteger)waterfallIndex; // abstract

- (void)requestAd;  // abstract
- (void)showAdFromViewController:(UIViewController *)viewController; // abstract

/**
 All adapters default to *not* being GDPR compliant, this means user consent for tracking
 must be given for the adapter to even start.  Adapters can override this as their
 ad network provides more subtle control with GDPR compliance.
 */
- (BOOL)isGdprCompliant;

@end

@protocol DDNASmartAdAdapterDelegate <NSObject>

@required

- (void)adapterDidLoadAd: (DDNASmartAdAdapter *)adapter;
- (void)adapterDidFailToLoadAd: (DDNASmartAdAdapter *)adapter withResult: (DDNASmartAdRequestResult *)result;
- (void)adapterIsShowingAd: (DDNASmartAdAdapter *)adapter;
- (void)adapterDidFailToShowAd: (DDNASmartAdAdapter *)adapter withResult: (DDNASmartAdShowResult *)result;
- (void)adapterWasClicked:(DDNASmartAdAdapter *)adapter;
- (void)adapterLeftApplication:(DDNASmartAdAdapter *)adapter;
- (void)adapterDidCloseAd: (DDNASmartAdAdapter *)adapter canReward: (BOOL)canReward;

- (NSInteger)sessionAdCount;
- (NSUInteger)adapterTimeoutSeconds;

@end
