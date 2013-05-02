//
//  FMODSoundEngine.h
//  Resonance
//
//  Created by Daniel Stepp on 9/7/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "fmod.hpp"
#import "fmod_errors.h"

#import "ISoundEngine.h"

@interface FMODSoundEngine : NSObject <ISoundEngine>

@property (readonly) FMOD::System * system;
@property (readonly) FMOD::System * recordingSystem;

+(id<ISoundEngine>)instance;
-(void)deinstance;

-(id<ISound>)getSoundForId:(int)identifier;
-(id<ITone>)getToneForId:(int)identifier;

@end
