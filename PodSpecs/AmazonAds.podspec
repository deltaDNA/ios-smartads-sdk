Pod::Spec.new do |s|

    s.name         = "AmazonAds"
    s.version      = "2.2.13"
    s.summary      = "Amazon Ads iOS SDK"

    s.description  = <<-DESC
                     Amazon Ads iOS SDK.
                     DESC

    s.homepage     = "https://developer.amazon.com/public/apis/earn/mobile-ads/ios"

    s.license      = { :type => 'Commercial', :file => 'NOTICE.txt' }
    s.author       = { "Amazon.com, Inc." => "https://developer.amazon.com/public/support/contact/contact-us" }

    s.platform     = :ios, "7.0"

    s.source       = { :http => "https://s3.amazonaws.com/dd-smartads-3rd-party-sdks/AmazonAds/2.2.13/AmazonAds.zip" }
    s.vendored_frameworks = "AmazonAd.framework"

    s.frameworks = "AdSupport",
                   "CoreLocation",
                   "SystemConfiguration",
                   "CoreTelephony",
                   "MediaPlayer",
                   "EventKit",
                   "EventKitUI",
                   "StoreKit"

    # Silence Clang warnings: https://forums.developer.apple.com/thread/17921
    s.xcconfig = { 'GCC_GENERATE_DEBUGGING_SYMBOLS' => 'NO' }

end
