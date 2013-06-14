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
#import "ResoFileManager.h"
#import "ResoModuleManager.h"
#import "ResoModule.h"
#import "ResoAppDelegate.h"
#import "IResoVisualization.h"
#import "ISound.h"
#import "ITone.h"
#import "ResoDataManager.h"
#import "ResoSlider.h"
#import "ResoMediaTransferManager.h"
#import "ResoModuleCloudListViewController.h"
#import "ResoModuleDeviceListViewController.h"
#import "ResoPlayerViewController.h"

@interface ResoModuleSoundDetailsViewController ()
{
  CGRect backButtonFrame;
  CGRect backButtonFrame_offscreen;
  
  CGRect viewPanelFrame;
  CGRect viewPanelFrame_offscreen;
}
@end

@implementation ResoModuleSoundDetailsViewController
@synthesize backButton, soundDetails, soundTitleLabel, soundImageView, titlePanel, devicePanel, devicePreviewButton, removeButton, deviceDescriptionTextView, loadButton, returnButton, storePanel, downloadProgress, storeDescriptionTextView, storePreviewButton, downloadButton, viewPanel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {

    soundDetails = [[NSMutableDictionary alloc] init];
    [self calculateWidgetFrames];
    
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
    
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
  backButton.layer.cornerRadius = CORNER_RADIUS;
  backButton.frame = backButtonFrame;
  [self.view addSubview:backButton];
  
  //view panel
  viewPanel = [[UIView alloc] initWithFrame:viewPanelFrame];
  [viewPanel setBackgroundColor:[UIColor clearColor]];
  [self.view addSubview:viewPanel];
  
  //title panel
  titlePanel = [[UIView alloc] initWithFrame:CGRectMake(10, 5, [ResoAppDelegate windowWidth] - 20, SLICE_IMAGE_HEIGHT)];
  titlePanel.layer.cornerRadius = CORNER_RADIUS;
  [titlePanel setClipsToBounds:YES];
  [titlePanel setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.15]];
  [viewPanel addSubview:titlePanel];
  
  //sound image
  soundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 75, 75)];
  soundImageView.layer.cornerRadius = CORNER_RADIUS;
  soundImageView.layer.shadowColor = [UIColor blackColor].CGColor;
  soundImageView.layer.shadowOffset = CGSizeMake(0, 1);
  soundImageView.layer.shadowOpacity = 1;
  soundImageView.layer.shadowRadius = 1.0;
  [soundImageView setClipsToBounds:NO];
  [titlePanel addSubview:soundImageView];
  
  //sound title
  soundTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+soundImageView.frame.size.width, 5, titlePanel.frame.size.width-10-soundImageView.frame.size.width, 75)];
  [soundTitleLabel setBackgroundColor:[UIColor clearColor]];
  [soundTitleLabel setFont:[UIFont systemFontOfSize:(FONT_SIZE*1.25)]];
  [soundTitleLabel setTextColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA]];
  [soundTitleLabel setLineBreakMode:NSLineBreakByWordWrapping];
  [soundTitleLabel setNumberOfLines:3];
  [titlePanel addSubview:soundTitleLabel];
  
  //device: panel
  devicePanel = [[UIView alloc] initWithFrame:CGRectMake(10, titlePanel.frame.origin.y+titlePanel.frame.size.height+10, [ResoAppDelegate windowWidth] - 20, [ResoAppDelegate windowHeight] - (backButton.frame.size.height+titlePanel.frame.size.height+25))];
  [devicePanel setBackgroundColor:[UIColor clearColor]];
  devicePanel.alpha = 0.0f;
  [viewPanel addSubview:devicePanel];
  
  //device: preview button
  devicePreviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [devicePreviewButton setTitle:@"Preview" forState:UIControlStateNormal];
  [devicePreviewButton addTarget:self action:@selector(previewSound:) forControlEvents:UIControlEventTouchUpInside];
  [devicePreviewButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [devicePreviewButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1]];
  
  devicePreviewButton.layer.borderColor = [UIColor blackColor].CGColor;
  devicePreviewButton.layer.borderWidth = 0.0f;
  devicePreviewButton.layer.cornerRadius = CORNER_RADIUS;
  devicePreviewButton.frame = CGRectMake(0, 0, (devicePanel.frame.size.width / 2.0f) - 5, 44);
  [devicePanel addSubview:devicePreviewButton];
  
  //device: remove button
  removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [removeButton setTitle:@"Remove" forState:UIControlStateNormal];
  [removeButton addTarget:self action:@selector(removeSound:) forControlEvents:UIControlEventTouchUpInside];
  [removeButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [removeButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1]];
  
  removeButton.layer.borderColor = [UIColor blackColor].CGColor;
  removeButton.layer.borderWidth = 0.0f;
  removeButton.layer.cornerRadius = CORNER_RADIUS;
  removeButton.frame = CGRectMake(devicePreviewButton.frame.size.width+10, 0, (devicePanel.frame.size.width / 2.0f) - 5, 44);
  [devicePanel addSubview:removeButton];
  
  //device: description
  deviceDescriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, removeButton.frame.origin.y+removeButton.frame.size.height+10, devicePanel.frame.size.width, 200)];
  [deviceDescriptionTextView setBackgroundColor:[UIColor clearColor]];
  [deviceDescriptionTextView setFont:[UIFont systemFontOfSize:FONT_SIZE]];
  [deviceDescriptionTextView setTextColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA]];
  [devicePanel addSubview:deviceDescriptionTextView];
  
  //device: load button
  loadButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [loadButton setTitle:@"Load" forState:UIControlStateNormal];
  [loadButton addTarget:self action:@selector(loadSound:) forControlEvents:UIControlEventTouchUpInside];
  [loadButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [loadButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1]];
  
  loadButton.layer.borderColor = [UIColor blackColor].CGColor;
  loadButton.layer.borderWidth = 0.0f;
  loadButton.layer.cornerRadius = CORNER_RADIUS;
  loadButton.frame = CGRectMake(0, devicePanel.frame.size.height - 50, devicePanel.frame.size.width, 50);
  [devicePanel addSubview:loadButton];
  
  //device: return button
  returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [returnButton setAdjustsImageWhenHighlighted:NO];
  [returnButton addTarget:self action:@selector(returnToPlayer:) forControlEvents:UIControlEventTouchUpInside];
  [returnButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [returnButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1]];
  returnButton.alpha = 0.0f;
  returnButton.layer.borderColor = [UIColor blackColor].CGColor;
  returnButton.layer.borderWidth = 0.0f;
  returnButton.layer.cornerRadius = CORNER_RADIUS;
  returnButton.frame = CGRectMake(0, devicePanel.frame.size.height - 50, devicePanel.frame.size.width, 50);
  returnButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
  [returnButton setImage:[UIImage imageNamed:@"icon-play-small.png"] forState:UIControlStateNormal];
  [devicePanel addSubview:returnButton];

  //store: panel
  storePanel = [[UIView alloc] initWithFrame:CGRectMake(10, titlePanel.frame.origin.y+titlePanel.frame.size.height+10, [ResoAppDelegate windowWidth] - 20, [ResoAppDelegate windowHeight] - (backButton.frame.size.height+titlePanel.frame.size.height+25))];
  [devicePanel setBackgroundColor:[UIColor clearColor]];
  storePanel.alpha = 1.0f;
  [viewPanel addSubview:storePanel];
  
  //store: progress
  downloadProgress = [[ResoSlider alloc]initWithFrame:CGRectMake(0, 0, storePanel.frame.size.width, 44) withOrientation:Horizontal withCornerRadius:1.0f];
  downloadProgress.minValue = 0;
  downloadProgress.maxValue = 1000;
  [downloadProgress setValue:0];
  [storePanel addSubview:downloadProgress];
  
  //store: description
  storeDescriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, downloadProgress.frame.origin.y+downloadProgress.frame.size.height+10, devicePanel.frame.size.width, 200)];
  [storeDescriptionTextView setBackgroundColor:[UIColor clearColor]];
  [storeDescriptionTextView setFont:[UIFont systemFontOfSize:FONT_SIZE]];
  [storeDescriptionTextView setTextColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA]];
  [storePanel addSubview:storeDescriptionTextView];
  
  //store: preview button
  storePreviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [storePreviewButton setTitle:@"Preview" forState:UIControlStateNormal];
  [storePreviewButton addTarget:self action:@selector(previewSound:) forControlEvents:UIControlEventTouchUpInside];
  [storePreviewButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [storePreviewButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1]];
  
  storePreviewButton.layer.borderColor = [UIColor blackColor].CGColor;
  storePreviewButton.layer.borderWidth = 0.0f;
  storePreviewButton.layer.cornerRadius = 4.0f;
  storePreviewButton.frame = CGRectMake(0, storePanel.frame.size.height-44, (storePanel.frame.size.width / 2.0f) - 5, 44);
  [storePanel addSubview:storePreviewButton];
  
  //store: download button
  downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
  [downloadButton addTarget:self action:@selector(downloadSound:) forControlEvents:UIControlEventTouchUpInside];
  [downloadButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [downloadButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1]];
  
  downloadButton.layer.borderColor = [UIColor blackColor].CGColor;
  downloadButton.layer.borderWidth = 0.0f;
  downloadButton.layer.cornerRadius = CORNER_RADIUS;
  downloadButton.frame = CGRectMake(storePreviewButton.frame.size.width+10, storePanel.frame.size.height-44, (storePanel.frame.size.width / 2.0f) - 5, 44);
  [storePanel addSubview:downloadButton];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [[ResoMediaTransferManager instance] addDelegate:self];
  
  NSString * uuid = [soundDetails objectForKey:@"uuid"];
  
  //title
  [soundTitleLabel setText:[soundDetails objectForKey:@"name"]];
  
  //thumb
  NSString * imagePath = [NSString stringWithFormat:@"sounds/%@/thumb", uuid];
  NSString * image = [[ResoFileManager resonanceAppSubDirectory:imagePath] path];
  [soundImageView setImage:[UIImage imageWithContentsOfFile:image]];
  
  //description
  [deviceDescriptionTextView setText:[soundDetails objectForKey:@"desc"]];
  [storeDescriptionTextView setText:[soundDetails objectForKey:@"desc"]];
  
  if (self.downloaded) {
    [self showPanelFor:SoundLocation_Device];
  } else {
    [self showPanelFor:SoundLocation_Store];
  }
  
  //check for loaded sound
  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  ResoModule * rm = [rmm.modules objectForKey:ad.currentModule];
  if ([rm.soundUuid isEqualToString:uuid]) {
    [self showReturnToModuleButton:true];
  } else {
    [self showReturnToModuleButton:false];
  }
}

