//
//  YBIMADAIAdapter.m
//  YouboraIMAAdapter
//
//  Created by Enrique Alfonso Burillo on 16/04/2018.
//  Copyright © 2018 NPAW. All rights reserved.
//

#import "YBIMADAIAdapter.h"

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

@interface YBIMADAIAdapter()<IMAStreamManagerDelegate>
@property (nonatomic,strong,readwrite) NSMutableArray* delegates;
@property (nonatomic,strong) IMAAd *currentAd;
@property (nonatomic,assign) double adProgress;
@property (nonatomic, strong) NSNumber * adsOnCurrentBreak;
@property (nonatomic, assign) BOOL isAdSkippable;
@property (nonatomic, strong) NSArray * breaksTime;

//This is done to prevent some "fake" quartile event that StreamManager fires
@property (nonatomic, assign) int lastQuartile;
@end

@implementation YBIMADAIAdapter

- (void)registerListeners {
    [super registerListeners];
    
    if(self.delegates == nil){
        self.delegates = [[NSMutableArray alloc]init];
    }
    
    [self.delegates addObject:self.player.delegate];
    
    self.player.delegate = self;
    self.adProgress = 0.0;
}

- (void) unregisterListeners {
    self.player.delegate = nil;
    [super unregisterListeners];
}

#pragma mark Get methods

- (NSNumber *)getPlayhead{
    return @(self.adProgress);
}

- (NSNumber *)getDuration{
    return self.currentAd == nil ? [super getDuration] : @(self.currentAd.duration);
}

- (NSString *)getTitle{
    return self.currentAd == nil ? [super getTitle] : self.currentAd.adTitle;
}

- (YBAdPosition) getPosition{
    if(self.currentAd == nil || [self getDuration] == nil){
        return YBAdPositionUnknown;
    }
    
    if(self.plugin != nil && [[self.plugin getIsLive] isEqualToValue:@YES]){
        return YBAdPositionMid;
    }
    
    double offset = self.currentAd.adPodInfo.timeOffset;
    
    if(offset == 0.0){
        return YBAdPositionPre;
    }
    
    if(self.plugin != nil && self.plugin.adapter != nil && (offset + 1) >= round([[self.plugin.adapter getDuration] doubleValue]) - round([[self getDuration] doubleValue])){
        return YBAdPositionPost;
    }
    return YBAdPositionMid;
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

- (NSNumber *) getAdGivenBreaks {
    return @([self.breaksTime count]);
}

- (NSArray *) getAdBreaksTime {
    
    NSMutableArray *cuePoints = [self.breaksTime mutableCopy];
    if (cuePoints != nil && [[cuePoints lastObject] isEqual:@(-1)]) {
        if (self.plugin != nil && self.plugin.adapter != nil) {
            cuePoints[cuePoints.count - 1] = [self.plugin getDuration];
        }
    }
    return cuePoints;
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
    return self.currentAd == nil ? [super getAdCreativeId] : self.currentAd.creativeAdID;
}

#pragma mark Delegate methods

- (void)streamManager:(IMAStreamManager *)streamManager adDidProgressToTime:(NSTimeInterval)time adDuration:(NSTimeInterval)adDuration adPosition:(NSInteger)adPosition totalAds:(NSInteger)totalAds adBreakDuration:(NSTimeInterval)adBreakDuration {
    self.adProgress = time;
    /*if(!self.flags.started){
        [self fireStart];
    }*/
    [self fireJoin];
    
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(streamManager:adDidProgressToTime:adDuration:adPosition:totalAds:adBreakDuration:)]){
            NSMethodSignature *sig = [self.delegates[k] methodSignatureForSelector:@selector(streamManager:adDidProgressToTime:adDuration:adPosition:totalAds:adBreakDuration:)];
            NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
            [invo setTarget:self.delegates[k]];
            [invo setSelector:@selector(streamManager:adDidProgressToTime:adDuration:adPosition:totalAds:adBreakDuration:)];
            //Index 0 and 1 are reserved, so the first one is 2
            [invo setArgument:&streamManager atIndex:2];
            [invo setArgument:&time atIndex:3];
            [invo setArgument:&adDuration atIndex:4];
            [invo setArgument:&adPosition atIndex:5];
            [invo setArgument:&totalAds atIndex:6];
            [invo setArgument:&adBreakDuration atIndex:7];
            [invo invoke];
        }
    }
}

- (void)streamManager:(IMAStreamManager *)streamManager didReceiveAdError:(IMAAdError *)error {
    [self fireErrorWithMessage:error.message code:[NSString stringWithFormat:@"%ld",(long)error.code] andMetadata:nil];
    
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(streamManager:didReceiveAdError:)]){
            [self.delegates[k] performSelector:@selector(streamManager:didReceiveAdError:) withObject:streamManager withObject:error];
        }
    }
}

