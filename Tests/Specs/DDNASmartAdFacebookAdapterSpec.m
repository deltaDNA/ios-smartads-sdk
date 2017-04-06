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

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <DeltaDNAAds/Networks/Facebook/DDNASmartAdFacebookAdapter.h>


SpecBegin(DDNASmartAdFacebookAdapter)

describe(@"Facebook adapter", ^{
    
    it(@"builds from valid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FACEBOOK",
            @"placementId": @"test-placement-id",
            @"eCPM": @150
        };
        
        DDNASmartAdFacebookAdapter *adapter = [[DDNASmartAdFacebookAdapter alloc] initWithConfiguration:configuration
                                                                                         waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.placementId).to.equal(@"test-placement-id");
        expect(adapter.eCPM).to.equal(150);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });
    
    it(@"returns nil from invalid configuration", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FACEBOOK"
        };
        
        DDNASmartAdFacebookAdapter *adapter = [[DDNASmartAdFacebookAdapter alloc] initWithConfiguration:configuration
                                                                                         waterfallIndex:1];
        
        expect(adapter).to.beNil();
    });
    
    it(@"supports test mode", ^{
        
        NSDictionary *configuration = @{
            @"adProvider": @"FACEBOOK",
            @"placementId": @"test-placement-id",
            @"testMode": @YES
        };
        
        DDNASmartAdFacebookAdapter *adapter = [[DDNASmartAdFacebookAdapter alloc] initWithConfiguration:configuration
                                                                                         waterfallIndex:1];
        
        expect(adapter).toNot.beNil();
        expect(adapter.placementId).to.equal(@"test-placement-id");
        expect(adapter.testMode).to.beTruthy();
        expect(adapter.eCPM).to.equal(0);
        expect(adapter.waterfallIndex).to.equal(1);
        
    });

    
});

SpecEnd
