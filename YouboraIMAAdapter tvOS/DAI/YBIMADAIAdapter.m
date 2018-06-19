//
//  YBIMADAIAdapter.m
//  YouboraIMAAdapter tvOS
//
//  Created by Enrique Alfonso Burillo on 19/06/2018.
//  Copyright © 2018 NPAW. All rights reserved.
//

#import "YBIMADAIAdapter.h"
@import AVKit;

@interface YBIMADAIAdapter ()<IMAStreamManagerDelegate>
    @property (nonatomic,strong,readwrite) NSMutableArray* delegates;
    @property YBAdPosition lastPosition;
    @property NSNumber* lastPlayhead;
    @property NSNumber* lastDuration;

    @property BOOL hasStarted;

    @property IMAAd* currentAd;
@end

@implementation YBIMADAIAdapter

- (void)registerListeners {
    [super registerListeners];
    
    if(self.delegates == nil){
        self.delegates = [[NSMutableArray alloc]init];
    }
    
    [self.delegates addObject:self.player.delegate];
    
    self.player.delegate = self;
    self.lastDuration = @0;
    self.hasStarted = NO;
    
    self.lastPosition = YBAdPositionUnknown;
    self.lastPlayhead = @-1;
}

- (void) unregisterListeners {
    if([self.delegates count] == 1){
        self.player.delegate = [self.delegates objectAtIndex:0];
    }else{
        self.player.delegate = nil;
    }
    [super unregisterListeners];
}

#pragma mark Delegate methods

- (void)streamManager:(IMAStreamManager *)streamManager didReceiveError:(NSError *)error {
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(streamManager:didReceiveError:)]){
            [self.delegates[k] performSelector:@selector(streamManager:didReceiveError:) withObject:streamManager withObject:error];
        }
    }
}

- (void)streamManager:(IMAStreamManager *)streamManager didInitializeStream:(NSString *)streamID {
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(streamManager:didInitializeStream:)]){
            [self.delegates[k] performSelector:@selector(streamManager:didInitializeStream:) withObject:streamManager withObject:streamID];
        }
    }
}

- (void)streamManager:(IMAStreamManager *)streamManager adBreakDidStart:(IMAAdBreakInfo *)adBreakInfo {
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(streamManager:adBreakDidStart:)]){
            [self.delegates[k] performSelector:@selector(streamManager:adBreakDidStart:) withObject:streamManager withObject:adBreakInfo];
        }
    }
}

- (void)streamManager:(IMAStreamManager *)streamManager adDidStart:(IMAAd *)ad {
    self.currentAd = ad;
    self.hasStarted = YES;
    if(self.plugin != nil && self.plugin.adapter != nil && self.plugin.adapter.flags.started && !self.plugin.adapter.flags.joined && [self getPosition] == YBAdPositionPre){
        [self.plugin.adapter fireJoin];
    }
    [self fireStart];
    NSString *adInfo = [NSString stringWithFormat:@"Showing ad %ld/%ld, title: %@, description: %@",
                        ad.adPosition, ad.adBreakInfo.totalAds, ad.adTitle, ad.adDescription];
    //[self playAdHandler];
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(streamManager:adDidStart:)]){
            [self.delegates[k] performSelector:@selector(streamManager:adDidStart:) withObject:streamManager withObject:ad];
        }
    }
}

- (void)streamManager:(IMAStreamManager *)streamManager adBreakDidEnd:(IMAAdBreakInfo *)adBreakInfo {
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(streamManager:adBreakDidEnd:)]){
            [self.delegates[k] performSelector:@selector(streamManager:adBreakDidEnd:) withObject:streamManager withObject:adBreakInfo];
        }
    }
}

- (void)streamManager:(IMAStreamManager *)streamManager didUpdateCuepoints:(NSArray<IMACuepoint *> *)cuepoints {
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(streamManager:didUpdateCuepoints:)]){
            [self.delegates[k] performSelector:@selector(streamManager:didUpdateCuepoints:) withObject:streamManager withObject:cuepoints];
        }
    }
}

- (void)streamManager:(IMAStreamManager *)streamManager ad:(IMAAd *)ad didCountdownTo:(NSTimeInterval)remainingTime {
    
    
    if([self.lastDuration floatValue] == 0.0){
        self.lastDuration = @(remainingTime);
    }
    self.lastPlayhead = @([self.lastDuration floatValue] - [@(remainingTime) floatValue]);
    if(![@(remainingTime) isEqual:self.lastDuration]){
        [self fireJoin];
    }
    double remainingTimeThreshold = [self getPosition] == YBAdPositionPost ? 1 : 0.1;
    if(remainingTime <= remainingTimeThreshold){
        [self fireStop];
    }
    
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(streamManager:ad:didCountdownTo:)]){
            NSMethodSignature *sig = [self.delegates[k] methodSignatureForSelector:@selector(streamManager:ad:didCountdownTo:)];
            NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
            [invo setTarget:self.delegates[k]];
            [invo setSelector:@selector(streamManager:ad:didCountdownTo:)];
            //Index 0 and 1 are reserved, so the first one is 2
            [invo setArgument:&streamManager atIndex:2];
            [invo setArgument:&ad atIndex:3];
            [invo setArgument:&remainingTime atIndex:4];
            [invo invoke];
        }
    }
}

- (void)streamManagerIsPlaybackReady:(IMAStreamManager *)streamManager{
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(streamManagerIsPlaybackReady:)]){
            [self.delegates[k] performSelector:@selector(streamManagerIsPlaybackReady:) withObject:streamManager];
        }
    }
}

#pragma mark Get methods

- (NSNumber *)getPlayhead{
    return self.currentAd == nil ? @0 : self.lastPlayhead;
}

- (NSNumber *)getDuration{
    return self.currentAd == nil ? [super getDuration] : self.lastDuration;
}

- (NSString*)getTitle{
    return self.currentAd == nil ? [super getTitle] : self.currentAd.adTitle;
}

- (YBAdPosition)getPosition {
    if(self.currentAd != nil){
        if(self.currentAd.adBreakInfo.timeOffset == 0){
            return YBAdPositionPre;
        }
        if(self.plugin != nil && self.currentAd.adBreakInfo.timeOffset == round([[self.plugin getDuration] doubleValue]) - round([[self getDuration] doubleValue])){
            return YBAdPositionPost;
        }
        return YBAdPositionMid;
    }
    return self.lastPosition;
}

- (void) fireStop{
    self.lastPosition =  self.lastPosition == YBAdPositionPost ? YBAdPositionPost : [self getPosition];
    
    self.lastPlayhead = self.lastPlayhead == nil ? @0 : self.lastPlayhead;
    
    self.hasStarted = NO;
    [super fireStop];
}

@end
