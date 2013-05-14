//
//  ResoPortalViewController.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 4/29/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ResoPortalViewController.h"
#import "ResoMixViewController.h"
#import "ResoPlayerViewController.h"
#import "ResoCloudSoundsViewController.h"
#import "ResoTimerViewController.h"
#import "ResoTypes.h"

@interface ResoPortalViewController ()
@end

@implementation ResoPortalViewController
@synthesize playerButton, mixButton, cloudSoundsButton, timerButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

      [self.view setBackgroundColor:[UIColor darkGrayColor]];
      
      //player button
      playerButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [playerButton setTitle:@"Player" forState:UIControlStateNormal];
      [playerButton addTarget:self action:@selector(showPlayer:) forControlEvents:UIControlEventTouchUpInside];
      [playerButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [playerButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      playerButton.layer.borderColor = [UIColor blackColor].CGColor;
      playerButton.layer.borderWidth = 0.0f;
      playerButton.layer.cornerRadius = 4.0f;
      playerButton.frame = CGRectMake(10, 100, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:playerButton];
      
      //mix button
      mixButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [mixButton setTitle:@"Mix" forState:UIControlStateNormal];
      [mixButton addTarget:self action:@selector(showMix:) forControlEvents:UIControlEventTouchUpInside];
      [mixButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [mixButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      mixButton.layer.borderColor = [UIColor blackColor].CGColor;
      mixButton.layer.borderWidth = 0.0f;
      mixButton.layer.cornerRadius = 4.0f;
      mixButton.frame = CGRectMake(10, 170, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:mixButton];
      
      //cloud sounds button
      cloudSoundsButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [cloudSoundsButton setTitle:@"Cloud Sounds" forState:UIControlStateNormal];
      [cloudSoundsButton addTarget:self action:@selector(showCloudSounds:) forControlEvents:UIControlEventTouchUpInside];
      [cloudSoundsButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [cloudSoundsButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      cloudSoundsButton.layer.borderColor = [UIColor blackColor].CGColor;
      cloudSoundsButton.layer.borderWidth = 0.0f;
      cloudSoundsButton.layer.cornerRadius = 4.0f;
      cloudSoundsButton.frame = CGRectMake(10, 240, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:cloudSoundsButton];
      
      //timer button
      timerButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [timerButton setTitle:@"Timer" forState:UIControlStateNormal];
      [timerButton addTarget:self action:@selector(showTimer:) forControlEvents:UIControlEventTouchUpInside];
      [timerButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [timerButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      timerButton.layer.borderColor = [UIColor blackColor].CGColor;
      timerButton.layer.borderWidth = 0.0f;
      timerButton.layer.cornerRadius = 4.0f;
      timerButton.frame = CGRectMake(10, 310, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:timerButton];
    }
    return self;
}

-(void)showMix:(id)sender
{
  ResoMixViewController * rmvc = [[ResoMixViewController alloc] initWithNibName:nil bundle:nil];
  //push it onto the 'navigation stack'
  [self.navigationController pushViewController:rmvc animated:YES];
}

-(void)showPlayer:(id)sender
{
  ResoPlayerViewController * rpvc = [[ResoPlayerViewController alloc] initWithNibName:nil bundle:nil];
  //push it onto the 'navigation stack'
  [self.navigationController pushViewController:rpvc animated:YES];
}

-(void)showCloudSounds:(id)sender
{  
  ResoCloudSoundsViewController * rdvc = [[ResoCloudSoundsViewController alloc] initWithNibName:nil bundle:nil];
  //push it onto the 'navigation stack'
  [self.navigationController pushViewController:rdvc animated:YES];
}

-(void)showTimer:(id)sender
{
  ResoTimerViewController * rtvc = [[ResoTimerViewController alloc] initWithNibName:nil bundle:nil];
  //push it onto the 'navigation stack'
  [self.navigationController pushViewController:rtvc animated:YES];
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

@end
