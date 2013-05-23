//
//  FMODSound.h
//  resonance
//
//  Created by Daniel Stepp on 5/23/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISound.h"

@interface FMODSound : NSObject <ISound>
-(id)initWithSoundEngine:(id<ISoundEngine>)ise;

-(void)load:(NSString*)newUrl;
-(void)load:(NSString*)newUrl looped:(BOOL)l;

-(void)unload;

-(NSString*)url;
-(bool)loaded;

-(void)play;
-(void)stop;

-(bool)playing;

-(bool)paused;
-(void)setPaused:(bool)state;

-(float)volume;
-(void)setVolume:(float)value;

-(NSMutableDictionary*)effectMappings;

-(void)addEffectOfType:(EffectType)et;
-(void)setEffectValueForType:(EffectType)et forParameter:(EffectParameter)ep withValue:(float)value;
-(void)removeEffectOfType:(EffectType)et;
-(bool)hasEffectOfType:(EffectType)et;
@end
