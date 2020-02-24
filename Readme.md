# YouboraIMAAdapter

A framework that will collect several video events from the GoogleInteractiveMediaAds and send it to the back end

# Installation

#### CocoaPods

For iOS insert in your podfile: 

```bash
target 'YOUR_TARGET' do
    platform :ios, '9.0'

    use_frameworks!
    
    # Pods 
    pod 'YouboraIMAAdapter'
end
```
For tvOS do: 
```bash
#tvOS
target 'YOUR_TARGET' do
    platform :tvos, '9.1'

    use_frameworks!
    
    # Pods 
    pod 'YouboraIMAAdapter'
end
```

and then in your project root folder execute 

```bash
pod install
```

or 

```bash
pod update
```

## How to use

## Start plugin and options

#### Swift

```swift

//Import
import YouboraLib

...

//Config Options and init plugin (do it just once for each play session)

var options: YBOptions {
        let options = YBOptions()
        options.contentResource = "http://example.com"
        options.accountCode = "accountCode"
        options.adResource = "http://example.com"
        options.contentIsLive = NSNumber(value: false)
        return options;
    }
    
lazy var plugin = YBPlugin(options: self.options)
```

#### Obj-C

```objectivec

//Import
#import <YouboraLib/YouboraLib.h>

...

// Declare the properties
@property YBPlugin *plugin;

...

//Config Options and init plugin (do it just once for each play session)

YBOptions *options = [YBOptions new];
options.offline = false;
options.contentResource = resource.resourceLink;
options.accountCode = @"powerdev";
options.adResource = self.ad?.adLink;
options.contentIsLive = [[NSNumber alloc] initWithBool: resource.isLive];
        
self.plugin = [[YBPlugin alloc] initWithOptions:self.options];
```

For more information about the options you can check [here](http://developer.nicepeopleatwork.com/apidocs/ios6/Classes/YBOptions.html)

### YouboraIMAAdapter

#### Swift

```swift
import YouboraIMAAdapter

...

//Once you have your player and plugin initialized you can set the adapter
// To set YBIMAAdapter
if let adsManager = adsLoadedData.adsManager {
  plugin.adsAdapter = YBIMAAdapterSwiftTransformer.tranformImaAdapter(YBIMAAdapter(player: adsManager))
}

...

//If you want to setup the YBIMADAIAdapter
if let streamManager = adsLoadedData.streamManager {
  plugin.adsAdapter = YBIMAAdapterSwiftTransformer.tranformImaDaiAdapter(YBIMADAIAdapter(player: streamManager))
}

...

// When the view gonna be destroyed you can force stop and clean the adapters in order to make sure you avoid retain cycles  
self.plugin.fireStop()
self.plugin.removeAdapter()
self.plugin.removeAdsAdapter()
```

#### Obj-C

```objectivec
#import <YouboraIMAAdapter/YouboraIMAAdapter.h>

...

//You can set the ads as soon as you have the adsLoader ready
self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:nil];
// NOTE: This line will cause a warning until the next step, "Get the Ads Manager".
self.adsLoader.delegate = self;


// To set YBIMAAdapter or YBIMADAIAdapter you can use the YBIMAAdapterHelper class. This one will distinguish which should be seted based on
// adsLoader info 
self.helper = [[YBIMAAdapterHelper alloc] initWithAdsLoader:self.adsLoader andPlugin:self.plugin];

...

// When the view gonna be destroyed you can force stop and clean the adapters in order to make sure you avoid retain cycles  
[self.plugin fireStop];
[self.plugin removeAdapter];
[self.plugin removeAdsAdapter];
```

## Run samples project
In the project root folder execute the follow command:
```bash
pod install
```

or 

```bash
pod update
```

#### Project structure
* **IMAAdapterExample:** is in the Example folder and here you can test the YBIMAAdapter for iOS
* **IMAAdapterExampleDAI:** is in the Example-DAI folder and here you can test the YBIMADAIAdapter for iOS
* **ExampleTvOS:** is in the ExampleTvOS folder and here you can test the YBIMAAdapter & YBIMADAIAdapter for tvOS
* **YouboraIMAAdapter:** is in the YouboraIMAAdapter folder and here you have the YBIMAAdapter & YBIMADAIAdapter