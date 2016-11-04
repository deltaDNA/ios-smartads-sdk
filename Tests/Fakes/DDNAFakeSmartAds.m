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

#import "DDNAFakeSmartAds.h"
#import <objc/runtime.h>

@implementation DDNAFakeSmartAds

+(void)load
{
    // replace singleton with our mock
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(sharedInstance);
        SEL swizzledSelector = @selector(mockSharedInstance);
        
        Method originalMethod = class_getClassMethod(class, originalSelector);
        Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

+(instancetype)mockSharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&pred, ^{
        sharedObject = [[DDNAFakeSmartAds alloc] init];
    });
    return sharedObject;
}

- (BOOL)isInterstitialAdAllowed:(DDNAEngagement *)engagement
{
    return self.allowInterstitial;
}

- (BOOL)isRewardedAdAllowed:(DDNAEngagement *)engagement
{
    return self.allowRewarded;
}

@end
