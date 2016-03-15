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

#import "DDNASmartAdAdapter.h"

@interface DDNASmartAdAdapter ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, assign) NSInteger eCPM;

@end

@implementation DDNASmartAdAdapter

- (instancetype)initWithName:(NSString *)name version:(NSString *)version eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super init])) {
        self.name = name;
        self.version = version;
        self.eCPM = eCPM;
        self.waterfallIndex = waterfallIndex;
        self.score = 0;
    }
    return self;
}

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)requestAd
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    [self doesNotRecognizeSelector:_cmd];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"SmartAdAdapter %@ %@", self.name, self.version];
}

@end