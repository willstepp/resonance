//
//  ITone.h
//  resonance
//
//  Created by Daniel Stepp on 5/23/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResoTypes.h"

@protocol ISoundEngine;

@protocol ITone <NSObject>

-(id)initWithSoundEngine:(id<ISoundEngine>)ise;

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

@end