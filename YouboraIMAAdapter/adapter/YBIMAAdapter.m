//
//  YBIMAAdapter.m
//  YouboraIMAAdapter
//
//  Created by Enrique Alfonso Burillo on 17/10/2017.
//  Copyright © 2017 NPAW. All rights reserved.
//

#import "YBIMAAdapter.h"

// Constants
#define MACRO_NAME(f) #f
#define MACRO_VALUE(f) MACRO_NAME(f)

#define PLUGIN_VERSION_DEF MACRO_VALUE(YOUBORAIMAADAPTER_VERSION)
#define PLUGIN_NAME_DEF "IMA"

#if TARGET_OS_TV==1
#define PLUGIN_PLATFORM_DEF "tvOS"
#else
#define PLUGIN_PLATFORM_DEF "iOS"
#endif

#define PLUGIN_NAME @PLUGIN_NAME_DEF "-" PLUGIN_PLATFORM_DEF
#define PLUGIN_VERSION @PLUGIN_VERSION_DEF "-" PLUGIN_NAME_DEF "-" PLUGIN_PLATFORM_DEF

@implementation YBIMAAdapter

IMAAdsManager *manager;

- (void)registerListeners {
    [super registerListeners];
    self.player.delegate = self;
    manager = [self getAdPlayer];
}

- (void) unregisterListeners {
    
    self.player.delegate = nil;
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    switch (event.type) {
        case kIMAAdEvent_LOADED:
            [self fireStart];
            break;
        case kIMAAdEvent_STARTED:
            [self fireJoin];
            break;
        case kIMAAdEvent_PAUSE:
            [self firePause];
            break;
        case kIMAAdEvent_RESUME:
            [self fireResume];
            break;
        case kIMAAdEvent_TAPPED:
        case kIMAAdEvent_CLICKED:
            //[self fireClick];
            break;
        case kIMAAdEvent_COMPLETE:
            [self fireStop];
            break;
        case kIMAAdEvent_SKIPPED:
            [self fireStop:@{@"skipped":@"true"}];
            break;
        case kIMAAdEvent_AD_BREAK_READY:
        case kIMAAdEvent_AD_BREAK_ENDED:
        case kIMAAdEvent_AD_BREAK_STARTED:
        case kIMAAdEvent_LOG:
        case kIMAAdEvent_MIDPOINT:
        case kIMAAdEvent_STREAM_LOADED:
        case kIMAAdEvent_FIRST_QUARTILE:
        case kIMAAdEvent_STREAM_STARTED:
        case kIMAAdEvent_THIRD_QUARTILE:
        case kIMAAdEvent_ALL_ADS_COMPLETED:
        case kIMAAdEvent_CUEPOINTS_CHANGED:
            break;
        
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    // Something went wrong with the ads manager after ads were loaded. Log the error and play the
    // content.
    NSLog(@"AdsManager error: %@", error.message);
    //[self fireErrorWithMessage:error.message code:[error.code description] andMetadata:nil];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    
    
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    
}

#pragma mark - Overridden get methods
- (NSNumber *)getPlayhead{
 return [NSNumber numberWithDouble:manager.adPlaybackInfo.currentMediaTime];
}

- (NSNumber *)getDuration{
    return [NSNumber numberWithDouble:manager.adPlaybackInfo.totalMediaTime];
}

- (NSString*)getTitle{
    return manager.adPlaybackInfo.description;
}

/*- (NSString*)getResource{
    return manager.adPlaybackInfo.
}*/            

- (IMAAdsManager *) getAdPlayer{
    return (IMAAdsManager *)self.player;
}
- (NSString *)getPlayerName {
    return PLUGIN_NAME;
}

- (NSString *)getPlayerVersion {
    return @PLUGIN_NAME_DEF;
}

- (NSString *)getVersion {
    return PLUGIN_VERSION;
}


@end
