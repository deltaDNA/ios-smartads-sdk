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

#import "ViewController.h"
#import <DeltaDNA/DeltaDNA.h>
#import <DeltaDNAAds/DeltaDNAAds.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <DDNASmartAdsRegistrationDelegate, DDNAInterstitialAdDelegate, DDNARewardedAdDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) DDNAInterstitialAd *interstitialAd;
@property (nonatomic, strong) DDNARewardedAd *rewardedAd1;
@property (nonatomic, strong) DDNARewardedAd *rewardedAd2;
@property (nonatomic, strong) DDNAImageMessage *imageMessage;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logoImageView.image = [UIImage imageNamed:@"Logo.png"];
    self.sdkVersion.text = [NSString stringWithFormat:@"smartads %@", [[DDNASmartAds sdkVersion] substringFromIndex:9]];
    self.showInterstitialAd.enabled = NO;
    self.interstitialMessage.text = @"";
    self.showRewardedAd1.enabled = NO;
    self.rewardedMessage1.text = @"";
    self.showRewardedAd2.enabled = NO;
    self.rewardedMessage2.text = @"";
    
    [DDNASDK setLogLevel:DDNALogLevelDebug];
    [DDNASDK sharedInstance].clientVersion = @"1.0.0";
    [DDNASDK sharedInstance].hashSecret = @"KmMBBcNwStLJaq6KsEBxXc6HY3A4bhGw";
    [DDNASmartAds sharedInstance].registrationDelegate = self;
    
    [[DDNASDK sharedInstance] startWithEnvironmentKey:@"55822530117170763508653519413932"
                                           collectURL:@"https://collect2010stst.deltadna.net/collect/api"
                                            engageURL:@"https://engage2010stst.deltadna.net"];
    
    
    // Prepare CoreLocation
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Launch refresh stats
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(updateStats)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showInterstitialAd:(id)sender
{
    if (self.interstitialAd) {
        // don't worry about checking if an ad is ready, trying to show when you want
        // an ad, it will give a report of your fill rate.
        [self.interstitialAd showFromRootViewController:self];
    }
}

- (IBAction)showRewardedAd1:(id)sender
{
    if (self.rewardedAd1 && self.rewardedAd1.isReady) {
        [self.rewardedAd1 showFromRootViewController:self];
    }
}

- (IBAction)showRewardedAd2:(id)sender
{
    if (self.rewardedAd2 && self.rewardedAd2.isReady) {
        [self.rewardedAd2 showFromRootViewController:self];
    }
}

- (IBAction)newSession:(id)sender
{
    [[DDNASDK sharedInstance] newSession];
}

- (IBAction)getGpsPosition:(id)sender
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"GPS authorisation %d", status);
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Location manager failed: %@", error);
}


#pragma mark - DDNASmartAdsRegistrationDelegate

- (void)didRegisterForInterstitialAds
{
    [[DDNASmartAds sharedInstance].engageFactory requestInterstitialAdForDecisionPoint:@"interstitialAd" parameters:nil handler:^(DDNAInterstitialAd * _Nonnull interstitialAd)
    {
        interstitialAd.delegate = self;
        self.interstitialAd = interstitialAd;
        
        self.showInterstitialAd.enabled = YES;
    }];
}

- (void)didFailToRegisterForInterstitialAdsWithReason:(NSString *)reason
{
    self.interstitialMessage.text = @"Failed to register for interstitial ads";
}

- (void)didRegisterForRewardedAds
{
    [[DDNASmartAds sharedInstance].engageFactory requestRewardedAdForDecisionPoint:@"rewardedAd1" parameters:nil handler:^(DDNARewardedAd * _Nonnull rewardedAd) {
        rewardedAd.delegate = self;
        self.rewardedAd1 = rewardedAd;
    }];
    
    [[DDNASmartAds sharedInstance].engageFactory requestRewardedAdForDecisionPoint:@"rewardedAd2" parameters:nil handler:^(DDNARewardedAd * _Nonnull rewardedAd) {
        rewardedAd.delegate = self;
        self.rewardedAd2 = rewardedAd;
    }];
    
}

- (void)didFailToRegisterForRewardedAdsWithReason:(NSString *)reason
{
    self.rewardedMessage1.text = @"Failed to register for rewarded ads";
    self.rewardedMessage2.text = @"Failed to register for rewarded ads";
}

#pragma mark - DDNAInterstitialAdDelegate

- (void)didOpenInterstitialAd:(DDNAInterstitialAd *)interstitialAd
{
    self.interstitialMessage.text = @"Fulfilled";
}

- (void)didFailToOpenInterstitialAd:(DDNAInterstitialAd *)interstitialAd withReason:(NSString *)reason
{
    self.interstitialMessage.text = reason;
}

