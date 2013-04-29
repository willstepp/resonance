//
//  FMODSound.m
//  Resonance
//
//  Created by Daniel Stepp on 9/7/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import "FMODSound.h"

@interface FMODSound()
{
    FMOD::Sound * sound;
    FMOD::Channel * channel;
    
    FMOD::DSP * reverb;
    FMOD::DSP * pitch;
    FMOD::DSP * distortion;
    FMOD::DSP * echo;
    FMOD::DSP * flange;
    
    FMOD::System * system;
    
    bool loaded;
    bool playing;
    NSString * url;
    
    NSMutableDictionary * effectMappings;
    
    id<ISound> listener;
}
-(void)ensureSoundReleased;
-(FMOD::DSP*)getDSPWithEffectType:(EffectType)et;
-(FMOD_DSP_TYPE)getDSPTypeWithEffectType:(EffectType)et;
-(void)setDSPWithEffectType:(EffectType)et withEffect:(FMOD::DSP*)effect;
-(int)getDSPParameterWithEffectParameter:(EffectParameter)ep;
-(EffectParameter)getEffectParameterFromDSPParameter:(int)p withType:(EffectType)et;
-(void)loadEffectMappings;
-(void)unloadEffectMappings;
-(void)addEffectMappingsForType:(EffectType)et;
-(void)removeEffectMappingsForType:(EffectType)et;
-(void)updateEffectMappingsForType:(EffectType)et forParameter:(EffectParameter)ep withValue:(float)value;
-(void)loadEffects;
@end

@implementation FMODSound

-(id)init
{
    //enforce client to use initWithSoundEngine
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                        reason:@"-init is not a valid initializer for the class FMODSound. Use -initWithSoundEngine instead."
                        userInfo:nil];
    return nil;
}

-(void)dealloc
{
    [self ensureSoundReleased];
    system = NULL;
    reverb = pitch = distortion = echo = flange = NULL;
    listener = nil;
}

-(void)ensureSoundReleased
{
    if (sound)
    {
        channel->stop();
        channel = NULL;
        sound->release();
        sound = NULL;
        loaded = false;
        playing = false;
        url = @"";
        [self unloadEffectMappings];
    }
}

-(FMOD::DSP*)getDSPWithEffectType:(EffectType)et
{
    switch (et)
    {
        case EffectType::Reverb:
            return reverb;
        case EffectType::Pitch:
            return pitch;
        case EffectType::Distortion:
            return distortion;
        case EffectType::Echo:
            return echo;
        case EffectType::Flange:
            return flange;
        default:
            return NULL;
    }
}

-(void)setDSPWithEffectType:(EffectType)et withEffect:(FMOD::DSP*)effect
{
    switch (et)
    {
        case EffectType::Reverb:
            reverb = effect;
            break;
        case EffectType::Pitch:
            pitch = effect;
            break;
        case EffectType::Distortion:
            distortion = effect;
            break;
        case EffectType::Echo:
            echo = effect;
            break;
        case EffectType::Flange:
            flange = effect;
            break;
        default:
            break;
    }
}

-(FMOD_DSP_TYPE)getDSPTypeWithEffectType:(EffectType)et
{
    switch(et)
    {
        case EffectType::Reverb:
            return FMOD_DSP_TYPE_SFXREVERB;
        case EffectType::Pitch:
            return FMOD_DSP_TYPE_PITCHSHIFT;
        case EffectType::Echo:
            return FMOD_DSP_TYPE_ECHO;
        case EffectType::Distortion:
            return FMOD_DSP_TYPE_DISTORTION;
        case EffectType::Flange:
            return FMOD_DSP_TYPE_FLANGE;
        default:
            return FMOD_DSP_TYPE_UNKNOWN;
    }
}

