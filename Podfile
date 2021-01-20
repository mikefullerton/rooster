
source 'https://github.com/CocoaPods/Specs.git'

project 'Rooster'
#inhibit_all_warnings!
use_frameworks!
use_modular_headers!

#supports_swift_versions '>= 5.0', '< 6.0'

#target 'Rooster' do
#   platform :ios, '14.0'
#end

target 'Rooster-macOS' do
  platform :osx, '11.0'
  pod 'Sparkle', '~> 1.0'
  
  post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
        config.build_settings['EXCLUDED_ARCHS'] = 'arm64e'
        config.build_settings['SDKROOT'] = 'macosx.internal'
        config.build_settings['ARCHS'] = '$(ARCHS_STANDARD)'
        config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = 11.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = 14.0
    end
  end
end
end

