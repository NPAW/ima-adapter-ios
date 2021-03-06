//
//  PlayerViewController.m
//  AVPlayerAdapterExample
//
//  Created by Joan on 20/04/2017.
//  Copyright © 2017 NPAW. All rights reserved.
//

#import "PlayerViewController.h"
#import <YouboraAVPlayerAdapter/YouboraAVPlayerAdapter.h>
#import <YouboraIMAAdapter/YouboraIMAAdapter.h>

@import AVFoundation;
@import AVKit;
@import YouboraConfigUtils;

@interface PlayerViewController ()

@property (nonatomic, strong) AVPlayerViewController * playerViewController;

@property (nonatomic, strong) YBAVPlayerAdapter * adapter;
@property (nonatomic, strong) YBPlugin * youboraPlugin;

//Testing purposes
@property BOOL adapterAdded;
@property BOOL executeReplay;

//IMA
@property(nonatomic, strong) IMAAVPlayerContentPlayhead *contentPlayhead;
@property(nonatomic, strong) IMAAdsLoader *adsLoader;
@property(nonatomic, strong) IMAAdsManager *adsManager;

@end


@implementation PlayerViewController

// Observation context
static void * const observationContext = (void *) &observationContext;

//VAST Url with pre, mid and post ads
NSString *const kTestAppAdTagUrl =
    @"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&"
    @"ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&"
    @"cust_params=deployment%3Ddevsite%26sample_ar%3Dpremidpostpod&cmsid=496"
    @"&vid=short_onecue&correlator=";
