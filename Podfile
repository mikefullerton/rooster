
source 'https://github.com/CocoaPods/Specs.git'

project 'Rooster'
inhibit_all_warnings!
use_frameworks!
use_modular_headers!

#supports_swift_versions '>= 5.0', '< 6.0'

#target 'Rooster' do
#   platform :ios, '14.0'
#end

target 'RoosterAppKitPlugin' do
  platform :osx, '11.0'
  pod 'Sparkle'
  
  post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
        config.build_settings.delete 'MACOSX_DEPLOYMENT_TARGET'
        config.build_settings.delete 'ARCHS'
      
    end
  end
end
end

