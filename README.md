![deltaDNA logo](https://deltadna.com/wp-content/uploads/2015/06/deltadna_www@1x.png)

## deltaDNA SmartAds iOS SDK

[![Build Status](https://travis-ci.org/deltaDNA/ios-smartads-sdk.svg)](https://travis-ci.org/deltaDNA/ios-smartads-sdk)

The deltaDNA SmartAds SDK provides your iOS game with access to our intelligent ad mediation platform.  It supports both interstitial and rewarded type ads.

### Installation with CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies using 3rd party libraries.  This enables SmartAds to select which ad networks are supported in a straightforward way.

#### Podfile

```ruby
source 'https://github.com/deltaDNA/CocoaPods.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'MyApp' do
    pod 'DeltaDNAAds', '~> 1.8.0'
end
```

The deltaDNA SDKs are available from our private spec repository, its url must be added as a source to your Podfile.  DeltaDNAAds depends on our analytics SDK, which will also be installed.

The above example will install all the ad networks we support.  To install just a subset declare each subspec separately in your Podfile, for example:

```ruby
source 'https://github.com/deltaDNA/CocoaPods.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'MyApp' do
    pod 'DeltaDNAAds', '~> 1.8.0', :subspecs => ['AdMob','MoPub']
end
```
The list of available subspecs can be found in `DeltaDNAAds.podspec` at the root of this project.

### Usage

Include the SDK header files.

```objective-c
#include <DeltaDNA/DeltaDNA.h>
#include <DeltaDNAAds/DeltaDNAAds.h>
```

Start the analytics SDK which will also register SmartAds for ads.

```objective-c
[DDNASDK sharedInstance].clientVersion = @"1.0";

[[DDNASDK sharedInstance] startWithEnvironmentKey:@"YOUR_ENVIRONMENT_KEY"
                                       collectURL:@"YOUR_COLLECT_URL"
                                        engageURL:@"YOUR_ENGAGE_URL"];
```

If everything went well the SmartAds service will start fetching ads in the background.  The `DDNASmartAdsRegistrationDelegate` methods report if the service was successfully configured:

* `-didRegisterForInterstitialAds` - Called when interstitial ads have been successfully configured.
* `-didFailToRegisterForInterstitialAdsWithReason:` - Called if interstitial ads can't be configured for some reason.
* `-didRegisterForRewardedAds` - Called when rewarded ads have successfully been configured.
* `-didFailToRegisterForRewardedAdsWithReason:` - Called when rewarded ads can't be configured for some reason.

#### Create an Interstitial Ad

An interstitial ad is a fullscreen popup that the player can dismiss from a close button.  In order to show an interstitial ad, try to create a `DDNAInterstitialAd` and then show it.

```objective-c
DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithDelegate:self];
if (interstitialAd != nil) {
    [interstitialAd showFromRootViewController:self];
}
```

The example assumes you're in a `UIViewController` and you've implemented the delegate methods of `DDNAInterstitialAdDelegate`.  Although there is an `isReady` method, we recommend not checking that and showing the interstitial whenever the game requires on as that will allow our platform to reports the game's fill rate.

The following callbacks are provided by `DDNAInterstitialAdDelegate`:

* `-didOpenInterstitialAd:` - Called when the ad is showing on screen.
* `-didFailToOpenInterstitialAd:withReason:` - Called if the ad fails to open for some reason.
* `-didCloseInterstitialAd:` - Called when the ad has been closed.

Make sure you keep a strong reference to the interstitial object else the delegate methods may not be called.  When you want to show another ad you can either reuse the interstitial object and call `-showFromRootViewController` again or create another one.

#### Create a Rewarded Ad

A rewarded ad is a short video, typically 30 seconds in length that the player must watch before being able to dismiss.  To show a rewarded ad, try to create a `DDNARewardedAd` object and then show it.

```objective-c
DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithDelegate:self];
self.rewardedAd = rewardedAd;

// wait for an ad to be loaded in the delegate

- (void)didLoadRewardedAd:(DDNARewardedAd *)rewardedAd
{
    // If they choose to watch the ad
    [rewardedAd showFromRootViewController:self];
}
```

The example again assumes you're in a `UIViewController` and you've implemented the delegate methods of `DDNARewardedAdDelegate`.  If a non nil object was returned you can call `-showFromRootViewController`.  Initialising the ad checks you have permission to show an ad at this point in time and that an ad has loaded.

The following callbacks are provided by `DDNARewardedAdDelegate`:

* `-didLoadRewardedAd:` - Called when an ad loads and is ready to view.
* `-didExpireRewardedAd:` - Called when a previously loaded ad is no longer available to view.
* `-didOpenRewardedAd:` - Called when the ad is showing on screen.
* `-didFailToOpenRewardedAd:withReason:` - Called if the ad fails to open for some reason.
* `-didCloseRewardedAd:withReward:` - Called when the ad is finished, the reward flag indicates if the ad was watched enough that you can reward the player.

Again, make sure you keep a strong reference to the rewarded ad object else the delegate methods may not be called.  When you want to show another ad either reuse the rewarded ad object or create another one.

#### Working with Engage

To fully take advantage of deltaDNA's SmartAds you want to work with our Engage service.  The game can ask Engage if it should show an ad for this particular player.  Engage will tailor its response according to which campaigns are running and which segment this player is in.  You can build an ad object with the SmartAds Engage factory.  We can also pass additional real-time parameters to Engage which could customise the reward for this player.  For more details on Engage checkout out the [analytics SDK](https://github.com/deltaDNA/ios-sdk).

```objective-c
[[DDNASmartAds sharedInstance].engageFactory requestRewardedAdForDecisionPoint:@"rewardedAd" parameters:nil handler:^(DDNARewardedAd * _Nonnull rewardedAd) {
    rewardedAd.delegate = self;
    self.rewardedAd = rewardedAd;
}

// wait for an ad to be loaded in the delegate

- (void)didLoadRewardedAd:(DDNARewardedAd *)rewardedAd
{
    NSInteger rewardAmount = rewardedAd.rewardAmount;

    // Present offer to player...

    // If they choose to watch the ad
    [rewardedAd showFromRootViewController:self];
}
```

Checkout the included example project for more details.

### iOS 10 and ATS Support

The following table is a list of considerations when integrating our library.  Many of the ad networks are ATS compliant, the others [recommend](https://firebase.google.com/docs/admob/ios/ios9) setting the `NSArbitararyLoads` key to true.  Most now support bitcode, but currently we don't.  Only MobPub and Flurry and ThirdPresence work with the CocoaPods `use_frameworks!` option, the others will give a transitive dependencies error. The library does not support dynamic frameworks, so avoid that for now.  Remember you can use the subspecs option if you only want certain networks included with SmartAds.  You will also want to consider configuring the privacy controls for iOS 10.

| Ad Network      | ATS Support  | Bitcode | Frameworks | Notes |
|-----------------|--------------|---------|------------|-------|
| AdMob           | YES          | YES     | NO         |       |
| Amazon          | NO           | YES     | NO         | see [iOS 10 integration](https://developer.amazon.com/public/apis/earn/mobile-ads/ios/docs/release-notes)      |
| MoPub           | YES          | YES     | YES        |       |
| Flurry          | YES          | YES     | YES        |       |
| InMobi          | NO           | YES     | NO         |       |
| MobFox          | NO           | YES     | NO         | requires iOS 9 for latest version      |
| AdColony        | NO           | YES     | NO         | see [iOS 10 integration](https://github.com/AdColony/AdColony-iOS-SDK-3/wiki/Xcode-Project-Setup#configuring-privacy-controls) |
| Chartboost      | YES          | YES     | NO         |       |
| Vungle          | YES          | YES     | NO         |       |
| UnityAds        | YES          | YES     | NO         |       |
| AppLovin        | YES          | YES     | NO         |       |
| ThirdPresence   | YES          | YES     | YES        |       |
| IronSource      | YES          | YES     | NO         |       |
| Facebook        | YES          | YES     | NO         |       |
| Tapjoy          | NO           | YES     | NO         |       |
| HyprMX          | NO           | YES     | NO         |       |
| LoopMe          | NO           | YES     | NO         | requires iOS 9 for latest version      |
| MachineZone     | YES          | YES     | NO         |       |

### Facebook Integration
Facebook Audience Network integration needs you to manage the account and create suitable placements for our mediation to use.  Contact support for more information.

### Diagnostics
More details on what ads are being loaded and shown can be enabled by adding debug notifications to your project. Follow the instructions for the project [here](https://github.com/deltaDNA/ios-debug-sdk) to find out more details.

## License

The sources are available under the Apache 2.0 license.

## Contact Us

For more information, please visit [deltadna.com](https://deltadna.com/). For questions or assistance, please email us at [support@deltadna.com](mailto:support@deltadna.com).
