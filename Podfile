# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

workspace 'YouboraIMAAdapter.xcworkspace'

target 'YouboraIMAAdapter' do
    project 'YouboraIMAAdapter.xcodeproj'
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!
    
    # Pods for YouboraAVPlayerAdapter
    pod 'YouboraLib',:path => '../lib-plugin-ios'
    #pod 'YouboraLib', '~> 6.0.5-beta'
    pod 'GoogleAds-IMA-iOS-SDK', '~> 3.6'
end

target 'IMAAdapterExample' do
    project 'Example/IMAAdapterExample.xcodeproj'
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!
    
    # Pods for AVPlayerAdapterExample
    pod 'YouboraLib',:path => '../lib-plugin-ios'
    #pod 'YouboraLib', '~> 6.0.5-beta'
    pod 'GoogleAds-IMA-iOS-SDK', '~> 3.6'
    pod 'YouboraAVPlayerAdapter', :git => 'https://NPAWEnrique@bitbucket.org/npaw/avplayer-adapter-ios.git', :commit => 'f86daf7e18fb911982a3e511dd695644bd1d5106'
end
