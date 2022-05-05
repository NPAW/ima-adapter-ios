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


@interface YBIMAAdapter()
    @property (weak) NSObject<IMAAdsManagerDelegate>* mainDelegate;
    @property YBAdPosition lastPosition;
    @property NSNumber* lastPlayhead;
    @property (nonatomic, strong) NSNumber * adsOnCurrentBreak;
    @property (nonatomic, assign) BOOL isAdSkippable;
    @property (nonatomic, strong) NSString * creativeId;
@property (nonatomic, strong) IMAAd* lastAd;
@end

@implementation YBIMAAdapter

BOOL adServed;

- (void)registerListeners {
    [super registerListeners];
   
    if (!self.player.delegate) {
        [YBLog error:@"No delegate found. Please init the ads adapter after the delegate be defined"];
        return;
    }
    
    self.mainDelegate = self.player.delegate;
    
    self.player.delegate = self;
    adServed = false;
}

- (void) unregisterListeners {
    self.player.delegate = nil;
    self.mainDelegate = nil;
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    if(self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(adsManager:didReceiveAdEvent:)]){
        [self.mainDelegate performSelector:@selector(adsManager:didReceiveAdEvent:) withObject:adsManager withObject:event];
    }
    
    switch (event.type) {
        case kIMAAdEvent_LOADED:{
            self.lastAd = event.ad;
            self.lastPosition = YBAdPositionUnknown;
            
            int pos = (int)event.ad.adPodInfo.podIndex;
            self.adsOnCurrentBreak = @(event.ad.adPodInfo.totalAds);
            self.isAdSkippable = event.ad.skippable;
            self.creativeId = event.ad.creativeAdID;
            if(pos == 0){
                self.lastPosition = YBAdPositionPre;
            }
            if(pos == -1){
                self.lastPosition = YBAdPositionPost;
            }
            if(pos > 0){
                self.lastPosition = YBAdPositionMid;
            }
            [self fireStart];
            break;
        }
        case kIMAAdEvent_STARTED:
            [self fireJoin];
            //The position is available here, not on kIMAAdEvent_COMPLETE event
            self.lastPlayhead = [self getDuration];
            break;
        case kIMAAdEvent_PAUSE:
            [self firePause];
            break;
        case kIMAAdEvent_RESUME:
            [self fireResume];
            break;
        case kIMAAdEvent_TAPPED:
            break;
        case kIMAAdEvent_CLICKED:
            [self fireClickWithAdUrl:[self adUrlWithAd:event.ad]];
            break;
        case kIMAAdEvent_COMPLETE:{
            [self sendStop];
            break;
        }
        case kIMAAdEvent_SKIPPED:
            [self fireStop:@{@"skipped":@"true"}];
            break;
        case kIMAAdEvent_ALL_ADS_COMPLETED:{
            //Not needed anymore
            //[self fireAllAdsCompleted];
            break;
        }
        case kIMAAdEvent_LOG:{
            [YBLog debug:@"EVENT_LOG: %@",[event.adData description]];
            NSDictionary *adData = event.adData;
            if(adData != nil && adData[@"errorCode"] != nil && ![adData[@"errorCode"] isEqualToString:@"1009"]){
                [self fireErrorWithMessage:adData[@"errorMessage"] code:adData[@"errorCode"] andMetadata:nil];
            }
        }
        case kIMAAdEvent_AD_BREAK_READY:
            break;
        case kIMAAdEvent_AD_BREAK_ENDED:
            break;
        case kIMAAdEvent_AD_BREAK_STARTED:
            break;
        case kIMAAdEvent_MIDPOINT:
            [self fireQuartile:2];
            break;
        case kIMAAdEvent_STREAM_LOADED:
        case kIMAAdEvent_FIRST_QUARTILE:
            [self fireQuartile:1];
            break;
        case kIMAAdEvent_STREAM_STARTED:
        case kIMAAdEvent_THIRD_QUARTILE:
            [self fireQuartile:3];
            break;
        case kIMAAdEvent_CUEPOINTS_CHANGED:
        case kIMAAdEvent_AD_PERIOD_ENDED:
        case kIMAAdEvent_AD_PERIOD_STARTED:
            break;
        case kIMAAdEvent_AD_BREAK_FETCH_ERROR:
            break;
        case kIMAAdEvent_ICON_FALLBACK_IMAGE_CLOSED:
            break;
        case kIMAAdEvent_ICON_TAPPED:
            break;
    }
}

- (NSString *) adUrlWithAd:(IMAAd *) ad {
    @try {
        if (self.player != nil && ad != nil) {
            NSString * adUrl = [ad valueForKey:@"_clickThroughUrl"];
            return adUrl;
        }
    } @catch (NSException *exception) {
        [YBLog logException:exception];
    }
    return nil;
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
        if(self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(adsManager:didReceiveAdError:)]){
            [self.mainDelegate performSelector:@selector(adsManager:didReceiveAdError:) withObject:adsManager withObject:error];
        }
    [YBLog debug:@"AdsManager error: %@",error.message];
    [self fireFatalErrorWithMessage:error.message code:[NSString stringWithFormat:@"%ld",(long)error.code] andMetadata:nil];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    if(self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(adsManagerDidRequestContentPause:)]){
        [self.mainDelegate performSelector:@selector(adsManagerDidRequestContentPause:) withObject:adsManager];
    }
    
    adServed = true;
    [self fireStart];
}

