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

@interface ViewController () <DDNASmartAdsRegistrationDelegate, DDNAInterstitialAdDelegate, DDNARewardedAdDelegate, DDNAImageMessageDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) DDNAInterstitialAd *interstitialAd;
@property (nonatomic, strong) DDNARewardedAd *rewardedAd;
@property (nonatomic, strong) DDNAImageMessage *imageMessage;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sdkVersion.text = [DDNASmartAds sdkVersion];
    self.smartAdsStatus.text = @"Registering...";
    self.smartAdsRewardedStatus.text = @"Registering...";
    
    [DDNASDK sharedInstance].clientVersion = @"0.1.0";
    [DDNASDK sharedInstance].hashSecret = @"KmMBBcNwStLJaq6KsEBxXc6HY3A4bhGw";
    
    [[DDNASDK sharedInstance] startWithEnvironmentKey:@"55822530117170763508653519413932"
                                           collectURL:@"http://collect2010stst.deltadna.net/collect/api"
                                            engageURL:@"http://engage2010stst.deltadna.net"];
    
    [DDNASmartAds sharedInstance].registrationDelegate = self;
    [[DDNASmartAds sharedInstance] registerForAds];
    
    // Prepare CoreLocation
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showInterstitialAd:(id)sender
{
    self.interstitialAd = [DDNAInterstitialAd interstitialAdWithDelegate:self];
    [self.interstitialAd showFromRootViewController:self];
}

- (IBAction)showInterstitialAdWithDecisionPoint:(id)sender
{
    DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"showInterstitial"];
    
    [[DDNASDK sharedInstance] requestEngagement:engagement engagementHandler:^(DDNAEngagement *response) {
        // get the response
        if (response != nil) {
            NSLog(@"Got a response from engage: %@", response.raw);

            self.interstitialAd = [DDNAInterstitialAd interstitialAdWithEngagement:response delegate:self];
            if (self.interstitialAd != nil) {
                [self.interstitialAd showFromRootViewController:self];
            } else {
                NSLog(@"Not allowed to show an ad.");
            }
        } else {
            // didn't get a useful engage response, move on...
            NSLog(@"Didn't get a useful response!");
        }
    }];
}

- (IBAction)showRewardedAd:(id)sender
{
    self.rewardedAd = [DDNARewardedAd rewardedAdWithDelegate:self];
    [self.rewardedAd showFromRootViewController:self];
}

- (IBAction)showRewardedAdWithDecisionPoint:(id)sender
{
    DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"showRewarded"];
    [[DDNASDK sharedInstance] requestEngagement:engagement engagementHandler:^(DDNAEngagement *response) {
        // get the response
        if (response != nil) {
            NSLog(@"Got a response from engage: %@", response.raw);
            self.rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:engagement delegate:self];
            if (self.rewardedAd != nil) {
                [self.rewardedAd showFromRootViewController:self];
            } else {
                NSLog(@"Not allowed to show an ad.");
            }
        } else {
            // didn't get a useful engage response, move on...
            NSLog(@"Didn't get a useful response!");
        }
    }];
}

- (IBAction)showRewardedAdOrImageMessage:(id)sender
{
    NSLog(@"Show rewarded ad or image message.");
    
    // make request to engage
    DDNAEngagement *engagement = [DDNAEngagement engagementWithDecisionPoint:@"rewardOrImage"];
    
    [[DDNASDK sharedInstance] requestEngagement:engagement engagementHandler:^(DDNAEngagement *response) {
        // get the response
        if (response != nil) {
            NSLog(@"Got a response from engage: %@", response.raw);
        
            // try and build a rewarded ad
            DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:response delegate:self];
            
            // try and build a popup
            DDNAImageMessage *imageMessage = [DDNAImageMessage imageMessageWithEngagement:response delegate:self];
            
            // Ad will succeed if Engagement contains no ad related parameters, so see if ImageMessage
            // is valid, else show the ad...
            if (imageMessage != nil) {
                NSLog(@"Got an image message!");
                // we got an image message to show
                [imageMessage fetchResources];
            }
            else if (rewardedAd != nil) {
                NSLog(@"Got a rewarded ad!");
                
                if (rewardedAd.parameters[@"rewardAmount"]) {
                    self.rewardAmount.text = [NSString stringWithFormat:@"Reward for watching %@", rewardedAd.parameters[@"rewardAmount"]];
                } else {
                    self.rewardAmount.text = @"No reward available";
                }
                
                // make offer to player... they like it so show ad
                
                if (rewardedAd.isReady) {
                    NSLog(@"Showing the rewarded ad.");
                    [rewardedAd showFromRootViewController:self];
                } else {
                    NSLog(@"Rewarded ad not ready.");
                }
            }
            else {
                // didn't get a useful engage response, move on...
                NSLog(@"Didn't get a useful response!");
            }
            
            self.rewardedAd = rewardedAd;
            self.imageMessage = imageMessage;
            
        } else {
            NSLog(@"No engage response!");
        }
        
    }];
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
    self.smartAdsStatus.text = @"Registered for interstitial ads.";
}

- (void)didFailToRegisterForInterstitialAdsWithReason:(NSString *)reason
{
    self.smartAdsStatus.text = @"Failed to register for interstitial ads.";
}

- (void)didRegisterForRewardedAds
{
    self.smartAdsRewardedStatus.text = @"Registered for rewarded ads.";
}

- (void)didFailToRegisterForRewardedAdsWithReason:(NSString *)reason
{
    self.smartAdsRewardedStatus.text = @"Failed to register for rewarded ads.";
}

#pragma mark - DDNAInterstitialAdDelegate

- (void)didOpenInterstitialAd:(DDNAInterstitialAd *)ad
{
    NSLog(@"Did open interstitial ad.");
}

- (void)didFailToOpenInterstitialAd:(DDNAInterstitialAd *)ad withReason:(NSString *)reason
{
    NSLog(@"Did fail to open interstitial ad with reason %@.", reason);
}

- (void)didCloseInterstitialAd:(DDNAInterstitialAd *)ad
{
    NSLog(@"Did close interstitial ad.");
}

#pragma mark - DDNARewardedAdDelegate

- (void)didOpenRewardedAd:(DDNARewardedAd *)ad
{
    NSLog(@"Did open rewarded ad.");
}

- (void)didFailToOpenRewardedAd:(DDNARewardedAd *)ad withReason:(NSString *)reason
{
    NSLog(@"Did fail to open rewarded ad with reason %@.", reason);
}

- (void)didCloseRewardedAd:(DDNARewardedAd *)ad withReward:(BOOL)reward
{
    NSLog(@"Did close rewarded ad with reward %@.", (reward ? @"YES" : @"NO"));
}

#pragma mark - DDNAImageMessageDelegate

- (void)didReceiveResourcesForImageMessage:(DDNAImageMessage *)imageMessage
{
    if (imageMessage.isReady) {
        [imageMessage showFromRootViewController:self];
    }
}

- (void)didFailToReceiveResourcesForImageMessage:(DDNAImageMessage *)imageMessage withReason:(NSString *)reason
{
    NSLog(@"Failed to download resources for the image message: %@", reason);
}

- (void)onDismissImageMessage:(DDNAImageMessage *)imageMessage name:(NSString *)name
{
    NSLog(@"ImageMessage dismissed by %@", name);
}

- (void)onActionImageMessage:(DDNAImageMessage *)imageMessage name:(NSString *)name type:(NSString *)type value:(NSString *)value
{
    NSLog(@"ImageMessage action from %@ with type %@ value %@", name, type, value);
}

@end
