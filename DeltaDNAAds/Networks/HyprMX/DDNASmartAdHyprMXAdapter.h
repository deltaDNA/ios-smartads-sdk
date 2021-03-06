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

#import <UIKit/UIKit.h>
#import "DeltaDNAAds/SmartAds/DDNASmartAdAdapter.h"

@interface DDNASmartAdHyprMXAdapter : DDNASmartAdAdapter

@property (nonatomic, copy, readonly) NSString *distributorId;
@property (nonatomic, copy, readonly) NSString *propertyId;
@property (nonatomic, assign, readonly) BOOL testMode;

- (instancetype)initWithDistributorId:(NSString *)distributorId
                           propertyId:(NSString *)propertyId
                             testMode:(BOOL)testMode
                                 eCPM:(NSInteger)eCPM
                              privacy: (DDNASmartAdPrivacy *)privacy
                       waterfallIndex:(NSInteger)waterfallIndex;

@end
