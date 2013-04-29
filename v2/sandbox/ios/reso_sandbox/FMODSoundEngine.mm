//
//  FMODSoundEngine.m
//  Resonance
//
//  Created by Daniel Stepp on 9/7/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import "FMODSoundEngine.h"
#import "FMODSound.h"
#import "FMODTone.h"

@interface FMODSoundEngine()
{
    NSMutableDictionary * sounds;
    NSMutableDictionary * tones;
    
    NSMutableDictionary * recordingSounds;
    NSMutableDictionary * recordingTones;
}
@end

@implementation FMODSoundEngine
@synthesize system;
@synthesize recordingSystem;

static FMODSoundEngine * player = nil;

-(id)init
{
    //enforce client to initWithEngineType
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                        reason:@"-init is not a valid initializer for the class FMODSoundEngine. Use -instance"
                        userInfo:nil];
    return nil;
}

#pragma mark
#pragma ISoundEngine methods

+(id<ISoundEngine>) instance
{
    if (player == nil)
        player = [[FMODSoundEngine alloc] initForSingleton];
    return player;
}

-(id)initForSingleton
{
    if (self = [super init])
    {
        FMOD_RESULT result = FMOD_OK;
        result = FMOD::System_Create(&system);
        result = system->init(32,
                                  FMOD_INIT_NORMAL | FMOD_INIT_ENABLE_PROFILE,
                                  NULL);
        sounds = [[NSMutableDictionary alloc] init];
        tones = [[NSMutableDictionary alloc] init];
        recordingSystem = nil;
    }
    return self;
}

-(void)deinstance
{
    [self stopRecording];
    
    if (sounds) sounds = nil;
    if (tones) tones = nil;
    
    if (system)
    {
        system->release();
        system = NULL;
    }
}

- (id<ISound>) getSoundForId:(int)identifier
{
    FMODSound * s = [sounds objectForKey:[NSNumber numberWithInt:identifier]];
    if (s == NULL)
    {
        s = [[FMODSound alloc] initWithSoundEngine:self];
        [sounds setObject:s forKey:[NSNumber numberWithInt:identifier]];
    }
    return s;
}

- (id<ITone>) getToneForId:(int)identifier
{
    FMODTone * t = [tones objectForKey:[NSNumber numberWithInt:identifier]];
    if (t == NULL)
    {
        t = [[FMODTone alloc] initWithSoundEngine:self];
        [tones setObject:t forKey:[NSNumber numberWithInt:identifier]];
    }
    return t;
}

-(void)startRecording:(NSString*)fileName
{
    //cleanup any old recordings
    [self stopRecording];
    
    recordingSounds = [[NSMutableDictionary alloc] init];
    recordingTones = [[NSMutableDictionary alloc] init];
    
    //initialize new recording system
    FMOD_RESULT result = FMOD_OK;
    result = FMOD::System_Create(&recordingSystem);
    result = recordingSystem->setOutput(FMOD_OUTPUTTYPE_WAVWRITER);
        
    char fn[256] = {0};
    [fileName getCString:fn maxLength:256 encoding:NSASCIIStringEncoding];
    recordingSystem->init(32, FMOD_INIT_NORMAL | FMOD_INIT_ENABLE_PROFILE, fn);
    
    //load sounds
    NSArray * soundKeys = [sounds allKeys];
    for (id sk in soundKeys)
    {
        FMODSound * s = [sounds objectForKey:sk];
        if (s)
        {
            FMODSound * rs = [[FMODSound alloc] initWithFMODSystem:recordingSystem];
            
            [rs load:[s url]];
            //playing/stopping will initialize channel, needed for effect mapping
            [rs play];
            [rs stop];
            
            //set effects from mappings
            NSMutableDictionary * effectMappings = [s effectMappings];
            NSArray * effectKeys = [effectMappings allKeys];
            for (id e in effectKeys)
            {
                NSNumber * num = e;
                int effect = [num intValue];
                [rs addEffectOfType:(EffectType)(effect)];
                
                //set effect parameters from mappings
                NSMutableDictionary * parameterMappings = [effectMappings objectForKey:e];
                if (parameterMappings)
                {
                    NSArray * paramKeys = [parameterMappings allKeys];
                    for (id pk in paramKeys)
                    {
                        NSNumber * param = pk;
                        int p = [param intValue];
                        NSNumber * v = [parameterMappings objectForKey:pk];
                        float value = [v floatValue];
                        [rs setEffectValueForType:(EffectType)(effect) forParameter:(EffectParameter)(p) withValue:value];
                    }
                }
            }
            
            //update playing states
            if ([s playing]) [rs play];
            [rs setPaused:[s paused]];
            [rs setVolume:[s volume]];
            
            //save
            [recordingSounds setObject:rs forKey:sk];
            [s addListener:rs];
        }
    }
    
    //load tones
    NSArray * toneKeys = [tones allKeys];
    for (id tk in toneKeys)
    {
        FMODTone * t = [tones objectForKey:tk];
        if (t)
        {
            FMODTone * rt = [[FMODTone alloc] initWithFMODSystem:recordingSystem];
            
            [rt load:[t toneType]];
            [rt play];
            [rt stop];
            
            //set parameters
            if ([t toneType] == ToneType::Binaural)
            {
                float bg = [t getPropertyOfType:ToneProperty::BinauralGap];
                [rt setPropertyOfType:ToneProperty::BinauralGap withValue:bg];
            }
            float freq = [t getPropertyOfType:ToneProperty::Frequency];
            [rt setPropertyOfType:ToneProperty::Frequency withValue:freq];
            
            //update playing states
            if ([t playing]) [rt play];
            [rt setPaused:[t paused]];
            [rt setVolume:[t volume]];
            
            //save
            [recordingTones setObject:rt forKey:tk];
            [t addListener:rt];
        }
    }

}

-(void)stopRecording
{
    //removing listeners
    NSArray * soundKeys = [sounds allKeys];
    for (id sk in soundKeys)
    {
        FMODSound * s = [sounds objectForKey:sk];
        if (s) [s removeListener];
    }
    NSArray * toneKeys = [tones allKeys];
    for (id tk in toneKeys)
    {
        FMODTone * t = [tones objectForKey:tk];
        if (t) [t removeListener];
    }
    
    //release resources
    if (recordingSounds) recordingSounds = nil;
    if (recordingTones) recordingTones = nil;
    if (recordingSystem)
    {
        recordingSystem->release();
        recordingSystem = NULL;
    }
}

@end
