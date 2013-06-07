//
//  ResoModuleManager.h
//  resonance
//
//  Created by Daniel Stepp on 5/23/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResoTypes.h"

@interface ResoModuleManager : NSObject
@property (readonly) NSMutableDictionary * modules;
+(ResoModuleManager*)instance;

-(void)addModuleWithUuid:(NSString*)uuid;
-(void)removeModuleWithUuid:(NSString*)uuid;

-(void)pauseModules;
-(void)playModules;
@end