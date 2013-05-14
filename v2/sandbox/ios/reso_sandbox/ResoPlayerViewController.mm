//
//  ResoPlayerViewController.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/7/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoAppDelegate.h"
#import "ResoPlayerViewController.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"
#import "ISound.h"

#import "ResoModuleViewController.h"

@interface ResoPlayerViewController ()
{
  ResoModule * module;
  UIImageView * backgroundImage;
}
@end

@implementation ResoPlayerViewController
@synthesize backButton;
@synthesize moduleOneButton, moduleTwoButton, moduleThreeButton, moduleFourButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
      //background image
      backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
      [self.view addSubview:backgroundImage];
      
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
      
      //module one
      moduleOneButton = [UIButton buttonWithType:UIButtonTypeCustom];
      moduleOneButton.tag = One;
      [moduleOneButton setTitle:@"Module One" forState:UIControlStateNormal];
      [moduleOneButton addTarget:self action:@selector(showModule:) forControlEvents:UIControlEventTouchUpInside];
      [moduleOneButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [moduleOneButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      moduleOneButton.layer.borderColor = [UIColor blackColor].CGColor;
      moduleOneButton.layer.borderWidth = 0.0f;
      moduleOneButton.layer.cornerRadius = 4.0f;
      moduleOneButton.frame = CGRectMake(10, 100, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:moduleOneButton];
      
      //module two
      moduleTwoButton = [UIButton buttonWithType:UIButtonTypeCustom];
      moduleTwoButton.tag = Two;
      [moduleTwoButton setTitle:@"Module Two" forState:UIControlStateNormal];
      [moduleTwoButton addTarget:self action:@selector(showModule:) forControlEvents:UIControlEventTouchUpInside];
      [moduleTwoButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [moduleTwoButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      moduleTwoButton.layer.borderColor = [UIColor blackColor].CGColor;
      moduleTwoButton.layer.borderWidth = 0.0f;
      moduleTwoButton.layer.cornerRadius = 4.0f;
      moduleTwoButton.frame = CGRectMake(10, 170, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:moduleTwoButton];
      
      //module three
      moduleThreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
      moduleThreeButton.tag = Three;
      [moduleThreeButton setTitle:@"Module Three" forState:UIControlStateNormal];
      [moduleThreeButton addTarget:self action:@selector(showModule:) forControlEvents:UIControlEventTouchUpInside];
      [moduleThreeButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [moduleThreeButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      moduleThreeButton.layer.borderColor = [UIColor blackColor].CGColor;
      moduleThreeButton.layer.borderWidth = 0.0f;
      moduleThreeButton.layer.cornerRadius = 4.0f;
      moduleThreeButton.frame = CGRectMake(10, 240, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:moduleThreeButton];
      
      //module four
      moduleFourButton = [UIButton buttonWithType:UIButtonTypeCustom];
      moduleFourButton.tag = Four;
      [moduleFourButton setTitle:@"Module Four" forState:UIControlStateNormal];
      [moduleFourButton addTarget:self action:@selector(showModule:) forControlEvents:UIControlEventTouchUpInside];
      [moduleFourButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [moduleFourButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      moduleFourButton.layer.borderColor = [UIColor blackColor].CGColor;
      moduleFourButton.layer.borderWidth = 0.0f;
      moduleFourButton.layer.cornerRadius = 4.0f;
      moduleFourButton.frame = CGRectMake(10, 310, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:moduleFourButton];
      
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

-(void)showModule:(id)sender
{
  UIButton * moduleButton = (UIButton*)sender;
  NSLog(@"showing module: %i", moduleButton.tag);
  
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  ad.currentModule = (Module)moduleButton.tag;
  
  ResoModuleViewController * rmvc = [[ResoModuleViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmvc animated:YES];
}

-(void)goBack:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

@end
