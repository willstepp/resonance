//
//  ResoModuleSoundCategoryViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoModuleSoundCategoryViewController.h"
#import "ResoSettings.h"
#import "ResoModuleCloudListViewController.h"
#import "ResoAppDelegate.h"

@interface ResoModuleSoundCategoryViewController ()
{
  CGRect backButtonFrame;
  CGRect backButtonFrame_offscreen;
}
@end

@implementation ResoModuleSoundCategoryViewController
@synthesize backButton, soundListBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      [self calculateWidgetFrames];
      
      [self.view setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_NORMAL]];
      
      //back button
      backButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [backButton setImage:[UIImage imageNamed:@"icon-chevron-left-small.png"] forState:UIControlStateNormal];
      [backButton setAdjustsImageWhenHighlighted:NO];
      backButton.alpha = ICON_BUTTON_OPACITY;
      [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
      [backButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [backButton setBackgroundColor:[UIColor clearColor]];
      
      backButton.layer.borderColor = [UIColor blackColor].CGColor;
      backButton.layer.borderWidth = 0.0f;
      backButton.layer.cornerRadius = 4.0f;
      backButton.frame = backButtonFrame;
      backButton.alpha = 1.0f;
      [self.view addSubview:backButton];
      
      //sound library bar
      soundListBar = [[ResoActionBar alloc] initWithFrame:CGRectMake(10, ([ResoAppDelegate windowHeight] / 2) - 50, [ResoAppDelegate windowWidth] - 20, 50) withText:@"Sounds List" withIconText:nil withIconColor:nil withDirection:Forward];
      [soundListBar.actionButton addTarget:self action:@selector(showSoundsList:) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:soundListBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goBack:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)calculateWidgetFrames
{
  //back button
  backButtonFrame = CGRectMake(0, 0, 50, 50);
  backButtonFrame_offscreen = CGRectMake(-(backButtonFrame.size.width), backButtonFrame.origin.y, backButtonFrame.size.width, backButtonFrame.size.height);
}

- (void)showSoundsList:(id)sender
{
  ResoModuleCloudListViewController * rmclvc = [[ResoModuleCloudListViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmclvc animated:YES];
}

@end
