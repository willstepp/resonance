//
//  ResoAlarm.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/8/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoAlarm.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"
#import "ISound.h"

@interface ResoAlarm ()
{
  int totalSeconds;
  NSTimer * timer;
  NSTimer * fadeInTimer;
  float step;
  bool fading;
}
@property (nonatomic, readwrite) int secondsRemaining;
@property (nonatomic, readwrite) bool running;
@end

@implementation ResoAlarm

@synthesize secondsRemaining, backgroundTaskId, running;
static ResoAlarm * ra = nil;

-(id)init
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"-init is not a valid initializer for the class ResoAlarm. Use -instance"
                               userInfo:nil];
  return nil;
}

+(ResoAlarm*)instance
{
  if (ra == nil)
    ra = [[ResoAlarm alloc] initForSingleton];
  return ra;
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
  
  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoModule * rm = [rmm.modules objectForKey:[NSNumber numberWithInt:One]];
  [rm.sound setVolume:0];
  [rm.sound stop];
  
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
  [fadeInTimer invalidate];
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
  
  if (secondsRemaining < 5) {
    if (!fading) {

      [rm.sound play];
      [rm.sound setVolume:0];
      
      float maxVolume = 1.0f;
      step = maxVolume / ((float)secondsRemaining * 10);
      
      fadeInTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                              target:self
                              selector:@selector(updateFadeIn)
                              userInfo:nil
                              repeats:YES];
      fading = true;
    }
  }
  
  if (secondsRemaining <= 0) {
    [self stop];
    
    //schedule local notification
    UILocalNotification * ln = [[UILocalNotification alloc] init];
    ln.alertAction = @"turn off alarm";
    //custom data, app will be notified, then show modal to turn off completely
    ln.alertBody = @"Alarm";
    ln.soundName = @"nothing.aiff";
    ln.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] presentLocalNotificationNow:ln];
    
    [self notifyTimerFinished];
    return;
  }
  
  [self notifySecondsRemaining];
}

-(void)updateFadeIn
{
  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoModule * rm = [rmm.modules objectForKey:[NSNumber numberWithInt:One]];
  float currVolume = [rm.sound volume];
  float newVolume = currVolume + step;
  [rm.sound setVolume:newVolume];
}

- (NSMutableArray*)delegates
{
  return delegates;
}

- (void)addDelegate:(id<ResoAlarmDelegate>)d
{
  [delegates addObject:d];
}

- (void)removeDelegate:(id<ResoAlarmDelegate>)d
{
  [delegates removeObject:d];
}

#pragma mark delegate notifications

- (void) notifySecondsRemaining
{
  for(id<ResoAlarmDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(alarmSecondsRemaining:)] ) {
      [delegate performSelector:@selector(alarmSecondsRemaining:) withObject:[NSNumber numberWithInt:secondsRemaining]];
    }
  }
}

- (void) notifyTimerFinished
{
  for(id<ResoAlarmDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(alarmFinished)] ) {
      [delegate performSelector:@selector(alarmFinished)];
    }
  }
}

@end
