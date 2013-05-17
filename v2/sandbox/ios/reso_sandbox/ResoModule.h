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
@protocol ISound;
@protocol ITone;

@interface ResoModule : NSObject
@property (readonly) ModuleType type;
@property (readonly) NSString * uuid;
@property (readonly) int tag;

@property (readonly) id<ISound> sound;
@property (readonly) id<ITone> tone;

-(id)initWithSoundEngine:(id<ISoundEngine>)ise tag:(int)t;

-(void)loadSound:(NSString*)newUuid looped:(bool)l;
-(void)loadPreview:(NSString*)newUuid looped:(bool)l mediaType:(int)t;

@end
