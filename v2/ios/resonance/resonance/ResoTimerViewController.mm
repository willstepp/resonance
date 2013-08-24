//
//  ResoTimerViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 6/1/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoTimerViewController.h"
#import "ResoSettings.h"
#import "ResoAppDelegate.h"

@interface ResoTimerViewController ()
{
  CGRect backButtonFrame;
  CGRect backButtonFrame_offscreen;
}
@end

@implementation ResoTimerViewController
@synthesize backButton, chooseTimePanel, startTimerbutton, timePicker, countdownPanel, countdownLabel, cancelTimerbutton, pauseTimerbutton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self calculateWidgetFrames];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_NORMAL]];
    
    //back button
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"icon-chevron-left-small.png"] forState:UIControlStateNormal];
    [backButton setAdjustsImageWhenHighlighted:NO];
    backButton.alpha = ICON_BUTTON_OPACITY;
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor clearColor]];
    
    backButton.layer.borderColor = [UIColor blackColor].CGColor;
    backButton.layer.borderWidth = 0.0f;
    backButton.layer.cornerRadius = 4.0f;
    backButton.frame = backButtonFrame;
    [self.view addSubview:backButton];
    
    //picker view: panel
    chooseTimePanel = [[UIView alloc] initWithFrame:CGRectMake(0, backButton.frame.size.height, [ResoAppDelegate windowWidth], [ResoAppDelegate windowHeight] - backButton.frame.size.height)];
    [self.view addSubview:chooseTimePanel];
    [chooseTimePanel setBackgroundColor:[UIColor clearColor]];
    
    //picker view: time picker
    int pickerY = 75;
    timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, pickerY, [ResoAppDelegate windowWidth], 200)];
    [timePicker setDatePickerMode:UIDatePickerModeCountDownTimer];
    [chooseTimePanel addSubview:timePicker];
    
    //picker view: start button
    int buttonHeight = 50;
    startTimerbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startTimerbutton setTitle:@"Start Timer" forState:UIControlStateNormal];
    [startTimerbutton addTarget:self action:@selector(startTimer:) forControlEvents:UIControlEventTouchUpInside];
    [startTimerbutton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [startTimerbutton setBackgroundColor:[UIColor colorWithRed:0.75 green:1.0 blue:0.75 alpha:0.25]];
    
    startTimerbutton.layer.borderWidth = 0.0f;
    startTimerbutton.layer.cornerRadius = CORNER_RADIUS;
    startTimerbutton.frame = CGRectMake(10, pickerY+timePicker.frame.size.height+buttonHeight, chooseTimePanel.frame.size.width-20, buttonHeight);
    [chooseTimePanel addSubview:startTimerbutton];
                         
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)startTimer:(id)sender
{
  ResoTimer * rt = [ResoTimer instance];
  NSTimeInterval ti = timePicker.countDownDuration;
  [rt setTimeout:round(ti)];
}

-(void)goBack:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)calculateWidgetFrames
{
  //back button
  backButtonFrame = CGRectMake(0, 0, 50, 50);
  backButtonFrame_offscreen = CGRectMake(-(backButtonFrame.size.width), backButtonFrame.origin.y, backButtonFrame.size.width, backButtonFrame.size.height);
}

#pragma mark resotimerdelegate

-(void) timerSecondsRemaining:(NSNumber*)seconds
{
  NSLog(@"timerSecondsRemaining(): %i", [seconds intValue]);
  //[timerLabel setText:[seconds stringValue]];
}

-(void) timerStarted
{
  NSLog(@"timerStarted()");
  //show timer panel
  //set label to timer timeout value
  ResoTimer * rt = [ResoTimer instance];
}

-(void) timerFinished
{
  NSLog(@"timerFinished()");
  //show time selection panel
}
@end
