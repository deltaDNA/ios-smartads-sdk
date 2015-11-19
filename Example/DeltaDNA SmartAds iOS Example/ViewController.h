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

- (IBAction)showInterstitialAd:(id)sender;
- (IBAction)showInterstitialAdWithAdPoint:(id)sender;

@end

