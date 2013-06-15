//
//  ResoMixViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoMixViewController.h"
#import "ResoSettings.h"

#import "ResoMixDeviceListViewController.h"
#import "ResoMixCloudListViewController.h"

#import "ResoAppDelegate.h"
#import "IResoVisualization.h"

#import "ResoDataManager.h"
#import "ResoMixManager.h"

@interface ResoMixViewController ()
{
  CGRect playerButtonFrame;
  CGRect playerButtonFrame_offscreen;
  
  CGRect viewPanelFrame;
  CGRect viewPanelFrame_offscreen;
}
@end

@implementation ResoMixViewController
@synthesize playerButton, mixListBar, viewPanel, currentMixPanel, currentMixTitle, currentMixThumb, currentMixButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self calculateWidgetFrames];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_NORMAL]];
    
    //player button
    playerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playerButton setImage:[UIImage imageNamed:@"icon-play-small.png"] forState:UIControlStateNormal];
    [playerButton setAdjustsImageWhenHighlighted:NO];
    [playerButton addTarget:self action:@selector(showPlayer:) forControlEvents:UIControlEventTouchUpInside];
    [playerButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
    [playerButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
    playerButton.layer.borderWidth = 0.0f;
    playerButton.alpha = ICON_BUTTON_OPACITY;
    playerButton.layer.cornerRadius = CORNER_RADIUS;
    playerButton.frame = playerButtonFrame_offscreen;
    [self.view addSubview:playerButton];
  
    //view panel
    viewPanel = [[UIView alloc] initWithFrame:viewPanelFrame_offscreen];
    [viewPanel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewPanel];
  
    //title panel
    currentMixPanel = [[UIView alloc] initWithFrame:CGRectMake(10, 5, [ResoAppDelegate windowWidth] - 20, ([ResoAppDelegate windowHeight] / 2.0f))];
    currentMixPanel.layer.cornerRadius = CORNER_RADIUS;
    [currentMixPanel setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.05]];
    [viewPanel addSubview:currentMixPanel];
  
    //mix title
    currentMixTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, currentMixPanel.frame.size.width-20, 60)];
    [currentMixTitle setBackgroundColor:[UIColor clearColor]];
    [currentMixTitle setFont:[UIFont systemFontOfSize:(FONT_SIZE*1.15)]];
    [currentMixTitle setTextColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA]];
    [currentMixTitle setLineBreakMode:NSLineBreakByWordWrapping];
    [currentMixTitle setNumberOfLines:3];
    [currentMixTitle setText:@"Current Mix"];
    [currentMixPanel addSubview:currentMixTitle];
  
    //mix image
    currentMixThumb = [[UIImageView alloc] initWithFrame:CGRectMake(10, currentMixTitle.frame.size.height, 75, 75)];
    currentMixThumb.layer.cornerRadius = CORNER_RADIUS;
    currentMixThumb.layer.shadowColor = [UIColor blackColor].CGColor;
    currentMixThumb.layer.shadowOffset = CGSizeMake(0, 1);
    currentMixThumb.layer.shadowOpacity = 1;
    currentMixThumb.layer.shadowRadius = 1.0;
    [currentMixThumb setClipsToBounds:NO];
    [currentMixThumb setBackgroundColor:[UIColor blackColor]];
    [currentMixPanel addSubview:currentMixThumb];
  
    //save mix button
    currentMixButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [currentMixButton setTitle:@"Save Mix" forState:UIControlStateNormal];
    [currentMixButton addTarget:self action:@selector(initSaveMix:) forControlEvents:UIControlEventTouchUpInside];
    [currentMixButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [currentMixButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.05]];
    
    currentMixButton.layer.borderColor = [UIColor blackColor].CGColor;
    currentMixButton.layer.borderWidth = 0.0f;
    currentMixButton.layer.cornerRadius = CORNER_RADIUS;
    currentMixButton.frame = CGRectMake(10, (currentMixPanel.frame.size.height-54), (currentMixPanel.frame.size.width - 20), 44);
    [currentMixPanel addSubview:currentMixButton];
  
    //mix list bar
    mixListBar = [[ResoActionBar alloc] initWithFrame:CGRectMake(10, viewPanel.frame.size.height - 60, viewPanel.frame.size.width-20, 50) withText:@"Mix Library" withIconText:nil withIconColor:nil withDirection:Forward];
    [mixListBar.actionButton addTarget:self action:@selector(showMixLibrary:) forControlEvents:UIControlEventTouchUpInside];
    [viewPanel addSubview:mixListBar];
  
    [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                          delay:0.00
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       playerButton.frame = playerButtonFrame;
                       viewPanel.frame = viewPanelFrame;
                     } completion:^(BOOL finished) {
                       if (finished) {
                       }
                     }];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
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

- (void)showPlayer:(id)sender
{
  [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                        delay:0.00
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     playerButton.frame = playerButtonFrame_offscreen;
                     viewPanel.frame = viewPanelFrame_offscreen;
                   } completion:^(BOOL finished) {
                     if (finished) {
                       ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
                       [ad.visualization refreshVisual];
                       [ad.visualization enableTransitions:true];
                       [self.navigationController popViewControllerAnimated:NO];
                     }
                   }];
}

- (void)showMixLibrary:(id)sender
{
  ResoDataManager * rdm = [ResoDataManager instance];
  if ([rdm mixCount] > 0) {
    ResoMixCloudListViewController * cvc = [[ResoMixCloudListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:cvc animated:NO];
    
    ResoMixDeviceListViewController * vc = [[ResoMixDeviceListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
  } else {
    ResoMixDeviceListViewController * dvc = [[ResoMixDeviceListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:dvc animated:NO];
    
    ResoMixCloudListViewController * vc = [[ResoMixCloudListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
  }
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

- (void)calculateWidgetFrames
{
  //player button
  playerButtonFrame = CGRectMake([ResoAppDelegate windowWidth]-50, 0, 50, 50);
  playerButtonFrame_offscreen = CGRectMake([ResoAppDelegate windowWidth]+50, 0, 50, 50);
  
  //view panel
  viewPanelFrame = CGRectMake(0, playerButtonFrame.size.height, [ResoAppDelegate windowWidth], ([ResoAppDelegate windowHeight] - playerButtonFrame.size.height));
  viewPanelFrame_offscreen = CGRectMake(-(viewPanelFrame.size.width), viewPanelFrame.origin.y, viewPanelFrame.size.width, viewPanelFrame.size.height);
}

#pragma uialertviewdelegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  if (buttonIndex == 1) {
    [self saveMixWithName:[alertView textFieldAtIndex:0].text];
  }
}

@end
