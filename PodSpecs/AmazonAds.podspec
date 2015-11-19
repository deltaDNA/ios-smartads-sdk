Pod::Spec.new do |s|

    s.name         = "AmazonAds"
    s.version      = "2.2.11"
    s.summary      = "Amazon Ads iOS SDK"

    s.description  = <<-DESC
                     Amazon Ads iOS SDK.
                     DESC

    s.homepage     = "https://developer.amazon.com/public/apis/earn/mobile-ads/ios"

    s.license      = { :type => 'Commercial', :file => 'NOTICE.txt' }
    s.author       = { "Amazon.com, Inc." => "https://developer.amazon.com/public/support/contact/contact-us" }

    s.platform     = :ios

    s.source       = { :http => "https://s3.amazonaws.com/dd-smartads-3rd-party-sdks/AmazonAds/2.2.11/AmazonAds.zip" }
    s.vendored_frameworks = "AmazonAd.framework"

    s.frameworks = "AdSupport",
                   "CoreLocation",
                   "SystemConfiguration",
                   "CoreTelephony",
                   "CoreGraphics",
                   "MediaPlayer",
                   "EventKit",
                   "EventKitUI"

end