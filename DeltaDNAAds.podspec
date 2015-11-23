Pod::Spec.new do |s|
    s.name = 'DeltaDNAAds'
    s.version = '0.9.0-beta.2'
    s.license = { :type => 'APACHE', :file => 'LICENSE' }
    s.summary = 'Smart advertising mediation from deltaDNA.'
    s.homepage = 'https://www.deltadna.com'
    s.authors = { 'David White' => 'david.white@deltadna.com' }
    s.source = { :git => 'https://github.com/deltaDNA/ios-smartads-sdk.git', :tag => s.version }
    s.platform = :ios, '7.0'
    s.requires_arc = true

#    s.public_header_files = 'DeltaDNAAds/*.h'
#    s.source_files = 'DeltaDNAAds/*.{h,m}'

#s.header_dir = 'DeltaDNAAds'
    s.header_mappings_dir = 'DeltaDNAAds'

    s.dependency 'DeltaDNA', '~> 4.0.0-beta.1'
    
    s.subspec 'SmartAds' do |ss|
        ss.source_files = 'DeltaDNAAds/*.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/*.h'
    end
    
    s.subspec 'Dummy' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.source_files = 'DeltaDNAAds/Networks/Dummy/DDNASmartAdDummyAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Dummy/DDNASmartAdDummyAdapter.h'
    end
    
    s.subspec 'AdMob' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'Google-Mobile-Ads-SDK', '~>7.5.0'
        ss.source_files = 'DeltaDNAAds/Networks/AdMob/DDNASmartAdAdMobAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/AdMob/DDNASmartAdAdMobAdapter.h'
    end
    
    s.subspec 'Amazon' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'AmazonAds', '~>2.2.0'
        ss.source_files = 'DeltaDNAAds/Networks/Amazon/DDNASmartAdAmazonAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Amazon/DDNASmartAdAmazonAdapter.h'
    end
    
    s.subspec 'MoPub' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'mopub-ios-sdk', '~>4.0'
        ss.source_files = 'DeltaDNAAds/Networks/MoPub/DDNASmartAdMoPubAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/MoPub/DDNASmartAdMoPubAdapter.h'
    end
    
    s.subspec 'Flurry' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'Flurry-iOS-SDK/FlurryAds', '~>7.0'
        ss.source_files = 'DeltaDNAAds/Networks/Flurry/DDNASmartAdFlurryAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/Flurry/DDNASmartAdFlurryAdapter.h'
    end
    
    s.subspec 'InMobi' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'InMobi', '~>5.0'
        ss.source_files = 'DeltaDNAAds/Networks/InMobi/DDNASmartAdInMobiAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/InMobi/DDNASmartAdInMobiAdapter.h'
    end
    
    s.subspec 'MobFox' do |ss|
        ss.dependency 'DeltaDNAAds/SmartAds'
        ss.dependency 'MobFox', '~>1.0'
        ss.dependency 'DeltaDNAAds/AdMob'
        ss.source_files = 'DeltaDNAAds/Networks/MobFox/DDNASmartAdMobFoxAdapter.{h,m}'
        ss.public_header_files = 'DeltaDNAAds/Networks/MobFox/DDNASmartAdMobFoxAdapter.h'
    end

end
