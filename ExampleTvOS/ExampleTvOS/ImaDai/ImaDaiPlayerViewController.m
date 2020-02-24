//
//  ImaDaiViewController.m
//  ExampleTvOS
//
//  Created by nice on 06/02/2020.
//  Copyright © 2020 npaw. All rights reserved.
//

#import "ImaDaiPlayerViewController.h"

@import AVKit;
@import GoogleInteractiveMediaAds;

static NSString *const kAssetKey = @"sN_IYUG8STe1ZzhIIE_ksA";
static NSString *const kContentSourceID = @"19463";
static NSString *const kVideoID = @"googleio-highlights";
static NSString *const kBackupStreamURLString =
@"http://googleimadev-vh.akamaihd.net/i/big_buck_bunny/bbb-,480p,720p,1080p,.mov.csmil/"
@"master.m3u8";


@interface ImaDaiPlayerViewController () <IMAAdsLoaderDelegate, IMAStreamManagerDelegate>

@property(nonatomic) IMAAdsLoader *adsLoader;
@property(nonatomic) UIView *adContainerView;
@property(nonatomic) IMAStreamManager *streamManager;
@property(nonatomic) AVPlayerViewController *playerViewController;

@end

@implementation ImaDaiPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewModel initPlugin];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupAdsLoader];
    
    // Create a stream video player.
    AVPlayer *player = [[AVPlayer alloc] init];
    self.playerViewController = [[AVPlayerViewController alloc] init];
    self.playerViewController.player = player;
    
    [self.viewModel setPlayerApdater:player];
    
    // Attach video player to view hierarchy.
    [self addChildViewController:self.playerViewController];
    self.playerViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.playerViewController.view];
    [self.playerViewController didMoveToParentViewController:self];
    
    [self attachAdContainer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self requestStream];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self isMovingFromParentViewController]) {
        [self.viewModel stopPlugin];
        self.playerViewController.player = nil;
        [self.streamManager destroy];
    }
}

- (void)setupAdsLoader {
    self.adsLoader = [[IMAAdsLoader alloc] init];
    self.adsLoader.delegate = self;
}

- (void)attachAdContainer {
    self.adContainerView = [[UIView alloc] init];
    [self.view addSubview:self.adContainerView];
    self.adContainerView.frame = self.view.bounds;
}

- (void)requestStream {
    IMAAVPlayerVideoDisplay *videoDisplay =
    [[IMAAVPlayerVideoDisplay alloc] initWithAVPlayer:self.playerViewController.player];
    IMAAdDisplayContainer *adDisplayContainer =
    [[IMAAdDisplayContainer alloc] initWithAdContainer:self.adContainerView];
//    IMALiveStreamRequest *request = [[IMALiveStreamRequest alloc] initWithAssetKey:kAssetKey
//                                                                adDisplayContainer:adDisplayContainer
//                                                                      videoDisplay:videoDisplay];
    
    IMAVODStreamRequest *request = [[IMAVODStreamRequest alloc] initWithContentSourceID:@"19463" videoID:@"tears-of-steel" adDisplayContainer:adDisplayContainer videoDisplay:videoDisplay];
          
    [self.adsLoader requestStreamWithRequest:request];
}

- (void)playBackupStream {
    NSURL *backupStreamURL = [NSURL URLWithString:kBackupStreamURLString];
    AVPlayerItem *backupStreamItem = [AVPlayerItem playerItemWithURL:backupStreamURL];
    [self.playerViewController.player replaceCurrentItemWithPlayerItem:backupStreamItem];
    [self.playerViewController.player play];
}

#pragma mark - IMAAdsLoaderDelegate

- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    // Initialize and listen to stream manager's events.
    self.streamManager = adsLoadedData.streamManager;
    
    self.streamManager.delegate = self;
    [self.streamManager initializeWithAdsRenderingSettings:nil];
    [self.viewModel setAdsApdater:adsLoadedData];
    NSLog(@"Stream created with: %@.", self.streamManager.streamId);
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    // Fall back to playing the backup stream.
    NSLog(@"Error loading ads: %@", adErrorData.adError.message);
    [self playBackupStream];
}


#pragma mark - IMAStreamManagerDelegate

- (void)streamManager:(IMAStreamManager *)streamManager didReceiveAdEvent:(IMAAdEvent *)event {
    NSLog(@"StreamManager event (%@).", event.typeString);
    switch (event.type) {
        case kIMAAdEvent_STARTED: {
            // Log extended data.
            NSString *extendedAdPodInfo = [[NSString alloc]
                                           initWithFormat:@"Showing ad %zd/%zd, bumper: %@, title: %@, description: %@, contentType:"
                                           @"%@, pod index: %zd, time offset: %lf, max duration: %lf.",
                                           event.ad.adPodInfo.adPosition, event.ad.adPodInfo.totalAds,
                                           event.ad.adPodInfo.isBumper ? @"YES" : @"NO", event.ad.adTitle,
                                           event.ad.adDescription, event.ad.contentType, event.ad.adPodInfo.podIndex,
                                           event.ad.adPodInfo.timeOffset, event.ad.adPodInfo.maxDuration];
            
            NSLog(@"%@", extendedAdPodInfo);
            break;
        }
        case kIMAAdEvent_AD_BREAK_STARTED: {
            // Prevent user seek through when an ad starts.
            self.playerViewController.requiresLinearPlayback = YES;
            break;
        }
        case kIMAAdEvent_AD_BREAK_ENDED: {
            // Allow user seek through after an ad ends.
            self.playerViewController.requiresLinearPlayback = NO;
            break;
        }
        default:
            break;
    }
}

- (void)streamManager:(IMAStreamManager *)streamManager didReceiveAdError:(IMAAdError *)error {
    NSLog(@"StreamManager error: %@", error.message);
    [self playBackupStream];
}

- (void)streamManager:(IMAStreamManager *)streamManager
  adDidProgressToTime:(NSTimeInterval)time
           adDuration:(NSTimeInterval)adDuration
           adPosition:(NSInteger)adPosition
             totalAds:(NSInteger)totalAds
      adBreakDuration:(NSTimeInterval)adBreakDuration { }
    


@end