-(int)getDSPParameterWithEffectParameter:(EffectParameter)ep
{
    switch (ep)
    {
        case EffectParameter::Reverb_DryLevel:
            return FMOD_DSP_SFXREVERB_DRYLEVEL;
        case EffectParameter::Reverb_Room:
            return FMOD_DSP_SFXREVERB_ROOM;
        case EffectParameter::Reverb_RoomHF:
            return FMOD_DSP_SFXREVERB_ROOMHF;
        case EffectParameter::Reverb_DecayTime:
            return FMOD_DSP_SFXREVERB_DECAYTIME;
        case EffectParameter::Reverb_DecayHFRatio:
            return FMOD_DSP_SFXREVERB_DECAYHFRATIO;
        case EffectParameter::Reverb_ReflectionsLevel:
            return FMOD_DSP_SFXREVERB_REFLECTIONSLEVEL;
        case EffectParameter::Reverb_ReflectionsDelay:
            return FMOD_DSP_SFXREVERB_REFLECTIONSDELAY;
        case EffectParameter::Reverb_ReverbLevel:
            return FMOD_DSP_SFXREVERB_REVERBLEVEL;
        case EffectParameter::Reverb_ReverbDelay:
            return FMOD_DSP_SFXREVERB_REVERBDELAY;
        case EffectParameter::Reverb_Diffusion:
            return FMOD_DSP_SFXREVERB_DIFFUSION;
        case EffectParameter::Reverb_Density:
            return FMOD_DSP_SFXREVERB_DENSITY;
        case EffectParameter::Reverb_HFReference:
            return FMOD_DSP_SFXREVERB_HFREFERENCE;
        case EffectParameter::Reverb_RoomLF:
            return FMOD_DSP_SFXREVERB_ROOMLF;
        case EffectParameter::Reverb_LFReference:
            return FMOD_DSP_SFXREVERB_LFREFERENCE;
            
        case EffectParameter::Echo_Delay:
            return FMOD_DSP_ECHO_DELAY;
        case EffectParameter::Echo_DecayRatio:
            return FMOD_DSP_ECHO_DECAYRATIO;
        case EffectParameter::Echo_MaxChannels:
            return FMOD_DSP_ECHO_MAXCHANNELS;
        case EffectParameter::Echo_DryMix:
            return FMOD_DSP_ECHO_DRYMIX;
        case EffectParameter::Echo_WetMix:
            return FMOD_DSP_ECHO_WETMIX;
        
        case EffectParameter::Flange_DryMix:
            return FMOD_DSP_FLANGE_DRYMIX;
        case EffectParameter::Flange_WetMix:
            return FMOD_DSP_FLANGE_WETMIX;
        case EffectParameter::Flange_Depth:
            return FMOD_DSP_FLANGE_DEPTH;
        case EffectParameter::Flange_Rate:
            return FMOD_DSP_FLANGE_RATE;
            
        case EffectParameter::Distortion_Level:
            return FMOD_DSP_DISTORTION_LEVEL;
            
        case EffectParameter::Pitch_Value:
            return FMOD_DSP_PITCHSHIFT_PITCH;
        case EffectParameter::Pitch_FFTSize:
            return FMOD_DSP_PITCHSHIFT_FFTSIZE;
        case EffectParameter::Pitch_Overlap:
            return FMOD_DSP_PITCHSHIFT_OVERLAP;
        case EffectParameter::Pitch_MaxChannels:
            return FMOD_DSP_PITCHSHIFT_MAXCHANNELS;
            
        default:
            return FMOD_DSP_TYPE_UNKNOWN;
    }
}

