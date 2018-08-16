source 'git@corp-vm-gitlab:gamesanalytics/CocoaPods.git'
source 'https://github.com/deltaDNA/CocoaPods'
source 'https://github.com/CocoaPods/Specs'

workspace 'DeltaDNAAds'
project 'DeltaDNAAds'

# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

target 'ObjC SmartAds Example' do

    pod 'DeltaDNAAds', :path => './'

    target 'ObjC SmartAds Tests' do
        inherit! :search_paths

        # Pods for testing
        pod 'Specta', '~> 1.0'
        pod 'Expecta', '~> 1.0'
        pod 'OCHamcrest', '7.1.1'
        pod 'OCMockito', '5.1.0'
    end

end

target 'Swift SmartAds Example' do
    pod 'DeltaDNAAds', :path => './'
end

target 'Integration Tester' do
    pod 'DeltaDNAAds', :path => './'
    pod 'SwiftyJSON', '~> 4.1.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end


