//
//  DDNASmartAdDummyAdapter.m
//  
//
//  Created by David White on 09/10/2015.
//
//

#import "DDNASmartAdDummyAdapter.h"

@implementation DDNASmartAdDummyAdapter

#pragma mark - DDNASmartAdsAdapter protocol

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    return [self initWithName:@"DUMMY" version:@"1.0.0" eCPM:100 waterfallIndex:0];
}

- (void)requestAd
{
    [self.delegate adapterDidLoadAd:self];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    [self.delegate adapterIsShowingAd:self];
}

@end
