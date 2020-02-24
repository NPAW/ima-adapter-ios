//
//  YBIMAAdapterSwiftTransformer.m
//  YouboraIMAAdapter
//
//  Created by nice on 05/02/2020.
//  Copyright © 2020 NPAW. All rights reserved.
//

#import "YBIMAAdapterSwiftTransformer.h"

@implementation YBIMAAdapterSwiftTransformer

+(YBPlayerAdapter <id>*)tranformImaDaiAdapter:(YBIMADAIAdapter*)adapter { return adapter; }
+(YBPlayerAdapter <id>*)tranformImaAdapter:(YBIMAAdapter*)adapter { return adapter; }

@end