- (void)viewDidDisappear:(BOOL)animated
{
  [[ResoMediaTransferManager instance] removeDelegate:self];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)goBack:(id)sender
{
  if (self.downloaded) {

    for (UIViewController * viewController in self.navigationController.viewControllers) {
      if ([viewController isKindOfClass:[ResoModuleDeviceListViewController class]] ) {
        ResoModuleDeviceListViewController * rmdlvc = (ResoModuleDeviceListViewController*)viewController;
        rmdlvc.refreshView = true;
        [self.navigationController popToViewController:rmdlvc animated:YES];
        return;
      }
    }
    
  } else {
    
    for (UIViewController * viewController in self.navigationController.viewControllers) {
      if ([viewController isKindOfClass:[ResoModuleCloudListViewController class]] ) {
        ResoModuleCloudListViewController * rmclvc = (ResoModuleCloudListViewController*)viewController;
        rmclvc.refreshView = true;
        [self.navigationController popToViewController:rmclvc animated:YES];
        return;
      }
    }
    
  }
}

- (void)calculateWidgetFrames
{
  //back button
  backButtonFrame = CGRectMake(0, 0, 50, 50);
  backButtonFrame_offscreen = CGRectMake(-(backButtonFrame.size.width), backButtonFrame.origin.y, backButtonFrame.size.width, backButtonFrame.size.height);
  
  //view panel
  viewPanelFrame = CGRectMake(0, backButtonFrame.size.height, [ResoAppDelegate windowWidth], ([ResoAppDelegate windowHeight] - backButtonFrame.size.height));
  viewPanelFrame_offscreen = CGRectMake(viewPanelFrame.size.width, viewPanelFrame.origin.y, viewPanelFrame.size.width, viewPanelFrame.size.height);
}

