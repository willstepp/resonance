//
//  ResoMenuViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 5/22/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoMenuViewController.h"
#import "ResoSettings.h"

#import "ResoAppDelegate.h"
#import "IResoVisualization.h"

@interface ResoMenuViewController ()
{
  CGRect playerButtonFrame;
  CGRect playerButtonFrame_offscreen;
  
  CGRect titleFrame;
  CGRect titleFrame_offscreen;
}
@end

@implementation ResoMenuViewController
@synthesize playerButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    playerButton.alpha = ICON_BUTTON_OPACITY;
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
                       ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
                       [ad.visualization refreshVisual];
                       [ad.visualization enableTransitions:true];
                       [self.navigationController popViewControllerAnimated:NO];
                     }
                   }];
}

- (void)calculateWidgetFrames
{
  //player button
  playerButtonFrame = CGRectMake([ResoAppDelegate windowWidth]-50, 0, 50, 50);
  playerButtonFrame_offscreen = CGRectMake([ResoAppDelegate windowWidth]+50, 0, 50, 50);
  
  //title
  titleFrame = CGRectMake(10, 0, 100, 50);
  titleFrame_offscreen = CGRectMake(-(titleFrame.size.width), titleFrame.origin.y, titleFrame.size.width, titleFrame.size.height);
}

@end