- (void) fireStart {
    if (self.lastPosition == YBAdPositionMid && self.plugin && self.plugin.adapter) {
        [self.plugin.adapter firePause];
    }
    [self fireAdBreakStart];
    [super fireStart];
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    [self sendStop];
    [self fireAdBreakStop];
    
    if(self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(adsManagerDidRequestContentResume:)]){
        [self.mainDelegate performSelector:@selector(adsManagerDidRequestContentResume:) withObject:adsManager];
    }
    
    if (self.lastPosition == YBAdPositionMid && self.plugin && self.plugin.adapter) {
        [self.plugin.adapter fireResume];
    }
}

#pragma mark - Overridden get methods
- (NSNumber *)getPlayhead {
    return @([self getAdPlayer].adPlaybackInfo.currentMediaTime);
}

- (NSNumber *)getDuration {
    return [NSNumber numberWithDouble: [self getAdPlayer].adPlaybackInfo.totalMediaTime];
}

- (NSString*)getTitle {
    if (!self.lastAd) { return [super getTitle]; }
    return self.lastAd.adTitle;
}

- (YBAdPosition)getPosition {
    return self.lastPosition;
}

- (IMAAdsManager *) getAdPlayer {
    return (IMAAdsManager *)self.player;
}

- (NSNumber *) getAdBreakNumber {
    return [super getAdBreakNumber];
}

- (NSNumber *) getAdGivenBreaks {
    return @([self getAdPlayer].adCuePoints.count);
}

- (NSArray *) getAdBreaksTime {
    NSMutableArray *cuePoints = [[self getAdPlayer].adCuePoints mutableCopy];
    if (cuePoints != nil && [[cuePoints lastObject] isEqual:@(-1)]) {
        if (self.plugin != nil && ![[self.plugin getDuration] isEqualToNumber:@(0)]) {
            cuePoints[cuePoints.count - 1] = [self.plugin getDuration];
        }
    }
    return cuePoints;
}

- (NSString *)getAdInsertionType {
    return YBConstantsAdInsertionType.clientSide;
}

- (NSNumber *) getGivenAds {
    return self.adsOnCurrentBreak;
}

- (NSValue *) isSkippable {
    return self.isAdSkippable ? @YES : @NO;
}

- (NSString *) getAdProvider {
    return @"DFP";
}

- (NSString *) getAdCreativeId {
    return self.creativeId;
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

- (void) sendStop {
    self.lastPosition = self.lastPosition == YBAdPositionPost ? YBAdPositionPost : [self getPosition];
    
    if (!adServed && self.plugin.adsAdapter.flags.adInitiated) {
        NSDictionary *notServedErrorParams = @{
                                               @"errorCode" : @"AD_NOT_SERVED",
                                               @"errorMsg" : @"Ad not served",
                                               @"errorSeverity" : @"AdsNotServed"
                                               };
        [self fireError:notServedErrorParams];
    }
    self.lastPlayhead = self.lastPlayhead == nil ? @0 : self.lastPlayhead;
    NSDictionary *adStopParams = @{
                                   @"adPlayhead": [NSString stringWithFormat:@"%lf",[self.lastPlayhead doubleValue]]
                                   };
    [self fireStop:adStopParams];
    
}

//Optional delegate methods

- (void)adsManager:(IMAAdsManager *)adsManager adDidProgressToTime:(NSTimeInterval)mediaTime totalTime:(NSTimeInterval)totalTime{
    
        if(self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(adsManager:adDidProgressToTime:totalTime:)]){
            NSMethodSignature *sig = [self.mainDelegate methodSignatureForSelector:@selector(adsManager:adDidProgressToTime:totalTime:)];
            NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
            [invo setTarget:self.mainDelegate];
            [invo setSelector:@selector(adsManager:adDidProgressToTime:totalTime:)];
            //Index 0 and 1 are reserved, so the first one is 2
            [invo setArgument:&adsManager atIndex:2];
            [invo setArgument:&mediaTime atIndex:3];
            [invo setArgument:&totalTime atIndex:4];
            [invo invoke];
        }
}

- (void)adsManagerAdPlaybackReady:(IMAAdsManager *)adsManager{
    if(self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(adsManagerAdPlaybackReady:)]){
        [self.mainDelegate performSelector:@selector(adsManagerAdPlaybackReady:) withObject:adsManager];
    }
}

- (void)adsManagerAdDidStartBuffering:(IMAAdsManager *)adsManager{
    if(self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(adsManagerAdDidStartBuffering:)]){
        [self.mainDelegate performSelector:@selector(adsManagerAdDidStartBuffering:) withObject:adsManager];
    }
    
    if(!self.flags.paused){
        [self fireBufferBegin];
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager adDidBufferToMediaTime:(NSTimeInterval)mediaTime{
    if(self.mainDelegate && [self.mainDelegate respondsToSelector:@selector(adsManager:adDidBufferToMediaTime:)]){
        
        NSMethodSignature *sig = [self.mainDelegate methodSignatureForSelector:@selector(adsManager:adDidBufferToMediaTime:)];
        NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
        [invo setTarget:self.mainDelegate];
        [invo setSelector:@selector(adsManager:adDidBufferToMediaTime:)];
        //Index 0 and 1 are reserved, so the first one is 2
        [invo setArgument:&adsManager atIndex:2];
        [invo setArgument:&mediaTime atIndex:3];
        [invo invoke];
    }
    
    [self fireBufferEnd];
}

@end
