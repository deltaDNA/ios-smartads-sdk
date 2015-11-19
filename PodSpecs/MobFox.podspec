Pod::Spec.new do |s|
  s.name         = "MobFox"
  s.version      = "1.0.4"
  s.summary      = "MobFox Ads SDK"
  s.description  = <<-DESC
                   MobFox Ads SDK.
                   DESC

  s.homepage     = "http://www.mobfox.com/"
  s.license      = "MIT"
  s.author       = "MobFox"
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/mobfox/MobFox-iOS-SDK-Core-Lib.git", :tag => "v1.0.4" }

  s.preserve_paths = "MobFoxSDKCore.embeddedframework/MobFoxSDKCore.framework"
  s.public_header_files = "MobFoxSDKCore.embeddedframework/MobFoxSDKCore.framework/Headers/*.h"
  s.resources = "MobFoxSDKCore.embeddedframework/MobFoxSDKCore.framework/MobFoxSDKCore.bundle"
  s.vendored_frameworks = "MobFoxSDKCore.embeddedframework/MobFoxSDKCore.framework"

  s.requires_arc = true

  s.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "\"$(PODS_ROOT)/MobFox/**\"" }
  
end
