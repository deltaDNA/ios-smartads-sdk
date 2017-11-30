Pod::Spec.new do |s|

s.name          = 'FMAdZone'
s.version       = '1.3.0'
s.license       = 'Commercial'
s.summary       = 'Fractional Media SDK.'

s.description   = <<-DESC
Fractional Media SDK for iOS.
DESC

s.homepage      = 'http://fractionalmedia.com/'
s.author        = 'FractionalMedia'
s.platform      = :ios, "8.0"
s.source        = { :http => "https://s3.amazonaws.com/dd-smartads-3rd-party-sdks/FractionalMedia/#{s.version}/FractionalMedia.zip" }

s.source_files = "**/include/FMAdZone/*"
s.public_header_files = "**/include/FMAdZone/*.h"
s.vendored_libraries = '**/lib-adzone-ios-core-v1.3.0.a'
s.resource = 'FMAdZoneResources.bundle'

s.frameworks = 'AVFoundation',
	'CoreGraphics',
	'CoreLocation',
	'CoreMedia',
	'CoreTelephony',
	'Foundation',
	'MediaPlayer',
	'QuartzCore',
	'SystemConfiguration',
	'UIKit',
	'SafariServices'

s.weak_frameworks =
	'AdSupport', 
	'WebKit',
	'StoreKit'

#s.libraries = 'xml2'

#s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }

end

