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

#import "DDNAFakeSmartAdFactory.h"
#import <DeltaDNA/DDNANetworkRequest.h>
#import <DeltaDNA/DDNAEngageService.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAdAgent.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAdService.h>


@implementation DDNAFakeSmartAdFactory

- (DDNASmartAdAgent *)buildSmartAdAgentWithWaterfall:(DDNASmartAdWaterfall *)waterfall adLimit:(NSNumber *)adLimit delegate:(id<DDNASmartAdAgentDelegate>)delegate
{
    if (self.fakeSmartAdAgent) {
        self.fakeSmartAdAgent.delegate = delegate;
        return self.fakeSmartAdAgent;
    } else {
        return [super buildSmartAdAgentWithWaterfall:waterfall adLimit:nil delegate:delegate];
    }
}

- (DDNASmartAdService *)buildSmartAdServiceWithDelegate:(id<DDNASmartAdServiceDelegate>)delegate
{
    if (self.fakeSmartAdService) {
        self.fakeSmartAdService.delegate = delegate;
        return self.fakeSmartAdService;
    } else {
        return [super buildSmartAdServiceWithDelegate:delegate];
    }
}

@end
