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
#import "ISound.h"
#import "ITone.h"

@interface ResoModuleManager()
@property (nonatomic, readwrite) NSMutableDictionary *  modules;
@end

@implementation ResoModuleManager
@synthesize modules;
static ResoModuleManager * rmm = nil;

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

-(void)addModuleWithUuid:(NSString*)uuid
{
  ResoModule * rm = [[ResoModule alloc] initWithSoundEngine:[FMODSoundEngine instance] uuid:uuid];
  [modules setObject:rm forKey:uuid];
}

-(void)removeModuleWithUuid:(NSString *)uuid
{
  [modules removeObjectForKey:uuid];
}

-(void)pauseModules
{
  for(id key in modules) {
    ResoModule * rm = [modules objectForKey:key];
    if ([rm loaded]) {
      if ([rm type] == ModuleType_Sound) [rm.sound setPaused:true];
      if ([rm type] == ModuleType_Tone) [rm.tone setPaused:true];
    }
  }
}

-(void)playModules
{
  for(id key in modules) {
    ResoModule * rm = [modules objectForKey:key];
    if ([rm loaded]) {
      if ([rm type] == ModuleType_Sound) [rm.sound setPaused:false];
      if ([rm type] == ModuleType_Tone) [rm.tone setPaused:false];
    }
  }
}

-(void)unloadCurrentMix
{
  NSArray * keys = [modules allKeys];
  for (id key in keys) {
    NSString * k = (NSString*)key;
    if (![k isEqualToString:@"preview"]) {
      [self removeModuleWithUuid:k];
    }
  }
}
@end