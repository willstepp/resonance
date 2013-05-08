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

@interface ResoTimerViewController ()

@end

@implementation ResoTimerViewController
@synthesize backButton, timerButton, alarmButton;

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

#pragma mark resotimerdelegate

-(void) timerSecondsRemaining:(NSNumber*)seconds
{
  NSLog(@"timerSecondsRemaining(): %i", [seconds intValue]);
}

-(void) timerFinished
{
  NSLog(@"timerFinished()");
}


@end
