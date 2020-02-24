//
//  ImaViewModelSwift.swift
//  ExampleTvOS
//
//  Created by nice on 05/02/2020.
//  Copyright © 2020 npaw. All rights reserved.
//

import Foundation
import YouboraLib
import YouboraConfigUtils
import YouboraIMAAdapter
import YouboraAVPlayerAdapter

class ImaViewModelSwift: NSObject,ImaViewModel {
    var options: YBOptions{
        let options = YouboraConfigManager.getOptions()
        return options;
    }
    
    var plugin: YBPlugin?
    
    func initPlugin() {
        
        let newOptions = options
        
        self.plugin = YBPlugin(options: newOptions)
    }
    
    func setPlayerApdater(_ player: AVPlayer!) {
        self.plugin?.adapter = YBAVPlayerAdapterSwiftTranformer.transform(from: YBAVPlayerAdapter(player: player))
    }
    
    func setAdsApdater(_ adsLoadedData: IMAAdsLoadedData!) {
        if let adsManager = adsLoadedData.adsManager {
            self.plugin?.adsAdapter = YBIMAAdapterSwiftTransformer.tranformImaAdapter(YBIMAAdapter(player: adsManager))
            return
        }
        
        if let streamManager = adsLoadedData.streamManager {
            self.plugin?.adsAdapter = YBIMAAdapterSwiftTransformer.tranformImaDaiAdapter(YBIMADAIAdapter(player: streamManager))
            return
        }
        
    }
    
    func stopPlugin() {
        self.plugin?.adsAdapter?.fireStop()
        self.plugin?.adapter?.fireStop()
        
        self.plugin?.removeAdapter()
        self.plugin?.removeAdsAdapter()
    }
    
}
