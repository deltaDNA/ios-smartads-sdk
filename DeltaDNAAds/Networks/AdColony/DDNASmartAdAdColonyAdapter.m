//
//  DDNASmartAdAdColonyAdapter.m
//  
//
//  Created by David White on 27/11/2015.
//
//

#import "DDNASmartAdAdColonyAdapter.h"
#import <AdColony/AdColony.h>

@interface DDNASmartAdAdColonyAdapter () <AdColonyDelegate, AdColonyAdDelegate>

@property (nonatomic, copy, readwrite) NSString *appId;
@property (nonatomic, copy, readwrite) NSString *zoneId;

@property (nonatomic, assign) BOOL configured;
@property (nonatomic, assign) BOOL videoAvailable;
@property (nonatomic, assign) BOOL watchedVideo;

@end

@implementation DDNASmartAdAdColonyAdapter

- (instancetype)initWithAppId:(NSString *)appId
                       zoneId:(NSString *)zoneId
                         eCPM:(NSInteger)eCPM
               waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super initWithName:@"ADCOLONY" version:@"2.6+" eCPM:eCPM waterfallIndex:waterfallIndex])) {
        self.appId = appId;
        self.zoneId = zoneId;
    }
    return self;
}

#pragma mark - DDNASmartAdAdapter

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    if (!configuration[@"appId"] || !configuration[@"zoneId"]) return nil;
    
    return [self initWithAppId:configuration[@"appId"]
                        zoneId:configuration[@"zoneId"]
                          eCPM:[configuration[@"eCPM"] integerValue]
                waterfallIndex:waterfallIndex];
}

- (void)requestAd
{
    if (!self.configured) {
        [AdColony configureWithAppID:self.appId zoneIDs:@[self.zoneId] delegate:self logging:NO];
        self.configured = YES;
    }
    
    if (self.videoAvailable) {
        [self.delegate adapterDidLoadAd:self];
    }
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    if (self.videoAvailable) {
        [AdColony playVideoAdForZone:self.zoneId withDelegate:self];
    } else {
        [self.delegate adapterDidFailToShowAd:self
                                   withResult:[DDNASmartAdClosedResult resultWith:DDNASmartAdClosedResultCodeNotReady]];
    }
}

#pragma mark - AdColonyDelegate

- (void)onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneID
{
    if (available) {
        [self.delegate adapterDidLoadAd:self];
    }
    self.videoAvailable = available;
}

#pragma mark - AdColonyAdDelegate

- (void)onAdColonyAdStartedInZone:(NSString *)zoneID
{
    
    [self.delegate adapterIsShowingAd:self];
}

- (void)onAdColonyAdFinishedWithInfo:(AdColonyAdInfo *)info
{
    self.watchedVideo = YES;
    [self.delegate adapterDidCloseAd:self canReward:self.watchedVideo];
    
    // if ads are still available, let the agent know
    if (self.videoAvailable) {
        [self.delegate adapterDidLoadAd:self];
    }
}

@end
