# Uncomment the next line to define a global platform for your project
workspace 'YouboraIMAAdapter.xcworkspace'

platform :ios, '12.0'

def common_pod
    pod 'YouboraLib', '~> 6.6'
end

def common_example_pod
    common_pod
    pod 'YouboraConfigUtils', '~>1.1.0'
    pod 'YouboraAVPlayerAdapter', '~> 6.6'
end

def google_ima_pod_ios
    pod 'GoogleAds-IMA-iOS-SDK', '~> 3.16'
end

def google_ima_pod_tvos
    pod 'GoogleAds-IMA-tvOS-SDK', '~> 4.3'
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

target 'ExampleTvOS' do
    platform :tvos, '10.0'
    project 'ExampleTvOS/ExampleTvOS.xcodeproj'

    use_frameworks!
    common_example_pod
    google_ima_pod_tvos
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
    platform :tvos, '10.0'
    project 'YouboraIMAAdapter.xcodeproj'
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!
    # Pods for YouboraIMAAdapter
    common_pod
    google_ima_pod_tvos
end
