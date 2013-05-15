//
//  ResoMixManager.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/10/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ResoAppDelegate.h"
#import "ResoMixManager.h"
#import "ResoTypes.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"
#import "ISound.h"
#import "ITone.h"

#import "FMODSoundEngine.h"

#import "ResoThumbnailGenerator.h"

@interface ResoMixManager ()
{
  id<ISoundEngine> soundEngine;
  NSTimer * recordingTimer;
  NSString * currentMixUuid;
}
@end

@implementation ResoMixManager
@synthesize backgroundTaskId;

static ResoMixManager * rmm = nil;

-(id)init
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                      reason:@"-init is not a valid initializer for the class ResoMixManager. Use -instance"
                      userInfo:nil];
  return nil;
}

+(ResoMixManager*)instance
{
  if (rmm == nil)
    rmm = [[ResoMixManager alloc] initForSingleton];
  return rmm;
}

-(id)initForSingleton
{
  if (self = [super init])
  {
    soundEngine = [FMODSoundEngine instance];
  }
  return self;
}

-(void)saveMix:(NSString*)name
{
  NSString * uuid = [[[NSUUID UUID] UUIDString] lowercaseString];
  currentMixUuid = uuid;
  
  //1) create coredata record
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  [ad addMixWithId:uuid name:name state:Completed];
  
  //2) create mix dictionary
  NSMutableDictionary * mix = [[NSMutableDictionary alloc] init];
  [mix setObject:name forKey:@"name"];
  [mix setObject:uuid forKey:@"uuid"];

  NSMutableArray * mixUuids = [[NSMutableArray alloc] init];
  NSMutableArray * modules = [[NSMutableArray alloc] init];
  for(id key in [ResoModuleManager instance].modules) {
    ResoModule * rm = [[ResoModuleManager instance].modules objectForKey:key];
    
    if (rm.tag != Preview && rm.tag != ModuleCount) {
      ModuleType type = rm.type;
      if (type != ModuleType_Unloaded) {
        
        NSMutableDictionary * module = [[NSMutableDictionary alloc] init];
        [module setObject:[NSNumber numberWithInt:rm.tag] forKey:@"number"];
        [module setObject:rm.uuid forKey:@"uuid"];
        
        float volume = 0.0f;
        if (rm.type == ModuleType_Sound) {
          volume = [rm.sound volume];
          NSDictionary * effects = [rm.sound effectMappings];
          [module setObject:effects forKey:@"effects"];
        }
        if (rm.type == ModuleType_Tone) {
          volume = [rm.tone volume];
          [module setObject:[NSNumber numberWithFloat:[rm.tone getPropertyOfType:BinauralGap]] forKey:@"binaural_gap"];
          [module setObject:[NSNumber numberWithFloat:[rm.tone getPropertyOfType:Frequency]] forKey:@"frequency"];
        }
        
        [module setObject:[NSNumber numberWithInt:type] forKey:@"type"];
        [module setObject:[NSNumber numberWithFloat:volume] forKey:@"volume"];
        
        [modules addObject:module];
        [mixUuids addObject:rm.uuid];
      }
    }
  }
  [mix setObject:modules forKey:@"modules"];
  
  //3) persist mix data to file as json
  [ad ensureDirectoryExists:[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@", uuid]]];
  
  NSError * error = nil;
  NSData * mixJson = [NSJSONSerialization dataWithJSONObject:mix options:NSJSONWritingPrettyPrinted error:&error];
  
  NSString *strData = [[NSString alloc]initWithData:mixJson encoding:NSUTF8StringEncoding];
  NSLog(@"mixJson: %@", strData);
  
  [mixJson writeToFile:[[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix", uuid]] path] atomically:YES];
  
  //4) record 20 second mix preview clip
  [soundEngine startRecording:[[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview", uuid]] path] dynamicInput:false];
  
  recordingTimer = [NSTimer scheduledTimerWithTimeInterval:20
                            target:self
                            selector:@selector(finishPreviewRecording)
                            userInfo:nil
                            repeats:NO];
  
  self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    [self finishPreviewRecording];
  }];

  NSLog(@"preview mix recording started");
  
  //5) generate mix thumbnail
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    ResoThumbnailGenerator * rtg = [[ResoThumbnailGenerator alloc] init];
    UIImage * thumb = [rtg generateMixThumbnail:mixUuids];
    
    //write thumb to file
    [UIImageJPEGRepresentation(thumb, 1.0) writeToFile:[[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb", uuid]] path] atomically:YES];
    
    [self performSelectorOnMainThread:@selector(mixThumbnailDone)
                           withObject:nil waitUntilDone:NO];
  });
}

-(void)loadMix:(NSString*)uuid
{
  ResoModuleManager * moduleManager = [ResoModuleManager instance];
  
  //read in json data from file
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  NSData * mixJson = [NSData dataWithContentsOfFile:[[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix", uuid]] path]];
  
  NSString *strData = [[NSString alloc]initWithData:mixJson encoding:NSUTF8StringEncoding];
  NSLog(@"loading mixJson: %@", strData);
  
  //construct dictionary
  NSDictionary * mix = [NSJSONSerialization
                      JSONObjectWithData:mixJson
                      options:kNilOptions
                      error:nil];
  
  //iterate over dictionary and recreate modules
  NSString * name = [mix objectForKey:@"name"];
  NSString * mixUuid = [mix objectForKey:@"uuid"];
  
  NSArray * modules = [mix objectForKey:@"modules"];
  for(NSDictionary * module in modules) {
    
    Module moduleNumber = (Module)[[module objectForKey:@"number"] intValue];
    ResoModule * m = [moduleManager.modules objectForKey:[NSNumber numberWithInt:moduleNumber]];
    
    ModuleType type = (ModuleType)[[module objectForKey:@"type"] intValue];
    float moduleVolume = [[module objectForKey:@"volume"] floatValue];
    if (type == ModuleType_Sound) {
      NSString * moduleUuid = [module objectForKey:@"uuid"];
      [m loadSound:moduleUuid looped:true];
      [m.sound play];
      [m.sound stop];
      
      NSDictionary * effectTypes = [module objectForKey:@"effects"];
      NSArray * effectTypeKeys = [effectTypes allKeys];
      for(NSString * et in effectTypeKeys) {
        
        EffectType effectType = (EffectType)[et intValue];
        [m.sound addEffectOfType:effectType];
        
        NSDictionary * effectParameters = [effectTypes objectForKey:et];
        NSArray * effectParameterKeys = [effectParameters allKeys];
        for(NSString * ep in effectParameterKeys) {
          
          EffectParameter effectParameter = (EffectParameter)[ep intValue];
          float effectParameterValue = [[effectParameters objectForKey:ep] floatValue];
          [m.sound setEffectValueForType:effectType forParameter:effectParameter withValue:effectParameterValue];
        }
      }
      
      [m.sound setVolume:moduleVolume];
      [m.sound play];
      
    }
    if (type == ModuleType_Tone) {
      float bg = [[module objectForKey:@"binaural_gap"] floatValue];
      float fq = [[module objectForKey:@"frequency"] floatValue];
      
      [m.tone setPropertyOfType:BinauralGap withValue:bg];
      [m.tone setPropertyOfType:Frequency withValue:fq];
      [m.tone setVolume:moduleVolume];
      [m.tone play];
    }
  }
}

-(void)removeMix:(NSString*)uuid
{
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  [ad removeMixWithIdentifier:uuid];
  [[NSFileManager defaultManager] removeItemAtPath:[[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@", uuid]] path] error:nil];
}

-(void)shareMix:(NSString*)uuid
{
  
}

-(void)finishPreviewRecording
{
  [recordingTimer invalidate];
  [soundEngine stopRecording];
  
  NSLog(@"preview mix recording finished");
}

-(void)mixThumbnailDone
{
  
}

@end
