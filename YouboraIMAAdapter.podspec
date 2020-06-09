Pod::Spec.new do |s|

  s.name         = "YouboraIMAAdapter"
  s.version      = "6.5.5"

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
  s.tvos.deployment_target = "9.1"

  # Swift version
  s.swift_version = "4.0", "4.1", "4.2", "4.3", "5.0", "5.1"

  # Source Location
  s.source       = { :git => 'https://bitbucket.org/npaw/ima-adapter-ios.git', :tag => s.version}

  # Source files
  s.source_files  = 'YouboraIMAAdapter/**/*.{h,m,swift}'
  
   # Public header files
  s.public_header_files = "YouboraIMAAdapter/**/*.h"

  # Project settings
  s.requires_arc = true
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) YOUBORAIMAADAPTER_VERSION=' + s.version.to_s }

  s.dependency 'YouboraLib', "~> 6.5.0"
  s.ios.dependency 'GoogleAds-IMA-iOS-SDK', '~> 4.11.4'
  s.tvos.dependency 'GoogleAds-IMA-tvOS-SDK', '~> 4.2'
end
