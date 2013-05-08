//
//  ResoTimer.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/8/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoTimer.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"
#import "ISound.h"

@interface ResoTimer ()
{
  int totalSeconds;
  NSTimer * timer;
}
@property (nonatomic, readwrite) int secondsRemaining;
@property (nonatomic, readwrite) bool running;
@end

@implementation ResoTimer

@synthesize secondsRemaining, backgroundTaskId, running;
static ResoTimer * rt = nil;

-(id)init
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"-init is not a valid initializer for the class ResoTimer. Use -instance"
                               userInfo:nil];
  return nil;
}

+(ResoTimer*)instance
{
  if (rt == nil)
    rt = [[ResoTimer alloc] initForSingleton];
  return rt;
}

-(id)initForSingleton
{
  if (self = [super init])
  {
    delegates = [[NSMutableArray alloc] init];
    running = false;
    secondsRemaining = 0;
    totalSeconds = 0;
  }
  return self;
}

-(void)setTimeout:(int)seconds
{
  [self stop];
  totalSeconds = seconds;
  secondsRemaining = totalSeconds;
}

-(void)start
{
  [self stop];
  
  timer = [NSTimer scheduledTimerWithTimeInterval:1
                   target:self
                   selector:@selector(updateTimer)
                   userInfo:nil
                   repeats:YES];
  
  self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    [self stop];
  }];
  
  running = true;
}

-(void)stop
{
  [timer invalidate];
  running = false;
  [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
}

-(void)updateTimer
{
  secondsRemaining--;
  NSLog(@"timer secondsRemaining: %i", secondsRemaining);
  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoModule * rm = [rmm.modules objectForKey:[NSNumber numberWithInt:One]];
  if (secondsRemaining < 30) {
    //TODO: fade out global volume
    NSLog(@"module: %s", [rm.uuid UTF8String]);
    if ([rm.sound playing]) {
      float currVolume = [rm.sound volume];
      NSLog(@"curr vol: %f", currVolume);
      float step = currVolume / (float)secondsRemaining;
      float newVolume = currVolume - step;
      NSLog(@"new vol: %f", newVolume);
      [rm.sound setVolume:newVolume];
    }
  }
  
  if (secondsRemaining <= 0) {
    [self stop];
    if ([rm.sound playing]) {
      [rm.sound stop];
    }
    [self notifyTimerFinished];
    return;
  }
  
  [self notifySecondsRemaining];
}

- (NSMutableArray*)delegates
{
  return delegates;
}

- (void)addDelegate:(id<ResoTimerDelegate>)d
{
  [delegates addObject:d];
}

- (void)removeDelegate:(id<ResoTimerDelegate>)d
{
  [delegates removeObject:d];
}

#pragma mark delegate notifications

- (void) notifySecondsRemaining
{
  for(id<ResoTimerDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(timerSecondsRemaining:)] ) {
      [delegate performSelector:@selector(timerSecondsRemaining:) withObject:[NSNumber numberWithInt:secondsRemaining]];
    }
  }
}

- (void) notifyTimerFinished
{
  for(id<ResoTimerDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(timerFinished)] ) {
      [delegate performSelector:@selector(timerFinished)];
    }
  }
}

@end