-(EffectParameter)getEffectParameterFromDSPParameter:(int)p withType:(EffectType)et
{
    switch (et)
    {
        case EffectType::Reverb:
        {
            switch (p)
            {
                case FMOD_DSP_SFXREVERB_DRYLEVEL:
                    return EffectParameter::Reverb_DryLevel;
                case FMOD_DSP_SFXREVERB_ROOM:
                    return EffectParameter::Reverb_Room;
                case FMOD_DSP_SFXREVERB_ROOMHF:
                    return EffectParameter::Reverb_RoomHF;
                case FMOD_DSP_SFXREVERB_DECAYTIME:
                    return EffectParameter::Reverb_DecayTime;
                case FMOD_DSP_SFXREVERB_DECAYHFRATIO:
                    return EffectParameter::Reverb_DecayHFRatio;
                case FMOD_DSP_SFXREVERB_REFLECTIONSLEVEL:
                    return EffectParameter::Reverb_ReflectionsLevel;
                case FMOD_DSP_SFXREVERB_REFLECTIONSDELAY:
                    return EffectParameter::Reverb_ReflectionsDelay;
                case FMOD_DSP_SFXREVERB_REVERBLEVEL:
                    return EffectParameter::Reverb_ReverbLevel;
                case FMOD_DSP_SFXREVERB_REVERBDELAY:
                    return EffectParameter::Reverb_ReverbDelay;
                case FMOD_DSP_SFXREVERB_DIFFUSION:
                    return EffectParameter::Reverb_Diffusion;
                case FMOD_DSP_SFXREVERB_DENSITY:
                    return EffectParameter::Reverb_Density;
                case FMOD_DSP_SFXREVERB_HFREFERENCE:
                    return EffectParameter::Reverb_HFReference;
                case FMOD_DSP_SFXREVERB_ROOMLF:
                    return EffectParameter::Reverb_RoomLF;
                case FMOD_DSP_SFXREVERB_LFREFERENCE:
                    return EffectParameter::Reverb_LFReference;
                default:
                    return EffectParameter::EffectParameterCount;
            }
        }
        case EffectType::Pitch:
        {
            switch (p)
            {
                case FMOD_DSP_PITCHSHIFT_PITCH:
                    return EffectParameter::Pitch_Value;
                case FMOD_DSP_PITCHSHIFT_FFTSIZE:
                    return EffectParameter::Pitch_FFTSize;
                case FMOD_DSP_PITCHSHIFT_OVERLAP:
                    return EffectParameter::Pitch_Overlap;
                case FMOD_DSP_PITCHSHIFT_MAXCHANNELS:
                    return EffectParameter::Pitch_MaxChannels;
                default:
                    return EffectParameter::EffectParameterCount;
            }
        }
        case EffectType::Echo:
        {
            switch (p)
            {
                case FMOD_DSP_ECHO_DELAY:
                    return EffectParameter::Echo_Delay;
                case FMOD_DSP_ECHO_DECAYRATIO:
                    return EffectParameter::Echo_DecayRatio;
                case FMOD_DSP_ECHO_MAXCHANNELS:
                    return EffectParameter::Echo_MaxChannels;
                case FMOD_DSP_ECHO_DRYMIX:
                    return EffectParameter::Echo_DryMix;
                case FMOD_DSP_ECHO_WETMIX:
                    return EffectParameter::Echo_WetMix;
                default:
                    return EffectParameter::EffectParameterCount;
            }
        }
        case EffectType::Distortion:
        {
            switch (p)
            {
                case FMOD_DSP_DISTORTION_LEVEL:
                    return EffectParameter::Distortion_Level;
                default:
                    return EffectParameter::EffectParameterCount;
            }
        }
        case EffectType::Flange:
        {
            switch (p)
            {
                case FMOD_DSP_FLANGE_DRYMIX:
                    return EffectParameter::Flange_DryMix;
                case FMOD_DSP_FLANGE_WETMIX:
                    return EffectParameter::Flange_WetMix;
                case FMOD_DSP_FLANGE_DEPTH:
                    return EffectParameter::Flange_Depth;
                case FMOD_DSP_FLANGE_RATE:
                    return EffectParameter::Flange_Rate;
                default:
                    return EffectParameter::EffectParameterCount;
            }
        }
        default:
            return EffectParameter::EffectParameterCount;
    }
}

#pragma mark
#pragma ISound methods

-(id)initWithSoundEngine:(id<ISoundEngine>)ise
{
    if (self = [super init])
    {
        FMODSoundEngine * se = ise;
        system = se.system;
        reverb = pitch = distortion = echo = flange = NULL;
        loaded = false;
        playing = false;
        url = @"";
        effectMappings = nil;
        listener = nil;
    }
    return self;
}

-(id)initWithFMODSystem:(FMOD::System*)s
{
    if (self = [super init])
    {
        system = s;
        reverb = pitch = distortion = echo = flange = NULL;
        loaded = false;
        playing = false;
        url = @"";
        effectMappings = nil;
        listener = nil;
    }
    return self;
}

-(void)load:(NSString*)newUrl
{
    [self ensureSoundReleased];
    
    FMOD_RESULT result = FMOD_OK;
    char buffer[200] = {0};

    [newUrl getCString:buffer maxLength:200 encoding:NSASCIIStringEncoding];
    result = system->createStream(buffer, FMOD_SOFTWARE | FMOD_LOOP_NORMAL, NULL, &sound);
    
    url = newUrl;
    loaded = true;
    [self loadEffectMappings];
    
    if (listener) [listener load:newUrl];
}

-(void)unload
{
    [self ensureSoundReleased];
    if (listener) [listener unload];
}

-(NSString*)url
{
    return url;
}

-(bool)loaded
{
    return loaded;
}

-(void)play
{
    if (sound)
    {
        system->playSound(FMOD_CHANNEL_FREE, sound, false, &channel);
        playing = true;
        [self loadEffects];
    }
    if (listener) [listener play];
}

-(void)stop
{
    if (channel) channel->stop();
    playing = false;
    
    if (listener) [listener stop];
}

-(bool)playing
{
    return playing;
}

