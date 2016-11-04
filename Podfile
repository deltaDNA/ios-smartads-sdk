source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/deltaDNA/CocoaPods'

workspace 'DeltaDNAAds'
project 'DeltaDNAAds'

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SmartAds iOS Example' do
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    # use_frameworks!
    
    # Pods for SmartAds iOS Example
    pod 'DeltaDNAAds', :path => './'
    
    target 'SmartAds iOS Tests' do
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
