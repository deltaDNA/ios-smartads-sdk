Pod::Spec.new do |s|
    s.name = 'DeltaDNAAds'
    s.version = '1.8.0-beta.3'
    s.license = { :type => 'APACHE', :file => 'LICENSE' }
    s.summary = 'Smart advertising mediation from deltaDNA.'
    s.homepage = 'https://www.deltadna.com'
    s.authors = { 'David White' => 'david.white@deltadna.com' }
    s.source = { :git => 'git@corp-vm-gitlab:gamesanalytics/ios-smartads-sdk.git', :tag => s.version.to_s }
    s.platform = :ios, '8.0'
    s.requires_arc = true

    s.header_mappings_dir = 'DeltaDNAAds'

    s.dependency 'DeltaDNA', '~> 4.7.0-beta.2'

    s.subspec 'SmartAds' do |ss|
        ss.source_files = 'DeltaDNAAds/DeltaDNAAds.{h,m}', 'DeltaDNAAds/SmartAds/**/*.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/DeltaDNAAds.h', 'DeltaDNAAds/SmartAds/**/*.h'
    end

    s.subspec 'Dummy' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.source_files = 'DeltaDNAAds/Networks/Dummy/DDNASmartAdDummyAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Dummy/DDNASmartAdDummyAdapter.h'
    end

    s.subspec 'AdMob' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'Google-Mobile-Ads-SDK', '~>7.29.0'
        ss.source_files = 'DeltaDNAAds/Networks/AdMob/DDNASmartAdAdMob*.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/AdMob/DDNASmartAdAdMob*.h'
        ss.frameworks = ['AdSupport','SafariServices']
    end

    s.subspec 'Amazon' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'AmazonAds', '2.2.15.1'
        ss.source_files = 'DeltaDNAAds/Networks/Amazon/DDNASmartAdAmazonAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Amazon/DDNASmartAdAmazonAdapter.h'
    end

    s.subspec 'MoPub' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'mopub-ios-sdk/Core', '~>4.20.1'
        ss.source_files = 'DeltaDNAAds/Networks/MoPub/DDNASmartAdMoPubAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/MoPub/DDNASmartAdMoPubAdapter.h'
    end

    s.subspec 'Flurry' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'Flurry-iOS-SDK/FlurryAds', '~>8.4.0'
        ss.source_files = 'DeltaDNAAds/Networks/Flurry/DDNASmartAdFlurry*.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Flurry/DDNASmartAdFlurry*.h'
    end

    s.subspec 'InMobi' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'InMobiSDK', '~>7.0.0'
        ss.source_files = 'DeltaDNAAds/Networks/InMobi/DDNASmartAdInMobi*.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/InMobi/DDNASmartAdInMobi*.h'
    end

    s.subspec 'MobFox' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'MobFoxSDK', '~>3.2'
        ss.source_files = 'DeltaDNAAds/Networks/MobFox/DDNASmartAdMobFoxAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/MobFox/DDNASmartAdMobFoxAdapter.h'
    end

    s.subspec 'AdColony' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'AdColony', '~>3.3.0'
        ss.source_files = 'DeltaDNAAds/Networks/AdColony/DDNASmartAdAdColonyAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/AdColony/DDNASmartAdAdColonyAdapter.h'
    end

    s.subspec 'Chartboost' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'ChartboostSDK', '~>7.1.0'
        ss.source_files = 'DeltaDNAAds/Networks/Chartboost/DDNASmartAdChartboost*.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Chartboost/DDNASmartAdChartboost*.h'
    end

    s.subspec 'Vungle' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'VungleSDK-iOS', '~>5.4.0'
        ss.source_files = 'DeltaDNAAds/Networks/Vungle/DDNASmartAdVungleAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Vungle/DDNASmartAdVungleAdapter.h'
    end

    s.subspec 'UnityAds' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'UnityAds', '~>2.2.0'
        ss.source_files = 'DeltaDNAAds/Networks/UnityAds/DDNASmartAdUnityAdsAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/UnityAds/DDNASmartAdUnityAdsAdapter.h'
    end

    s.subspec 'ThirdPresence' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'thirdpresence-ad-sdk-ios', '~>1.5.11'
        ss.source_files = 'DeltaDNAAds/Networks/ThirdPresence/DDNASmartAdThirdPresenceAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/ThirdPresence/DDNASmartAdThirdPresenceAdapter.h'
    end

    s.subspec 'AppLovin' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'AppLovinSDK', '~>4.8.4'
        ss.source_files = 'DeltaDNAAds/Networks/AppLovin/DDNASmartAdAppLovinAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/AppLovin/DDNASmartAdAppLovinAdapter.h'
    end

    s.subspec 'IronSource' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'IronSourceSDK', '~>6.7.6.0'
        ss.source_files = 'DeltaDNAAds/Networks/IronSource/DDNASmartAdIronSource*.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/IronSource/DDNASmartAdIronSource*.h'
    end

    s.subspec 'Facebook' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'FBAudienceNetwork', '~>4.27.1'
        ss.source_files = 'DeltaDNAAds/Networks/Facebook/DDNASmartAdFacebook*.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Facebook/DDNASmartAdFacebook*.h'
    end

    s.subspec 'Tapjoy' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'TapjoySDK', '~>11.11.0'
        ss.source_files = 'DeltaDNAAds/Networks/Tapjoy/DDNASmartAdTapjoyAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Tapjoy/DDNASmartAdTapjoyAdapter.h'
    end

    s.subspec 'HyprMX' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'HyprMX', '110'
        ss.source_files = 'DeltaDNAAds/Networks/HyprMX/DDNASmartAdHyprMXAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/HyprMX/DDNASmartAdHyprMXAdapter.h'
    end

    s.subspec 'LoopMe' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'LoopMeSDK', '~>6.0'
        ss.source_files = 'DeltaDNAAds/Networks/LoopMe/DDNASmartAdLoopMeAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/LoopMe/DDNASmartAdLoopMeAdapter.h'
    end

    s.subspec 'MachineZone' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'FMAdZone', '1.3.0'
        ss.source_files = 'DeltaDNAAds/Networks/MachineZone/DDNASmartAdMachineZone*.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/MachineZone/DDNASmartAdMachineZone*.h'
    end
end
