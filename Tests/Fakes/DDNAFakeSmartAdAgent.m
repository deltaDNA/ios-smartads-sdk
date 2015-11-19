//
//  DDNAFakeSmartAdAgent.m
//  SmartAds
//
//  Created by David White on 28/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import "DDNAFakeSmartAdAgent.h"
#import <DeltaDNAAds/Networks/Dummy/DDNASmartAdDummyAdapter.h>

@interface DDNASmartAdAgent (UnitTest)

- (void)adapterDidLoadAd: (DDNASmartAdAdapter *)adapter;
- (void)adapterIsShowingAd: (DDNASmartAdAdapter *)adapter;
- (void)adapterDidCloseAd: (DDNASmartAdAdapter *)adapter;

@end

@interface DDNAFakeSmartAdAgent ()

@property (nonatomic, strong) DDNASmartAdDummyAdapter *dummyAdapter;

@end

@implementation DDNAFakeSmartAdAgent

- (instancetype)init
{
    self.dummyAdapter = [[DDNASmartAdDummyAdapter alloc] initWithName:@"DUMMY" version:@"1.0.0" eCPM:100 waterfallIndex:1];
    
    if ((self = [super initWithAdapters:@[self.dummyAdapter]])) {
        
    }
    return self;
}

- (void)requestAd
{
    if ([self respondsToSelector:@selector(adapterDidLoadAd:)]) {
        [self adapterDidLoadAd:self.dummyAdapter];
    }
}

- (void)showAdWithAdPoint:(NSString *)adPoint
{
    [self adapterIsShowingAd:self.dummyAdapter];
}

- (void)closeAd
{
    [self adapterDidCloseAd:self.dummyAdapter];
}

@end
