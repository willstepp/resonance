//
//  ResoModuleDeviceListViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 6/6/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SSZipArchive.h"

#import "ResoModuleDeviceListViewController.h"
#import "ResoModuleCloudListViewController.h"
#import "ResoModuleTypeViewController.h"

#import "ResoAppDelegate.h"
#import "ResoFileManager.h"
#import "ResoDataManager.h"

#import "ResoTypes.h"
#import "ResoSettings.h"

#import "FMODSoundEngine.h"

#import "ResoMediaTransfer.h"
#import "ResoMediaTransferItem.h"
#import "ResoMediaTransferManager.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"

#import "ISound.h"
#import "IResoVisualization.h"

@interface ResoModuleDeviceListViewController ()
{
  UITableView * soundsView;
  NSMutableArray * soundsData;
  
  dispatch_queue_t global_queue;
  dispatch_queue_t thumbnail_queue;
  dispatch_queue_t preview_queue;
  
  ResoMediaTransfer * mediaTransfer;
  
  CGRect backButtonFrame;
  CGRect backButtonFrame_offscreen;
}
@end

@implementation ResoModuleDeviceListViewController
@synthesize backButton, removeButton, redownloadButton, loadButton, progressBar, deviceButton, cloudButton;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
    static bool initialized = false;
    if (!initialized) {
      [[ResoMediaTransferManager instance] addDelegate:self];
      initialized = true;
    }
    
    mediaTransfer = nil;
    [self calculateWidgetFrames];
    
    soundsData = [[NSMutableArray alloc] init];
    [self loadAvailableSoundsFromDevice];
    
    ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSLog(@"sound library for module: %@", ad.currentModule);
    
    //set up table view
    soundsView = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, self.view.bounds.size.width, self.view.bounds.size.height - 210) style:UITableViewStylePlain];
    soundsView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    soundsView.delegate = self;
    soundsView.dataSource = self;
    [soundsView reloadData];
    
    [self.view addSubview:soundsView];
    
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
    
    float sourceButtonWidth = self.view.bounds.size.width / 4.0f;
    float sourceButtonHeight = 35.0f;
    float sourceButtonGap = 7.0f;
    
    //device button
    deviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deviceButton setTitle:@"Device" forState:UIControlStateNormal];
    [deviceButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE * 0.85]];
    [deviceButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [deviceButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.075]];
    deviceButton.layer.borderWidth = 0.0f;
    deviceButton.layer.cornerRadius = 4.0f;
    deviceButton.frame = CGRectMake(self.view.bounds.size.width - (sourceButtonWidth * 2) - (sourceButtonGap), sourceButtonGap, sourceButtonWidth, sourceButtonHeight);
    [self.view addSubview:deviceButton];
    
    //cloud button
    cloudButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cloudButton setTitle:@"Cloud" forState:UIControlStateNormal];
    [cloudButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE * 0.85]];
    [cloudButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [cloudButton addTarget:self action:@selector(showCloudList:) forControlEvents:UIControlEventTouchUpInside];
    [cloudButton setBackgroundColor:[UIColor clearColor]];
    cloudButton.layer.borderColor = [UIColor blackColor].CGColor;
    cloudButton.layer.borderWidth = 0.0f;
    cloudButton.layer.cornerRadius = 4.0f;
    cloudButton.frame = CGRectMake(deviceButton.frame.origin.x+sourceButtonWidth, sourceButtonGap, sourceButtonWidth, sourceButtonHeight);
    [self.view addSubview:cloudButton];
    
    //remove button
    removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeButton setTitle:@"Remove" forState:UIControlStateNormal];
    [removeButton addTarget:self action:@selector(removeSound:) forControlEvents:UIControlEventTouchUpInside];
    [removeButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [removeButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
    
    removeButton.layer.borderColor = [UIColor blackColor].CGColor;
    removeButton.layer.borderWidth = 0.0f;
    removeButton.layer.cornerRadius = 4.0f;
    removeButton.frame = CGRectMake(5, self.view.bounds.size.height - 110, (self.view.bounds.size.width / 2) - 10, 44);
    [self.view addSubview:removeButton];
    
    //redownload
    redownloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [redownloadButton setTitle:@"Re-Download" forState:UIControlStateNormal];
    [redownloadButton addTarget:self action:@selector(redownloadSound:) forControlEvents:UIControlEventTouchUpInside];
    [redownloadButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [redownloadButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
    
    redownloadButton.layer.borderColor = [UIColor blackColor].CGColor;
    redownloadButton.layer.borderWidth = 0.0f;
    redownloadButton.layer.cornerRadius = 4.0f;
    redownloadButton.frame = CGRectMake(removeButton.frame.size.width + 15, self.view.bounds.size.height - 110, (self.view.bounds.size.width / 2) - 10, 44);
    [self.view addSubview:redownloadButton];
    
    //load
    loadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loadButton setTitle:@"Load" forState:UIControlStateNormal];
    [loadButton addTarget:self action:@selector(loadSound:) forControlEvents:UIControlEventTouchUpInside];
    [loadButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [loadButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
    
    loadButton.layer.borderColor = [UIColor blackColor].CGColor;
    loadButton.layer.borderWidth = 0.0f;
    loadButton.layer.cornerRadius = 4.0f;
    loadButton.frame = CGRectMake(5, self.view.bounds.size.height - 55, self.view.bounds.size.width - 10, 44);
    [self.view addSubview:loadButton];
    
    //progress bar
    progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressBar.progress = 0.0f;
    progressBar.frame = CGRectMake(10, 65, self.view.bounds.size.width - 20, 25);
    [self.view addSubview:progressBar];
    
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

- (void)showCloudList:(id)sender
{
  //iterate through navigation list, if cloud list view is found, pop to that one
  for (UIViewController * viewController in self.navigationController.viewControllers) {
    if ([viewController isKindOfClass:[ResoModuleCloudListViewController class]] ) {
      ResoModuleCloudListViewController * rmclvc = (ResoModuleCloudListViewController*)viewController;
      [self.navigationController popToViewController:rmclvc animated:NO];
      return;
    }
  }
  
  //push a new cloud list view onto stack
  ResoModuleCloudListViewController * rmclvc = [[ResoModuleCloudListViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmclvc animated:NO];
}

- (void)loadSound:(id)sender
{
  //get currently selected row index
  NSIndexPath * path = [soundsView indexPathForSelectedRow];
  int row = path ? [path row] : -1;
  
  if (row >= 0) {
    NSDictionary * sound = [soundsData objectAtIndex:[path row]];
    NSString * uuid = [sound objectForKey:@"uuid"];
    
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
    
    //load new sound
    [rm loadSound:uuid looped:true];
    [rm.sound play];
    if (!ad.playing) {
      [rm.sound setPaused:true];
    }
    
    //update visualization
    [ad.visualization removeSound:rm.soundUuid];
    [ad.visualization addSound:uuid];
    [ad.visualization setActiveSound:uuid];
    
    NSLog(@"sound loaded for module: %@", ad.currentModule);
  }
}

- (void)saveSound:(NSDictionary*)sound {
  NSString * uuid = [sound objectForKey:@"uuid"];
  
  //preview image download
  ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
  [rmtm initTransferOfType:SoundThumbnailTransfer withIdentifier:uuid withObject:nil];
  
  [soundsData addObject:sound];
  [soundsView reloadData];
}

- (void)addSoundToTable:(NSDictionary*)sound
{
  [soundsData addObject:sound];
  [soundsView reloadData];
}

-(void)goBack:(id)sender
{
  //iterate through navigation list, if device list view is found, pop to that one
  for (UIViewController * viewController in self.navigationController.viewControllers) {
    if ([viewController isKindOfClass:[ResoModuleTypeViewController class]] ) {
      ResoModuleTypeViewController * rmtvc = (ResoModuleTypeViewController*)viewController;
      [self.navigationController popToViewController:rmtvc animated:YES];
      return;
    }
  }
}

-(void)loadAvailableSoundsFromDevice
{
  [soundsData removeAllObjects];
  ResoDataManager * rdm = [ResoDataManager instance];
  NSArray * sounds = [rdm soundsWithState:Completed];
  [soundsData addObjectsFromArray:sounds];
}

-(void)removeSound:(id)sender
{
  //get currently selected row index
  NSIndexPath * path = [soundsView indexPathForSelectedRow];
  int row = path ? [path row] : -1;
  
  if (row >= 0) {
    NSDictionary * sound = [soundsData objectAtIndex:[path row]];
    NSString * uuid = [sound objectForKey:@"uuid"];
    
    [self removeSoundFromDevice:uuid];
    
    //reload
    [self loadAvailableSoundsFromDevice];
    [soundsView reloadData];
  }
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

-(void)playPreview:(NSString*)filePath
{
  id<ISoundEngine> player = [FMODSoundEngine instance];
  id<ISound> sound = [player getSoundForUuid:@"preview"];
  [sound load:filePath looped:false];
  [sound play];
}

-(void)redownloadSound:(id)sender
{
  //get currently selected row index
  NSIndexPath * path = [soundsView indexPathForSelectedRow];
  int row = path ? [path row] : -1;
  
  if (row >= 0) {
    //get uuid for currently selected row
    NSDictionary * sound = [soundsData objectAtIndex:[path row]];
    NSString * uuid = [sound objectForKey:@"uuid"];
    
    //remove sound
    [self removeSoundFromDevice:uuid];
    
    //download using rtm
    ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
    [rmtm initTransferOfType:SoundTransferDownload withIdentifier:uuid withObject:nil];
  }
}

-(void)downloadComplete:(NSString*)uuid
{
  progressBar.progress = 0.0f;
  [self loadAvailableSoundsFromDevice];
  [soundsView reloadData];
}

#pragma mark - TableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return soundsData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary * sound = [soundsData objectAtIndex:indexPath.row];
  
  static NSString * cellIdentifier = @"";
  NSString * uuid = [sound objectForKey:@"uuid"];
  cellIdentifier = uuid;
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  
  cell.backgroundView = [[UIView alloc] init];
  [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
  
  cell.textLabel.text = [NSString stringWithFormat:@"%@", [sound objectForKey:@"name"]];
  cell.imageView.image = [UIImage imageWithContentsOfFile:[[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/thumb", uuid]] path]];
  
  return cell;
}

#pragma mark -
#pragma mark ResoMediaTransfer Delegates
-(void) transferStarted:(ResoMediaTransfer*)t
{
  if (t.transferType == SoundTransferDownload) {
    progressBar.progress = 0.0f;
  }
}

-(void) transferProgressUpdated:(ResoMediaTransfer*)t
{
  if (t.transferType == SoundTransferDownload) {
    long long tbc = t.totalByteCount;
    long long cbc = t.currentByteCount;
    float p = (float)cbc / (float)tbc;
    progressBar.progress = p;
  }
  
}

-(void) transferFinished:(ResoMediaTransfer*)t
{
  if (t.transferType == SoundThumbnailTransfer) {
    [soundsView reloadData];
  } else if (t.transferType == SoundPreviewTransfer) {
    NSString * file_path = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/preview", t.uuid]] path];
    [self playPreview:file_path];
  } else if (t.transferType == SoundTransferDownload) {
    [self downloadComplete:t.uuid];
  }
}

-(void) transferError:(ResoMediaTransfer*)t
{
}

- (void)calculateWidgetFrames
{
  //back button
  backButtonFrame = CGRectMake(0, 0, 50, 50);
  backButtonFrame_offscreen = CGRectMake(-(backButtonFrame.size.width), backButtonFrame.origin.y, backButtonFrame.size.width, backButtonFrame.size.height);
}

@end
