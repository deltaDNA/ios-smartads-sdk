//
//  ViewController.m
//  DeltaDNA SmartAds iOS Example
//
//  Created by David White on 19/11/2015.
//  Copyright © 2015 deltaDNA. All rights reserved.
//

#import "ViewController.h"
#import <DeltaDNA/DeltaDNA.h>
#import <DeltaDNAAds/DDNASmartAds.h>

@interface ViewController () <DDNASmartAdsDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sdkVersion.text = [DDNASmartAds sdkVersion];
    self.smartAdsStatus.text = @"Registering...";
    
    [DDNASDK sharedInstance].clientVersion = @"0.1.0";
    [DDNASDK sharedInstance].hashSecret = @"KmMBBcNwStLJaq6KsEBxXc6HY3A4bhGw";
    
    [[DDNASDK sharedInstance] startWithEnvironmentKey:@"55822530117170763508653519413932"
                                           collectURL:@"http://collect2010stst.deltadna.net/collect/api"
                                            engageURL:@"http://engage2010stst.deltadna.net"];
    
    [DDNASmartAds sharedInstance].delegate = self;
    [[DDNASmartAds sharedInstance] registerForAds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showInterstitialAd:(id)sender
{
    [[DDNASmartAds sharedInstance] showAdFromRootViewController:self];
}

- (IBAction)showInterstitialAdWithAdPoint:(id)sender
{
    [[DDNASmartAds sharedInstance] showAdFromRootViewController:self adPoint:@"testAdPoint"];
}


#pragma mark - DDNASmartAdsDelegate

- (void)didRegisterForAds
{
    self.smartAdsStatus.text = @"Registered for ads.";
}

- (void)didFailToRegisterForAdsWithReason:(NSString *)reason
{
    self.smartAdsStatus.text = @"Failed to register for ads.";
}

- (void)didOpenAd
{
    
}

- (void)didFailToOpenAd
{
    
}

- (void)didCloseAd
{
    
}

@end
