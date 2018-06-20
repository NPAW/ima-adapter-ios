//
//  YBIMADAIAdapterSwiftWrapper.m
//  YouboraIMAAdapter
//
//  Created by Enrique Alfonso Burillo on 16/04/2018.
//  Copyright © 2018 NPAW. All rights reserved.
//

#import "YBIMADAIAdapterSwiftWrapper.h"

@interface YBIMADAIAdapterSwiftWrapper()
@property(nonatomic,strong) NSObject* player;
@property(nonatomic,strong) YBPlugin* plugin;
@property(nonatomic,strong) YBIMADAIAdapter* adapter;
@end

@implementation YBIMADAIAdapterSwiftWrapper

- (id) initWithPlayer:(NSObject*)adsManager andPlugin:(YBPlugin*)plugin{
    if (self = [super init]) {
        self.player = adsManager;
        self.plugin = plugin;
    }
    [self initAdapterIfNecessary];
    return self;
}

- (void) fireAdInit{
    [self initAdapterIfNecessary];
    [self.plugin.adsAdapter fireAdInit];
}

- (void) fireStart{
    [self initAdapterIfNecessary];
    [self.plugin.adsAdapter fireStart];
}

- (void) fireStop{
    [self initAdapterIfNecessary];
    [self.plugin.adsAdapter fireStop];
}
- (void) firePause{
    [self initAdapterIfNecessary];
    [self.plugin.adsAdapter firePause];
}
- (void) fireResume{
    [self initAdapterIfNecessary];
    [self.plugin.adsAdapter fireResume];
}
- (void) fireJoin{
    [self initAdapterIfNecessary];
    [self.plugin.adsAdapter fireJoin];
}

- (YBIMADAIAdapter *) getAdapter{
    return self.adapter;
}

- (YBPlugin *) getPlugin{
    return self.plugin;
}

- (void) initAdapterIfNecessary{
    if(self.plugin.adsAdapter == nil){
        if(self.plugin != nil){
            IMAStreamManager* adsManager = (IMAStreamManager*) self.player;
            [self.plugin setAdsAdapter:[[YBIMADAIAdapter alloc] initWithPlayer:adsManager]];
        }
    }
}

- (void) removeAdapter{
    [self.plugin removeAdsAdapter];
}

@end
