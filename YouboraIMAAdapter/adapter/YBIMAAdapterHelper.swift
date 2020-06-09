//
//  YBIMAAdapterHelper.swift
//  YouboraIMAAdapter
//
//  Created by Enrique Alfonso Burillo on 04/06/2019.
//  Copyright © 2019 NPAW. All rights reserved.
//

import UIKit

@objcMembers
open class YBIMAAdapterHelper: NSObject, IMAAdsLoaderDelegate {
    
    fileprivate var delegates: [IMAAdsLoaderDelegate] = []
    
    fileprivate var adsLoader: IMAAdsLoader?
    fileprivate var plugin: YBPlugin?

    @objc public init(withAdsLoader loader: IMAAdsLoader, andPlugin plugin: YBPlugin) {
        self.adsLoader = loader
        self.plugin = plugin
        super.init()
        if let adsLoader = self.adsLoader {
            self.delegates.append(adsLoader.delegate)
            
            adsLoader.delegate = self
        }
    }
    
    @objc public func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        delegates.forEach { delegate in
            delegate.adsLoader(loader, adsLoadedWith: adsLoadedData)
        }
        
        guard let _ = self.plugin else {
            return
        }
        
        if let adsManager = adsLoadedData.adsManager {
            self.plugin?.adsAdapter = YBIMAAdapterSwiftTransformer.tranformImaAdapter(YBIMAAdapter(player: adsManager))
            self.plugin?.adsAdapter?.fireAdManifest([:])
        }
        if let streamManager = adsLoadedData.streamManager {
            self.plugin?.adsAdapter = YBIMAAdapterSwiftTransformer.tranformImaDaiAdapter(YBIMADAIAdapter(player: streamManager))
            self.plugin?.adsAdapter?.fireAdManifest([:])
        }
    }
    
    @objc public func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        delegates.forEach { delegate in
            delegate.adsLoader(loader, failedWith: adErrorData)
            var errorType = YBAdManifestError.errorNoResponse
            
            switch adErrorData.adError.code {
                //case .API_ERROR, .FAILED_TO_REQUEST_ADS, .PLAYLIST_MALFORMED_RESPONSE, .UNKNOWN_ERROR, .VAST_ASSET_NOT_FOUND
            case .VAST_EMPTY_RESPONSE:
                errorType = .emptyResponse
            case .VAST_TRAFFICKING_ERROR, .UNKNOWN_ERROR, .VAST_LOAD_TIMEOUT:
                errorType = .errorNoResponse
            case .API_ERROR, .FAILED_TO_REQUEST_ADS, .PLAYLIST_MALFORMED_RESPONSE, .VAST_ASSET_NOT_FOUND:
                errorType = .wrongResponse
            case .VAST_MALFORMED_RESPONSE,
                 .VAST_TOO_MANY_REDIRECTS,
                 .VAST_INVALID_URL,
                 .VIDEO_PLAY_ERROR,
                 .VAST_MEDIA_LOAD_TIMEOUT,
                 .VAST_LINEAR_ASSET_MISMATCH,
                 .COMPANION_AD_LOADING_FAILED,
                 .REQUIRED_LISTENERS_NOT_ADDED,
                 .ADSLOT_NOT_VISIBLE,
                 .FAILED_LOADING_AD,
                 .INVALID_ARGUMENTS,
                 .VIDEO_ELEMENT_USED,
                 .VIDEO_ELEMENT_REQUIRED,
                 .CONTENT_PLAYHEAD_MISSING,
                 .STREAM_INITIALIZATION_FAILED:
                errorType = YBAdManifestError.errorNoResponse
            @unknown default:
                errorType = YBAdManifestError.errorNoResponse
            }
            
            self.plugin?.adsAdapter?.fireAdManifestWithError(errorType, andMessage: adErrorData.adError.message)
        }
    }
}
