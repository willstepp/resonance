//
//  ResoTimerViewController.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/8/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoTimerViewController.h"

#import "ResoTimer.h"
#import "ResoAlarm.h"

@interface ResoTimerViewController ()

@end

@implementation ResoTimerViewController
@synthesize backButton, timerButton, timerLabel, alarmButton, alarmLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      //back button
      backButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [backButton setTitle:@"<" forState:UIControlStateNormal];
      [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
      [backButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [backButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      backButton.layer.borderColor = [UIColor blackColor].CGColor;
      backButton.layer.borderWidth = 0.0f;
      backButton.layer.cornerRadius = 4.0f;
      backButton.frame = CGRectMake(10, 10, 44, 44);
      [self.view addSubview:backButton];
      
      //timer button
      timerButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [timerButton setTitle:@"Start Timer" forState:UIControlStateNormal];
      [timerButton addTarget:self action:@selector(toggleTimer:) forControlEvents:UIControlEventTouchUpInside];
      [timerButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [timerButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      timerButton.layer.borderColor = [UIColor blackColor].CGColor;
      timerButton.layer.borderWidth = 0.0f;
      timerButton.layer.cornerRadius = 4.0f;
      timerButton.frame = CGRectMake(10, 100, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:timerButton];
      
      //timer label
      timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 75, 65, 26)];
      [timerLabel setText:@"30"];
      [timerLabel setBackgroundColor:[UIColor clearColor]];
      [timerLabel setTextColor:[UIColor whiteColor]];
      [self.view addSubview:timerLabel];
      
      //alarm button
      alarmButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [alarmButton setTitle:@"Start Alarm" forState:UIControlStateNormal];
      [alarmButton addTarget:self action:@selector(toggleAlarm:) forControlEvents:UIControlEventTouchUpInside];
      [alarmButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [alarmButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      alarmButton.layer.borderColor = [UIColor blackColor].CGColor;
      alarmButton.layer.borderWidth = 0.0f;
      alarmButton.layer.cornerRadius = 4.0f;
      alarmButton.frame = CGRectMake(10, 200, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:alarmButton];
      
      //alarm label
      alarmLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 175, 65, 26)];
      [alarmLabel setText:@"30"];
      [alarmLabel setBackgroundColor:[UIColor clearColor]];
      [alarmLabel setTextColor:[UIColor whiteColor]];
      [self.view addSubview:alarmLabel];

      
      [self.view setBackgroundColor:[UIColor darkGrayColor]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)goBack:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

-(void)toggleTimer:(id)sender
{
  ResoTimer * rt = [ResoTimer instance];
  if ([rt running]) {
    [timerButton setTitle:@"Start Timer" forState:UIControlStateNormal];
    [rt removeDelegate:self];
    [rt stop];
  } else {
    [timerButton setTitle:@"Stop Timer" forState:UIControlStateNormal];
    [rt addDelegate:self];
    [rt setTimeout:30];
    [rt start];
  }
}

-(void)toggleAlarm:(id)sender
{
  ResoAlarm * ra = [ResoAlarm instance];
  if ([ra running]) {
    [alarmButton setTitle:@"Start Alarm" forState:UIControlStateNormal];
    [ra removeDelegate:self];
    [ra stop];
  } else {
    [alarmButton setTitle:@"Stop Alarm" forState:UIControlStateNormal];
    [ra addDelegate:self];
    [ra setTimeout:30];
    [ra start];
  }
}

#pragma mark resotimerdelegate

-(void) timerSecondsRemaining:(NSNumber*)seconds
{
  NSLog(@"timerSecondsRemaining(): %i", [seconds intValue]);
  [timerLabel setText:[seconds stringValue]];
}

-(void) timerFinished
{
  NSLog(@"timerFinished()");
  [timerButton setTitle:@"Start Timer" forState:UIControlStateNormal];
  [timerLabel setText:@"30"];
}

#pragma mark resoalarmdelegate

-(void) alarmSecondsRemaining:(NSNumber*)seconds
{
  NSLog(@"alarmSecondsRemaining(): %i", [seconds intValue]);
  [alarmLabel setText:[seconds stringValue]];
}

-(void) alarmFinished
{
  NSLog(@"alarmFinished()");
  [alarmButton setTitle:@"Start Alarm" forState:UIControlStateNormal];
  [alarmLabel setText:@"30"];
}


@end
