source 'https://github.com/deltaDNA/CocoaPods'
source 'https://github.com/CocoaPods/Specs'

workspace 'DeltaDNAAds'
project 'DeltaDNAAds'

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SmartAds iOS Example' do
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    # use_frameworks!

    # Pods for SmartAds iOS Example
    pod 'DeltaDNAAds', :path => './', :subspecs => ['ThirdPresence']

    target 'SmartAds iOS Tests' do
        # This breaks since CocoaPods v1.2 with missing frameworks, but links correctly without
        # although I should need it.
        # Think it's related to https://github.com/CocoaPods/CocoaPods/issues/6065
        inherit! :search_paths
        
        # Pods for testing
        pod 'Specta', '~> 1.0'
        pod 'Expecta', '~> 1.0'
        pod 'OCMockito', '~> 1.0'
    end

end

# Enable extra logging
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'DeltaDNA' || target.name == 'DeltaDNAAds'
            target.build_configurations.each do |config|
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'DDNA_DEBUG=1'
            end
        end
    end
end
