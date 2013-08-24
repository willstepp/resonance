//
//  ResoTimer.h
//  resonance
//
//  Created by Daniel Stepp on 6/17/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ResoTimerDelegate <NSObject>

-(void) timerSecondsRemaining:(NSNumber*)seconds;
-(void) timerStarted;
-(void) timerFinished;

@end

@interface ResoTimer : NSObject {
  NSMutableArray * delegates;
}

+(ResoTimer*)instance;

-(void)setTimeout:(int)seconds;
-(void)start;
-(void)stop;

@property (readonly) int secondsRemaining;
@property (readonly) bool running;

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskId;

- (NSMutableArray*)delegates;
- (void)addDelegate:(id<ResoTimerDelegate>)d;
- (void)removeDelegate:(id<ResoTimerDelegate>)d;

@end