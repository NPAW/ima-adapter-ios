# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

workspace 'YouboraIMAAdapter.xcworkspace'

target 'YouboraIMAAdapter' do
    project 'YouboraIMAAdapter.xcodeproj'
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!
    
    # Pods for YouboraAVPlayerAdapter
    #pod 'YouboraLib',:path => '../lib-plugin-ios'
    pod 'YouboraLib', '~> 6.0.3'
    pod 'GoogleAds-IMA-iOS-SDK', '~> 3.6'
end

target 'IMAAdapterExample' do
    project 'Example/IMAAdapterExample.xcodeproj'
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!
    
    # Pods for AVPlayerAdapterExample
    #pod 'YouboraLib',:path => '../lib-plugin-ios'
    #pod 'YouboraLib', '~> 6.0.2'
    pod 'GoogleAds-IMA-iOS-SDK', '~> 3.6'
    pod 'YouboraAVPlayerAdapter', '~> 6.0.1'
end
