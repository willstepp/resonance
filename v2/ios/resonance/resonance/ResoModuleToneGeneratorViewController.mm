//
//  ResoModuleToneGeneratorViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoModuleToneGeneratorViewController.h"
#import "ResoSettings.h"
#import "ResoAppDelegate.h"

@interface ResoModuleToneGeneratorViewController ()
{
  CGRect backButtonFrame;
  CGRect backButtonFrame_offscreen;
}
@end

@implementation ResoModuleToneGeneratorViewController
@synthesize backButton, toneGeneratorButton;

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
    backButton.frame = backButtonFrame_offscreen;
    backButton.alpha = 0.0f;
    [self.view addSubview:backButton];
    
    toneGeneratorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [toneGeneratorButton setTitle:@"Tone Generator" forState:UIControlStateNormal];
    [toneGeneratorButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
    [toneGeneratorButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_LIGHT]];
    toneGeneratorButton.layer.borderWidth = 0.0f;
    toneGeneratorButton.layer.cornerRadius = CORNER_RADIUS;
    toneGeneratorButton.frame = CGRectMake(10, ([ResoAppDelegate windowHeight] / 2) - 50, [ResoAppDelegate windowWidth] - 20, 50);
    [self.view addSubview:toneGeneratorButton];
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
  
  backButton.alpha = ICON_BUTTON_OPACITY;
  [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     backButton.frame = backButtonFrame;
                   } completion:nil];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)goBack:(id)sender
{
  backButton.alpha = 0.0f;
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)calculateWidgetFrames
{
  //back button
  backButtonFrame = CGRectMake(0, 0, 50, 50);
  backButtonFrame_offscreen = CGRectMake(-(backButtonFrame.size.width), backButtonFrame.origin.y, backButtonFrame.size.width, backButtonFrame.size.height);
}
@end
