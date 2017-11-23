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

#import "DDNADebugListener.h"
#import "DDNASmartAdService.h"
#import <DeltaDNA/DDNALog.h>
#import <UserNotifications/UserNotifications.h>

@interface AdInfo : NSObject

@property (nonatomic, copy) NSString *network;
@property (nonatomic, copy) NSString *message;

@end

@implementation AdInfo

- (instancetype)init
{
    if ((self = [super init])) {
        self.network = @"";
        self.message = @"";
    }
    return self;
}

@end

@interface DDNADebugListener ()

@property (nonatomic, assign) BOOL userNotifications;
@property (nonatomic, strong) NSMutableDictionary *content;

@end

@implementation DDNADebugListener

- (instancetype)init
{
    if ((self = [super init])) {
        
        self.userNotifications = YES;
        self.content = [NSMutableDictionary dictionaryWithDictionary:@{
            AD_TYPE_INTERSTITIAL: [[AdInfo alloc] init],
            AD_TYPE_REWARDED: [[AdInfo alloc] init]
        }];
        
        // register notification handlers
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserverForName:@"DDNASDKNewSession" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            self.content[AD_TYPE_INTERSTITIAL] = [[AdInfo alloc] init];
            self.content[AD_TYPE_REWARDED] = [[AdInfo alloc] init];
            [self postNotificationWithMessage:@"New SmartAds session started."];
        }];
        [center addObserverForName:kDDNAAdsDisabledEngage object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            AdInfo *interstitialAdInfo = self.content[AD_TYPE_INTERSTITIAL];
            AdInfo *rewardedAdInfo = self.content[AD_TYPE_REWARDED];
            NSString *message = @"Ads disabled by Engage.";
            interstitialAdInfo.message = message;
            interstitialAdInfo.network = @"";
            rewardedAdInfo.message = message;
            rewardedAdInfo.network = @"";
            [self postNotificationWithMessage:message];
        }];
        [center addObserverForName:kDDNAAdsDisabledNoNetworks object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSString *adType = note.userInfo[kDDNAAdType];
            AdInfo *adInfo = self.content[adType];
            adInfo.message = [NSString stringWithFormat:@"No %@ ad networks configured.", [adType lowercaseString]];
            [self postNotificationWithMessage:adInfo.message];
        }];
        [center addObserverForName:kDDNALoadedAd object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            
            NSString *adType = note.userInfo[kDDNAAdType];
            NSString *adNetwork = note.userInfo[kDDNAAdNetwork];
            NSString *message = @"";
            AdInfo *adInfo = self.content[adType];
        
            if ([adInfo.network isEqualToString:@""]) {
                message = [NSString stringWithFormat:@"Loaded %@ ad from %@.", [adType lowercaseString], adNetwork];
            } else {
                message = [NSString stringWithFormat:@"Shown %@ ad from %@ and loaded ad from %@.", [adType lowercaseString], adInfo.network, adNetwork];
            }

            adInfo.network = note.userInfo[kDDNAAdNetwork];
            adInfo.message = message;
            
            [self postNotificationWithMessage:message];
        }];
        [center addObserverForName:kDDNAShowingAd object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            
            NSString *adType = note.userInfo[kDDNAAdType];
            AdInfo *adInfo = self.content[adType];
            adInfo.message = [NSString stringWithFormat:@"Showing %@ ad from %@.", [adType lowercaseString], adInfo.network];
            
            [self postNotificationWithMessage:adInfo.message];
        }];
        [center addObserverForName:kDDNAClosedAd object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            
            NSString *adType = note.userInfo[kDDNAAdType];
            BOOL skipped = ![note.userInfo[kDDNAFullyWatched] boolValue];
            AdInfo *adInfo = self.content[adType];
            adInfo.message = [NSString stringWithFormat:@"Closed %@ ad%@ from %@.", [adType lowercaseString], skipped ? @" (skipped)": @"", adInfo.network];
            
            [self postNotificationWithMessage:adInfo.message];
        }];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)disableNotifications
{
    self.userNotifications = NO;
}

- (void)postNotificationWithMessage:(NSString *)message
{
    DDNALogDebug(message);
    
    if (self.userNotifications) {
        AdInfo *interstialInfo = self.content[AD_TYPE_INTERSTITIAL];
        AdInfo *rewardedInfo = self.content[AD_TYPE_REWARDED];
        
        UNNotificationRequest *userNotification = [self createUserNotificationWithBody:message
                                                                          interstitial:interstialInfo.message
                                                                              rewarded:rewardedInfo.message];
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:userNotification withCompletionHandler:nil];
    }
}

- (UNNotificationRequest *)createUserNotificationWithBody:(NSString *)body interstitial:(NSString *)interstitial rewarded:(NSString *)rewarded
{
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.categoryIdentifier = @"com.deltadna.diagnosticCategory";
    content.title = [NSString localizedUserNotificationStringForKey:@"deltaDNA SmartAds" arguments:nil];
    content.body = body;
    content.userInfo = @{
        @"interstitial": interstitial,
        @"rewarded": rewarded
    };
    
    // When to launch the notification
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:1 repeats:NO];
    
    // Create the request object to launch the notification.
    UNNotificationRequest* request = [UNNotificationRequest
                                      requestWithIdentifier:@"deltaDNA-SDK" content:content trigger:trigger];
    return request;
}

@end
