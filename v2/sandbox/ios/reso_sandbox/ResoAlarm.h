//
//  ResoAlarm.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/8/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ResoAlarmDelegate <NSObject>

-(void) alarmSecondsRemaining:(NSNumber*)seconds;
-(void) alarmFinished;

@end

@interface ResoAlarm : NSObject {
  NSMutableArray * delegates;
}

+(ResoAlarm*)instance;

-(void)setTimeout:(int)seconds;
-(void)start;
-(void)stop;

@property (readonly) int secondsRemaining;
@property (readonly) bool running;

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskId;

- (NSMutableArray*)delegates;
- (void)addDelegate:(id<ResoAlarmDelegate>)d;
- (void)removeDelegate:(id<ResoAlarmDelegate>)d;

@end
