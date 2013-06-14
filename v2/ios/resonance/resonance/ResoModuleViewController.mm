//
//  ResoModuleViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoModuleViewController.h"
#import "ResoAppDelegate.h"
#import "IResoVisualization.h"
#import "ResoSettings.h"
#import "ResoModuleManager.h"
#import "ResoModule.h"

#import "ResoDataManager.h"
#import "ResoFileManager.h"

#import "ResoModuleSettingsViewController.h"
#import "ResoModuleTypeViewController.h"

@interface ResoModuleViewController ()
{
  CGRect playerButtonFrame;
  CGRect playerButtonFrame_offscreen;
  
  CGRect settingsBarFrame;
  CGRect settingsBarFrame_offscreen;
  
  CGRect changeSoundBarFrame;
  CGRect changeSoundBarFrame_offscreen;
  
  CGRect soundLabelFrame;
  CGRect soundImageFrame;
  CGRect soundDescriptionFrame;
  CGRect soundSliceFrame;
  
  CGRect propertiesPanelFrame;
  CGRect propertiesPanelFrame_offscreen;
}
@end

@implementation ResoModuleViewController
@synthesize playerButton, settingsBar, changeSoundBar;
@synthesize soundTitleLabel, soundImageView, descriptionTextView, propertiesPanel, sliceImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
      playerButton.layer.cornerRadius = CORNER_RADIUS;
      playerButton.frame = playerButtonFrame_offscreen;
      playerButton.alpha = ICON_BUTTON_OPACITY;
      [self.view addSubview:playerButton];
      
      //sound title
      soundTitleLabel = [[UILabel alloc] initWithFrame:soundLabelFrame];
      [soundTitleLabel setBackgroundColor:[UIColor clearColor]];
      [soundTitleLabel setFont:[UIFont systemFontOfSize:(FONT_SIZE*1.5f)]];
      [soundTitleLabel setTextColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA]];
      
      //sound slice
      sliceImageView = [[UIImageView alloc] initWithFrame:soundSliceFrame];
      sliceImageView.alpha = 0.50f;
      [sliceImageView setClipsToBounds:YES];
      
      //sound image
      soundImageView = [[UIImageView alloc] initWithFrame:soundImageFrame];
      soundImageView.layer.cornerRadius = CORNER_RADIUS;
      soundImageView.layer.shadowColor = [UIColor blackColor].CGColor;
      soundImageView.layer.shadowOffset = CGSizeMake(0, 1);
      soundImageView.layer.shadowOpacity = 1;
      soundImageView.layer.shadowRadius = 1.0;
      [soundImageView setClipsToBounds:NO];
      
      //sound description
      descriptionTextView = [[UITextView alloc] initWithFrame:soundDescriptionFrame];
      descriptionTextView.contentInset = UIEdgeInsetsMake(-8,-8,-8,-8);
      [descriptionTextView setBackgroundColor:[UIColor clearColor]];
      [descriptionTextView setFont:[UIFont systemFontOfSize:FONT_SIZE]];
      [descriptionTextView setTextColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA]];
      
      //properties panel
      propertiesPanel = [[UIView alloc] initWithFrame:propertiesPanelFrame_offscreen];
      [propertiesPanel setBackgroundColor:[UIColor clearColor]];
      
      [propertiesPanel addSubview:soundTitleLabel];
      [propertiesPanel addSubview:sliceImageView];
      [propertiesPanel addSubview:soundImageView];
      [propertiesPanel addSubview:descriptionTextView];
      
      [self.view addSubview:propertiesPanel];
      
      changeSoundBar = [[ResoActionBar alloc] initWithFrame:changeSoundBarFrame_offscreen withText:@"Change Sound" withIconText:nil withIconColor:nil withDirection:Forward];
      [changeSoundBar.actionButton addTarget:self action:@selector(changeSound:) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:changeSoundBar];
      
      settingsBar = [[ResoActionBar alloc] initWithFrame:settingsBarFrame_offscreen withText:@"Settings" withIconText:nil withIconColor:nil withDirection:Forward];
      [settingsBar.actionButton addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:settingsBar];
  }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  
  if (ad.currentModule == nil) {
    [self showChangeSound:NO];
    return;
  }
  
  //load properties
  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoModule * rm = [rmm.modules objectForKey:ad.currentModule];
  ResoDataManager * rdm = [ResoDataManager instance];
  NSMutableDictionary * sound = [rdm soundWithIdentifier:rm.soundUuid];
  
  //title
  [soundTitleLabel setText:[sound objectForKey:@"name"]];
  
  //slice
  NSString * slicePath = [NSString stringWithFormat:@"sounds/%@/slice", rm.soundUuid];
  NSString * slice = [[ResoFileManager resonanceAppSubDirectory:slicePath] path];
  [sliceImageView setImage:[UIImage imageWithContentsOfFile:slice]];
  
  //thumb
  NSString * imagePath = [NSString stringWithFormat:@"sounds/%@/thumb", rm.soundUuid];
  NSString * image = [[ResoFileManager resonanceAppSubDirectory:imagePath] path];
  [soundImageView setImage:[UIImage imageWithContentsOfFile:image]];

  //description
  [descriptionTextView setText:[sound objectForKey:@"desc"]];
  
  if (animated) {
    playerButton.frame = playerButtonFrame;
    propertiesPanel.frame = propertiesPanelFrame;
    settingsBar.frame = settingsBarFrame;
    changeSoundBar.frame = changeSoundBarFrame;
  } else {
    [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                          delay:0.00
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       playerButton.frame = playerButtonFrame;
                       propertiesPanel.frame = propertiesPanelFrame;
                       settingsBar.frame = settingsBarFrame;
                       changeSoundBar.frame = changeSoundBarFrame;
                     } completion:nil];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSound:(id)sender
{
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  ResoModuleManager * rmm = [ResoModuleManager instance];
  
  if (ad.currentModule != nil)
    [rmm removeModuleWithUuid:ad.currentModule];
  
  NSString * uuid = [[NSUUID UUID] UUIDString];
  [rmm addModuleWithUuid:uuid];
  ResoModule * rm = [rmm.modules objectForKey:uuid];
  [rm loadSound:@"test" looped:false];

  ad.currentModule = uuid;
}

