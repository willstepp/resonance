//
//  ResoPlayerViewController.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/7/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoPlayerViewController.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"

@interface ResoPlayerViewController ()
{
  ResoModule * module;
}
@end

@implementation ResoPlayerViewController
@synthesize backButton, playButton, reverbSwitch;

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
      
      //player button
      playButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [playButton setTitle:@"Play Sound" forState:UIControlStateNormal];
      [playButton addTarget:self action:@selector(playSound:) forControlEvents:UIControlEventTouchUpInside];
      [playButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [playButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      playButton.layer.borderColor = [UIColor blackColor].CGColor;
      playButton.layer.borderWidth = 0.0f;
      playButton.layer.cornerRadius = 4.0f;
      playButton.frame = CGRectMake(10, 180, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:playButton];
      
      //reverb label
      UILabel * reverbLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 250, 65, 26)];
      [reverbLabel setText:@"Reverb"];
      [reverbLabel setBackgroundColor:[UIColor clearColor]];
      [reverbLabel setTextColor:[UIColor whiteColor]];
      [self.view addSubview:reverbLabel];
      
      //reverb switch
      CGRect frame = CGRectMake(80, 250, 60.0, 26.0);
      reverbSwitch = [[UISwitch alloc] initWithFrame:frame];
      [reverbSwitch addTarget:self action:@selector(toggleReverb:) forControlEvents:UIControlEventTouchUpInside];
      
      [reverbSwitch setBackgroundColor:[UIColor clearColor]];
      [self.view addSubview:reverbSwitch];
      
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

-(void)playSound:(id)sender
{
  ResoModuleManager * rmm = [ResoModuleManager instance];
  module = [rmm.modules objectForKey:[NSNumber numberWithInt:One]];
  if ([module loaded]) {
    if ([module playing]) {
      [playButton setTitle:@"Play Sound" forState:UIControlStateNormal];
      [module stop];
    } else {
      [playButton setTitle:@"Stop Sound" forState:UIControlStateNormal];
      [module play];
    }
  }
}

-(void)toggleReverb:(id)sender
{
  if ([reverbSwitch isOn]) {
    [module addEffectOfType:Reverb];
    [module setEffectValueForType:Reverb forParameter:Reverb_Room withValue:0.0f];
  } else {
    [module removeEffectOfType:Reverb];
  }
}

@end
