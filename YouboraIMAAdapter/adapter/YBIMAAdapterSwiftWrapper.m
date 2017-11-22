//
//  YBIMAAdapterSwiftWrapper.m
//  YouboraIMAAdapter
//
//  Created by Enrique Alfonso Burillo on 22/11/2017.
//  Copyright © 2017 NPAW. All rights reserved.
//

#import "YBIMAAdapterSwiftWrapper.h"

@interface YBIMAAdapterSwiftWrapper ()

@property(nonatomic,strong) NSObject* player;
@property(nonatomic,strong) YBPlugin* plugin;
@property(nonatomic,strong) YBIMAAdapter* adapter;

@end

@implementation YBIMAAdapterSwiftWrapper

- (id) initWithPlayer:(NSObject*)player andPlugin:(YBPlugin*)plugin{
    if (self = [super init]) {
        self.player = player;
        self.plugin = plugin;
    }
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

- (YBIMAAdapter *) getAdapter{
    return self.adapter;
}

- (YBPlugin *) getPlugin{
    return self.plugin;
}

- (void) initAdapterIfNecessary{
    if(self.plugin.adsAdapter == nil){
        if(self.plugin != nil){
            IMAAdsManager* adsManager = (IMAAdsManager*) self.player;
            [self.plugin setAdsAdapter:[[YBIMAAdapter alloc] initWithPlayer:adsManager]];
        }
    }
}

@end