- (void)returnToPlayer:(id)sender
{
  [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                        delay:0.00
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     backButton.frame = backButtonFrame_offscreen;
                     viewPanel.frame = viewPanelFrame_offscreen;
                   } completion:^(BOOL finished) {
                     if (finished) {
                       ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
                       [ad.visualization enableTransitions:true];
                       if (ad.currentModule == nil) {
                         [ad.visualization refreshVisual];
                       }
                       [self showPlayer];
                     }
                   }];
}

- (void)showPlayer
{
  //This for loop iterates through all the view controllers in navigation stack.
  for (UIViewController * viewController in self.navigationController.viewControllers) {
    
    //This if condition checks whether the viewController's class is MyGroupViewController
    // if true that means its the MyGroupViewController (which has been pushed at some point)
    if ([viewController isKindOfClass:[ResoPlayerViewController class]] ) {
      
      // Here viewController is a reference of UIViewController base class of MyGroupViewController
      // but viewController holds MyGroupViewController  object so we can type cast it here
      ResoPlayerViewController * rpvc = (ResoPlayerViewController*)viewController;
      [self.navigationController popToViewController:rpvc animated:NO];
    }
  }
}

- (void)showReturnToModuleButton:(bool)show
{
  if (show) {
    loadButton.alpha = 0.0f;
    returnButton.alpha = 1.0f;
  } else {
    returnButton.alpha = 0.0f;
    loadButton.alpha = 1.0f;
  }
}

