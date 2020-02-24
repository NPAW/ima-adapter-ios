//
//  SwiftTest.swift
//  IMAAdapterExample
//
//  Created by nice on 06/02/2020.
//  Copyright © 2020 NPAW. All rights reserved.
//

import Foundation
import YouboraIMAAdapter
import GoogleInteractiveMediaAds

class SwiftTest {
    var plugin: YBPlugin?
    
    func setupPlugin(adsLoadedData: IMAAdsLoadedData) {
        guard let plugin = self.plugin else { return }
        
        
        if let streamManager = adsLoadedData.streamManager {
            plugin.adsAdapter = YBIMAAdapterSwiftTransformer.tranformImaDaiAdapter(YBIMADAIAdapter(player: streamManager))
        }
        
        if let adsManager = adsLoadedData.adsManager {
             plugin.adsAdapter = YBIMAAdapterSwiftTransformer.tranformImaAdapter(YBIMAAdapter(player: adsManager))
        }
    }
}
