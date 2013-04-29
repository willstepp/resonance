//
//  ISound.h
//  Resonance
//
//  Created by Daniel Stepp on 9/7/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISoundEngine.h"

@protocol ISound <NSObject>

-(id)initWithSoundEngine:(id<ISoundEngine>)ise;

-(void)load:(NSString*)newUrl;
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

@end