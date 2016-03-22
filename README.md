![deltaDNA logo](https://deltadna.com/wp-content/uploads/2015/06/deltadna_www@1x.png)

## deltaDNA SmartAds iOS SDK

The deltaDNA SmartAds SDK provides your iOS game with access to our intelligent ad mediation platform.  It supports both interstitial and rewarded type ads.

SmartAds is currently an Enterprise only feature.  SmartAds On Demand will be available soon, meanwhile once you've completed the integration steps below, contact <louise.cameron@deltadna.com> to enable the service.

### Installation with CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies using 3rd party libraries.  This enables SmartAds to select which ad networks are supported in a straightforward way.

#### Podfile

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/deltaDNA/CocoaPods.git'

platform :ios, '7.0'

pod 'DeltaDNAAds', '~> 1.0'
```

The deltaDNA SDKs are available from our private spec repository, its url must be added as a source to your podfile.  DeltaDNAAds depends on our analytics SDK, which will also be installed.  

The above example will install all the ad networks we support.  To install just a subset declare each subspec separately in your podfile, for example:

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
[[DDNASmartAds sharedInstance] registerForAds];
```

You can test if an interstitial ad is ready to be displayed with `isInterstitialAdAvailable`.

Show an interstitial ad by calling `showInterstitialAdFromRootViewController:`.

You can test if a rewarded ad is ready to be displayed with `isRewardedAdAvailable`.

Show a rewarded ad by calling `showRewardedAdFromRootViewController:`.

You will likely want to set the delegates for the DDNASmartAds object, so the SDK behaviour will be reported to you.

```objective-c
[DDNASmartAds sharedInstance].interstitialDelegate = self;
[DDNASmartAds sharedInstance].rewardedDelegate = self;
```

See [DDNASmartAds.h](https://github.com/deltaDNA/ios-smartads-sdk/blob/master/DeltaDNAAds/SmartAds/DDNASmartAds.h) for more details.

## License

The sources are available under the Apache 2.0 license.
