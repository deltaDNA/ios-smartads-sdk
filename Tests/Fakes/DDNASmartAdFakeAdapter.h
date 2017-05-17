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
#import <DeltaDNAAds/SmartAds/DDNASmartAdAdapter.h>

@interface DDNASmartAdFakeAdapter : DDNASmartAdAdapter

@property (nonatomic, assign, readonly,getter=isShowing) BOOL showing;
@property (nonatomic, assign, readonly) BOOL failToShow;

- (instancetype)initWithName: (NSString *)name;

- (instancetype)initWithName:(NSString *)name resultCode:(DDNASmartAdRequestResultCode)resultCode;

- (instancetype)initWithName:(NSString *)name resultCodes:(NSArray *)resultCodes;

- (instancetype)initWithName:(NSString *)name failToShow:(BOOL)failToShow;

- (void)clickAdAndLeaveApplication: (BOOL)didLeave;

- (void)closeAd;

@end
