//
//  ISoundEngine.h
//  Resonance
//
//  Created by Daniel Stepp on 9/7/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RESOTypes.h"

@protocol ISound;
@protocol ITone;

@protocol ISoundEngine <NSObject>

+(id<ISoundEngine>)instance;
-(void)deinstance;

-(id<ISound>)getSoundForId:(int)identifier;
-(id<ITone>)getToneForId:(int)identifier;

-(void)startRecording:(NSString*)fileName;
-(void)stopRecording;

@end