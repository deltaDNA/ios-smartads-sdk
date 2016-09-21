Pod::Spec.new do |s|
  s.name         = "MobFox"
  s.version      = "2.3.4"
  s.summary      = "The MobFox iOS SDK."
  s.description  = <<-DESC
                   MobFox's iOS SDK Core.
                   DESC

  s.homepage     = "http://www.mobfox.com/"
  s.license      = "MIT"
  s.author         = { "Matomy/MobFox" => "itamar.n@matomy.com" }
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/mobfox/MobFox-iOS-SDK-Core-Lib.git", :tag => "v#{s.version}" }

  s.preserve_paths = "MobFoxSDKCore.embeddedframework/MobFoxSDKCore.framework"
  s.public_header_files = "MobFoxSDKCore.embeddedframework/MobFoxSDKCore.framework/Headers/*.h"
  s.source_files = "MobFoxSDKCore.embeddedframework/MobFoxSDKCore.framework/Headers/*.h"
  s.resources = "MobFoxSDKCore.embeddedframework/MobFoxSDKCore.bundle"
  s.vendored_frameworks = "MobFoxSDKCore.embeddedframework/MobFoxSDKCore.framework"
  s.frameworks = "AdSupport"

  s.requires_arc = true

  # Silence Clang warnings: https://forums.developer.apple.com/thread/17921
  s.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "\"$(PODS_ROOT)/MobFox/**\"",
                 "GCC_GENERATE_DEBUGGING_SYMBOLS" => "NO" }

end
