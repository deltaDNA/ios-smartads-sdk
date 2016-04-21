# Change Log

## [Unreleased]() ()
### Added
- `DDNAInterstitialAd` and `DDNARewardedAd` classes, which replace calling the `DDNASmartAds` class directly.  The idea is to decouple the call to Engage which currently takes place when you call `-showAdWithDecisionPoint:` from the `DDNASmartAds` object.  The caller attempts to construct an ad object from `DDNAEngagement`, so can test if Engage is allowing an ad for this player and handle the display appropriately.

### Changed
- A separate `DDNASmartAdsRegistrationDelegate` now handles the registration delegate methods from `DDNASmartAdsInterstitialDelegate` and `DDNASmartAdsRewardedDelegate`.
- `DDNASmartAdsInterstitialDelegate` `-didFailToOpenInterstitialAd` now returns the reason for the ad failing.  Similarly so does `-didFailToOpenRewardedAd` on `DDNASmartAdsRewardedDelegate`.

## [1.0.0](https://github.com/deltaDNA/ios-smartads-sdk/releases/tag/1.0.0) (2016-03-15)
Initial version 1.0 release.