- (void)loadSound:(id)sender
{
    NSString * uuid = [soundDetails objectForKey:@"uuid"];
    
    ResoModuleManager * rmm = [ResoModuleManager instance];
    ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    //create new module if current module is nil
    NSString * moduleUuid = ad.currentModule;
    if (moduleUuid == nil) {
      moduleUuid = [[NSUUID UUID] UUIDString];
      [rmm addModuleWithUuid:moduleUuid];
      ad.currentModule = moduleUuid;
    }
    
    ResoModule * rm = [rmm.modules objectForKey:ad.currentModule];
    
    //remove old sound from visualization
    [ad.visualization removeSound:rm.soundUuid];
    
    //load new sound
    [rm loadSound:uuid looped:true];
    [rm.sound play];
    rm.volume = BASE_MODULE_VOLUME;
    [rm updateVolume:BASE_MODULE_VOLUME];
    if (!ad.playing) {
      [rm.sound setPaused:true];
    }
    
    //update visualization
    [ad.visualization addSound:uuid];
    [ad.visualization setActiveSound:uuid];
  
    [self showReturnToModuleButton:true];
}

-(void)previewSound:(id)sender
{
    NSString * uuid = [soundDetails objectForKey:@"uuid"];
    NSString * pp = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/preview", uuid]] path];
    bool exists = [[NSFileManager defaultManager] fileExistsAtPath:pp];
    if (exists) {
      [self playPreview:uuid];
    } else {
      //enqueue preview download
      ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
      [rmtm initTransferOfType:SoundPreviewTransfer withIdentifier:uuid withObject:nil];
    }
}

-(void)playPreview:(NSString*)uuid
{
  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoModule * rm = [rmm.modules objectForKey:@"preview"];
  [rm loadPreview:uuid looped:false mediaType:MediaType_Sound];
  [rm.sound play];
}

-(void)downloadSound:(id)sender
{
    NSString * uuid = [soundDetails objectForKey:@"uuid"];
    
    //first test if sound already exists
    ResoDataManager * rdm = [ResoDataManager instance];
    if (![rdm soundExists:uuid withContext:[rdm managedObjectContext]]) {
      
      //download using rtm
      ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
      [rmtm initTransferOfType:SoundTransferDownload withIdentifier:uuid withObject:nil];
    }
}

-(void)downloadComplete:(NSString*)uuid
{
  self.downloaded = true;
  [downloadProgress updateValue:0];
  [self showReturnToModuleButton:false];
  [self showPanelFor:SoundLocation_Device];
}

-(void)removeSound:(id)sender
{
    NSString * uuid = [soundDetails objectForKey:@"uuid"];
    [self removeSoundFromDevice:uuid];
    self.downloaded = false;
    [self showPanelFor:SoundLocation_Store];
  
    ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];

    //if sound is loaded, unload it
    ResoModuleManager * rmm = [ResoModuleManager instance];
    ResoModule * rm = [rmm.modules objectForKey:ad.currentModule];
    if ([rm.soundUuid isEqualToString:uuid]) {
      [rm unload];
    }
  
    //remove old sound from visualization
    [ad.visualization removeSound:rm.soundUuid];
    [ad.visualization setActiveSound:nil];
}

-(void)removeSoundFromDevice:(NSString*)uuid
{
  ResoDataManager * rdm = [ResoDataManager instance];
  
  //remove install folder
  NSString * soundInstallPath = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]] path];
  [[NSFileManager defaultManager] removeItemAtPath:soundInstallPath error:nil];
  
  //remove record from coredata
  [rdm removeSoundWithIdentifier:uuid];
}

-(void)showPanelFor:(SoundLocation)sl
{
  if (sl == SoundLocation_Store) {
    devicePanel.alpha = 0.0f;
    storePanel.alpha = 1.0f;
  } else if (sl == SoundLocation_Device) {
    storePanel.alpha = 0.0f;
    devicePanel.alpha = 1.0f;
  }
  [devicePanel setNeedsDisplay];
  [storePanel setNeedsDisplay];
}

#pragma mark -
#pragma mark ResoMediaTransferManager Delegates
-(void) transferStarted:(ResoMediaTransfer*)t
{
  NSLog(@"transfer started");
  if (t.transferType == SoundTransferDownload) {
    [downloadProgress updateValue:0];
  }
}

-(void) transferProgressUpdated:(ResoMediaTransfer*)t
{
  NSLog(@"transfer progress");
  
  if (t.transferType == SoundTransferDownload) {
    long long tbc = t.totalByteCount;
    long long cbc = t.currentByteCount;
    float p = (float)cbc / (float)tbc;
    [downloadProgress updateValue:p * 1000];
  }
  
}

-(void) transferFinished:(ResoMediaTransfer*)t
{
  NSLog(@"transfer finished");
  
  if (t.transferType == SoundPreviewTransfer) {
    [self playPreview:t.uuid];
  } else if (t.transferType == SoundTransferDownload) {
    [self downloadComplete:t.uuid];
  }
}

-(void) transferError:(ResoMediaTransfer*)t
{
  NSLog(@"transfer error");
}

@end
