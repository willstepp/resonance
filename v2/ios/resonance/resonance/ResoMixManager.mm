//
//  ResoMixManager.m
//  resonance
//
//  Created by Daniel Stepp on 6/15/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ResoAppDelegate.h"
#import "ResoDataManager.h"
#import "ResoFileManager.h"
#import "ResoMixManager.h"
#import "ResoTypes.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"
#import "ISound.h"
#import "ITone.h"
#import "IResoVisualization.h"

#import "FMODSoundEngine.h"

#import "ResoThumbnailGenerator.h"
#import "ResoMediaTransferManager.h"
#import "ResoMediaTransfer.h"

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
  ResoDataManager * rdm = [ResoDataManager instance];
  NSString * uuid = [[[NSUUID UUID] UUIDString] lowercaseString];
  currentMixUuid = uuid;
  
  //1) create mix dictionary
  NSMutableDictionary * mix = [[NSMutableDictionary alloc] init];
  [mix setObject:name forKey:@"name"];
  [mix setObject:uuid forKey:@"uuid"];
  
  NSMutableArray * mixUuids = [[NSMutableArray alloc] init];
  NSMutableArray * modules = [[NSMutableArray alloc] init];

  for(id key in [ResoModuleManager instance].modules) {
    ResoModule * rm = [[ResoModuleManager instance].modules objectForKey:key];
    
    if (![rm.moduleUuid isEqualToString:@"preview"]) {
      ModuleType type = rm.type;
      if (type != ModuleType_Unloaded) {
        
        NSMutableDictionary * module = [[NSMutableDictionary alloc] init];
        //every module will be 0 for now
        [module setObject:rm.moduleUuid forKey:@"number"];
        [module setObject:rm.soundUuid forKey:@"uuid"];
        
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
        [mixUuids addObject:rm.soundUuid];
      }
    }
  }

  [mix setObject:modules forKey:@"modules"];
  
  //2) create coredata record
  [rdm addMixWithId:uuid name:name state:Completed sounds:mixUuids shared:NO];
  
  //3) persist mix data to file as json
  [ResoFileManager ensureDirectoryExists:[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@", uuid]]];
  
  NSError * error = nil;
  NSData * mixJson = [NSJSONSerialization dataWithJSONObject:mix options:NSJSONWritingPrettyPrinted error:&error];
  
  NSString *strData = [[NSString alloc]initWithData:mixJson encoding:NSUTF8StringEncoding];
  NSLog(@"mixJson: %@", strData);
  
  [mixJson writeToFile:[[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix", uuid]] path] atomically:YES];
  
  //4) record 15 second mix preview clip
  [soundEngine startRecording:[[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview", uuid]] path] dynamicInput:false];
  
  recordingTimer = [NSTimer scheduledTimerWithTimeInterval:15
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
    [UIImageJPEGRepresentation(thumb, 1.0) writeToFile:[[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb", uuid]] path] atomically:YES];
    
    [self performSelectorOnMainThread:@selector(mixThumbnailDone)
                           withObject:nil waitUntilDone:NO];
  });
}

-(void)loadMix:(NSString*)uuid
{
  ResoModuleManager * moduleManager = [ResoModuleManager instance];
  [moduleManager unloadCurrentMix];
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  [ad.visualization clearSounds];

  //read in json data from file
  NSData * mixJson = [NSData dataWithContentsOfFile:[[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix", uuid]] path]];
  
  NSString *strData = [[NSString alloc]initWithData:mixJson encoding:NSUTF8StringEncoding];
  NSLog(@"loading mixJson: %@", strData);
  
  //construct dictionary
  NSDictionary * mix = [NSJSONSerialization
                        JSONObjectWithData:mixJson
                        options:kNilOptions
                        error:nil];
  
  //iterate over dictionary and recreate modules
  NSArray * modules = [mix objectForKey:@"modules"];
  for(NSDictionary * module in modules) {
    
    NSString * moduleUuid = [module objectForKey:@"number"];
    [moduleManager addModuleWithUuid:moduleUuid];
    ResoModule * m = [moduleManager.modules objectForKey:moduleUuid];
    
    ModuleType type = (ModuleType)[[module objectForKey:@"type"] intValue];
    float moduleVolume = [[module objectForKey:@"volume"] floatValue];
    if (type == ModuleType_Sound) {
      NSString * soundUuid = [module objectForKey:@"uuid"];
      [m loadSound:soundUuid looped:true];
      [m.sound play];
      [m.sound setPaused:true];
      
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
      if (ad.playing) {
        [m.sound setPaused:false];
      }
      
      //add sound to visualization
      [ad.visualization addSound:soundUuid];
      
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
  [ad playAll];
}

-(void)removeMix:(NSString*)uuid
{
  ResoDataManager * rdm = [ResoDataManager instance];
  [rdm removeMixWithIdentifier:uuid];
  [[NSFileManager defaultManager] removeItemAtPath:[[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@", uuid]] path] error:nil];
}

-(void)shareMix:(NSString*)uuid
{
  //upload using rtm
  ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
  [rmtm initTransferOfType:MixTransferUpload withIdentifier:uuid withObject:nil];
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