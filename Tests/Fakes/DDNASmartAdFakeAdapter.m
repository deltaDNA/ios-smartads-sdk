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

@property (nonatomic, assign, readwrite) BOOL failRequest;
@property (nonatomic, assign, readwrite) BOOL showing;
@property (nonatomic, assign, readwrite) BOOL failOpen;

@end

@implementation DDNASmartAdFakeAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration
{
    return [self init];
}

- (instancetype)initWithName:(NSString *)name failRequest:(BOOL)failRequest
{
    return [self initWithName:name failRequest:failRequest failOpen:NO];
}

- (instancetype)initWithName:(NSString *)name failRequest:(BOOL)failRequest failOpen:(BOOL)failOpen
{
    if ((self = [super initWithName:name version:@"1.0.0" eCPM:150 waterfallIndex:1])) {
        self.failRequest = failRequest;
        self.showing = NO;
        self.failOpen = failOpen;
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
    NSLog(@"Fake adapter requesting ad");
    
    if (self.failRequest) {
        [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError]];
    } else {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.failOpen) {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
    } else {
        self.showing = YES;
        [self.delegate adapterIsShowingAd:self];
    }
}

@end
