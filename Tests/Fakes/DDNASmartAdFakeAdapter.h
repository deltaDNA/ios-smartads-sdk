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

//@property (nonatomic, weak) id<DDNASmartAdAdapterDelegate> delegate;

//@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL failRequest;
@property (nonatomic, assign, readonly,getter=isShowing) BOOL showing;
@property (nonatomic, assign, readonly) BOOL failOpen;

- (instancetype)initWithName: (NSString *)name failRequest: (BOOL)failRequest;

- (instancetype)initWithName:(NSString *)name failRequest:(BOOL)failRequest failOpen:(BOOL)failOpen;

- (void)clickAdAndLeaveApplication: (BOOL)didLeave;

- (void)closeAd;

@end
