//
//  ResoSoundLibraryViewController.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/17/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoSoundLibraryViewController.h"
#import "ResoDeviceSoundsViewController.h"
#import "ResoCloudSoundsViewController.h"

@interface ResoSoundLibraryViewController ()

@end

@implementation ResoSoundLibraryViewController
@synthesize backButton, deviceSoundsButton, cloudSoundsButton;

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
      
        //device sounds button
        deviceSoundsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deviceSoundsButton setTitle:@"Device Sounds" forState:UIControlStateNormal];
        [deviceSoundsButton addTarget:self action:@selector(showDeviceSounds:) forControlEvents:UIControlEventTouchUpInside];
        [deviceSoundsButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
        [deviceSoundsButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
        
        deviceSoundsButton.layer.borderColor = [UIColor blackColor].CGColor;
        deviceSoundsButton.layer.borderWidth = 0.0f;
        deviceSoundsButton.layer.cornerRadius = 4.0f;
        deviceSoundsButton.frame = CGRectMake(10, 100, self.view.bounds.size.width - 20, 50);
        [self.view addSubview:deviceSoundsButton];
        
        //cloud sounds button
        cloudSoundsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cloudSoundsButton setTitle:@"Cloud Sounds" forState:UIControlStateNormal];
        [cloudSoundsButton addTarget:self action:@selector(showCloudSounds:) forControlEvents:UIControlEventTouchUpInside];
        [cloudSoundsButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
        [cloudSoundsButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
        
        cloudSoundsButton.layer.borderColor = [UIColor blackColor].CGColor;
        cloudSoundsButton.layer.borderWidth = 0.0f;
        cloudSoundsButton.layer.cornerRadius = 4.0f;
        cloudSoundsButton.frame = CGRectMake(10, 170, self.view.bounds.size.width - 20, 50);
        [self.view addSubview:cloudSoundsButton];
      
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

-(void)showDeviceSounds:(id)sender
{
  ResoDeviceSoundsViewController * rdsvc = [[ResoDeviceSoundsViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rdsvc animated:YES];
}

-(void)showCloudSounds:(id)sender
{
  ResoCloudSoundsViewController * rcsvc = [[ResoCloudSoundsViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rcsvc animated:YES];
}

@end
