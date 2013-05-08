//
//  ResoModule.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/8/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoAppDelegate.h"
#import "ResoModule.h"

#import "ISoundEngine.h"
#import "ISound.h"
#import "ITone.h"

@interface ResoModule ()
{
  id<ISoundEngine> soundEngine;
  id<ISound> sound;
  id<ITone> tone;
}
@property (nonatomic, readwrite) NSString *  uuid;
@property (nonatomic, readwrite) int tag;
@end

@implementation ResoModule
@synthesize uuid, tag;

-(id)init
{
  //enforce client use to initWithSoundEngine
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"-init is not a valid initializer for the class ResoModule. Use -initWithSoundEngine"
                               userInfo:nil];
  return nil;
}

-(id)initWithSoundEngine:(id<ISoundEngine>)ise tag:(int)t
{
  if (self = [super init])
  {
    tag = t;
    soundEngine = ise;
    sound = [soundEngine getSoundForId:tag];
    tone = [soundEngine getToneForId:tag];
  }
  return self;
}

-(void)loadSound:(NSString*)newUuid looped:(bool)l
{
  uuid = newUuid;
  
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  NSString * soundPath = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/sound", uuid]] path];
  bool exists = [[NSFileManager defaultManager] fileExistsAtPath:soundPath];
  if (exists) {
    [sound load:soundPath looped:l];
  }
}

-(void)loadPreview:(NSString*)newUuid looped:(bool)l
{
  uuid = newUuid;
  
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  NSString * previewPath = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/preview", uuid]] path];
  bool exists = [[NSFileManager defaultManager] fileExistsAtPath:previewPath];
  if (exists) {
    [sound load:previewPath looped:l];
  }
}

-(bool)loaded
{
  return [sound loaded];
}

-(void)unload
{
  [sound unload];
}

-(void)play
{
  [sound play];
}

-(bool)playing
{
  return [sound playing];
}

-(void)setPaused:(bool)state
{
  [sound setPaused:state];
}

-(bool)paused
{
  return [sound paused];
}

-(void)stop
{
  [sound stop];
}

-(void)setVolume:(float)value
{
  [sound setVolume:value];
}

-(float)volume
{
  return [sound volume];
}

-(void)addEffectOfType:(EffectType)et
{
  [sound addEffectOfType:et];
}

-(void)removeEffectOfType:(EffectType)et
{
  [sound removeEffectOfType:et];
}

-(void)setEffectValueForType:(EffectType)et forParameter:(EffectParameter)ep withValue:(float)value
{
  [sound setEffectValueForType:et forParameter:ep withValue:value];
}
@end
