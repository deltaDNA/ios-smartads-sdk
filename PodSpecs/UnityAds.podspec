Pod::Spec.new do |s|

    s.name         = 'UnityAds'
    s.version      = '2.0.6'
    s.license      = 'UNKNOWN'
    s.summary      = 'Unity Ads SDK for iOS.'

    s.description  = <<-DESC
                     Unity Ads is a monetization tool that allows you to display video trailers of other games to your users,
                     earn money with each view, and reward users with a virtual item. To monetize your users with Unity Ads,
                     the product must be integrated into your game. This document will guide you through that process.
                     DESC

    s.homepage     = 'https://unity3d.com/services/ads'
    s.authors      = { 'Unity Technologies' => 'unityads-support@unity3d.com' }
    s.platform     = :ios, "7.0"
    s.source       = { :http => 'https://github.com/Unity-Technologies/unity-ads-ios/releases/download/2.0.6/UnityAds.framework.zip' }

    s.vendored_frameworks = 'UnityAds.framework'

    s.frameworks = 'AdSupport'

end
