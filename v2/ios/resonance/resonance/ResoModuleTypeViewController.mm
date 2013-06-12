//
//  ResoModuleTypeViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoModuleTypeViewController.h"
#import "ResoSettings.h"
#import "ResoModuleCloudListViewController.h"
#import "ResoModuleDeviceListViewController.h"
#import "ResoModuleToneGeneratorViewController.h"
#import "ResoDataManager.h"
#import "ResoAppDelegate.h"
#import "IResoVisualization.h"
#import "ResoPlayerViewController.h"

@interface ResoModuleTypeViewController ()
{
  CGRect backButtonFrame;
  CGRect backButtonFrame_offscreen;
  
  CGRect soundLibraryFrame;
  CGRect soundLibraryFrame_offscreen;
  
  CGRect toneGeneratorFrame;
  CGRect toneGeneratorFrame_offscreen;
  
  CGRect playerButtonFrame;
  CGRect playerButtonFrame_offscreen;
}
@end

@implementation ResoModuleTypeViewController
@synthesize backButton, soundLibraryBar, toneGeneratorBar, playerButton;

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
        backButton.alpha = ICON_BUTTON_OPACITY;
        backButton.frame = backButtonFrame;
        [self.view addSubview:backButton];
      
        //player button
        playerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playerButton setImage:[UIImage imageNamed:@"icon-play-small.png"] forState:UIControlStateNormal];
        [playerButton setAdjustsImageWhenHighlighted:NO];
        [playerButton addTarget:self action:@selector(showPlayer:) forControlEvents:UIControlEventTouchUpInside];
        [playerButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
        [playerButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
        playerButton.layer.borderWidth = 0.0f;
        playerButton.layer.cornerRadius = CORNER_RADIUS;
        playerButton.frame = playerButtonFrame_offscreen;
        playerButton.alpha = ICON_BUTTON_OPACITY;
        [self.view addSubview:playerButton];
      
        //sound library bar
        soundLibraryBar = [[ResoActionBar alloc] initWithFrame:soundLibraryFrame withText:@"Sound Library" withIconText:nil withIconColor:nil withDirection:Forward];
        [soundLibraryBar.actionButton addTarget:self action:@selector(showSoundLibrary:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:soundLibraryBar];
      
        //tone generator bar
        toneGeneratorBar = [[ResoActionBar alloc] initWithFrame:toneGeneratorFrame  withText:@"Tone Generator" withIconText:nil withIconColor:nil withDirection:Forward];
        [toneGeneratorBar.actionButton addTarget:self action:@selector(showToneGenerator:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:toneGeneratorBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  }

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  if (ad.currentModule != nil) {
    //just show widgets
    playerButton.frame = playerButtonFrame_offscreen;
    playerButton.alpha = 0.0f;
    backButton.frame = backButtonFrame;
    soundLibraryBar.frame = soundLibraryFrame;
    toneGeneratorBar.frame = toneGeneratorFrame;
  } else {
    backButton.frame = backButtonFrame_offscreen;
    soundLibraryBar.frame = soundLibraryFrame_offscreen;
    toneGeneratorBar.frame = toneGeneratorFrame_offscreen;
    playerButton.frame = playerButtonFrame_offscreen;
    playerButton.alpha = ICON_BUTTON_OPACITY;
    
    //animate in player button, widgets
    if (animated) {
      soundLibraryBar.frame = soundLibraryFrame;
      toneGeneratorBar.frame = toneGeneratorFrame;
      playerButton.frame = playerButtonFrame;
    } else {
      [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                            delay:0.00
                          options:UIViewAnimationOptionCurveEaseOut
                       animations:^{
                         soundLibraryBar.frame = soundLibraryFrame;
                         toneGeneratorBar.frame = toneGeneratorFrame;
                         playerButton.frame = playerButtonFrame;
                       } completion:nil];
    }
  }

}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goBack:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)showPlayer:(id)sender
{
  [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                        delay:0.00
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     playerButton.frame = playerButtonFrame_offscreen;
                     soundLibraryBar.frame = soundLibraryFrame_offscreen;
                     toneGeneratorBar.frame = toneGeneratorFrame_offscreen;
                   } completion:^(BOOL finished) {
                     if (finished) {
                       playerButton.alpha = 0.0f;
                       ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
                       [ad.visualization enableTransitions:true];
                       if (ad.currentModule == nil) {
                         [ad.visualization refreshVisual];
                       }
                       for (UIViewController * viewController in self.navigationController.viewControllers) {
                         if ([viewController isKindOfClass:[ResoPlayerViewController class]] ) {
                           ResoPlayerViewController * rpvc = (ResoPlayerViewController*)viewController;
                           [self.navigationController popToViewController:rpvc animated:NO];
                           return;
                         }
                       }
                     }
                   }];
}

-(void)showSoundLibrary:(id)sender
{
  ResoDataManager * rdm = [ResoDataManager instance];
  if ([rdm soundCount] > 0) {
    ResoModuleCloudListViewController * cvc = [[ResoModuleCloudListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:cvc animated:NO];
    
    ResoModuleDeviceListViewController * vc = [[ResoModuleDeviceListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
  } else {
    ResoModuleDeviceListViewController * dvc = [[ResoModuleDeviceListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:dvc animated:NO];
    
    ResoModuleCloudListViewController * vc = [[ResoModuleCloudListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
  }
}

-(void)showToneGenerator:(id)sender
{
  playerButton.alpha = 0.0f;
  ResoModuleToneGeneratorViewController * rmtgvc = [[ResoModuleToneGeneratorViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmtgvc animated:YES];
}

- (void)calculateWidgetFrames
{
  //back button
  backButtonFrame = CGRectMake(0, 0, 50, 50);
  backButtonFrame_offscreen = CGRectMake(-(backButtonFrame.size.width), backButtonFrame.origin.y, backButtonFrame.size.width, backButtonFrame.size.height);
  
  //player button
  playerButtonFrame = CGRectMake([ResoAppDelegate windowWidth]-50, 0, 50, 50);
  playerButtonFrame_offscreen = CGRectMake([ResoAppDelegate windowWidth]+50, 0, 50, 50);
  
  //sound library
  soundLibraryFrame = CGRectMake(10, ([ResoAppDelegate windowHeight] / 2) - 75, [ResoAppDelegate windowWidth] - 20, 50);
  soundLibraryFrame_offscreen = CGRectMake(-(soundLibraryFrame.size.width), soundLibraryFrame.origin.y, soundLibraryFrame.size.width, soundLibraryFrame.size.height);
  
  //tone generator
  toneGeneratorFrame = CGRectMake(10, soundLibraryFrame.origin.y+60, [ResoAppDelegate windowWidth] - 20, 50);
  toneGeneratorFrame_offscreen = CGRectMake(-(toneGeneratorFrame.size.width), toneGeneratorFrame.origin.y, toneGeneratorFrame.size.width, toneGeneratorFrame.size.height);
}

@end
