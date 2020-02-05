# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

workspace 'YouboraIMAAdapter.xcworkspace'

def common_pod
    pod 'YouboraLib', '~> 6.5.0'
end

def common_example_pod
    common_pod
    pod 'YouboraAVPlayerAdapter', '~>6.5.0'
    pod 'YouboraConfigUtils', '~>1.1.0'
end

def google_ima_pod_ios
    pod 'GoogleAds-IMA-iOS-SDK', '~> 3.6'
end

target 'IMAAdapterExample' do
    project 'Example/IMAAdapterExample.xcodeproj'
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!
    
    # Pods for IMAAdapterExample
    common_example_pod
    google_ima_pod_ios
    
end

target 'IMAAdapterExampleDAI' do
    project 'Example-DAI/IMAAdapterExampleDAI.xcodeproj'
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!
    
    # Pods for IMAAdapterExampleDAI
    common_example_pod
    google_ima_pod_ios
    pod 'google-cast-sdk', '~>3.2.0'
end

target 'IMAAdapterExampleDAItvOS' do
    platform :tvos, '9.0'
    project 'Example-DAI-tvOS/IMAAdapterExampleDAItvOS.xcodeproj'
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!
    
    # Pods for IMAAdapterExampleDAItvOS
    common_example_pod
end

target 'YouboraIMAAdapter' do
    project 'YouboraIMAAdapter.xcodeproj'
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!
    
    # Pods for YouboraIMAAdapter
    common_pod
    google_ima_pod_ios
end

target 'YouboraIMAAdapter tvOS' do
    platform :tvos, '9.0'
    project 'YouboraIMAAdapter.xcodeproj'
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!
    # Pods for YouboraIMAAdapter
    common_pod
end
