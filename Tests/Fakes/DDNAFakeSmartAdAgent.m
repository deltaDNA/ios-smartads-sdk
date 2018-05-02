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

#import "DDNAFakeSmartAdAgent.h"
#import <DeltaDNAAds/Networks/Dummy/DDNASmartAdDummyAdapter.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAdWaterfall.h>

@interface DDNASmartAdAgent (UnitTest)

@property (nonatomic, strong) NSNumber *adLimit;

- (void)adapterDidLoadAd: (DDNASmartAdAdapter *)adapter;
- (void)adapterIsShowingAd: (DDNASmartAdAdapter *)adapter;
- (void)adapterDidCloseAd: (DDNASmartAdAdapter *)adapter canReward:(BOOL)canReward;

@end

@interface DDNAFakeSmartAdAgent ()

@property (nonatomic, strong) DDNASmartAdDummyAdapter *dummyAdapter;

@end

@implementation DDNAFakeSmartAdAgent

- (instancetype)init
{
    self.dummyAdapter = [[DDNASmartAdDummyAdapter alloc] initWithName:@"DUMMY" version:@"1.0.0" eCPM:100 privacy:nil  waterfallIndex:1];
    
    DDNASmartAdWaterfall *waterfall = [[DDNASmartAdWaterfall alloc] initWithAdapters:@[self.dummyAdapter] demoteOnOptions:0 maxRequests:0];
    if ((self = [super initWithWaterfall:waterfall])) {
        
    }
    return self;
}

- (instancetype)initWithAdLimit:(NSNumber *)adLimit
{
    DDNAFakeSmartAdAgent *agent = [self init];
    agent.adLimit = adLimit;
    return agent;
}

- (void)closeAd
{
    [self adapterDidCloseAd:self.dummyAdapter canReward:YES];
}

- (void)closeAdWithReward:(BOOL)reward
{
    [self adapterDidCloseAd:self.dummyAdapter canReward:reward];
}

@end
