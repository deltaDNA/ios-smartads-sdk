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

#import "DDNASmartAdUnityAdsAdapter.h"
#import "DDNASmartAds.h"
#import <UnityAds/UnityAds.h>

@interface DDNASmartAdUnityAdsAdapter () <UnityAdsDelegate>

@property (nonatomic, copy) NSString *gameId;

// zoneId was renamed placementId in v2.0
@property (nonatomic, copy) NSString *zoneId;
@property (nonatomic, assign) BOOL testMode;

@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) BOOL showing;

@end

@implementation DDNASmartAdUnityAdsAdapter

- (instancetype)initWithGameId:(NSString *)gameId zoneId:(NSString *)zoneId testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"UNITY" version:[UnityAds getVersion] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        self.gameId = gameId;
        self.zoneId = !zoneId || [zoneId isEqualToString:@""] ? @"defaultZone" : zoneId;
        self.testMode = testMode;
        self.showing = NO;
        
        id mediationMetaData = [[UADSMediationMetaData alloc] init];
        [mediationMetaData setName:@"deltaDNA"];
        [mediationMetaData setVersion:[DDNASmartAds sdkVersion]];
        [mediationMetaData commit];
        
        [UnityAds initialize:self.gameId delegate:self testMode:self.testMode];
        self.started = YES;
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"gameId"]) return nil;
    
    return [self initWithGameId:configuration[@"gameId"] zoneId:configuration[@"zoneId"] testMode:[configuration[@"testMode"] boolValue] eCPM:[configuration[@"eCPM"] integerValue] waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (!self.started) {
        return;
    }
    
    if ([UnityAds isSupported] && [self isReady]) {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([UnityAds isSupported] && [self isReady]) {
        self.showing = YES;
        id mediationMetaData = [[UADSMediationMetaData alloc] init];
        [mediationMetaData setOrdinal:self.delegate.sessionAdCount+1];
        [mediationMetaData commit];
        [UnityAds show:viewController placementId:self.zoneId];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

- (BOOL)isReady
{
    return self.zoneId ? [UnityAds isReady:self.zoneId] : [UnityAds isReady];
}

#pragma mark - UnityAdsDelegate

/**
 *  Called when `UnityAds` is ready to show an ad. After this callback you can call the `UnityAds` `show:` method for this placement.
 *  Note that sometimes placement might no longer be ready due to exceptional reasons. These situations will give no new callbacks.
 *
 *  @warning To avoid error situations, it is always best to check `isReady` method status before calling show.
 *  @param placementId The ID of the placement that is ready to show, as defined in Unity Ads admin tools.
 */
- (void)unityAdsReady:(NSString *)placementId
{
    if (!self.zoneId || [self.zoneId isEqualToString:placementId]) {
        [self.delegate adapterDidLoadAd:self];
    }
}

/**
 *  Called when `UnityAds` encounters an error. All errors will be logged but this method can be used as an additional debugging aid. This callback can also be used for collecting statistics from different error scenarios.
 *
 *  @param error   A `UnityAdsError` error enum value indicating the type of error encountered.
 *  @param message A human readable string indicating the type of error encountered.
 */
- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message
{
    if (self.showing) {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
        self.showing = NO;
    } else if (self.started) {
        DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError error:message];
        [self.delegate adapterDidFailToLoadAd:self withResult:result];
    } else {
        //NSLog(@"UnityAds initialise error: %@ %@", error, message);
    }
}

/**
 *  Called on a successful start of advertisement after calling the `UnityAds` `show:` method.
 *
 * @warning If there are errors in starting the advertisement, this method may never be called. Unity Ads will directly call `unityAdsDidFinish:withFinishState:` with error status.
 *
 *  @param placementId The ID of the placement that has started, as defined in Unity Ads admin tools.
 */
- (void)unityAdsDidStart:(NSString *)placementId
{
    if (!self.zoneId || [self.zoneId isEqualToString:placementId]) {
        [self.delegate adapterIsShowingAd:self];
    }
}

/**
 *  Called after the ad has closed.
 *
 *  @param placementId The ID of the placement that has finished, as defined in Unity Ads admin tools.
 *  @param state       An enum value indicating the finish state of the ad. Possible values are `Completed`, `Skipped`, and `Error`.
 */
- (void)unityAdsDidFinish:(NSString *)placementId
          withFinishState:(UnityAdsFinishState)state
{
    if (!self.zoneId || [self.zoneId isEqualToString:placementId]) {
        self.showing = NO;
        
        switch (state) {
            /**
             *  A state that indicates that the ad did not successfully display.
             */
            case kUnityAdsFinishStateError : {
                [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
                break;
            }
            /**
             *  A state that indicates that the user skipped the ad.
             */
            case kUnityAdsFinishStateSkipped : {
                [self.delegate adapterDidCloseAd:self canReward:NO];
                break;
            }
            /**
             *  A state that indicates that the ad was played entirely.
             */
            case kUnityAdsFinishStateCompleted : {
                [self.delegate adapterDidCloseAd:self canReward:YES];
                break;
            }
            default : {
                [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
                break;
            }
        }
    }
}

@end