- (void)showPlayer:(id)sender
{
  [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                        delay:0.00
                      options:UIViewAnimationOptionCurveEaseIn
                   animations:^{
                     playerButton.frame = playerButtonFrame_offscreen;
                     propertiesPanel.frame = propertiesPanelFrame_offscreen;
                     settingsBar.frame = settingsBarFrame_offscreen;
                     changeSoundBar.frame = changeSoundBarFrame_offscreen;
                   } completion:^(BOOL finished) {
                     if (finished) {
                       ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
                       [ad.visualization enableTransitions:true];
                       if (ad.currentModule == nil) {
                         [ad.visualization refreshVisual];
                       }
                       [self.navigationController popViewControllerAnimated:NO];
                     }
                   }];
}

- (void)showSettings:(id)sender
{
  ResoModuleSettingsViewController * rmsvc = [[ResoModuleSettingsViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmsvc animated:YES];
}

- (void)changeSound:(id)sender
{
  [self showChangeSound:YES];
}

- (void)showChangeSound:(BOOL)animated
{
  ResoModuleTypeViewController * rmtvc = [[ResoModuleTypeViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmtvc animated:animated];
}

- (void)calculateWidgetFrames
{
  //player button
  playerButtonFrame = CGRectMake([ResoAppDelegate windowWidth]-50, 0, 50, 50);
  playerButtonFrame_offscreen = CGRectMake([ResoAppDelegate windowWidth]+50, 0, 50, 50);
  
  //change sound bar
  changeSoundBarFrame = CGRectMake(10, ([ResoAppDelegate windowHeight] - 60), [ResoAppDelegate windowWidth] - 20, 50);
  changeSoundBarFrame_offscreen = CGRectMake(-(changeSoundBarFrame.size.width), changeSoundBarFrame.origin.y, changeSoundBarFrame.size.width, changeSoundBarFrame.size.height);
  
  //settings bar
  settingsBarFrame = CGRectMake(10, (changeSoundBarFrame.origin.y - 60), [ResoAppDelegate windowWidth] - 20, 50);
  settingsBarFrame_offscreen = CGRectMake(-(settingsBarFrame.size.width), settingsBarFrame.origin.y, settingsBarFrame.size.width, settingsBarFrame.size.height);
  
  //properties panel
  float panelHeight = ([ResoAppDelegate windowHeight] - (playerButton.frame.size.height+changeSoundBar.frame.size.height+settingsBar.frame.size.height+10)) / 1.5f;
  propertiesPanelFrame = CGRectMake(0, playerButtonFrame.size.height-5, [ResoAppDelegate windowWidth], panelHeight);
  
  propertiesPanelFrame_offscreen = CGRectMake(-(propertiesPanelFrame.size.width), propertiesPanelFrame.origin.y, propertiesPanelFrame.size.width, propertiesPanelFrame.size.height);
  
  //sound title
  soundLabelFrame = CGRectMake(10, 0, [ResoAppDelegate windowWidth] - 20, 35);
  
  //sound slice
  soundSliceFrame = CGRectMake(0, soundLabelFrame.origin.y+soundLabelFrame.size.height+7, [ResoAppDelegate windowWidth], SLICE_IMAGE_HEIGHT);
  
  //sound thumb
  soundImageFrame = CGRectMake(10, soundLabelFrame.origin.y+soundLabelFrame.size.height+15, 100, 100);
  
  //sound description
  soundDescriptionFrame = CGRectMake(10, soundImageFrame.origin.y+soundImageFrame.size.height+15, [ResoAppDelegate windowWidth] - 20, 200);
}

@end
