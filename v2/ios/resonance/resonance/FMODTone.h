//
//  FMODTone.h
//  Resonance
//
//  Created by Daniel Stepp on 9/7/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMODSoundEngine.h"
#import "ITone.h"

@interface FMODTone : NSObject <ITone>

-(id)initWithSoundEngine:(id<ISoundEngine>)ise;
-(id)initWithFMODSystem:(FMOD::System*)s;

-(void)load:(ToneType)tt;
-(void)unload;

-(ToneType)toneType;
-(bool)loaded;

-(void)play;
-(void)stop;

-(bool)playing;

-(bool)paused;
-(void)setPaused:(bool)state;

-(float)volume;
-(void)setVolume:(float)value;

-(void)setPropertyOfType:(ToneProperty)tp withValue:(float)value;
-(float)getPropertyOfType:(ToneProperty)tp;

-(void)addListener:(id<ITone>)l;
-(void)removeListener;
@end
