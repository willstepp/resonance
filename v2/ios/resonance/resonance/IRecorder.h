//
//  IRecorder.h
//  resonance
//
//  Created by Daniel Stepp on 5/23/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IRecorder <NSObject>
-(void)startRecording:(NSString*)fileName;
-(void)stopRecording;
@end
