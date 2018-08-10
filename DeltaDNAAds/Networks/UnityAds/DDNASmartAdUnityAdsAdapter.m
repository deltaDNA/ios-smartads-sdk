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
#import <UnityAds/UnityAdsExtended.h>
#import <DeltaDNA/DDNALog.h>

typedef NS_ENUM(NSInteger, UnityAdsState) {
    kUnityAdsStateInitialising = 0,
    kUnityAdsStateWaiting,
    kUnityAdsStateRequesting,
    kUnityAdsStateReady,
    kUnityAdsStateShowing,
    kUnityAdsStateError
};


@interface DDNASmartAdUnityAdsAdapter () <UnityAdsExtendedDelegate>

@property (nonatomic, copy) NSString *gameId;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, assign) UnityAdsState state;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, assign) UnityAdsPlacementState placementState;

@end

@implementation DDNASmartAdUnityAdsAdapter

- (instancetype)initWithGameId:(NSString *)gameId placementId:(NSString *)placementId testMode:(BOOL)testMode eCPM:(NSInteger)eCPM privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"UNITY" version:[UnityAds getVersion] eCPM:eCPM privacy:privacy waterfallIndex:waterfallIndex])) {
        self.gameId = gameId;
        self.placementId = placementId;
        self.testMode = testMode;
        self.state = kUnityAdsStateInitialising;
        self.placementState = kUnityAdsPlacementStateNotAvailable;
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"gameId"] || !configuration[@"placementId"]) return nil;
    
    return [self initWithGameId:configuration[@"gameId"] placementId:configuration[@"placementId"] testMode:[configuration[@"testMode"] boolValue] eCPM:[configuration[@"eCPM"] integerValue] privacy:privacy waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    [gdprConsentMetaData set:@"gdpr.consent" value:[NSNumber numberWithBool:self.privacy.advertiserGdprUserConsent]];
    [gdprConsentMetaData commit];
    
    id mediationMetaData = [[UADSMediationMetaData alloc] init];
    [mediationMetaData setName:@"deltaDNA"];
    [mediationMetaData setVersion:[DDNASmartAds sdkVersion]];
    [mediationMetaData commit];
    
    if (![UnityAds isInitialized] && self.state != kUnityAdsStateError) {
        [UnityAds initialize:self.gameId delegate:self testMode:self.testMode];
    }
    
    if ([UnityAds isInitialized] && self.state == kUnityAdsStateInitialising) {
        self.state = kUnityAdsStateWaiting;
    }
    
    if (self.state == kUnityAdsStateWaiting && [UnityAds isReady:self.placementId]) {
        self.state = kUnityAdsStateReady;
        [self.delegate adapterDidLoadAd:self];
    } else if (self.placementState == kUnityAdsPlacementStateNoFill) {
        DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill errorDescription:[NSString stringWithFormat:@"No fill for placement %@", self.placementId]];
        [self.delegate adapterDidFailToLoadAd:self withResult:result];
    } else if (self.state == kUnityAdsStateError) {
        DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError errorDescription:self.errorMessage];
        [self.delegate adapterDidFailToLoadAd:self withResult:result];
    } else {
        self.state = kUnityAdsStateRequesting;
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.state == kUnityAdsStateReady && [UnityAds isReady:self.placementId]) {
        id mediationMetaData = [[UADSMediationMetaData alloc] init];
        [mediationMetaData setOrdinal:(int)(self.delegate.sessionAdCount+1)];
        [mediationMetaData commit];
        self.state = kUnityAdsStateShowing;
        [UnityAds show:viewController placementId:self.placementId];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeExpired]];
    }
}

- (BOOL)isGdprCompliant
{
    return YES;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.state == kUnityAdsStateRequesting && [self.placementId isEqualToString:placementId]) {
            self.state = kUnityAdsStateReady;
            [self.delegate adapterDidLoadAd:self];
        }
    });
}

/**
 *  Called when `UnityAds` encounters an error. All errors will be logged but this method can be used as an additional debugging aid. This callback can also be used for collecting statistics from different error scenarios.
 *
 *  @param error   A `UnityAdsError` error enum value indicating the type of error encountered.
 *  @param message A human readable string indicating the type of error encountered.
 */
- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message
{
    // All the errors are bad so let's give up.
    self.errorMessage = message;
    self.state = kUnityAdsStateError;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString * errorMessage = [NSString stringWithFormat:@"UnityAdsError %@ - %@", [DDNASmartAdUnityAdsAdapter stringFromUnityAdsError:error], message];
        
        switch (self.state) {
            case kUnityAdsStateRequesting: {
                DDNASmartAdRequestResult *result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError errorDescription:errorMessage];
                [self.delegate adapterDidFailToLoadAd:self withResult:result];
                break;
            }
            case kUnityAdsStateShowing: {
                [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeError]];
                break;
            }
            default:
                DDNALogWarn(@"UnityAds initialising error: %@", errorMessage);
        }
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.placementId isEqualToString:placementId]) {
            [self.delegate adapterIsShowingAd:self];
        }
    });
}

/**
 *  Called when a click event happens.
 *
 *  @param placementId The ID of the placement that was clicked.
 */
- (void)unityAdsDidClick:(NSString *)placementId {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.state == kUnityAdsStateShowing && [self.placementId isEqualToString:placementId]) {
            [self.delegate adapterWasClicked:self];
        }
    });
}

/**
 *  Called when a placement changes state.
 *
 *  @param placementId The ID of the placement that changed state.
 *  @param oldState The state before the change.
 *  @param newState The state after the change.
 */
- (void)unityAdsPlacementStateChanged:(NSString *)placementId oldState:(UnityAdsPlacementState)oldState newState:(UnityAdsPlacementState)newState
{
    DDNALogDebug(@"UnityAds placement state changed: %@ %ld -> %ld", placementId, (long)oldState, (long)newState);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.placementId isEqualToString:placementId]) {
            self.placementState = newState;

            if (self.state == kUnityAdsStateRequesting && newState == kUnityAdsPlacementStateNoFill) {
                self.state = kUnityAdsStateWaiting;
                [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill]];
            }
        }
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.state == kUnityAdsStateShowing && [self.placementId isEqualToString:placementId]) {
            self.state = kUnityAdsStateWaiting;
            
            switch (state) {
                /**
                 *  A state that indicates that the ad did not successfully display.
                 */
                case kUnityAdsFinishStateError : {
                    [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeError]];
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
                    [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeError]];
                    break;
                }
            }
        }
        else {
            DDNALogWarn(@"unityAdsDidFinish called with inconsistent state: %ld %@", (long)self.state, placementId);
        }
    });
}

#pragma mark - private methods

+ (NSString *)stringFromUnityAdsError:(UnityAdsError)error
{
    switch (error) {
        case kUnityAdsErrorNotInitialized : return @"NotInitialized";
        case kUnityAdsErrorInitializedFailed: return @"InitializedFailed";
        case kUnityAdsErrorInvalidArgument: return @"InvalidArgument";
        case kUnityAdsErrorVideoPlayerError: return @"VideoPlayerError";
        case kUnityAdsErrorInitSanityCheckFail: return @"InitSanityCheckFail";
        case kUnityAdsErrorAdBlockerDetected: return @"AdBlockerDetected";
        case kUnityAdsErrorFileIoError: return @"FileIoError";
        case kUnityAdsErrorDeviceIdError: return @"DeviceIdError";
        case kUnityAdsErrorShowError: return @"ShowError";
        case kUnityAdsErrorInternalError: return @"InternalError";
        default: return @"UnknownError";
    }
}

@end
