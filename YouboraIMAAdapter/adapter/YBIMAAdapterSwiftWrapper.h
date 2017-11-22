//
//  YBIMAAdapterSwiftWrapper.h
//  YouboraIMAAdapter
//
//  Created by Enrique Alfonso Burillo on 22/11/2017.
//  Copyright © 2017 NPAW. All rights reserved.
//

#import "YouboraIMAAdapter.h"

@interface YBIMAAdapterSwiftWrapper : NSObject


- (id) initWithPlayer:(NSObject*)player andPlugin:(YBPlugin*)plugin;
- (void) fireStart;
- (void) fireStop;
- (void) firePause;
- (void) fireResume;
- (void) fireJoin;

@end
