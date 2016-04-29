![deltaDNA logo](https://deltadna.com/wp-content/uploads/2015/06/deltadna_www@1x.png)

## deltaDNA SmartAds iOS SDK

[![Build Status](https://travis-ci.org/deltaDNA/ios-smartads-sdk.svg)](https://travis-ci.org/deltaDNA/ios-smartads-sdk)

The deltaDNA SmartAds SDK provides your iOS game with access to our intelligent ad mediation platform.  It supports both interstitial and rewarded type ads.

### Installation with CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies using 3rd party libraries.  This enables SmartAds to select which ad networks are supported in a straightforward way.

#### Podfile

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/deltaDNA/CocoaPods.git'

platform :ios, '7.0'

pod 'DeltaDNAAds', '~> 1.1'
```

The deltaDNA SDKs are available from our private spec repository, its url must be added as a source to your Podfile.  DeltaDNAAds depends on our analytics SDK, which will also be installed.  

The above example will install all the ad networks we support.  To install just a subset declare each subspec separately in your Podfile, for example:

```ruby

pod 'DeltaDNAAds/AdMob'
pod 'DeltaDNAAds/AdColony'

```
The list of available subspecs can be found in `DeltaDNAAds.podspec` at the root of this project.

### Usage

Include the SDK header files.

```objective-c
#include <DeltaDNA/DeltaDNA.h>
#include <DeltaDNAAds/DeltaDNAAds.h>
```

Start the analytics SDK.

```objective-c
[DDNASDK sharedInstance].clientVersion = @"1.0";

[[DDNASDK sharedInstance] startWithEnvironmentKey:@"YOUR_ENVIRONMENT_KEY"
                                       collectURL:@"YOUR_COLLECT_URL"
                                        engageURL:@"YOUR_ENGAGE_URL"];


```

Register for ads.

```objective-c
[DDNASmartAds sharedInstance].registrationDelegate = self;
[[DDNASmartAds sharedInstance] registerForAds];
```

If everything went well the SmartAds service will start fetching ads in the background.  The `DDNASmartAdsRegistrationDelegate` methods report if the service was successfully configured:

* `-didRegisterForInterstitialAds` - Called when interstitial ads have been successfully configured.
* `-didFailToRegisterForInterstitialAdsWithReason:` - Called if interstitial ads can't be configured for some reason.
* `-didRegisterForRewardedAds` - Called when rewarded ads have successfully been configured.
* `-didFailToRegisterForRewardedAdsWithReason:` - Called when rewarded ads can't be configured for some reason.

#### Create an Interstitial Ad

An interstitial ad is a fullscreen popup that the player can dismiss from a close button.  In order to show an interstitial ad, create a `DDNAInterstitialAd` and attempt to show it.  

```objective-c
DDNAInterstitialAd *interstitialAd = [DDNAInterstitialAd interstitialAdWithDelegate:self];
[interstitialAd showFromRootViewController:self];
```

The example assumes you're in a `UIViewController` and you've implemented the delegate methods of `DDNAInterstitialAdDelegate`.  Notice how we don't bother to test if an ad is available, instead always try to show the ad where you want one and we will record *No Fill* if one wasn't available.  This helps us accurately report your fill rate.

The following callbacks are provided by `DDNAInterstitialAdDelegate`:

* `-didOpenInterstitialAd:` - Called when the ad is showing on screen.
* `-didFailToOpenInterstitialAd:withReason:` - Called if the ad fails to open for some reason.
* `-didCloseInterstitialAd:` - Called when the ad has been closed.

Make sure you keep a strong reference to the interstitial object else the delegate methods may not be called.  When you want to show another ad you can either reuse the interstitial object and call `-showFromRootViewController` again or create another one.

#### Create a Rewarded Ad

A rewarded ad is a short video, typically 30 seconds in length that the player must watch before being able to dismiss.  To show a rewarded ad, create a `DDNARewardedAd` object and attempt to show it.

```objective-c
DDNARewardedAd *rewardedAd = [DDNARewardedAd rewardedAdWithDelegate:self];
[rewardedAd showFromRootViewController:self];
```

The example again assumes you're in a `UIViewController` and you've implemented the delegate methods of `DDNARewardedAdDelegate`.  This will show the video if one is available else no fill is reported.  If you'd rather only offer a rewarded ad to your player if one is available you can call `-isReady` to test if a video has loaded.

The following callbacks are provided by `DDNARewardedAdDelegate`:

* `-didOpenRewardedAd:` - Called when the ad is showing on screen.
* `-didFailToOpenRewardedAd:withReason:` - Called if the ad fails to open for some reason.
* `-didCloseRewardedAd:withReward:` - Called when the ad is finished, the reward flag indicates if the ad was watched enough that you can reward the player.

Again, make sure you keep a strong reference to the rewarded ad object else the delegate methods may not be called.  When you want to show another ad either reuse the rewarded ad object or create another one.

#### Working with Engage

To fully take advantage of deltaDNA's SmartAds you want to work with our Engage service.  The game can ask Engage if it should show an ad for this particular player.  Engage will tailor is response according to which campaigns are running and which segment this player is in.  You can try to build an ad from a `DDNAEngagement` object, it will only succeed if the Engage response allows it.  We can also add additional parameters into the Engage response which the game can use, perhaps to customise the reward for this player.  For more details on Engage checkout out the [analytics SDK](https://github.com/deltaDNA/ios-sdk).  

```objective-c
DDNAEngagement* engagement = [DDNAEngagement engagementWithDecisionPoint:@"showRewardedAd"];

[[DDNASDK sharedInstance] requestEngagement:engagement engagementHandler:^(DDNAEngagement* response) {

    DDNARewardedAd* rewardedAd = [DDNARewardedAd rewardedAdWithEngagement:response delegate:self];
    if (rewardedAd != nil) {

        // See what reward is being offered
        if (rewardedAd.parameters[@"rewardAmount"]) {
            NSInteger rewardAmount = [rewardedAd.parameters[@"rewardAmount"] integerValue];

            // Present offer to player...

            // If they choose to watch the add
            [rewardedAd showFromRootViewController:self];
        }
    }
}];
```

Checkout the included example project for more details.

#### Legacy Interface

Instead of creating `DDNAInterstitialAd` and `DDNARewardedAd` objects, it is still possible to use the `DDNASmartAds` object directly.

You can test if an interstitial ad is ready to be displayed with `-isInterstitialAdAvailable`.  Show an interstitial ad by calling `-showInterstitialAdFromRootViewController:`.  You can test if a rewarded ad is ready to be displayed with `-isRewardedAdAvailable`.  Show a rewarded ad by calling `-showRewardedAdFromRootViewController:`.

The additional show methods that use Decision Points are now deprecated, since they hide what Engage is returning which prevents you from controlling if and when to show the ad in your game.

You can also set the delegates for the DDNASmartAds object, so the SDK behaviour will be reported to you.

```objective-c
[DDNASmartAds sharedInstance].interstitialDelegate = self;
[DDNASmartAds sharedInstance].rewardedDelegate = self;
```

See [DDNASmartAds.h](https://github.com/deltaDNA/ios-smartads-sdk/blob/master/DeltaDNAAds/SmartAds/DDNASmartAds.h) for more details.

## License

The sources are available under the Apache 2.0 license.
