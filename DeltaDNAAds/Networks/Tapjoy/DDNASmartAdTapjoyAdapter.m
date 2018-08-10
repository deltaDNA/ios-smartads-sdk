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

#import "DDNASmartAdTapjoyAdapter.h"
#import <Tapjoy/Tapjoy.h>

@interface DDNASmartAdTapjoyAdapter () <TJPlacementDelegate, TJPlacementVideoDelegate>

@property (nonatomic, copy) NSString *sdkKey;
@property (nonatomic, copy) NSString *placementName;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, strong) TJPlacement *placement;
@property (nonatomic, assign) BOOL reward;
@property (nonatomic, assign) BOOL connecting;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) BOOL requested;

@end

@implementation DDNASmartAdTapjoyAdapter

- (instancetype)initWithSdkKey:(NSString *)sdkKey placementName:(NSString *)placementName testMode:(BOOL)testMode eCPM:(NSInteger)eCPM privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"TAPJOY" version:[Tapjoy getVersion] eCPM:eCPM privacy:privacy waterfallIndex:waterfallIndex])) {
        
        self.sdkKey = sdkKey;
        self.placementName = placementName;
        self.testMode = testMode;
        self.reward = NO;
        self.connecting = NO;
        self.connected = NO;
        self.requested = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tjcConnectSuccess:)
                                                     name:TJC_CONNECT_SUCCESS
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tjcConnectFail:)
                                                     name:TJC_CONNECT_FAILED
                                                   object:nil];
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration privacy:(DDNASmartAdPrivacy *)privacy waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"sdkKey"] || !configuration[@"placementName"]) return nil;
    
    return [self initWithSdkKey:configuration[@"sdkKey"] placementName:configuration[@"placementName"] testMode:[configuration[@"testMode"] boolValue] eCPM:[configuration[@"eCPM"] integerValue] privacy:privacy waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (self.connected) {
        TJPlacement *p = [TJPlacement placementWithName:self.placementName delegate:self];
        p.videoDelegate = self;
        [p requestContent];
        self.placement = p;
        self.reward = NO;
    } else if (!self.connecting) {
        [Tapjoy setDebugEnabled:self.testMode];
        [Tapjoy enableLogging:self.testMode];
        [Tapjoy subjectToGDPR:YES];
        [Tapjoy setUserConsent:self.privacy.advertiserGdprUserConsent ? @"1" : @"0"];
        
        NSDictionary *options = @{
            @"TJC_MEDIATION_NETWORK_NAME" : @"deltaDNA"
        };
        
        if (![self.sdkKey isEqualToString:@"test-sdk-key"]) {
            [Tapjoy connect:self.sdkKey options:options];
        }
        
        self.connecting = YES;
    }
    
    self.requested = YES;
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([self.placement isContentReady]) {
        [self.placement showContentWithViewController:viewController];
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeExpired]];
    }
}

- (BOOL)isGdprCompliant
{
    return YES;
}

#pragma mark - TJPlacementDelegate

- (void)requestDidFail:(TJPlacement*)placement error:(NSError*)error
{
    if (placement == self.placement) {
        [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError errorDescription:error.localizedDescription]];
    }
}

- (void)contentIsReady:(TJPlacement*)placement
{
    if (placement == self.placement) {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)contentDidAppear:(TJPlacement*)placement
{
    if (placement == self.placement) {
        [self.delegate adapterIsShowingAd:self];
    }
}

- (void)contentDidDisappear:(TJPlacement*)placement
{
    if (placement == self.placement) {
        [self.delegate adapterDidCloseAd:self canReward:self.reward];
    }
}

#pragma mark - TJPlacementVideoDelegate

- (void)videoDidComplete:(TJPlacement*)placement
{
    self.reward = YES;
}

- (void)videoDidFail:(TJPlacement*)placement error:(NSString*)errorMsg
{
    self.reward = NO;
}

- (void)tjcConnectSuccess:(NSNotification*)notifyObj
{
    self.connected = YES;
    self.connecting = NO;
    
    if (self.requested) {
        [self requestAd];
        self.requested = NO;
    }
}

- (void)tjcConnectFail:(NSNotification*)notifyObj
{
    self.connected = NO;
    self.connecting = NO;
}


@end
