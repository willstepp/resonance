//
//  ResoModuleManager.mm
//  resonance
//
//  Created by Daniel Stepp on 5/23/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoModuleManager.h"
#import "ResoModule.h"
#import "FMODSoundEngine.h"

@interface ResoModuleManager()
@property (nonatomic, readwrite) NSMutableDictionary *  modules;
@end

@implementation ResoModuleManager
@synthesize modules;
static  ResoModuleManager * rmm = nil;

-(id)init
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"-init is not a valid initializer for the class ResoModuleManager. Use -instance"
                               userInfo:nil];
  return nil;
}

+(ResoModuleManager*)instance
{
  if (rmm == nil)
    rmm = [[ResoModuleManager alloc] initForSingleton];
  return rmm;
}

-(id)initForSingleton
{
  if (self = [super init])
  {
    modules = [[NSMutableDictionary alloc] init];
  }
  return self;
}

-(void)addModuleWithId:(int)i
{
  ResoModule * rm = [[ResoModule alloc] initWithSoundEngine:[FMODSoundEngine instance] tag:i];
  [modules setObject:rm forKey:[NSNumber numberWithInt:i]];
}
@end