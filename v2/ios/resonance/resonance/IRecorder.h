//
//  IRecorder.h
//  sound_engine_sandbox
//
//  Created by Daniel Stepp on 9/15/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IRecorder <NSObject>
-(void)startRecording:(NSString*)fileName;
-(void)stopRecording;
@end
