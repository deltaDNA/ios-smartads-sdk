//
//  ViewController.m
//  DeltaDNA SmartAds iOS Example
//
//  Created by David White on 19/11/2015.
//  Copyright © 2015 deltaDNA. All rights reserved.
//

#import "ViewController.h"
#import <DeltaDNA/DeltaDNA.h>
#import <DeltaDNAAds/DeltaDNAAds.h>

@interface ViewController () <DDNASmartAdsInterstitialDelegate, DDNASmartAdsRewardedDelegate>

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
    
    [DDNASmartAds sharedInstance].interstitialDelegate = self;
    [DDNASmartAds sharedInstance].rewardedDelegate = self;
    [[DDNASmartAds sharedInstance] registerForAds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showInterstitialAd:(id)sender
{
    [[DDNASmartAds sharedInstance] showInterstitialAdFromRootViewController:self];
}

- (IBAction)showInterstitialAdWithDecisionPoint:(id)sender
{
    [[DDNASmartAds sharedInstance] showInterstitialAdFromRootViewController:self decisionPoint:@"testDecisionPoint"];
}

- (IBAction)showRewardedAd:(id)sender
{
    [[DDNASmartAds sharedInstance] showRewardedAdFromRootViewController:self];
}

- (IBAction)showRewardedAdWithDecisionPoint:(id)sender
{
    [[DDNASmartAds sharedInstance] showRewardedAdFromRootViewController:self decisionPoint:@"testRewardedDecisionPoint"];
}


#pragma mark - DDNASmartAdsInterstitialDelegate

- (void)didRegisterForInterstitialAds
{
    self.smartAdsStatus.text = @"Registered for interstitial ads.";
}

- (void)didFailToRegisterForInterstitialAdsWithReason:(NSString *)reason
{
    self.smartAdsStatus.text = @"Failed to register for interstitial ads.";
}

- (void)didOpenInterstitialAd
{
    
}

- (void)didFailToOpenInterstitialAd
{
    
}

- (void)didCloseInterstitialAd
{
    
}

#pragma mark - DDNASmartAdsRewardedDelegate

- (void)didRegisterForRewardedAds
{
    self.smartAdsRewardedStatus.text = @"Registered for rewarded ads.";
}

- (void)didFailToRegisterForRewardedAdsWithReason:(NSString *)reason
{
    self.smartAdsRewardedStatus.text = @"Failed to register for rewarded ads.";
}

- (void)didOpenRewardedAd
{
    
}

- (void)didFailToOpenRewardedAd
{
    
}

- (void)didCloseRewardedAdWithReward:(BOOL)reward
{
    
}


@end
