//
//  PlayerViewController.h
//  AVPlayerAdapterExample
//
//  Created by Joan on 20/04/2017.
//  Copyright © 2017 NPAW. All rights reserved.
//

@import UIKit;
@import GoogleInteractiveMediaAds;

@interface PlayerViewController : UIViewController<IMAAdsLoaderDelegate,IMAAdsManagerDelegate>

/**
 * The resource url to load onto the player.
 *
 * This should be set right before pushing the ViewController. For instance in the
 * prepareForSegue method
 */
@property (nonatomic, strong) NSString * resourceUrl;

@property (weak, nonatomic) IBOutlet UIView *adVIew;
@property (weak, nonatomic) IBOutlet UIButton *replayButton;

@end
