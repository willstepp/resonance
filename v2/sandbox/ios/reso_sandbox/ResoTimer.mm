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
  NSTimer * fadeOutTimer;
  float step;
  bool fading;
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
    step = 0.0f;
    fading = false;
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
  [fadeOutTimer invalidate];
  step = 0.0f;
  running = false;
  fading = false;
  [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
}

-(void)updateTimer
{
  secondsRemaining--;

  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoModule * rm = [rmm.modules objectForKey:[NSNumber numberWithInt:One]];
  
  if (secondsRemaining < 30) {
    if ([rm.sound playing] && !fading) {
      
      float currVolume = [rm.sound volume];
      step = currVolume / ((float)secondsRemaining * 10);
      
      fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                              target:self
                              selector:@selector(updateFadeOut)
                              userInfo:nil
                              repeats:YES];
      fading = true;
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

-(void)updateFadeOut
{
  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoModule * rm = [rmm.modules objectForKey:[NSNumber numberWithInt:One]];
  float currVolume = [rm.sound volume];
  float newVolume = currVolume - step;
  [rm.sound setVolume:newVolume];

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
