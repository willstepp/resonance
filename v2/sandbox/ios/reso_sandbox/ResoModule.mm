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
}
@property (nonatomic, readwrite) NSString *  uuid;
@property (nonatomic, readwrite) int tag;

@property (nonatomic, readwrite) id<ISound> sound;
@property (nonatomic, readwrite) id<ITone> tone;
@end

@implementation ResoModule
@synthesize uuid, tag, sound, tone;

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

@end
