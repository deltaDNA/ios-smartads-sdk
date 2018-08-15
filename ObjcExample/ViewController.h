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

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *sdkVersion;
@property (weak, nonatomic) IBOutlet UILabel *interstitialStats;
@property (weak, nonatomic) IBOutlet UILabel *interstitialMessage;
@property (weak, nonatomic) IBOutlet UILabel *rewardedStats1;
@property (weak, nonatomic) IBOutlet UILabel *rewardedMessage1;
@property (weak, nonatomic) IBOutlet UILabel *rewardedStats2;
@property (weak, nonatomic) IBOutlet UILabel *rewardedMessage2;
@property (weak, nonatomic) IBOutlet UIButton *showInterstitialAd;
@property (weak, nonatomic) IBOutlet UIButton *showRewardedAd1;
@property (weak, nonatomic) IBOutlet UIButton *showRewardedAd2;
@property (weak, nonatomic) IBOutlet UISwitch *gdprConsentSwitch;
@property (weak, nonatomic) IBOutlet UIButton *forgetMe;


- (IBAction)showInterstitialAd:(id)sender;
- (IBAction)showRewardedAd1:(id)sender;
- (IBAction)showRewardedAd2:(id)sender;
- (IBAction)setGdprConsent:(id)sender;
- (IBAction)newSession:(id)sender;
- (IBAction)getGpsPosition:(id)sender;
- (IBAction)forgetMe:(id)sender;
- (IBAction)restart:(id)sender;

@end

