//
//  ResoPortalViewController.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 4/29/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ResoPortalViewController.h"
#import "ResoUiViewController.h"
#import "ResoSoundViewController.h"
#import "ResoDataViewController.h"
#import "ResoMediaTransferViewController.h"
#import "ResoTypes.h"

@interface ResoPortalViewController ()
@end

@implementation ResoPortalViewController
@synthesize uiButton, soundButton, dataButton, mediaTransferButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

      [self.view setBackgroundColor:[UIColor darkGrayColor]];
      
      //ui button
      uiButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [uiButton setTitle:@"UI" forState:UIControlStateNormal];
      [uiButton addTarget:self action:@selector(showUI:) forControlEvents:UIControlEventTouchUpInside];
      [uiButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [uiButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      uiButton.layer.borderColor = [UIColor blackColor].CGColor;
      uiButton.layer.borderWidth = 0.0f;
      uiButton.layer.cornerRadius = 4.0f;
      uiButton.frame = CGRectMake(10, 100, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:uiButton];
      
      //sound button
      soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [soundButton setTitle:@"Sound" forState:UIControlStateNormal];
      [soundButton addTarget:self action:@selector(showSound:) forControlEvents:UIControlEventTouchUpInside];
      [soundButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [soundButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      soundButton.layer.borderColor = [UIColor blackColor].CGColor;
      soundButton.layer.borderWidth = 0.0f;
      soundButton.layer.cornerRadius = 4.0f;
      soundButton.frame = CGRectMake(10, 170, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:soundButton];
      
      //data button
      dataButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [dataButton setTitle:@"Data" forState:UIControlStateNormal];
      [dataButton addTarget:self action:@selector(showData:) forControlEvents:UIControlEventTouchUpInside];
      [dataButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [dataButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      dataButton.layer.borderColor = [UIColor blackColor].CGColor;
      dataButton.layer.borderWidth = 0.0f;
      dataButton.layer.cornerRadius = 4.0f;
      dataButton.frame = CGRectMake(10, 240, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:dataButton];
      
      //media transfer button
      mediaTransferButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [mediaTransferButton setTitle:@"Media Transfer" forState:UIControlStateNormal];
      [mediaTransferButton addTarget:self action:@selector(showMediaTransfer:) forControlEvents:UIControlEventTouchUpInside];
      [mediaTransferButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [mediaTransferButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      mediaTransferButton.layer.borderColor = [UIColor blackColor].CGColor;
      mediaTransferButton.layer.borderWidth = 0.0f;
      mediaTransferButton.layer.cornerRadius = 4.0f;
      mediaTransferButton.frame = CGRectMake(10, 310, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:mediaTransferButton];
    }
    return self;
}

-(void)showSound:(id)sender
{
  ResoSoundViewController * rsvc = [[ResoSoundViewController alloc] initWithNibName:@"ResoSoundViewController" bundle:nil];
  //push it onto the 'navigation stack'
  [self.navigationController pushViewController:rsvc animated:YES];
}

-(void)showUI:(id)sender
{
  ResoUiViewController * ruvc = [[ResoUiViewController alloc] initWithNibName:nil bundle:nil];
  //push it onto the 'navigation stack'
  [self.navigationController pushViewController:ruvc animated:YES];
}

-(void)showData:(id)sender
{  
  ResoDataViewController * rdvc = [[ResoDataViewController alloc] initWithNibName:nil bundle:nil];
  //push it onto the 'navigation stack'
  [self.navigationController pushViewController:rdvc animated:YES];
}

-(void)showMediaTransfer:(id)sender
{
  ResoMediaTransferViewController * rmtvc = [[ResoMediaTransferViewController alloc] initWithNibName:nil bundle:nil];
  //push it onto the 'navigation stack'
  [self.navigationController pushViewController:rmtvc animated:YES];
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
