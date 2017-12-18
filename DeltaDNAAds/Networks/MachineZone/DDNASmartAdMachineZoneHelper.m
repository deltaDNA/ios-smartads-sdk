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

#import "DDNASmartAdMachineZoneHelper.h"
#import <FMAdZone/FMAdZone.h>
#import <DeltaDNA/DDNALog.h>

@interface DDNASmartAdMachineZoneHelper() <FMAdZoneDelegate>
    
@property (nonatomic, assign) BOOL adZoneStarted;

@end

@implementation DDNASmartAdMachineZoneHelper

- (instancetype)init
{
    if ((self = [super init])) {
        self.adZoneStarted = NO;
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
    
- (void)startAdZone
{
    [[FMAdZone sharedAdZone] startWithOptions:nil delegate:self];
}
    
+ (NSString *)sdkVersion
{
    return [FMAdZone version];
}
    
#pragma mark - FMAdZoneDelegate
    
- (void)adZoneStartSuccess:(FMAdZone *)adZone
{
    self.adZoneStarted = YES;
    if (self.requestInterstitial) {
        self.requestInterstitial();
        self.requestInterstitial = nil;
    }
    if (self.requestRewarded) {
        self.requestRewarded();
        self.requestRewarded = nil;
    }
}
    
- (void)adZoneStartFailed:(FMAdZone *)adZone
{
    self.adZoneStarted = NO;
}
    
@end

