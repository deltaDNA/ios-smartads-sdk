Pod::Spec.new do |s|
    s.name = 'DeltaDNAAds'
    s.version = '1.2.3'
    s.license = { :type => 'APACHE', :file => 'LICENSE' }
    s.summary = 'Smart advertising mediation from deltaDNA.'
    s.homepage = 'https://www.deltadna.com'
    s.authors = { 'David White' => 'david.white@deltadna.com' }
    s.source = { :git => 'https://github.com/deltaDNA/ios-smartads-sdk.git', :tag => s.version.to_s }
    s.platform = :ios, '8.0'
    s.requires_arc = true

    s.header_mappings_dir = 'DeltaDNAAds'

    s.dependency 'DeltaDNA', '~> 4.2'

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
        ss.dependency 'Google-Mobile-Ads-SDK', '~>7.11'
        ss.source_files = 'DeltaDNAAds/Networks/AdMob/DDNASmartAdAdMobAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/AdMob/DDNASmartAdAdMobAdapter.h'
        ss.frameworks = ['AdSupport','SafariServices']
    end

    s.subspec 'Amazon' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'AmazonAd', '~>2.2'
        ss.source_files = 'DeltaDNAAds/Networks/Amazon/DDNASmartAdAmazonAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Amazon/DDNASmartAdAmazonAdapter.h'
    end

    s.subspec 'MoPub' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'mopub-ios-sdk', '~>4.9'
        ss.source_files = 'DeltaDNAAds/Networks/MoPub/DDNASmartAdMoPubAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/MoPub/DDNASmartAdMoPubAdapter.h'
    end

    s.subspec 'Flurry' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'Flurry-iOS-SDK/FlurryAds', '~>7.6'
        ss.source_files = 'DeltaDNAAds/Networks/Flurry/DDNASmartAdFlurry*.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Flurry/DDNASmartAdFlurry*.h'
    end

    s.subspec 'InMobi' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'InMobiSDK', '~>6.0'
        ss.source_files = 'DeltaDNAAds/Networks/InMobi/DDNASmartAdInMobi*.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/InMobi/DDNASmartAdInMobi*.h'
    end

    s.subspec 'MobFox' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'MobFox', '2.3.9'
        ss.source_files = 'DeltaDNAAds/Networks/MobFox/DDNASmartAdMobFoxAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/MobFox/DDNASmartAdMobFoxAdapter.h'
    end

    s.subspec 'AdColony' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'AdColony', '~>3.0'
        ss.source_files = 'DeltaDNAAds/Networks/AdColony/DDNASmartAdAdColonyAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/AdColony/DDNASmartAdAdColonyAdapter.h'
    end

    s.subspec 'Chartboost' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'ChartboostSDK', '~>6.4'
        ss.source_files = 'DeltaDNAAds/Networks/Chartboost/DDNASmartAdChartboost*.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Chartboost/DDNASmartAdChartboost*.h'
    end

    s.subspec 'Vungle' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'VungleSDK-iOS', '~>4.0'
        ss.source_files = 'DeltaDNAAds/Networks/Vungle/DDNASmartAdVungleAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Vungle/DDNASmartAdVungleAdapter.h'
    end

    s.subspec 'UnityAds' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'UnityAds', '~>2.0'
        ss.source_files = 'DeltaDNAAds/Networks/UnityAds/DDNASmartAdUnityAdsAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/UnityAds/DDNASmartAdUnityAdsAdapter.h'
    end

end
