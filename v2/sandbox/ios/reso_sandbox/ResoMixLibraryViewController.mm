//
//  ResoMixLibraryViewController.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/17/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoMixLibraryViewController.h"
#import "ResoCloudMixesViewController.h"
#import "ResoDeviceMixesViewController.h"

@interface ResoMixLibraryViewController ()

@end

@implementation ResoMixLibraryViewController
@synthesize backButton, cloudMixesButton, deviceMixesButton;

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
      
        //device mixes button
        deviceMixesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deviceMixesButton setTitle:@"Device Mixes" forState:UIControlStateNormal];
        [deviceMixesButton addTarget:self action:@selector(showDeviceMixes:) forControlEvents:UIControlEventTouchUpInside];
        [deviceMixesButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
        [deviceMixesButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
        
        deviceMixesButton.layer.borderColor = [UIColor blackColor].CGColor;
        deviceMixesButton.layer.borderWidth = 0.0f;
        deviceMixesButton.layer.cornerRadius = 4.0f;
        deviceMixesButton.frame = CGRectMake(10, 100, self.view.bounds.size.width - 20, 50);
        [self.view addSubview:deviceMixesButton];
        
        //cloud mixes button
        cloudMixesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cloudMixesButton setTitle:@"Cloud Mixes" forState:UIControlStateNormal];
        [cloudMixesButton addTarget:self action:@selector(showCloudMixes:) forControlEvents:UIControlEventTouchUpInside];
        [cloudMixesButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
        [cloudMixesButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
        
        cloudMixesButton.layer.borderColor = [UIColor blackColor].CGColor;
        cloudMixesButton.layer.borderWidth = 0.0f;
        cloudMixesButton.layer.cornerRadius = 4.0f;
        cloudMixesButton.frame = CGRectMake(10, 170, self.view.bounds.size.width - 20, 50);
        [self.view addSubview:cloudMixesButton];
      
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

-(void)showDeviceMixes:(id)sender
{
  ResoDeviceMixesViewController * rdmvc = [[ResoDeviceMixesViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rdmvc animated:YES];
}

-(void)showCloudMixes:(id)sender
{
  ResoCloudMixesViewController * rcmvc = [[ResoCloudMixesViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rcmvc animated:YES];
}

@end
