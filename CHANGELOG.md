# Change Log

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
