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

-(id<ISound>)getSoundForId:(int)identifier;
-(id<ITone>)getToneForId:(int)identifier;

-(void)startRecording:(NSString*)fileName dynamicInput:(bool)di;
-(void)stopRecording;

@end