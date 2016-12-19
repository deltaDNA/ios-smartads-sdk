# Change Log

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
