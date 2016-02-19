Pod::Spec.new do |s|
  s.name         = 'InMobi'
  s.version      = '5.2.0'
  s.summary      = 'InMobi iOS SDK'
  s.description  = <<-DESC
                   This is the InMobi iOS SDK 5.2.0. Please proceed to http://www.inmobi.com/sdk for more information.
                   DESC

  s.homepage     = 'http://www.inmobi.com/'
  s.license      = 'Custom'
  s.author       = { 'InMobi' => 'sdk-dev-support@inmobi.com' }
  s.platform     = :ios, '7.0'

  s.source       = { :http => 'https://dl.inmobi.com/SDK/InMobi-iOS-SDK-5.2.0.zip' }
  s.source_files  = 'Libs', 'Libs/**/*.{h,m}'
  s.public_header_files = 'Libs/**/*.h'
  s.vendored_libraries = 'Libs/libInMobi-5.2.0.a'
  s.frameworks = 'AdSupport',
                 'AudioToolbox',
                 'AVFoundation',
                 'CoreLocation',
                 'CoreTelephony',
                 'EventKit',
                 'EventKitUI',
                 'Foundation',
                 'MediaPlayer',
                 'MessageUI',
                 'Security',
                 'Social',
                 'StoreKit',
                 'SystemConfiguration',
                 'UIKit',
                 'SafariServices'

  s.libraries = 'sqlite3.0', 'c++'

end
