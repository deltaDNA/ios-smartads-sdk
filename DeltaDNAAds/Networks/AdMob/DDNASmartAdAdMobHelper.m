//
// Copyright (c) 2017 deltaDNA Ltd. All rights reserved.
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

#import "DDNASmartAdAdMobHelper.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <DeltaDNA/DDNALog.h>

@interface DDNASmartAdAdMobHelper ()

@property (atomic, copy) NSString *appId;
    
@end

@implementation DDNASmartAdAdMobHelper

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}
    
+ (void)configureWithAppId:(NSString *)appId
{
    appId = @"ca-app-pub-3940256099942544~1458002511";  // Test one
    NSLog(@"AppId = %@", appId);
    if ([DDNASmartAdAdMobHelper sharedInstance].appId == nil) {
        [GADMobileAds configureWithApplicationID:appId];
        [DDNASmartAdAdMobHelper sharedInstance].appId = appId;
    }
    else if (![appId isEqualToString:[DDNASmartAdAdMobHelper sharedInstance].appId]) {
        DDNALogWarn(@"AdMob already started with appId='%@'", [DDNASmartAdAdMobHelper sharedInstance].appId);
    }
}
    
+ (NSString *)sdkVersion
{
    return [GADRequest sdkVersion];
}
    
+ (DDNASmartAdRequestResult *)resultCodeFromError:(NSError *)error
{
    DDNASmartAdRequestResult *result;
    
    switch (error.code) {
        case kGADErrorInvalidRequest:
        
        /// The ad request is invalid. The localizedFailureReason error description will have more
        /// details. Typically this is because the ad did not have the ad unit ID or root view
        /// controller set.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
        break;
        
        case kGADErrorNoFill:
        /// The ad request was successful, but no ad was returned.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
        break;
        
        case kGADErrorNetworkError:
        /// There was an error loading data from the network.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
        break;
        
        case kGADErrorServerError:
        /// The ad server experienced a failure processing the request.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
        break;
        
        case kGADErrorOSVersionTooLow:
        /// The current device's OS is below the minimum required version.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration];
        break;
        
        case kGADErrorTimeout:
        /// The request was unable to be loaded before being timed out.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNetwork];
        break;
        
        case kGADErrorInterstitialAlreadyUsed:
        /// Will not send request because the interstitial object has already been used.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
        break;
        
        case kGADErrorMediationDataError:
        /// The mediation response was invalid.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
        break;
        
        case kGADErrorMediationAdapterError:
        /// Error finding or creating a mediation ad network adapter.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
        break;
        
        case kGADErrorMediationNoFill:
        /// The mediation request was successful, but no ad was returned from any ad networks.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
        break;
        
        case kGADErrorMediationInvalidAdSize:
        /// Attempting to pass an invalid ad size to an adapter.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeConfiguration];
        break;
        
        case kGADErrorInternalError:
        /// Internal error.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
        break;
        
        case kGADErrorInvalidArgument:
        /// Invalid argument error.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
        break;
        
        case kGADErrorReceivedInvalidResponse:
        /// Received invalid response.
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError];
        break;
        
        default:
        result = [DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill];
        break;
    }
    result.errorDescription = [error localizedDescription];
    return result;
}
    
@end
