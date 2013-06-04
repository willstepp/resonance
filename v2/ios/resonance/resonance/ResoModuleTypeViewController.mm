//
//  ResoModuleTypeViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoModuleTypeViewController.h"
#import "ResoSettings.h"
#import "ResoModuleSoundCategoryViewController.h"
#import "ResoModuleToneGeneratorViewController.h"

@interface ResoModuleTypeViewController ()
{
  CGRect backButtonFrame;
  CGRect backButtonFrame_offscreen;
}
@end

@implementation ResoModuleTypeViewController
@synthesize backButton, soundLibraryBar, toneGeneratorBar;

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
        backButton.frame = backButtonFrame_offscreen;
        backButton.alpha = 0.0f;
        [self.view addSubview:backButton];
      
        //sound library bar
        soundLibraryBar = [[ResoActionBar alloc] initWithFrame:CGRectMake(10, (self.view.bounds.size.height / 2) - 75, self.view.bounds.size.width - 20, 50) withText:@"Sound Library" withIconText:nil withIconColor:nil];
        [soundLibraryBar.actionButton addTarget:self action:@selector(showSoundLibrary:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:soundLibraryBar];
      
        //tone generator bar
        toneGeneratorBar = [[ResoActionBar alloc] initWithFrame:CGRectMake(10, soundLibraryBar.frame.origin.y+60, self.view.bounds.size.width - 20, 50)  withText:@"Tone Generator" withIconText:nil withIconColor:nil];
        [toneGeneratorBar.actionButton addTarget:self action:@selector(showToneGenerator:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:toneGeneratorBar];
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
  
  backButton.alpha = ICON_BUTTON_OPACITY;
  [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST / 2.0f
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     backButton.frame = backButtonFrame;
                   } completion:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goBack:(id)sender
{
  [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST / 2.0f
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     backButton.frame = backButtonFrame_offscreen;
                   } completion:^(BOOL finished){
                     backButton.alpha = 0.0f;
                     [self.navigationController popViewControllerAnimated:YES];
                   }];
}

-(void)showSoundLibrary:(id)sender
{
  ResoModuleSoundCategoryViewController * rmscvc = [[ResoModuleSoundCategoryViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmscvc animated:YES];
}

-(void)showToneGenerator:(id)sender
{
  ResoModuleToneGeneratorViewController * rmtgvc = [[ResoModuleToneGeneratorViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmtgvc animated:YES];
}

- (void)calculateWidgetFrames
{
  //back button
  backButtonFrame = CGRectMake(0, 0, 50, 50);
  backButtonFrame_offscreen = CGRectMake(-(backButtonFrame.size.width), backButtonFrame.origin.y, backButtonFrame.size.width, backButtonFrame.size.height);
}

@end