- (void)streamManager:(IMAStreamManager *)streamManager didReceiveAdEvent:(IMAAdEvent *)event {
    [YBLog debug:@"Adapter event: %@",event.typeString];
    if(event.ad != nil){
        self.currentAd = event.ad;
    }
    
    switch (event.type) {
        case kIMAAdEvent_AD_BREAK_READY:
            break;
        case kIMAAdEvent_AD_BREAK_ENDED:
            [self fireAdBreakStop];
            break;
        case kIMAAdEvent_AD_BREAK_STARTED:{
            if (self.plugin != nil && self.plugin.adapter != nil && self.plugin.adapter.flags.joined) {
                [self fireAdBreakStart];
            }
        }
            break;
        case kIMAAdEvent_ALL_ADS_COMPLETED:
            //[self fireAllAdsCompleted];
            break;
        case kIMAAdEvent_TAPPED:
            break;
        case kIMAAdEvent_CLICKED:
            [self fireClickWithAdUrl:[self getAdUrl]];
            break;
        case kIMAAdEvent_COMPLETE:{
            float duration = [self getDuration] == nil ? 0.0 : [[self getDuration] floatValue];
            [self fireStop:@{@"adPlayhead": [NSString stringWithFormat:@"%f",duration]}];
        }
            break;
        case kIMAAdEvent_CUEPOINTS_CHANGED:
            self.breaksTime = event.adData[@"cuepoints"];
            break;
        case kIMAAdEvent_FIRST_QUARTILE:
            [self fireQuartile:1];
            break;
        case kIMAAdEvent_LOADED:
            
            break;
        case kIMAAdEvent_LOG:
            
            break;
        case kIMAAdEvent_MIDPOINT:
            [self fireQuartile:2];
            break;
        case kIMAAdEvent_PAUSE:
            [self firePause];
            break;
        case kIMAAdEvent_RESUME:
            [self fireResume];
            break;
        case kIMAAdEvent_SKIPPED:
            [self fireStop:@{@"skipped": @"true"}];
            break;
        case kIMAAdEvent_STARTED:
            self.adsOnCurrentBreak = @(self.currentAd.adPodInfo.totalAds);
            self.isAdSkippable = self.currentAd.skippable;
            [self fireStart];
            break;
        case kIMAAdEvent_STREAM_LOADED:
            
            break;
        case kIMAAdEvent_STREAM_STARTED:
            
            break;
        case kIMAAdEvent_THIRD_QUARTILE:
            [self fireQuartile:3];
            break;
        case kIMAAdEvent_AD_PERIOD_ENDED:
            //[self fireAdBreakStop];
            break;
        case kIMAAdEvent_AD_PERIOD_STARTED:
            //[self fireAdBreakStart];
            break;
        case kIMAAdEvent_AD_BREAK_FETCH_ERROR:
            break;
        case kIMAAdEvent_ICON_FALLBACK_IMAGE_CLOSED:
            break;
        case kIMAAdEvent_ICON_TAPPED:
            break;
    }
    
    for (int k = 0; k < [self.delegates count]; k++) {
        if([self.delegates[k] respondsToSelector:@selector(streamManager:didReceiveAdEvent:)]){
            [self.delegates[k] performSelector:@selector(streamManager:didReceiveAdEvent:) withObject:streamManager withObject:event];
        }
    }
}

- (NSString *) getAdUrl {
    @try {
        if (self.player != nil && self.currentAd != nil) {
            NSString * adUrl = [self.currentAd valueForKey:@"_clickThroughUrl"];
            return adUrl;
        }
    } @catch (NSException *exception) {
        [YBLog logException:exception];
    }
    return nil;
}

- (void) fireStart{
    [self fireAdBreakStart];
    if(self.plugin != nil && self.plugin.adapter != nil && !self.plugin.adapter.flags.joined && ([self getPosition] == YBAdPositionPre || ([self.plugin getIsLive] != nil && [[self.plugin getIsLive] isEqualToValue:@YES]))){
        [self.plugin.adapter fireJoin];
    }
    [super fireStart];
}

- (void) fireStop:(NSDictionary<NSString *,NSString *> *)params{
    [super fireStop:params];
    self.currentAd = nil;
    self.lastQuartile = 0;
    self.isAdSkippable = false;
}

- (void) fireQuartile:(int)quartileNumber {
    if (quartileNumber > self.lastQuartile) {
        self.lastQuartile = quartileNumber;
        [super fireQuartile:quartileNumber];
    }
}

- (void) fireAdBreakStop {
    [super fireAdBreakStop];
    self.breaksTime = @[];
    self.adsOnCurrentBreak = nil;
}

@end
