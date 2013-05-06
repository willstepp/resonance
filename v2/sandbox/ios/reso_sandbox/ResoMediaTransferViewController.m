//
//  ResoMediaTransferViewController.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/6/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoMediaTransferViewController.h"
#import "ResoMediaTransferManager.h"

@interface ResoMediaTransferViewController ()

@end

@implementation ResoMediaTransferViewController
@synthesize backButton, monitorButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      [self.view setBackgroundColor:[UIColor redColor]];
      
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
      
      //monitor button
      monitorButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [monitorButton setTitle:@"Monitor" forState:UIControlStateNormal];
      [monitorButton addTarget:self action:@selector(monitorDownload:) forControlEvents:UIControlEventTouchUpInside];
      [monitorButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [monitorButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      monitorButton.layer.borderColor = [UIColor blackColor].CGColor;
      monitorButton.layer.borderWidth = 0.0f;
      monitorButton.layer.cornerRadius = 4.0f;
      monitorButton.frame = CGRectMake(10, 100, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:monitorButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
    [rmtm initTransferOfType:SoundTransfer withIdentifier:@"3d6bac86-65f9-48b1-8d1e-b40fdd59b62a"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)goBack:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

-(void)monitorDownload:(id)sender
{
  ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
  ResoMediaTransfer * rmt = [rmtm.transfers objectForKey:@"3d6bac86-65f9-48b1-8d1e-b40fdd59b62a"];
  [rmt addDelegate:self];
}

#pragma mark -
#pragma mark ResoMediaTransfer Delegates
-(void) transferStarted:(ResoMediaTransfer*)t
{
  NSLog(@"ResoMediaTransferViewController::transferStarted");
}

-(void) transferProgressUpdated:(ResoMediaTransfer*)t
{
  NSLog(@"ResoMediaTransferViewController::transferProgressReceived");
}

-(void) transferFinished:(ResoMediaTransfer*)t
{
  NSLog(@"ResoMediaTransferViewController::transferFinished");
}

-(void) transferError:(ResoMediaTransfer*)t
{
  NSLog(@"ResoMediaTransferViewController::transferError");
}

@end
