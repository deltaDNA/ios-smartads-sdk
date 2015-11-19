//
//  DDNASmartAds.m
//  
//
//  Created by David White on 12/10/2015.
//
//

#import "DDNASmartAds.h"
#import "DeltaDNAAds/DDNASmartAdFactory.h"
#import "DeltaDNAAds/DDNASmartAdService.h"
#import <DeltaDNA/DeltaDNA.h>

@interface DDNASmartAds () <DDNASmartAdServiceDelegate>
{
    
}

@property (nonatomic, strong) DDNASmartAdFactory *factory;
@property (nonatomic, strong) DDNASmartAdService *adService;

@end

@implementation DDNASmartAds

- (id)init
{
    if ((self = [super init])) {
        self.factory = [DDNASmartAdFactory sharedInstance];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

+ (NSString *)sdkVersion
{
    return @"SmartAds v0.9.0-beta.1";
}

- (void)registerForAds
{
    @synchronized(self) {
        @try{
            self.adService = [self.factory buildSmartAdServiceWithDelegate:self];
        
            [self.adService beginSessionWithDecisionPoint:@"advertising"];
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error registering for ads: %@", exception);
        }
        @finally {
            if (!self.adService) {
                DDNALogWarn(@"Failed to register for ads.");
            }
        }
    }
}

- (void)showAdFromRootViewController: (UIViewController *)viewController
{
    @synchronized(self) {
        @try {
            if (self.adService) {
                [self.adService showAdFromRootViewController:viewController];
            } else {
                DDNALogWarn(@"RegisterForAds must be called before showing ads will work.");
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error showing ad: %@", exception);
        }
    }
}

- (void)showAdFromRootViewController: (UIViewController *)viewController adPoint: (NSString *)adPoint
{
    @synchronized(self) {
        @try {
            if (self.adService) {
                [self.adService showAdFromRootViewController:viewController adPoint:adPoint];
            } else {
                DDNALogWarn(@"RegisterForAds must be called before showing ads will work.");
            }
        }
        @catch (NSException *exception) {
            DDNALogWarn(@"Error showing ad: %@", exception);
        }
    }
}

#pragma mark - DDNASmartAdServiceDelegate

- (void)didRegisterForAds
{
    DDNALogDebug(@"Registered for ads.");
    [self.delegate didRegisterForAds];
}

- (void)didFailToRegisterForAdsWithReason:(NSString *)reason
{
    DDNALogWarn(@"Failed to register for ads: %@.", reason);
    [self.delegate didFailToRegisterForAdsWithReason:reason];
}

- (void)didFailToOpenAd
{
    DDNALogWarn(@"Failed to open ad.");
    [self.delegate didFailToOpenAd];
}

- (void)didOpenAd
{
    DDNALogDebug(@"Opened ad.");
    [self.delegate didOpenAd];
}

- (void)didCloseAd
{
    DDNALogDebug(@"Closed ad.");
    [self.delegate didCloseAd];
}

- (void)recordEventWithName:(NSString *)eventName andParamJson:(NSString *)paramJson
{
    // TODO - This is clunky converting back and forth from dictionary to json.
    [[DDNASDK sharedInstance] recordEvent:eventName withEventDictionary:[NSDictionary dictionaryWithJSONString:paramJson]];
}

@end
