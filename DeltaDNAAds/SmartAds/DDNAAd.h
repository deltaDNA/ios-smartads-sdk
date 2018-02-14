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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DDNAEngagement;

NS_ASSUME_NONNULL_BEGIN

/**
 @c DDNAAd contains common properties for @c InterstitialAd and @c RewardedAd classes.
 */
@interface DDNAAd : NSObject

/**
 The decisionPoint associated with this ad.
 */
@property (nonatomic, copy, readonly, nullable) NSString *decisionPoint;

/**
 The engagement used to create this engagement.
 */
@property (nonatomic, strong, readonly, nullable) DDNAEngagement *engagement;

/**
 The parameters returned by a matching engage request.
 */
@property (nonatomic, strong, readonly) NSDictionary *parameters;

/**
 The last time an ad was shown at this decision point.
 */
@property (nonatomic, strong, readonly) NSDate *lastShown;

/**
 The number of secs to wait between showing ads at this decision point.
 */
@property (nonatomic, assign, readonly) NSInteger showWaitSecs;

/**
 The number of ads this session shown at this decision point.
 */
@property (nonatomic, assign, readonly) NSInteger sessionCount;

/**
 The maximum number of ads in a session allowed to show at this decision point.
 */
@property (nonatomic, assign, readonly) NSInteger sessionLimit;

/**
 The number of ads shown today at this decision point.
 */
@property (nonatomic, assign, readonly) NSInteger dailyCount;

/**
 The maximum number of ads in a day allowed to show at this decision point.
 */
@property (nonatomic, assign, readonly) NSInteger dailyLimit;

- (instancetype)initWithEngagement:(nullable DDNAEngagement *)engagement;
- (BOOL)isReady;  // abstract
- (void)showFromRootViewController:(UIViewController *)viewController; // abstract

- (instancetype)init __attribute__((unavailable("Use initWithEngagement: instead.")));

@end

NS_ASSUME_NONNULL_END
