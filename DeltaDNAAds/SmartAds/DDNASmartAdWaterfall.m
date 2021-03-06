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

#import "DDNASmartAdWaterfall.h"
#import "DDNASmartAdAdapter.h"

@interface DDNASmartAdWaterfall ()

@property (nonatomic, assign) DDNASmartAdRequestResultCode demoteOptions;
@property (nonatomic, strong) NSMutableArray *waterfall;
@property (nonatomic, assign) NSInteger currentPosition;
@property (nonatomic, assign) NSInteger maxRequests;

@end

@implementation DDNASmartAdWaterfall

- (instancetype)initWithAdapters:(NSArray *)adapters demoteOnOptions:(DDNASmartAdRequestResultCode)options maxRequests:(NSInteger)maxRequests
{
    if (adapters == nil || adapters.count == 0) {
        @throw([NSException exceptionWithName:NSInvalidArgumentException reason:@"adapters cannot be nil or empty" userInfo:nil]);
    }
    
    if ((self = [super init])) {
        self.waterfall = [NSMutableArray arrayWithArray:adapters];
        self.demoteOptions = options;
        self.maxRequests = maxRequests;
        self.currentPosition = 0;
        [self resetScores];
        [self setWaterfallIndex];
    }
    return self;
}

- (DDNASmartAdAdapter *)resetWaterfall
{
    if (self.waterfall.count > 0) {
        
        // sort adapters on score, and then waterfall index
        NSSortDescriptor *scoreDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
        NSSortDescriptor *indexDescriptor = [[NSSortDescriptor alloc] initWithKey:@"waterfallIndex" ascending:YES];
        NSArray *sortDescriptors = @[scoreDescriptor, indexDescriptor];
        self.waterfall = [NSMutableArray arrayWithArray:[self.waterfall sortedArrayUsingDescriptors:sortDescriptors]];
        self.currentPosition = 0;
        
        // reset scores and waterfall index
        [self resetScores];
        [self setWaterfallIndex];
        
        return self.waterfall[self.currentPosition];
    }
    
    return nil;
}

- (DDNASmartAdAdapter *)getNextAdapter
{
    if (self.currentPosition + 1 < self.waterfall.count) {
        self.currentPosition++;
        return self.waterfall[self.currentPosition];
    }
    
    return nil;
}

- (void)scoreAdapter:(DDNASmartAdAdapter *)adapter withRequestCode:(DDNASmartAdRequestResultCode)requestCode
{
    if (requestCode & self.demoteOptions) {
        adapter.score--;
    }
    
    if ((requestCode & DDNASmartAdRequestResultCodeConfiguration) == DDNASmartAdRequestResultCodeConfiguration) {
        [self removeAdapter:adapter];
    }
    
    if ((requestCode & DDNASmartAdRequestResultCodeError) == DDNASmartAdRequestResultCodeError) {
        [self removeAdapter:adapter];
    }
    
    if (requestCode == DDNASmartAdRequestResultCodeLoaded) {
        adapter.requestCount++;
        if ((self.demoteOptions & DDNASmartAdRequestResultCodeMaxRequests) == DDNASmartAdRequestResultCodeMaxRequests &&
            self.maxRequests > 0 &&
            adapter.requestCount >= self.maxRequests) {
            adapter.score--;
        }
    }
}

- (void)removeAdapter:(DDNASmartAdAdapter *)adapter
{
    NSUInteger position = [self.waterfall indexOfObject:adapter];
    [self.waterfall removeObject:adapter];
    if (self.currentPosition >= position) {
        self.currentPosition--;
    }
}

- (NSArray *)getAdapters
{
    return [NSArray arrayWithArray:self.waterfall];
}

- (void)resetScores
{
    for (DDNASmartAdAdapter *adapter in self.waterfall) {
        adapter.score = 0;
    }
}

- (void)setWaterfallIndex
{
    for (DDNASmartAdAdapter *adapter in self.waterfall) {
        adapter.waterfallIndex = [self.waterfall indexOfObject:adapter];
    }
}

@end
