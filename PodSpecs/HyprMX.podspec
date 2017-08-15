Pod::Spec.new do |s|

s.name          = 'HyprMX'
s.version       = '93'
s.license       = { :type => 'Commercial', :file => 'LICENSE.txt' }
s.summary       = 'HyprMX SDK.'

s.description   = <<-DESC
HyprMX SDK for iOS.
DESC

s.homepage      = 'https://hyprmx.com/'
s.authors       = { 'HyprMX' => 'support@hyprmx.com' }
s.platform      = :ios, "9.0"
s.source        = { :http => "https://s3.amazonaws.com/dd-smartads-3rd-party-sdks/HyprMX/#{s.version}/HyprMXSDK.zip" }

s.vendored_frameworks = 'HyprMX.framework'

s.frameworks    = 'AdSupport',
'AVFoundation',
'CoreGraphics',
'CoreTelephony',
'Foundation',
'MessageUI',
'MobileCoreServices',
'QuartzCore',
'SystemConfiguration',
'UIKit',
'EventKit',
'EventKitUI'

s.weak_frameworks = 'WebKit',
'SafariServices',
'StoreKit'

s.libraries = 'xml2'

s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }

end
