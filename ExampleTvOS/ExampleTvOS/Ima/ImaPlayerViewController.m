//
//  ImaPlayerViewController.m
//  ExampleTvOS
//
//  Created by nice on 05/02/2020.
//  Copyright © 2020 npaw. All rights reserved.
//

#import "ImaPlayerViewController.h"

@import AVKit;
@import GoogleInteractiveMediaAds;

NSString *const kContentURLString =
@"https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/"
@"master.m3u8";
NSString *const kAdTagURLString = @"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&"
@"iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&"
@"output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3D"
@"premidpostlongpod&cmsid=496&vid=short_tencue&correlator=[TIMESTAMP]";

@interface ImaPlayerViewController () <IMAAdsLoaderDelegate, IMAAdsManagerDelegate>

@property(nonatomic) IMAAdsLoader *adsLoader;
@property(nonatomic) IMAAdsManager *adsManager;
@property(nonatomic) IMAAVPlayerContentPlayhead *contentPlayhead;
@property(nonatomic) AVPlayerViewController *contentPlayerViewController;

@end

@implementation ImaPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewModel initPlugin];
    self.view.backgroundColor = UIColor.blackColor;
    [self setupContentPlayer];
    [self setupAdsLoader];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self isMovingFromParentViewController]) {
        [self.viewModel stopPlugin];
        [self.adsManager destroy];
        self.contentPlayerViewController.player = nil;
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self requestAds];
}

- (void)setupAdsLoader {
    self.adsLoader = [[IMAAdsLoader alloc] init];
    self.adsLoader.delegate = self;
}

- (void)requestAds {
    // Pass the main view as the container for ad display.
    IMAAdDisplayContainer *adDisplayContainer =
    [[IMAAdDisplayContainer alloc] initWithAdContainer:self.view viewController:self];
    IMAAdsRequest *request = [[IMAAdsRequest alloc] initWithAdTagUrl:kAdTagURLString
                                                  adDisplayContainer:adDisplayContainer
                                                     contentPlayhead:self.contentPlayhead
                                                         userContext:nil];
    [self.adsLoader requestAdsWithRequest:request];
}

- (void)setupContentPlayer {
    // Create a content video player.
    NSURL *contentURL = [NSURL URLWithString:kContentURLString];
    AVPlayer *player = [AVPlayer playerWithURL:contentURL];
    self.contentPlayerViewController = [[AVPlayerViewController alloc] init];
    self.contentPlayerViewController.player = player;
    self.contentPlayerViewController.view.frame = self.view.bounds;
    
    [self.viewModel setPlayerApdater:player];
    
    self.contentPlayhead =
    [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:self.contentPlayerViewController.player];
    
    // Track end of content.
    AVPlayerItem *contentPlayerItem = self.contentPlayerViewController.player.currentItem;
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(contentDidFinishPlaying:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:contentPlayerItem];
    
    // Attach content video player to view hierarchy.
    [self showContentPlayer];
}

// Add the content video player as a child view controller.
- (void)showContentPlayer {
    [self addChildViewController:self.contentPlayerViewController];
    self.contentPlayerViewController.view.frame = self.view.bounds;
    [self.view insertSubview:self.contentPlayerViewController.view atIndex:0];
    [self.contentPlayerViewController didMoveToParentViewController:self];
}

// Remove and detach the content video player.
- (void)hideContentPlayer {
    // The whole controller needs to be detached so that it doesn't capture events from the remote.
    [self.contentPlayerViewController willMoveToParentViewController:nil];
    [self.contentPlayerViewController.view removeFromSuperview];
    [self.contentPlayerViewController removeFromParentViewController];
}

- (void)contentDidFinishPlaying:(NSNotification *)notification {
    [self.adsLoader contentComplete];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - IMAAdsLoaderDelegate

- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    // Initialize and listen to the ads manager loaded for this request.
    self.adsManager = adsLoadedData.adsManager;
    self.adsManager.delegate = self;
    [self.adsManager initializeWithAdsRenderingSettings:nil];
    [self.viewModel setAdsApdater:adsLoadedData];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    // Fall back to playing content.
    NSLog(@"Error loading ads: %@", adErrorData.adError.message);
    [self.contentPlayerViewController.player play];
}

#pragma mark - IMAAdsManagerDelegate
- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    // Play each ad once it has loaded.
    if (event.type == kIMAAdEvent_LOADED) {
        [adsManager start];
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    // Fall back to playing content.
    NSLog(@"AdsManager error: %@", error.message);
    [self showContentPlayer];
    [self.contentPlayerViewController.player play];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    // Pause the content for the SDK to play ads.
    [self.contentPlayerViewController.player pause];
    [self hideContentPlayer];
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    // Resume the content since the SDK is done playing ads (at least for now).
    [self showContentPlayer];
    [self.contentPlayerViewController.player play];
}

@end
