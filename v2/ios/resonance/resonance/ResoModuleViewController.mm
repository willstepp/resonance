//
//  ResoModuleViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoModuleViewController.h"
#import "ResoAppDelegate.h"
#import "ResoSettings.h"
#import "ResoModuleManager.h"
#import "ResoModule.h"

#import "ResoModuleSettingsViewController.h"
#import "ResoModuleTypeViewController.h"

@interface ResoModuleViewController ()
{
  CGRect playerButtonFrame;
  CGRect playerButtonFrame_offscreen;
  
  CGRect soundButtonFrame;
  CGRect soundButtonFrame_offscreen;
  
  CGRect settingsBarFrame;
  CGRect settingsBarFrame_offscreen;
  
  CGRect changeSoundBarFrame;
  CGRect changeSoundBarFrame_offscreen;
}
@end

@implementation ResoModuleViewController
@synthesize playerButton, loadSoundButton, settingsBar, changeSoundBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
      playerButton.layer.cornerRadius = CORNER_RADIUS;
      playerButton.frame = playerButtonFrame_offscreen;
      playerButton.alpha = ICON_BUTTON_OPACITY;
      [self.view addSubview:playerButton];

      //sound button
      loadSoundButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [loadSoundButton setTitle:@"Load Sound" forState:UIControlStateNormal];
      [loadSoundButton addTarget:self action:@selector(loadSound:) forControlEvents:UIControlEventTouchUpInside];
      [loadSoundButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
      [loadSoundButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_LIGHT]];
      loadSoundButton.layer.borderWidth = 0.0f;
      loadSoundButton.layer.cornerRadius = CORNER_RADIUS;
      loadSoundButton.frame = soundButtonFrame_offscreen;
      [self.view addSubview:loadSoundButton];
      
      changeSoundBar = [[ResoActionBar alloc] initWithFrame:changeSoundBarFrame_offscreen withText:@"Change Sound" withIconText:nil withIconColor:nil];
      [changeSoundBar.actionButton addTarget:self action:@selector(changeSound:) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:changeSoundBar];
      
      settingsBar = [[ResoActionBar alloc] initWithFrame:settingsBarFrame_offscreen withText:@"Settings" withIconText:nil withIconColor:nil];
      [settingsBar.actionButton addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:settingsBar];
      
      [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                            delay:0.00
                          options:UIViewAnimationOptionCurveEaseOut
                       animations:^{
                         playerButton.frame = playerButtonFrame;
                         loadSoundButton.frame = soundButtonFrame;
                         settingsBar.frame = settingsBarFrame;
                         changeSoundBar.frame = changeSoundBarFrame;
                       } completion:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSound:(id)sender
{
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  ResoModuleManager * rmm = [ResoModuleManager instance];
  
  if (ad.currentModule != nil)
    [rmm removeModuleWithUuid:ad.currentModule];
  
  NSString * uuid = [[NSUUID UUID] UUIDString];
  [rmm addModuleWithUuid:uuid];
  ResoModule * rm = [rmm.modules objectForKey:uuid];
  [rm loadSound:@"test" looped:false];

  ad.currentModule = uuid;
}

- (void)showPlayer:(id)sender
{
  [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                        delay:0.00
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     loadSoundButton.frame = soundButtonFrame_offscreen;
                     playerButton.frame = playerButtonFrame_offscreen;
                     settingsBar.frame = settingsBarFrame_offscreen;
                     changeSoundBar.frame = changeSoundBarFrame_offscreen;
                   } completion:^(BOOL finished) {
                     if (finished) {
                       [self.navigationController popViewControllerAnimated:NO];
                     }
                   }];
}

- (void)showSettings:(id)sender
{
  ResoModuleSettingsViewController * rmsvc = [[ResoModuleSettingsViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmsvc animated:YES];
}

- (void)changeSound:(id)sender
{
  ResoModuleTypeViewController * rmtvc = [[ResoModuleTypeViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmtvc animated:YES];
}

- (void)calculateWidgetFrames
{
  //player button
  playerButtonFrame = CGRectMake(self.view.bounds.size.width-50, 0, 50, 50);
  playerButtonFrame_offscreen = CGRectMake(self.view.bounds.size.width+50, 0, 50, 50);
  
  //load sound button
  soundButtonFrame = CGRectMake(10, (self.view.bounds.size.height / 2) - 50, self.view.bounds.size.width - 20, 50);
  soundButtonFrame_offscreen = CGRectMake(-(soundButtonFrame.size.width), soundButtonFrame.origin.y, soundButtonFrame.size.width, soundButtonFrame.size.height);
  
  //change sound bar
  changeSoundBarFrame = CGRectMake(10, (self.view.bounds.size.height - 60), self.view.bounds.size.width - 20, 50);
  changeSoundBarFrame_offscreen = CGRectMake(-(changeSoundBarFrame.size.width), changeSoundBarFrame.origin.y, changeSoundBarFrame.size.width, changeSoundBarFrame.size.height);
  
  //settings bar
  settingsBarFrame = CGRectMake(10, (changeSoundBarFrame.origin.y - 60), self.view.bounds.size.width - 20, 50);
  settingsBarFrame_offscreen = CGRectMake(-(settingsBarFrame.size.width), settingsBarFrame.origin.y, settingsBarFrame.size.width, settingsBarFrame.size.height);
}

@end
