//
//  ViewController.h
//  DeltaDNA SmartAds iOS Example
//
//  Created by David White on 19/11/2015.
//  Copyright © 2015 deltaDNA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *sdkVersion;
@property (weak, nonatomic) IBOutlet UILabel *smartAdsStatus;
@property (weak, nonatomic) IBOutlet UILabel *smartAdsRewardedStatus;
@property (weak, nonatomic) IBOutlet UILabel *rewardAmount;


- (IBAction)showInterstitialAd:(id)sender;
- (IBAction)showInterstitialAdWithDecisionPoint:(id)sender;
- (IBAction)showRewardedAd:(id)sender;
- (IBAction)showRewardedAdWithDecisionPoint:(id)sender;
- (IBAction)showRewardedAdOrImageMessage:(id)sender;

@end

