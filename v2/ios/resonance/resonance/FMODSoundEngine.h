//
//  FMODSoundEngine.h
//  resonance
//
//  Created by Daniel Stepp on 5/23/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "fmod.hpp"
//#import "fmod_errors.h"

#import "ISoundEngine.h"

@interface FMODSoundEngine : NSObject <ISoundEngine>

//@property (readonly) FMOD::System * system;
//@property (readonly) FMOD::System * recordingSystem;

+(id<ISoundEngine>)instance;
-(void)deinstance;

-(id<ISound>)getSoundForUuid:(NSString*)uuid;
-(id<ITone>)getToneForUuid:(NSString*)uuid;

@end