//VAST preroll
NSString *const preRollTag = @"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpreonly&cmsid=496&vid=short_onecue&correlator=";
//Single skippable url with just a postroll
/*NSString *const kTestAppAdTagUrl =
    @"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&"
    @"ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&"
    @"cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=";*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.executeReplay = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // Set Youbora log level
    [YBLog setDebugLevel:YBLogLevelVerbose];
    
    // Create Youbora plugin
    YBOptions * youboraOptions = [YouboraConfigManager getOptions]; // [YBOptions new];
    youboraOptions.autoDetectBackground = true;
    youboraOptions.waitForMetadata = false;
    self.youboraPlugin = [[YBPlugin alloc] initWithOptions:youboraOptions];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.adapterAdded = NO;
    
    [self initPlayer];
    
    [self setupAdsLoader];
    // As soon as we have the player instance, create an Adapter to listen for the player events
    [self startYoubora];
    
    // Start playback
    [self requestAdsWithTag:kTestAppAdTagUrl];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    if ([self isMovingFromParentViewController]) {
        [self.playerViewController.player removeObserver:self forKeyPath:@"rate"];
        [self.playerViewController.player removeObserver:self forKeyPath:@"status"];
        [self.youboraPlugin fireStop];
        [self.youboraPlugin removeAdapter];
        [self.youboraPlugin removeAdsAdapter];
    }
}

-(void)initPlayer {
    // Video player controller
    self.playerViewController = [[AVPlayerViewController alloc] init];
    
    [self addChildViewController:self.playerViewController];
    [self.view addSubview:self.playerViewController.view];
    
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:self.resourceUrl]];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(observeConnectionFail:)
     name:AVPlayerItemFailedToPlayToEndTimeNotification
     object:item];
    
    // Create AVPlayer
    self.playerViewController.player = [AVPlayer playerWithPlayerItem:item];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(contentDidFinishPlaying:)
                                                   name:AVPlayerItemDidPlayToEndTimeNotification
                                                 object:nil];
    
    [self.playerViewController.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:observationContext];
    
    [self.playerViewController.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:observationContext];
}

- (void) startYoubora {
    YBAVPlayerAdapter * adapter = [[YBAVPlayerAdapter alloc] initWithPlayer:self.playerViewController.player];
    [self.youboraPlugin setAdapter:adapter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    //[self.youboraPlugin pter];
    [super viewWillDisappear:animated];
}

-(void)appDidBecomeActive:(NSNotification*)notification {
    //[self startYoubora];
    if(!self.adsManager.adPlaybackInfo.isPlaying){
        [self.adsManager resume];
    }
}

-(void)appWillResignActive:(NSNotification*)notification {
    //[self.youboraPlugin removeAdapter];
}

#pragma mark AVPlayer observer

-(void)observeConnectionFail:(NSNotification*)notification {
    NSError *error = notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
    
    if (self.youboraPlugin && self.youboraPlugin.adapter) {
        NSString *code = [NSString stringWithFormat:@"%ld",error.code];
        [self.youboraPlugin.adapter fireFatalErrorWithMessage:error.localizedDescription code:code andMetadata:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    @try {
        
        NSInteger newStatus = ((NSNumber *)[change objectForKey:NSKeyValueChangeNewKey]).integerValue;
        
        if (newStatus == AVPlayerItemStatusFailed) { // If failed
            // It can be either the status of the player or the status from its currentItem
            // because both of them are subscribed
            NSError * error = self.playerViewController.player.error;
            
            if (!error) {
                error = self.playerViewController.player.currentItem.error;
            }
            
            if (error && self.youboraPlugin && self.youboraPlugin.adapter) {
                NSString *code = [NSString stringWithFormat:@"%ld",error.code];
                
                [self.youboraPlugin.adapter
                 fireFatalErrorWithMessage:error.description
                 code:code
                 andMetadata:nil];
            }
        }
        
        if (context == observationContext) {
            AVPlayer * player = self.playerViewController.player;
            
            // AVPlayer properties
            if ([keyPath isEqualToString:@"rate"]) {
                NSNumber * newRate = (NSNumber *) [change objectForKey:NSKeyValueChangeNewKey];
                NSNumber * oldRate = (NSNumber *) [change objectForKey:NSKeyValueChangeOldKey];
                [YBLog debug:@"AVPlayer's rate has changed, old: %@, new: %@", oldRate, newRate];
                
                // We have to check that currentItem is not nil
                // If the player is sent a "play" message, but has no currentItem loaded
                // it will still set the rate to 0
                if (player.currentItem != nil) {
                    if ([newRate isEqualToNumber:@0]) {
                        NSNumber* playhead = @(CMTimeGetSeconds(player.currentTime));
                        NSNumber* duration = @(CMTimeGetSeconds(player.currentItem.asset.duration));
                        if([playhead intValue] == [duration intValue]){
                            [self.adsLoader contentComplete];
                        }
                    }
                }
            }
        }
        
    } @catch (NSException *exception) {
        [YBLog logException:exception];
    }
}


#pragma mark - IMA
- (void)contentDidFinishPlaying:(NSNotification *)notification {
    if (notification.object == self.playerViewController.player.currentItem) {
        [self.adsLoader contentComplete];
    }
}
    
- (void)setupAdsLoader {
    //IMA
    self.contentPlayhead = [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:self.playerViewController.player];
    
    // Re-use this IMAAdsLoader instance for the entire lifecycle of your app.
    self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:nil];
    // NOTE: This line will cause a warning until the next step, "Get the Ads Manager".
    self.adsLoader.delegate = self;
}

- (void)requestAdsWithTag:(NSString*) adTag  {
    // Create an ad display container for ad rendering.
    IMAAdDisplayContainer *adDisplayContainer =
    [[IMAAdDisplayContainer alloc] initWithAdContainer:self.adVIew viewController:self companionSlots:nil];
    // Create an ad request with our ad tag, display container, and optional user context.
    IMAAdsRequest *request = [[IMAAdsRequest alloc] initWithAdTagUrl:adTag
                                                  adDisplayContainer:adDisplayContainer
                                                     contentPlayhead:self.contentPlayhead
                                                         userContext:nil];
    [self.adsLoader requestAdsWithRequest:request];
}
- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
    self.adsManager = adsLoadedData.adsManager;
    
    // NOTE: This line will cause a warning until the next step, "Display Ads".
    self.adsManager.delegate = self;
    
    
    [self.youboraPlugin setAdsAdapter: [[YBIMAAdapter alloc] initWithPlayer: self.adsManager]];
    //id<IMAAdsManagerDelegate> oldOne = self.adsManager.delegate;
    
    /*YBIMAAdapter* adsAdapter = [[YBIMAAdapter alloc] initWithPlayer:self.adsManager];
    //[adsAdapter addDelegate:oldOne];
    [self.youboraPlugin setAdsAdapter:adsAdapter];
    //[self.youboraPlugin.adsAdapter fireAdInit];*/
    
    // Create ads rendering settings and tell the SDK to use the in-app browser.
    IMAAdsRenderingSettings *adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
    adsRenderingSettings.webOpenerPresentingController = self;
    
    // Initialize the ads manager.
    [self.adsManager initializeWithAdsRenderingSettings:adsRenderingSettings];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    // Something went wrong loading ads. Log the error and play the content.
    NSLog(@"Error loading ads: %@", adErrorData.adError.message);
    if(self.adapterAdded == NO){
        [self startYoubora];
        self.adapterAdded = YES;
    }
    [self.adVIew setHidden: YES];
    [self.view sendSubviewToBack: self.adVIew];
    [self.playerViewController.player play];
    [self.view bringSubviewToFront:self.replayButton];
}
- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    if (event.type == kIMAAdEvent_LOADED) {
        // When the SDK notifies us that ads have been loaded, play them.
        [self.adVIew setHidden: NO];
        [self.view bringSubviewToFront: self.adVIew];
        [adsManager start];
    }
    
    [self.view bringSubviewToFront:self.replayButton];
    /*if(event.type == kIMAAdEvent_COMPLETE && event.ad.adPodInfo.podIndex == 0){
        if(self.adapterAdded == NO){
            [self startYoubora];
            self.adapterAdded = YES;
        }
    }*/
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    // Something went wrong with the ads manager after ads were loaded. Log the error and play the
    // content.
    NSLog(@"AdsManager error: %@", error.message);
    if(self.adapterAdded == NO){
        [self startYoubora];
        self.adapterAdded = YES;
    }
    [self.adVIew setHidden: YES];
    [self.view sendSubviewToBack: self.adVIew];
    [self.playerViewController.player play];
    [self.view bringSubviewToFront: self.replayButton];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    // The SDK is going to play ads, so pause the content.
    [self.playerViewController.player pause];
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    // The SDK is done playing ads (at least for now), so resume the content.
    [self.adVIew setHidden:YES];
    [self.view sendSubviewToBack:self.adVIew];
    if(self.adapterAdded == NO){
        [self startYoubora];
        self.adapterAdded = YES;
    }
    [self.playerViewController.player play];
    [self.view bringSubviewToFront: self.replayButton];
}

-(IBAction)pressToReplay:(id)sender {
    [self.youboraPlugin removeAdapter];
    [self.youboraPlugin removeAdsAdapter];
    [self.adsManager destroy];
    self.adsLoader = nil;
    [self setupAdsLoader];
    [self requestAdsWithTag: kTestAppAdTagUrl];
    [self.playerViewController.player seekToTime: kCMTimeZero];
    [self.playerViewController.player play];
}

@end