- (void)didCloseInterstitialAd:(DDNAInterstitialAd *)interstitialAd
{
    // This is a good place to request another one.
    [[DDNASmartAds sharedInstance].engageFactory requestInterstitialAdForDecisionPoint:@"interstitialAd" parameters:nil handler:^(DDNAInterstitialAd * _Nonnull interstitialAd) {
        interstitialAd.delegate = self;
        self.interstitialAd = interstitialAd;
        
        self.showInterstitialAd.enabled = YES;
    }];
}

#pragma mark - DDNARewardedAdDelegate

- (void)didLoadRewardedAd:(DDNARewardedAd *)rewardedAd
{
    if (rewardedAd == self.rewardedAd1) {
        self.showRewardedAd1.enabled = YES;
        self.rewardedMessage1.text = @"Ready";
    } else if (rewardedAd == self.rewardedAd2) {
        self.showRewardedAd2.enabled = YES;
        self.rewardedMessage2.text = @"Ready";
    }
}

- (void)didExpireRewardedAd:(DDNARewardedAd *)rewardedAd
{
    if (rewardedAd == self.rewardedAd1) {
        self.showRewardedAd1.enabled = NO;
        self.rewardedMessage1.text = @"Expired";
    } else if (rewardedAd == self.rewardedAd2) {
        self.showRewardedAd2.enabled = NO;
        self.rewardedMessage2.text = @"Expired";
    }
}

- (void)didOpenRewardedAd:(DDNARewardedAd *)rewardedAd
{
    if (rewardedAd == self.rewardedAd1) {
        self.showRewardedAd1.enabled = NO;
        self.rewardedMessage1.text = @"Fulfilled";
    } else if (rewardedAd == self.rewardedAd2) {
        self.showRewardedAd2.enabled = NO;
        self.rewardedMessage2.text = @"Fulfilled";
    }
}

- (void)didFailToOpenRewardedAd:(DDNARewardedAd *)rewardedAd withReason:(NSString *)reason
{
    if (rewardedAd == self.rewardedAd1) {
        self.rewardedMessage1.text = reason;
    } else if (rewardedAd == self.rewardedAd2) {
        self.rewardedMessage2.text = reason;
    }
}

- (void)didCloseRewardedAd:(DDNARewardedAd *)rewardedAd withReward:(BOOL)reward
{
    NSString *message = reward ? [NSString stringWithFormat:@"Watched, reward player %ld %@", (long)rewardedAd.rewardAmount, rewardedAd.rewardType] : @"Skipped, don't reward player";
    if (rewardedAd == self.rewardedAd1) {
        self.rewardedMessage1.text = message;
        
        [[DDNASmartAds sharedInstance].engageFactory requestRewardedAdForDecisionPoint:@"rewardedAd1" parameters:nil handler:^(DDNARewardedAd * _Nonnull rewardedAd) {
            rewardedAd.delegate = self;
            self.rewardedAd1 = rewardedAd;
        }];
    } else if (rewardedAd == self.rewardedAd2) {
        self.rewardedMessage2.text = message;
        
        [[DDNASmartAds sharedInstance].engageFactory requestRewardedAdForDecisionPoint:@"rewardedAd2" parameters:nil handler:^(DDNARewardedAd * _Nonnull rewardedAd) {
            rewardedAd.delegate = self;
            self.rewardedAd2 = rewardedAd;
        }];
    }
}

#pragma mark - private helpers

- (void)updateStatsWithAd:(DDNAAd *)ad label:(UILabel *)label
{
    if (ad == nil || label == nil) return;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSDate *lastShown = ad.lastShown;
    NSString *formattedDateString = @"-";
    if (lastShown && [[NSDate date] timeIntervalSinceDate:lastShown] < 86400) {
        formattedDateString = [dateFormatter stringFromDate:lastShown];
    }
    
    NSString *sessionLimit = ad.sessionLimit > 0 ? [NSString stringWithFormat:@"(%ld)", ad.sessionLimit] : @"";
    NSString *dailyLimit = ad.dailyLimit > 0 ? [NSString stringWithFormat:@"(%ld)", ad.dailyLimit] : @"";
    NSString *showWaitSecs = @"";
    if (lastShown && ad.showWaitSecs > 0) {
        NSTimeInterval secsSinceLastShown = [[NSDate date] timeIntervalSinceDate:lastShown];
        NSTimeInterval secsRemaining = MAX(ad.showWaitSecs - secsSinceLastShown, 0);
        showWaitSecs = secsRemaining > 0 ? [NSString stringWithFormat:@"(%.0f secs)", secsRemaining] : @"";
    }

    NSString *text = [NSString stringWithFormat:@"Session:%3ld %@  Today:%3ld %@  Time: %@ %@", ad.sessionCount, sessionLimit, ad.dailyCount, dailyLimit, formattedDateString, showWaitSecs];
    label.text = text;
}

- (void)updateStats
{
    [self updateStatsWithAd:self.interstitialAd label:self.interstitialStats];
    [self updateStatsWithAd:self.rewardedAd1 label:self.rewardedStats1];
    [self updateStatsWithAd:self.rewardedAd2 label:self.rewardedStats2];
}

@end
