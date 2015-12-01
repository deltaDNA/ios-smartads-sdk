//
//  DDNASmartAdVungleAdapter.m
//  
//
//  Created by David White on 01/12/2015.
//
//

#import "DDNASmartAdVungleAdapter.h"
#import <VungleSDK/VungleSDK.h>

@interface DDNASmartAdVungleAdapter () <VungleSDKDelegate>

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) BOOL reward;

@end

@implementation DDNASmartAdVungleAdapter

- (instancetype)initWithAppId:(NSString *)appId eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"VUNGLE" version:VungleSDKVersion eCPM:eCPM waterfallIndex:waterfallIndex])) {
        self.appId = appId;
        [[VungleSDK sharedSDK] setDelegate:self];
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appId"]) return nil;
    
    return [self initWithAppId:configuration[@"appId"] eCPM:[configuration[@"eCPM"] integerValue] waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (!self.started) {
        [[VungleSDK sharedSDK] startWithAppId:self.appId];
        self.started = YES;
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if ([[VungleSDK sharedSDK] isAdPlayable]) {
        NSError *error;
        if (![[VungleSDK sharedSDK] playAd:viewController error:&error]) {
            [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeError]];
        }
    } else {
        [self.delegate adapterDidFailToShowAd:self withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - VungleSDKDelegate protocol

- (void)vungleSDKAdPlayableChanged:(BOOL)isAdPlayable
{
    if (isAdPlayable) {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)vungleSDKwillShowAd
{
    [self.delegate adapterIsShowingAd:self];
}

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary*)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet
{
    self.reward = [viewInfo[@"completedView"] boolValue];
    
    if ([viewInfo[@"didDownload"] boolValue]) {
        [self.delegate adapterWasClicked:self];
    }
    
    if (!willPresentProductSheet) {
        [self.delegate adapterDidCloseAd:self canReward:self.reward];
        if ([[VungleSDK sharedSDK] isAdPlayable]) {
            [self.delegate adapterDidLoadAd:self];
        }
    }
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet
{
    [self.delegate adapterDidCloseAd:self canReward:self.reward];
    if ([[VungleSDK sharedSDK] isAdPlayable]) {
        [self.delegate adapterDidLoadAd:self];
    }
}


@end
