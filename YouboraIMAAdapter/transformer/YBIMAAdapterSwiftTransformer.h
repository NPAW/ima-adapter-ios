//
//  YBIMAAdapterSwiftTransformer.h
//  YouboraIMAAdapter
//
//  Created by nice on 05/02/2020.
//  Copyright © 2020 NPAW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBIMAAdapter.h"
#import "YBIMADAIAdapter.h"

@import YouboraLib;


@interface YBIMAAdapterSwiftTransformer : NSObject

+(YBPlayerAdapter <id>*)tranformImaDaiAdapter:(YBIMADAIAdapter*)adapter;
+(YBPlayerAdapter <id>*)tranformImaAdapter:(YBIMAAdapter*)adapter;

@end
