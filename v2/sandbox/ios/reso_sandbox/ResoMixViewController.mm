//
//  ResoMixViewController.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/7/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ResoMixViewController.h"
#import "ResoMixManager.h"

@interface ResoMixViewController ()

@end

@implementation ResoMixViewController
@synthesize backButton, saveMixButton, loadMixButton;

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
      
      //save mix button
      saveMixButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [saveMixButton setTitle:@"Save Mix" forState:UIControlStateNormal];
      [saveMixButton addTarget:self action:@selector(initSaveMix:) forControlEvents:UIControlEventTouchUpInside];
      [saveMixButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [saveMixButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      saveMixButton.layer.borderColor = [UIColor blackColor].CGColor;
      saveMixButton.layer.borderWidth = 0.0f;
      saveMixButton.layer.cornerRadius = 4.0f;
      saveMixButton.frame = CGRectMake(10, 100, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:saveMixButton];
      
      //load mix button
      loadMixButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [loadMixButton setTitle:@"Load Mix" forState:UIControlStateNormal];
      [loadMixButton addTarget:self action:@selector(loadMix:) forControlEvents:UIControlEventTouchUpInside];
      [loadMixButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [loadMixButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      loadMixButton.layer.borderColor = [UIColor blackColor].CGColor;
      loadMixButton.layer.borderWidth = 0.0f;
      loadMixButton.layer.cornerRadius = 4.0f;
      loadMixButton.frame = CGRectMake(10, 175, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:loadMixButton];
      
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

-(void)initSaveMix:(id)sender
{
  //prompt for name of mix
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mix Name" message:@"Enter a name for your mix" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
  alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
  alertView.delegate = self;
  [alertView show];
}

-(void)saveMixWithName:(NSString*)name
{
  ResoMixManager * rmm = [ResoMixManager instance];
  [rmm saveMix:name];
}

-(void)loadMix:(id)sender
{
  NSLog(@"loadMix");
}

#pragma uialertviewdelegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  if (buttonIndex == 1) {
    [self saveMixWithName:[alertView textFieldAtIndex:0].text];
  }
}
@end
