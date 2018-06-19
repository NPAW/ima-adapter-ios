//
//  YBIMAAdapter.h
//  YouboraIMAAdapter
//
//  Created by Enrique Alfonso Burillo on 17/10/2017.
//  Copyright © 2017 NPAW. All rights reserved.
//

#import <YouboraLib/YouboraLib.h>
#import <GoogleInteractiveMediaAds/GoogleInteractiveMediaAds.h>

@interface YBIMAAdapter : YBPlayerAdapter<IMAAdsManager *> <IMAAdsManagerDelegate>



@end
