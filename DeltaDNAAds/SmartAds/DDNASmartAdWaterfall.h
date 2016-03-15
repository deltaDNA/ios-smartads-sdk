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

#import <Foundation/Foundation.h>
#import "DDNASmartAdStatus.h"

@class DDNASmartAdAdapter;

@interface DDNASmartAdWaterfall : NSObject

- (instancetype)initWithAdapters:(NSArray *)adapters
                 demoteOnOptions:(DDNASmartAdRequestResultCode)options
                     maxRequests:(NSInteger)maxRequests;

- (DDNASmartAdAdapter *)resetWaterfall;

- (DDNASmartAdAdapter *)getNextAdapter;

- (void)scoreAdapter:(DDNASmartAdAdapter *)adapter
     withRequestCode:(DDNASmartAdRequestResultCode)requestCode;

- (void)removeAdapter:(DDNASmartAdAdapter *)adapter;

- (NSArray *)getAdapters;

@end
