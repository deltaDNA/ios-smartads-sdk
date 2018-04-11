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

#import "DDNASmartAdHyprMXAdapter.h"
#import <HyprMX/HyprMX.h>

static NSString * const kUserDefaultsUserIDKey = @"hyprmxUserId";

@interface DDNASmartAdHyprMXAdapter ()

@property (nonatomic, copy) NSString *distributorId;
@property (nonatomic, copy) NSString *propertyId;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, assign) BOOL reward;
@property (nonatomic, assign) BOOL isOfferReady;

@end

@implementation DDNASmartAdHyprMXAdapter

- (instancetype)initWithDistributorId:(NSString *)distributorId propertyId:(NSString *)propertyId testMode:(BOOL)testMode eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"HYPRMX" version:[[HYPRManager sharedManager] versionString] eCPM:eCPM waterfallIndex:waterfallIndex])) {
        
        self.distributorId = distributorId;
        self.propertyId = propertyId;
        self.testMode = testMode;
        self.reward = NO;
        self.isOfferReady = NO;
        
        // generate and persist a unique userid for device
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsUserIDKey];
        
        if (!userId) {
            userId = [[NSProcessInfo processInfo] globallyUniqueString];
            [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kUserDefaultsUserIDKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [[HYPRManager sharedManager] setLogLevel:HYPRLogLevelDebug];
        [[HYPRManager sharedManager] initializeWithDistributorId:self.distributorId propertyId:self.propertyId userId:userId];
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"distributorId"] || !configuration[@"propertyId"]) return nil;
    
    return [self initWithDistributorId:configuration[@"distributorId"] propertyId:configuration[@"propertyId"] testMode:[configuration[@"testMode"] boolValue] eCPM:[configuration[@"eCPM"] integerValue] waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    [[HYPRManager sharedManager] checkInventory:^(BOOL isOfferReady) {
        if (isOfferReady) {
            [self.delegate adapterDidLoadAd:self];
        } else {
            [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeNoFill]];
        }
        self.isOfferReady = isOfferReady;
    }];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.isOfferReady) {
        [self.delegate adapterIsShowingAd:self];
        [[HYPRManager sharedManager] displayOffer:^(BOOL completed, HYPROffer *offer) {
            [self.delegate adapterDidCloseAd:self canReward:completed];
        }];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeExpired]];
    }
}

@end
