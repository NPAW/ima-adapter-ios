//
//  YBIMAAdapter.m
//  YouboraIMAAdapter
//
//  Created by Enrique Alfonso Burillo on 17/10/2017.
//  Copyright © 2017 NPAW. All rights reserved.
//

#import "YBIMAAdapter.h"

#import <objc/message.h>

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


@interface YBIMAAdapter()
    @property (nonatomic,strong,readwrite) NSMutableArray* delegates;
@end

@implementation YBIMAAdapter

IMAAdsManager *manager;

- (void)registerListeners {
    [super registerListeners];
    
    if(self.delegates == nil){
        self.delegates = [[NSMutableArray alloc]init];
    }
    
    [self.delegates addObject:self.player.delegate];
    
    self.player.delegate = self;
    manager = [self getAdPlayer];
}

- (void) unregisterListeners {
    self.player.delegate = nil;
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(adsManager:didReceiveAdEvent:)]){
            [self.delegates[k] performSelector:@selector(adsManager:didReceiveAdEvent:) withObject:adsManager withObject:event];
        }
    }
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
            [self fireClick];
            break;
        case kIMAAdEvent_COMPLETE:
            [self fireStop];
            break;
        case kIMAAdEvent_SKIPPED:
            [self fireStop:@{@"skipped":@"true"}];
            break;
        case kIMAAdEvent_ALL_ADS_COMPLETED:
            self.plugin.options.adsAfterStop = 0;
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
        case kIMAAdEvent_CUEPOINTS_CHANGED:
            break;
        
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(adsManager:didReceiveAdError:)]){
            [self.delegates[k] performSelector:@selector(adsManager:didReceiveAdError:) withObject:adsManager withObject:error];
        }
    }
    NSLog(@"AdsManager error: %@", error.message);
    [self fireFatalErrorWithMessage:error.message code:[NSString stringWithFormat:@"%ld",(long)error.code] andMetadata:nil];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(adsManagerDidRequestContentPause:)]){
            [self.delegates[k] performSelector:@selector(adsManagerDidRequestContentPause:) withObject:adsManager];
        }
    }
    [self fireStart];
    
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(adsManagerDidRequestContentResume:)]){
            [self.delegates[k] performSelector:@selector(adsManagerDidRequestContentResume:) withObject:adsManager];
        }
    }
    [self fireStop];
}

#pragma mark - Overridden get methods
- (NSNumber *)getPlayhead{
 return @(manager.adPlaybackInfo.currentMediaTime);
}

- (NSNumber *)getDuration{
    return [NSNumber numberWithDouble:manager.adPlaybackInfo.totalMediaTime];
}

- (NSString*)getTitle{
    return manager.adPlaybackInfo.description;
}

- (YBAdPosition)getPosition {
    if([[self.plugin getPlayhead] doubleValue] <= 0){
        return YBAdPositionPre;
    }
    if([[self.plugin getPlayhead] doubleValue] >= [[self.plugin getDuration] doubleValue]){
        return YBAdPositionPost;
    }
    return YBAdPositionMid;
    
    /*if(cuePoints){
        
    }*/
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

//Optional delegate methods

- (void)adsManager:(IMAAdsManager *)adsManager adDidProgressToTime:(NSTimeInterval)mediaTime totalTime:(NSTimeInterval)totalTime{
    
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(adsManager:adDidProgressToTime:totalTime:)]){
            NSMethodSignature *sig = [self.delegates[k] methodSignatureForSelector:@selector(adsManager:adDidProgressToTime:totalTime:)];
            NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
            [invo setTarget:self.delegates[k]];
            [invo setSelector:@selector(adsManager:adDidProgressToTime:totalTime:)];
            //Index 0 and 1 are reserved, so the first one is 2
            [invo setArgument:&adsManager atIndex:2];
            [invo setArgument:&mediaTime atIndex:3];
            [invo setArgument:&totalTime atIndex:4];
            [invo invoke];
        }
    }
}

- (void)adsManagerAdPlaybackReady:(IMAAdsManager *)adsManager{
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(adsManagerAdPlaybackReady:)]){
            [self.delegates[k] performSelector:@selector(adsManagerAdPlaybackReady:) withObject:adsManager];
        }
    }
}

- (void)adsManagerAdDidStartBuffering:(IMAAdsManager *)adsManager{
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(adsManagerAdDidStartBuffering:)]){
            [self.delegates[k] performSelector:@selector(adsManagerAdDidStartBuffering:) withObject:adsManager];
        }
    }
    if(!self.flags.paused){
        [self fireBufferBegin];
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager adDidBufferToMediaTime:(NSTimeInterval)mediaTime{
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(adsManager:adDidBufferToMediaTime:)]){
            
            NSMethodSignature *sig = [self.delegates[k] methodSignatureForSelector:@selector(adsManager:adDidBufferToMediaTime:)];
            NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
            [invo setTarget:self.delegates[k]];
            [invo setSelector:@selector(adsManager:adDidBufferToMediaTime:)];
            //Index 0 and 1 are reserved, so the first one is 2
            [invo setArgument:&adsManager atIndex:2];
            [invo setArgument:&mediaTime atIndex:3];
            [invo invoke];
        }
    }
    [self fireBufferEnd];
}

@end
