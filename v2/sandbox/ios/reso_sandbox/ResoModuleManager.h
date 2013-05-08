//
//  ResoModuleManager.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/8/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResoTypes.h"

@interface ResoModuleManager : NSObject
@property (readonly) NSMutableDictionary * modules;
+(ResoModuleManager*)instance;
-(void)addModuleWithId:(int)i;
@end
