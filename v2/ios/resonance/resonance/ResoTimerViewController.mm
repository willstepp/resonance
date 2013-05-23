//
//  ResoTimerViewController.m
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoTimerViewController.h"
#import "ResoSettings.h"

@interface ResoTimerViewController ()
{
  CGRect playerButtonFrame;
  CGRect playerButtonFrame_offscreen;
}
@end

@implementation ResoTimerViewController
@synthesize playerButton;

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
    [playerButton setTitle:@"Pl" forState:UIControlStateNormal];
    [playerButton addTarget:self action:@selector(showPlayer:) forControlEvents:UIControlEventTouchUpInside];
    [playerButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
    [playerButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
    playerButton.layer.borderWidth = 0.0f;
    playerButton.layer.cornerRadius = CORNER_RADIUS;
    playerButton.frame = playerButtonFrame_offscreen;
    [self.view addSubview:playerButton];
    
    [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                          delay:0.00
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       playerButton.frame = playerButtonFrame;
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
                   } completion:^(BOOL finished) {
                     if (finished) {
                       [self.navigationController popViewControllerAnimated:NO];
                     }
                   }];
}

- (void)calculateWidgetFrames
{
  //player button
  playerButtonFrame = CGRectMake(self.view.bounds.size.width-50, 0, 50, 50);
  playerButtonFrame_offscreen = CGRectMake(self.view.bounds.size.width+50, 0, 50, 50);
}

@end
