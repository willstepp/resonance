//
//  ResoClocksViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoClocksViewController.h"
#import "ResoSettings.h"

#import "ResoAlarmViewController.h"
#import "ResoTimerViewController.h"

#import "ResoAppDelegate.h"
#import "IResoVisualization.h"

@interface ResoClocksViewController ()
{
  CGRect playerButtonFrame;
  CGRect playerButtonFrame_offscreen;
  
  CGRect alarmFrame;
  CGRect alarmFrame_offscreen;
  
  CGRect timerFrame;
  CGRect timerFrame_offscreen;
}
@end

@implementation ResoClocksViewController
@synthesize playerButton, alarmBar, timerBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self calculateWidgetFrames];
  
    [self.view setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_NORMAL]];
    
    //player button
    playerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playerButton setImage:[UIImage imageNamed:@"icon-play-small.png"] forState:UIControlStateNormal];
    [playerButton setAdjustsImageWhenHighlighted:NO];
    [playerButton addTarget:self action:@selector(showPlayer:) forControlEvents:UIControlEventTouchUpInside];
    [playerButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
    [playerButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
    playerButton.layer.borderWidth = 0.0f;
    playerButton.alpha = ICON_BUTTON_OPACITY;
    playerButton.layer.cornerRadius = CORNER_RADIUS;
    playerButton.frame = playerButtonFrame_offscreen;
    [self.view addSubview:playerButton];
  
    //sound library bar
    alarmBar = [[ResoActionBar alloc] initWithFrame:alarmFrame_offscreen withText:@"Alarm" withIconText:nil withIconColor:nil];
    [alarmBar.actionButton addTarget:self action:@selector(showAlarm:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:alarmBar];
    
    //tone generator bar
    timerBar = [[ResoActionBar alloc] initWithFrame:timerFrame_offscreen  withText:@"Timer" withIconText:nil withIconColor:nil];
    [timerBar.actionButton addTarget:self action:@selector(showTimer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:timerBar];
  
    [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                          delay:0.00
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       playerButton.frame = playerButtonFrame;
                       alarmBar.frame = alarmFrame;
                       timerBar.frame = timerFrame;
                     } completion:^(BOOL finished) {
                       if (finished) {
                       }
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPlayer:(id)sender
{
  [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                        delay:0.00
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     playerButton.frame = playerButtonFrame_offscreen;
                     alarmBar.frame = alarmFrame_offscreen;
                     timerBar.frame = timerFrame_offscreen;
                   } completion:^(BOOL finished) {
                     if (finished) {
                       ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
                       [ad.visualization refreshVisual];
                       [ad.visualization enableTransitions:true];
                       [self.navigationController popViewControllerAnimated:NO];
                     }
                   }];
}

- (void)showAlarm:(id)sender
{
  ResoAlarmViewController * ravc = [[ResoAlarmViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:ravc animated:YES];
}

- (void)showTimer:(id)sender
{
  ResoTimerViewController * rtvc = [[ResoTimerViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rtvc animated:YES];
}

- (void)calculateWidgetFrames
{
  //player button
  playerButtonFrame = CGRectMake(self.view.bounds.size.width-50, 0, 50, 50);
  playerButtonFrame_offscreen = CGRectMake(self.view.bounds.size.width+50, 0, 50, 50);
  
  //alarm bar
  alarmFrame = CGRectMake(10, (self.view.bounds.size.height / 2) - 75, self.view.bounds.size.width - 20, 50);
  alarmFrame_offscreen = CGRectMake(-(alarmFrame.size.width), alarmFrame.origin.y, alarmFrame.size.width, alarmFrame.size.height);
  
  //timer bar
  timerFrame = CGRectMake(10, alarmFrame.origin.y+60, self.view.bounds.size.width - 20, 50);
  timerFrame_offscreen = CGRectMake(-(timerFrame.size.width), timerFrame.origin.y, timerFrame.size.width, timerFrame.size.height);
}

@end
