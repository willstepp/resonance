//
//  ISoundEngine.h
//  Resonance
//
//  Created by Daniel Stepp on 9/7/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

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