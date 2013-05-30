//
//  ISoundEngine.h
//  resonance
//
//  Created by Daniel Stepp on 5/23/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

@protocol ISound;
@protocol ITone;

@protocol ISoundEngine <NSObject>

+(id<ISoundEngine>)instance;
-(void)deinstance;

-(id<ISound>)getSoundForUuid:(NSString*)uuid;
-(id<ITone>)getToneForUuid:(NSString*)uuid;

-(void)startRecording:(NSString*)fileName dynamicInput:(bool)di;
-(void)stopRecording;

@end