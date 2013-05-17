//
//  ResoMixViewController.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/7/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ResoAppDelegate.h"
#import "ResoMixViewController.h"
#import "ResoMixManager.h"
#import "ResoMediaTransferManager.h"
#import "ResoMixLibraryViewController.h"

@interface ResoMixViewController ()

@end

@implementation ResoMixViewController
@synthesize backButton, saveMixButton, mixLibraryButton;

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
      [saveMixButton setTitle:@"Save Current Mix" forState:UIControlStateNormal];
      [saveMixButton addTarget:self action:@selector(initSaveMix:) forControlEvents:UIControlEventTouchUpInside];
      [saveMixButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [saveMixButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      saveMixButton.layer.borderColor = [UIColor blackColor].CGColor;
      saveMixButton.layer.borderWidth = 0.0f;
      saveMixButton.layer.cornerRadius = 4.0f;
      saveMixButton.frame = CGRectMake(10, 100, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:saveMixButton];
      
      //load mix button
      mixLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [mixLibraryButton setTitle:@"Mix Library" forState:UIControlStateNormal];
      [mixLibraryButton addTarget:self action:@selector(showMixLibrary:) forControlEvents:UIControlEventTouchUpInside];
      [mixLibraryButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [mixLibraryButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      mixLibraryButton.layer.borderColor = [UIColor blackColor].CGColor;
      mixLibraryButton.layer.borderWidth = 0.0f;
      mixLibraryButton.layer.cornerRadius = 4.0f;
      mixLibraryButton.frame = CGRectMake(10, 175, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:mixLibraryButton];
      
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
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mix Name" message:@"Give your mix a name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
  alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
  alertView.delegate = self;
  [alertView show];
}

-(void)saveMixWithName:(NSString*)name
{
  ResoMixManager * rmm = [ResoMixManager instance];
  [rmm saveMix:name];
}

-(void)showMixLibrary:(id)sender
{
  ResoMixLibraryViewController * rmlvc = [[ResoMixLibraryViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmlvc animated:YES];
}

#pragma uialertviewdelegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  if (buttonIndex == 1) {
    [self saveMixWithName:[alertView textFieldAtIndex:0].text];
  }
}
@end
