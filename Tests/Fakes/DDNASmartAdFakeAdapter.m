//
//  DDNASmartAdFakeAdapter.m
//  SmartAds
//
//  Created by David White on 13/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import "DDNASmartAdFakeAdapter.h"

@interface DDNASmartAdFakeAdapter ()

@property (nonatomic, assign, readwrite) BOOL failRequest;
@property (nonatomic, assign, readwrite) BOOL showing;
@property (nonatomic, assign, readwrite) BOOL failOpen;

@end

@implementation DDNASmartAdFakeAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration
{
    return [self init];
}

- (instancetype)initWithName:(NSString *)name failRequest:(BOOL)failRequest
{
    return [self initWithName:name failRequest:failRequest failOpen:NO];
}

- (instancetype)initWithName:(NSString *)name failRequest:(BOOL)failRequest failOpen:(BOOL)failOpen
{
    if ((self = [super initWithName:name version:@"1.0.0" eCPM:150 waterfallIndex:1])) {
        self.failRequest = failRequest;
        self.showing = NO;
        self.failOpen = failOpen;
    }
    return self;
}

- (void)clickAdAndLeaveApplication:(BOOL)didLeave
{
    [self.delegate adapterWasClicked:self];
    
    if (didLeave) {
        [self.delegate adapterLeftApplication:self];
    }
}

- (void)closeAd
{
    self.showing = false;
    [self.delegate adapterDidCloseAd:self];
}

#pragma mark - DDNASmartAdAdapter

//- (NSString *)name
//{
//    return self.adapterName;
//}
//
//- (NSString *)version
//{
//    return @"1.0.0";
//}
//
//- (NSInteger)eCPM
//{
//    return 100;
//}

- (void)requestAd
{
    if (self.failRequest) {
        [self.delegate adapterDidFailToLoadAd:self withResult:[DDNASmartAdRequestResult resultWith:DDNASmartAdRequestResultCodeError]];
    } else {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.failOpen) {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
    } else {
        self.showing = YES;
        [self.delegate adapterIsShowingAd:self];
    }
}

@end
