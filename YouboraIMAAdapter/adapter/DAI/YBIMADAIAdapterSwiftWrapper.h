//
//  YBIMADAIAdapterSwiftWrapper.h
//  YouboraIMAAdapter
//
//  Created by Enrique Alfonso Burillo on 16/04/2018.
//  Copyright © 2018 NPAW. All rights reserved.
//

#import "YBIMADAIAdapter.h"

@interface YBIMADAIAdapterSwiftWrapper : NSObject

- (id) initWithPlayer:(NSObject*)adsManager andPlugin:(YBPlugin*)plugin;
- (void) fireAdInit;
- (void) fireStart;
- (void) fireStop;
- (void) firePause;
- (void) fireResume;
- (void) fireJoin;

- (YBPlugin *) getPlugin;
- (YBIMADAIAdapter *) getAdapter;
- (void) removeAdapter;

@end