-(void)loadEffects
{
    NSArray * ems = [effectMappings allKeys];
    for (id em in ems)
    {
        //first release the effect
        NSNumber * effectType = em;
        EffectType et = (EffectType)[effectType intValue];
        FMOD::DSP * effect = [self getDSPWithEffectType:(EffectType)et];
        if (effect) effect->remove(); effect = NULL;
        
        //recreate the effect
        system->createDSPByType([self getDSPTypeWithEffectType:(EffectType)et], &effect);
        channel->addDSP(effect, 0);
        [self setDSPWithEffectType:(EffectType)et withEffect:effect];
        
        //set the effect parameters
        NSMutableDictionary * effectParams = [effectMappings objectForKey:em];
        NSArray * epms = [effectParams allKeys];
        for (id epm in epms)
        {
            NSNumber * effectParam = epm;
            EffectParameter ep = (EffectParameter)[effectParam intValue];
            NSNumber * paramValue = [effectParams objectForKey:epm];
            float value = [paramValue floatValue];
            effect->setParameter([self getDSPParameterWithEffectParameter:ep], value);
        }
    }
}

-(void)setPaused:(bool)state
{
    if (channel) channel->setPaused(state);
    
    if (listener) [listener setPaused:state];
}

-(bool)paused
{
    bool paused = false;
    if (channel) channel->getPaused(&paused);
    return paused;
}

-(void)setVolume:(float)value
{
    if (channel) channel->setVolume(value);
    
    if (listener) [listener setVolume:value];
}

-(float)volume
{
    float volume = 0.0f;
    if (channel) channel->getVolume(&volume);
    return volume;
}

-(void)addEffectOfType:(EffectType)et;
{
    if (channel)
    {
        [self removeEffectOfType:et];
        
        FMOD::DSP * effect = NULL;
        system->createDSPByType([self getDSPTypeWithEffectType:et], &effect);
        channel->addDSP(effect, 0);
        
        [self setDSPWithEffectType:et withEffect:effect];
        [self addEffectMappingsForType:et];
    }
    if (listener) [listener addEffectOfType:et];
}

-(void)removeEffectOfType:(EffectType)et
{
    FMOD::DSP * effect = [self getDSPWithEffectType:et];
    if (effect) effect->remove(); effect = NULL;
    [self setDSPWithEffectType:et withEffect:effect];
    [self removeEffectMappingsForType:et];
    
    if (listener) [listener removeEffectOfType:et];
}

-(void)setEffectValueForType:(EffectType)et forParameter:(EffectParameter)ep withValue:(float)value
{
    FMOD::DSP * effect = [self getDSPWithEffectType:et];
    if (effect)
    {
        effect->setParameter([self getDSPParameterWithEffectParameter:ep], value);
        [self updateEffectMappingsForType:et forParameter:ep withValue:value];
    }
    
    if (listener) [listener setEffectValueForType:et forParameter:ep withValue:value];
}

-(NSMutableDictionary*)effectMappings
{
    return effectMappings;
}

-(void)loadEffectMappings
{
    if (sound)
    {
        effectMappings = [[NSMutableDictionary alloc] initWithCapacity:EffectType::EffectTypeCount];
    }
}

-(void)addEffectMappingsForType:(EffectType)et
{
    [self removeEffectMappingsForType:et];
    
    FMOD::DSP * effect = [self getDSPWithEffectType:et];
    int numParams = 0;
    if (effect) effect->getNumParameters(&numParams);
    NSMutableDictionary * mappings = [[NSMutableDictionary alloc] initWithCapacity:numParams];
    for (int i = 0; i < numParams; i++)
    {
        float param = 0.0f;
        effect->getParameter(i, &param, NULL, 0);
        EffectParameter ep = [self getEffectParameterFromDSPParameter:i withType:et];
        [mappings setObject:[NSNumber numberWithFloat:param] forKey:[NSNumber numberWithInt:ep]];
    }
    if ([mappings count] > 0)
        [effectMappings setObject:mappings forKey:[NSNumber numberWithInt:et]];
    else
        mappings = nil;
}

-(void)updateEffectMappingsForType:(EffectType)et forParameter:(EffectParameter)ep withValue:(float)value
{
    NSMutableDictionary * mappings = [effectMappings objectForKey:[NSNumber numberWithInt:et]];
    if (mappings) [mappings setObject:[NSNumber numberWithFloat:value] forKey:[NSNumber numberWithInt:ep]];
}

-(void)removeEffectMappingsForType:(EffectType)et
{
    NSMutableDictionary * mappings = [effectMappings objectForKey:[NSNumber numberWithInt:et]];
    if (mappings) { [mappings removeAllObjects]; mappings = nil; }
}

-(void)unloadEffectMappings
{
    NSArray * effects = [effectMappings allKeys];
    for (id e in effects)
    {
        NSMutableDictionary * params = [effectMappings objectForKey:e];
        if (params) { [params removeAllObjects]; params = nil; }
    }
    effectMappings = nil;
}

-(void)addListener:(id<ISound>)l
{
    listener = l;
}

-(void)removeListener
{
    listener = nil;
}

@end
