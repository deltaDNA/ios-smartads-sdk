# Change Log

## [1.6.0](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.6.0)
### Added
- Support for Facebook rewarded video (see README for integration instructions).

## [1.5.2](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.5.2) (2017-09-20)
### Fixed
- Updated InMobi and HyprMX to latest versions.

## [1.5.1](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.5.1) (2017-09-14)
### Fixed
- Updated AdMob, MoPub, Flurry, MobFox, AdColony, Chartboost, AppLovin and IronSource to latest versions.

## [1.5.0](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.5.0) (2017-08-22)
### Added
- Send adSdkVersion when requesting configuration.
- Support for Tapjoy.
- Support for AdMob rewarded ads.
- Support for HyprMX.
- Support for LoopMe (requires min target iOS 9 for latest features).

### Fixed
- IronSource timing out during no fill cases.
- Updated Admob, MobFox, Vungle, IronSource, Facebook to latest versions.

## [1.4.5](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.4.5) (2017-06-21)
### Fixed
- Not instantiating Facebook adapter.
- AdColony reward callback ordering.
- Updated AdMob and MoPub ad networks to latest versions.

## [1.4.4](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.4.4) (2017-06-08)
### Fixed
- Improvements to UnityAds adapter.
- Updated AppLovin to 4.2.0.
- Ensure callbacks run on the main thread.

## [1.4.3](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.4.3) (2017-05-25)
### Fixed
- Thirdpresence adapter repeat event fix.
- Fix MobFox cocoapods version.

## [1.4.2](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.4.2) (2017-05-18)
### Fixed
- Improved adAgent behaviour
- Updated unit test libraries

## [1.4.1](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.4.1) (2017-05-12)
### Fixed
- Ensure ads are shown from the main thread.
- Updated ad networks.

## [1.4.0](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.4.0) (2017-04-17)
### Added
- Support for Supersonic (IronSource)
- Support for Facebook Audience Network

## [1.3.0](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.3.0) (2017-03-13)
### Added
- Support for AppLovin.
- Support for ThirdPresence.

## [1.2.7](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.2.7) (2017-01-30)
### Changed
- Updated MobFox to v3.1.5.
- Updated UnityAds to v2.0.8.

### Fixed
- Check dispatch queue isn't nil.
- Don't request more ads after session limit reached.

## [1.2.6.1](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.2.6.1) (2016-12-19)
### Fixed
- Fix UnityAds and CocoaPods.

## [1.2.6](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.2.6) (2016-12-19)
### Fixed
- Minor fixes to adapters.
- Updated ad networks.

## [1.2.5](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.2.5) (2016-12-08)
### Fixed
- Use cached Engage ad network configuration.

## [1.2.4](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.2.4) (2016-11-25)
### Fixed
- Prevent callbacks happening from wrong state.
- Record when no adProvider is available.

## [1.2.3](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.2.3) (2016-11-11)
### Changed
- iOS 8 minimum version.
- Use AdColony Aurora SDK for iOS 10 support.
- Updated Mobfox to v2.3.9.
- Simplified project layout.

### Fixed
- Truncate error message to 512 characters.
- Crash on UnityAds initialisation.
- Disable Mobfox requesting location services.
- Cancel timeout timer on ad result.

## [1.2.2](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.2.2) (2016-09-23)
### Changed
- Review and updated networks for iOS 10 support.  See README for details.
- Use UnityAds 2.0.

## [1.2.1](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.2.1) (2016-09-08)
### Changed
- Updated ad network dependencies.
- Reports no ad available when not loaded an ad yet.

## [1.2.0](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.2.0) (2016-05-27)
### Added
- An `-isInterstitialAdAllowed:` and `-isRewardedAdAllowed:` methods let you test if you will be allowed to show the ad.  These calls take the session limit and time limits into account, as well as an optional Engagement response.  They also test if an ad has loaded, so if YES is allowed you can call `-showInterstitialAdFromRootViewController:` and an ad will open, similarly for the rewarded methods.
- Calls '-registerForAds' again when a new session is started.

### Changed
- `-showInterstitialAdFromRootViewController:` no longer posts the `adShow` events, they are handled by `-isInterstitialAdAllowed:` and the same for the rewarded methods.

### Fixed
- The minimal time interval between ads is now respected.

## [1.1.0](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.1.0) (2016-04-29)
### Added
- `DDNAInterstitialAd` and `DDNARewardedAd` classes, which replace calling the `DDNASmartAds` class directly.  The idea is to decouple the call to Engage which currently takes place when you call `-showAdWithDecisionPoint:` from the `DDNASmartAds` object.  The caller attempts to construct an ad object from `DDNAEngagement`, so can test if Engage is allowing an ad for this player and handle the display appropriately.

### Changed
- A separate `DDNASmartAdsRegistrationDelegate` now handles the registration delegate methods from `DDNASmartAdsInterstitialDelegate` and `DDNASmartAdsRewardedDelegate`.
- `DDNASmartAdsInterstitialDelegate` `-didFailToOpenInterstitialAd` now returns the reason for the ad failing.  Similarly so does `-didFailToOpenRewardedAd` on `DDNASmartAdsRewardedDelegate`.
- Registering for ads will automatically try again in the background on if a connection error occurs.
- If Engage can't be reached and we show the ad anyway, the status is logged as 'fulfilled' instead of 'engage error'.
- Updated Amazon, MobFox and InMobi SDKs to latest version.

## [1.0.0](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.0.0) (2016-03-15)
Initial version 1.0 release.
