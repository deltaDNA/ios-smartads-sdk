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

#import "DDNAFakeSmartAdService.h"
#import "DDNAFakeSmartAdAgent.h"
#import "DDNAFakeSmartAdFactory.h"

@interface DDNAFakeSmartAdService ()

@property (nonatomic, strong) DDNASmartAdAgent *interstitialAgent;
@property (nonatomic, strong) DDNASmartAdAgent *rewardedAgent;

@end

@implementation DDNAFakeSmartAdService

- (instancetype)init
{
    if ((self = [super init])) {
        
    }
    return self;
}

- (void)beginSessionWithDecisionPoint:(NSString *)decisionPoint
{
    self.interstitialAgent = [self.factory buildSmartAdAgentWithWaterfall:nil adLimit:nil delegate:nil];
    self.rewardedAgent = [self.factory buildSmartAdAgentWithWaterfall:nil adLimit:nil delegate:nil];
    
    [self.delegate didRegisterForInterstitialAds];
    [self.delegate didRegisterForRewardedAds];
}


@end
