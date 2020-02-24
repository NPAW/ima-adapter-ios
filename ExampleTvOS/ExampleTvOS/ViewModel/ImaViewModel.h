//
//  ImaViewModel.h
//  ExampleTvOS
//
//  Created by nice on 05/02/2020.
//  Copyright © 2020 npaw. All rights reserved.
//

#ifndef ImaViewModel_h
#define ImaViewModel_h

@import AVKit;
@import GoogleInteractiveMediaAds;

@protocol ImaViewModel

-(void)initPlugin;
-(void)setPlayerApdater:(AVPlayer*)player;
-(void)setAdsApdater:(IMAAdsLoadedData*)adsLoadedData;
-(void)stopPlugin;

@end


#endif
