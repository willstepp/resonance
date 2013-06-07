//
//  ResoModule.mm
//  resonance
//
//  Created by Daniel Stepp on 5/23/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

//
//  ResoModule.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/8/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoAppDelegate.h"
#import "ResoFileManager.h"
#import "ResoModule.h"

#import "ISoundEngine.h"
#import "ISound.h"
#import "ITone.h"

@interface ResoModule ()
{
  id<ISoundEngine> soundEngine;
}
@property (nonatomic, readwrite) ModuleType type;
@property (nonatomic, readwrite) NSString *  soundUuid;
@property (nonatomic, readwrite) NSString * moduleUuid;

@property (nonatomic, readwrite) id<ISound> sound;
@property (nonatomic, readwrite) id<ITone> tone;
@end

@implementation ResoModule
@synthesize type, soundUuid, moduleUuid, sound, tone, volume;

-(id)init
{
  //enforce client use to initWithSoundEngine
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"-init is not a valid initializer for the class ResoModule. Use -initWithSoundEngine"
                               userInfo:nil];
  return nil;
}

-(id)initWithSoundEngine:(id<ISoundEngine>)ise uuid:(NSString*)uuid
{
  if (self = [super init])
  {
    moduleUuid = uuid;
    soundEngine = ise;
    sound = [soundEngine getSoundForUuid:uuid];
    tone = [soundEngine getToneForUuid:uuid];
    type = ModuleType_Unloaded;
    soundUuid = @"";
  }
  return self;
}

-(void)dealloc
{
  [self unload];
  tone = nil;
  sound = nil;
  soundEngine = nil;
}

-(bool)loaded
{
  return [tone loaded] || [sound loaded];
}

-(void)loadSound:(NSString*)newUuid looped:(bool)l
{
  soundUuid = newUuid;
  
  NSString * soundPath = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/sound", soundUuid]] path];
  bool exists = [[NSFileManager defaultManager] fileExistsAtPath:soundPath];
  if (exists) {
    [sound load:soundPath looped:l];
    type = ModuleType_Sound;
  }
}

-(void)loadPreview:(NSString*)newUuid looped:(bool)l mediaType:(int)t
{
  soundUuid = newUuid;
  
  NSString * mediaType = (t == MediaType_Sound ? @"sounds" : @"mixes");
  NSString * previewPath = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"%@/%@/preview", mediaType, soundUuid]] path];
  bool exists = [[NSFileManager defaultManager] fileExistsAtPath:previewPath];
  if (exists) {
    [sound load:previewPath looped:l];
    type = ModuleType_Sound;
  }
}

-(void)unload
{
  if ([tone loaded]) [tone unload];
  if ([sound loaded]) [sound unload];
}

-(void)updateVolume:(float)v
{
  float normalized = v / 100.0f;
  if (type == ModuleType_Sound) {
    [sound setVolume:normalized];
  }
  if (type == ModuleType_Tone) {
    [tone setVolume:normalized];
  }
}

@end
