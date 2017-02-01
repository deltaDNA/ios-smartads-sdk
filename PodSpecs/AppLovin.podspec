Pod::Spec.new do |s|

s.name          = 'AppLovin'
s.version       = '3.5.2'
s.license       = 'COMMERCIAL'
s.summary       = 'AppLovin SDK.'

s.description   = <<-DESC
AppLovin SDK for iOS.
DESC

s.homepage      = 'https://www.applovin.com'
s.authors       = { 'AppLovin' => 'support@applovin.com' }
s.platform      = :ios, "8.0"
s.source        = { :http => 'https://s3.amazonaws.com/dd-smartads-3rd-party-sdks/AppLovin/3.5.2/AppLovinSDK.zip' }

s.vendored_frameworks = 'AppLovinSDK.framework'

s.frameworks    = 'AdSupport',
                  'AVFoundation',
                  'CoreGraphics',
                  'CoreMedia',
                  'CoreTelephony',
                  'StoreKit',
                  'SystemConfiguration',
                  'UIKit',
                  'WebKit'

end
