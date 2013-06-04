//
//  ResoModuleSoundDetailsViewController.m
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoModuleSoundDetailsViewController.h"
#import "ResoSettings.h"
#import "ResoModuleViewController.h"

@interface ResoModuleSoundDetailsViewController ()
{
  CGRect backButtonFrame;
  CGRect backButtonFrame_offscreen;
}
@end

@implementation ResoModuleSoundDetailsViewController
@synthesize backButton, returnBar;

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
    [self.view addSubview:backButton];
    
    //return bar
    returnBar = [[ResoActionBar alloc] initWithFrame:CGRectMake(10, (self.view.bounds.size.height / 2) - 50, self.view.bounds.size.width - 20, 50) withText:@"Return to Module" withIconText:nil withIconColor:nil];
    [returnBar.actionButton addTarget:self action:@selector(returnToModule:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:returnBar];
  }
  return self;
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

-(void)goBack:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)calculateWidgetFrames
{
  //back button
  backButtonFrame = CGRectMake(0, 0, 50, 50);
}

- (void)returnToModule:(id)sender
{
  //This for loop iterates through all the view controllers in navigation stack.
  for (UIViewController * viewController in self.navigationController.viewControllers) {
    
    //This if condition checks whether the viewController's class is MyGroupViewController
    // if true that means its the MyGroupViewController (which has been pushed at some point)
    if ([viewController isKindOfClass:[ResoModuleViewController class]] ) {
      
      // Here viewController is a reference of UIViewController base class of MyGroupViewController
      // but viewController holds MyGroupViewController  object so we can type cast it here
      ResoModuleViewController * rmvc = (ResoModuleViewController*)viewController;
      [self.navigationController popToViewController:rmvc animated:YES];
    }
  }
}

@end
