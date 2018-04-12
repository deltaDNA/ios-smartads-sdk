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

#import "DDNASmartAdFakeAdapter.h"

@interface DDNASmartAdFakeAdapter ()

@property (nonatomic, assign, readwrite) BOOL showing;
@property (nonatomic, assign, readwrite) BOOL failToShow;
@property (nonatomic, strong) NSMutableArray *resultCodes;

@end

@implementation DDNASmartAdFakeAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration
{
    return [self init];
}

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name resultCode:DDNASmartAdRequestResultCodeLoaded failToShow:NO];
}

- (instancetype)initWithName:(NSString *)name failToShow:(BOOL)failToShow
{
    return [self initWithName:name resultCode:DDNASmartAdRequestResultCodeLoaded failToShow:failToShow];
}

- (instancetype)initWithName:(NSString *)name resultCode:(DDNASmartAdRequestResultCode)resultCode
{
    return [self initWithName:name resultCode:resultCode failToShow:NO];
}

- (instancetype)initWithName:(NSString *)name resultCode:(DDNASmartAdRequestResultCode)resultCode failToShow:(BOOL)failToShow
{
    return [self initWithName:name
                  resultCodes:[NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:resultCode]]
                   failToShow:failToShow];
}

- (instancetype)initWithName:(NSString *)name resultCodes:(NSArray *)resultCodes
{
    return [self initWithName:name resultCodes:resultCodes failToShow:NO];
}

- (instancetype)initWithName:(NSString *)name resultCodes:(NSArray *)resultCodes failToShow:(BOOL)failToShow
{
    if ((self = [super initWithName:name version:@"1.0.0" eCPM:150 waterfallIndex:1])) {
        self.showing = NO;
        self.failToShow = failToShow;
        self.resultCodes = [NSMutableArray arrayWithArray:resultCodes];
    }
    return self;
}

- (void)clickAdAndLeaveApplication:(BOOL)didLeave
{
    [self.delegate adapterWasClicked:self];
    
    if (didLeave) {
        [self.delegate adapterLeftApplication:self];
    }
}

- (void)closeAd
{
    self.showing = false;
    [self.delegate adapterDidCloseAd:self canReward:YES];
}

#pragma mark - DDNASmartAdAdapter

- (void)requestAd
{
    NSLog(@"Fake adapter %@ requesting ad", self.name);
    
    DDNASmartAdRequestResultCode resultCode = DDNASmartAdRequestResultCodeLoaded;
    if (_resultCodes.count > 0) {
        resultCode = [[_resultCodes objectAtIndex:0] unsignedIntegerValue];
        [_resultCodes removeObjectAtIndex:0];
    }
    
    if (resultCode != DDNASmartAdRequestResultCodeLoaded) {
        [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdRequestResult resultWith:resultCode]];
    } else {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.failToShow) {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdShowResult resultWith:DDNASmartAdShowResultCodeError]];
    } else {
        self.showing = YES;
        [self.delegate adapterIsShowingAd:self];
    }
}

@end
