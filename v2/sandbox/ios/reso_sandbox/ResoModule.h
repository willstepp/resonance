//
//  ResoModule.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/8/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResoTypes.h"

@protocol ISoundEngine;

@interface ResoModule : NSObject
@property (readonly) NSString * uuid;
@property (readonly) int tag;

-(id)initWithSoundEngine:(id<ISoundEngine>)ise tag:(int)t;

-(void)loadSound:(NSString*)newUuid looped:(bool)l;
-(void)loadPreview:(NSString*)newUuid looped:(bool)l;
-(bool)loaded;

-(void)unload;

-(void)play;
-(bool)playing;

-(void)setPaused:(bool)state;
-(bool)paused;

-(void)stop;

-(void)setVolume:(float)value;
-(float)volume;

-(void)addEffectOfType:(EffectType)et;
-(void)setEffectValueForType:(EffectType)et forParameter:(EffectParameter)ep withValue:(float)value;
-(void)removeEffectOfType:(EffectType)et;
@end
