Pod::Spec.new do |s|

    s.name         = 'UnityAds'
    s.version      = '1.5.6'
    s.license      = { :type => 'Apache License, Version 2.0', :text => 'See http://www.apache.org/licenses/LICENSE-2.0.html' }
    s.summary      = 'Unity Ads SDK for iOS.'

    s.description  = <<-DESC
                     Unity Ads is a monetization tool that allows you to display video trailers of other games to your users,
                     earn money with each view, and reward users with a virtual item. To monetize your users with Unity Ads,
                     the product must be integrated into your game. This document will guide you through that process.
                     DESC

    s.homepage     = 'http://unityads.unity3d.com'
    s.authors      = { 'Unity Technologies' => 'unityads-support@unity3d.com' }
    s.platform     = :ios
    s.source       = { :git => 'https://github.com/Applifier/unity-ads-sdk.git', :tag => s.version.to_s }

    s.vendored_frameworks = 'UnityAds.framework'
    s.resources = 'UnityAds.bundle'
    s.frameworks = 'AdSupport',
                   'AVFoundation',
                   'CoreMedia',
                   'CoreTelephony',
                   'SystemConfiguration',
                   'StoreKit'

    # Silence Clang warnings: https://forums.developer.apple.com/thread/17921
    s.xcconfig = { 'GCC_GENERATE_DEBUGGING_SYMBOLS' => 'NO' }

end
