Pod::Spec.new do |s|

  s.name         = "YouboraIMAAdapter"
  s.version      = "6.5.10"

  # Metadata
  s.summary      = "Library required to track IMA Ads on Youbora"

  s.description  = "<<-DESC
                    YouboraIMAAdaoter is a library created by Nice People at Work.
                     DESC"

  s.homepage     = "http://developer.nicepeopleatwork.com/"

  s.license      = { :type => "MIT", :file => "LICENSE.md" }

  s.author             = { "Nice People at Work" => "support@nicepeopleatwork.com" }

  # Platforms
  s.ios.deployment_target = "10.0"
  s.tvos.deployment_target = "10.0"

  # Swift version
  s.swift_version = "4.0", "4.1", "4.2", "4.3", "5.0", "5.1"

  # Source Location
  s.source       = { :git => 'https://bitbucket.org/npaw/ima-adapter-ios.git', :tag => s.version}

  # Source files
  s.source_files  = 'YouboraIMAAdapter/**/*.{h,m,swift}'
  
   # Public header files
  s.public_header_files = "YouboraIMAAdapter/**/*.h"

  s.ios.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64',
  }
  s.ios.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64',
  }

  s.tvos.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64',
  }
  
  s.tvos.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64',
  }

  # Project settings
  s.requires_arc = true
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) YOUBORAIMAADAPTER_VERSION=' + s.version.to_s }

  s.dependency 'YouboraLib', "~> 6.5.0"
  s.ios.dependency 'GoogleAds-IMA-iOS-SDK', '~> 3.13'
  s.tvos.dependency 'GoogleAds-IMA-tvOS-SDK', '~> 4.3'
end
