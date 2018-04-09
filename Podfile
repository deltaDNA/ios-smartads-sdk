source 'https://github.com/deltaDNA/CocoaPods'
source 'https://github.com/CocoaPods/Specs'

workspace 'DeltaDNAAds'
project 'DeltaDNAAds'

# Uncomment the next line to define a global platform for your project
platform :ios, '8.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

# Workaround Cocoapods v1.2.1 preventing Swift project using a child without use_frameworks! flag
install! 'cocoapods',
         :integrate_targets => false,
         :deterministic_uuids => true

target 'ObjC SmartAds Example' do
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    # use_frameworks!

    # Pods for SmartAds iOS Example
    pod 'DeltaDNA', git: 'git@corp-vm-gitlab:gamesanalytics/ios-sdk-v4.git', branch: 'develop'
    pod 'DeltaDNAAds', :path => './'

    target 'ObjC SmartAds Tests' do
        inherit! :search_paths

        # Pods for testing
        pod 'Specta', '~> 1.0'
        pod 'Expecta', '~> 1.0'
        pod 'OCHamcrest', '7.0.2'
        pod 'OCMockito', '5.0.1'
    end

end

# Framework with all pods statically linked for Swift example
target 'DeltaDNAAds' do
    pod 'DeltaDNAAds', :path => './'
end

target 'Integration Tester' do
    use_frameworks!
    pod 'SwiftyJSON', '~> 4.0.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end


