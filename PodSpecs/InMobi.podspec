Pod::Spec.new do |s|
  s.name         = "InMobi"
  s.version      = "5.1.0"
  s.summary      = "InMobi iOS SDK"
  s.description  = <<-DESC
                   InMobi iOS SDK.
                   DESC

  s.homepage     = "http://www.inmobi.com/"
  s.license      = { :type => "Commercial", :file => "LICENSE" }
  s.author             = { "InMobi" => "http://www.inmobi.com/company/contact/" }
  s.platform     = :ios
  
  s.source       = { :http => "https://s3.amazonaws.com/dd-smartads-3rd-party-sdks/InMobi/5.1.0/InMobi_iOS_SDK.zip" }
  s.source_files  = "Libs/Headers/*.h"
  s.public_header_files = "Libs/Headers/*.h"
  s.preserve_paths = "Libs/*.a"
  s.vendored_libraries = "Libs/libInMobi-5.1.0.a"
  
  s.frameworks = "AdSupport",
                 "AudioToolbox",
                 "AVFoundation",
                 "CoreLocation",
                 "CoreTelephony",
                 "EventKit",
                 "EventKitUI",
                 "MediaPlayer",
                 "MessageUI",
                 "Security",
                 "Social",
                 "StoreKit",
                 "SystemConfiguration",
                 "UIKit",
                 "SafariServices"

  s.libraries = "sqlite3.0", "c++"
  
  s.xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

end
