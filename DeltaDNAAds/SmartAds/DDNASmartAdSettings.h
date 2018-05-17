//
// Copyright (c) 2018 deltaDNA Ltd. All rights reserved.
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

@interface DDNASmartAdSettings : NSObject

/**
 If you've collected consent from the user to have advertising networks track them set this flag
 to YES and it will be passed to the ad networks that support opt-in consent.  The default is NO.
 */
@property (nonatomic, assign) BOOL advertiserGdprUserConsent;

/**
 If the user is known to be in an age restricted category, i.e. under the age of 16, set this
 flag to YES and it will be passed to supporting ad networks.  The default is NO.
 */
@property (nonatomic, assign) BOOL advertiserGdprAgeRestrictedUser;

@end
