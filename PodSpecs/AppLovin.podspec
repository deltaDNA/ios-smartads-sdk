Pod::Spec.new do |s|

s.name          = 'AppLovin'
s.version       = '3.4.3'
s.license       = 'COMMERCIAL'
s.summary       = 'Unity Ads SDK for iOS.'

s.description   = <<-DESC
AppLovin SDK.
DESC

s.homepage      = 'https://www.applovin.com'
s.authors       = { 'AppLovin' => 'support@applovin.com' }
s.platform      = :ios, "7.0"
s.source        = { :http => 'https://s3.amazonaws.com/dd-smartads-3rd-party-sdks/AppLovin/3.4.3/applovin-ios-sdk-3.4.3.tar.bz2' }

s.source_files  = 'headers'
s.preserve_paths = 'libAppLovinSdk.a'
s.frameworks    = 'AdSupport',
                  'AVFoundation',
                  'CoreGraphics',
                  'CoreMedia',
                  'CoreTelephony',
                  'StoreKit',
                  'SystemConfiguration',
                  'UIKit'

s.libraries     = 'AppLovinSdk'
s.xcconfig      = { "LIBRARY_SEARCH_PATHS" => "$(PODS_ROOT)/AppLovin/" }

end
