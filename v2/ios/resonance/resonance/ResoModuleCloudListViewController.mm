//
//  ResoModuleSoundListViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoModuleCloudListViewController.h"
#import "ResoModuleDeviceListViewController.h"
#import "ResoModuleTypeViewController.h"
#import "ResoAppDelegate.h"
#import "ResoFileManager.h"
#import "ResoDataManager.h"
#import "ResoSettings.h"
#import "ResoModuleSoundDetailsViewController.h"
#import "ResoModuleManager.h"
#import "ResoModule.h"
#import "ISound.h"

@interface ResoModuleCloudListViewController ()
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

@implementation ResoModuleCloudListViewController
@synthesize backButton, previewButton, downloadButton, progressBar, deviceButton, cloudButton;
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
    
    [self calculateWidgetFrames];
    
    mediaTransfer = nil;
    ResoDataManager * rdm = [ResoDataManager instance];
    
    soundsData = [[NSMutableArray alloc] init];
    //[self loadAvailableSoundsFromDevice];
    
    //set up table view
    soundsView = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, self.view.bounds.size.width, self.view.bounds.size.height - 150) style:UITableViewStylePlain];
    soundsView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    soundsView.delegate = self;
    soundsView.dataSource = self;
    //[soundsView reloadData];
    
    [self.view addSubview:soundsView];
    
    //initate background queue for global tasks
    global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //initiate background queue to retreive thumbnails
    thumbnail_queue = dispatch_queue_create("com.resonance.thumbnail_fetch", NULL);
    //initiate background queue to retreive preview clips
    preview_queue = dispatch_queue_create("com.resonance.preview_fetch", NULL);
    
    //get list of sounds on background thread
    dispatch_async(global_queue, ^{
      //init
      NSManagedObjectContext * context;
      NSPersistentStoreCoordinator * coordinator = [rdm persistentStoreCoordinator];
      if (coordinator != nil) {
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:coordinator];
      }
      
      //1) fetch sounds from server
      NSData * data = [NSData dataWithContentsOfURL:soundsUrl];
      
      //2) parse into json array
      NSArray * sounds = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:nil];
      
      //3) iterate sounds and create new record if needed
      for(NSDictionary * sound in sounds) {
        NSString * uuid = [sound objectForKey:@"uuid"];
        if(![rdm soundExists:uuid withContext:context]) {
          
          //save sound record on main thread
          [self performSelectorOnMainThread:@selector(saveSound:)
                                 withObject:sound waitUntilDone:NO];
        }
      }
    });
    
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
    [deviceButton addTarget:self action:@selector(showDeviceList:) forControlEvents:UIControlEventTouchUpInside];
    [deviceButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [deviceButton setBackgroundColor:[UIColor clearColor]];
    deviceButton.layer.borderWidth = 0.0f;
    deviceButton.layer.cornerRadius = 4.0f;
    deviceButton.frame = CGRectMake(self.view.bounds.size.width - (sourceButtonWidth * 2) - (sourceButtonGap), sourceButtonGap, sourceButtonWidth, sourceButtonHeight);
    [self.view addSubview:deviceButton];
    
    //cloud button
    cloudButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cloudButton setTitle:@"Cloud" forState:UIControlStateNormal];
    [cloudButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE * 0.85]];
    [cloudButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [cloudButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.075]];
    
    cloudButton.layer.borderColor = [UIColor blackColor].CGColor;
    cloudButton.layer.borderWidth = 0.0f;
    cloudButton.layer.cornerRadius = 4.0f;
    cloudButton.frame = CGRectMake(deviceButton.frame.origin.x+sourceButtonWidth, sourceButtonGap, sourceButtonWidth, sourceButtonHeight);
    [self.view addSubview:cloudButton];

    //preview button
    previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [previewButton setTitle:@"Preview" forState:UIControlStateNormal];
    [previewButton addTarget:self action:@selector(previewSound:) forControlEvents:UIControlEventTouchUpInside];
    [previewButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [previewButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
    
    previewButton.layer.borderColor = [UIColor blackColor].CGColor;
    previewButton.layer.borderWidth = 0.0f;
    previewButton.layer.cornerRadius = 4.0f;
    previewButton.frame = CGRectMake(5, self.view.bounds.size.height - 50, (self.view.bounds.size.width / 2) - 10, 44);
    [self.view addSubview:previewButton];
    
    //download
    downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
    [downloadButton addTarget:self action:@selector(downloadSound:) forControlEvents:UIControlEventTouchUpInside];
    [downloadButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [downloadButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
    
    downloadButton.layer.borderColor = [UIColor blackColor].CGColor;
    downloadButton.layer.borderWidth = 0.0f;
    downloadButton.layer.cornerRadius = 4.0f;
    downloadButton.frame = CGRectMake(previewButton.frame.size.width + 15, self.view.bounds.size.height - 50, (self.view.bounds.size.width / 2) - 10, 44);
    [self.view addSubview:downloadButton];
    
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

- (void)showDeviceList:(id)sender
{
  //iterate through navigation list, if device list view is found, pop to that one
  for (UIViewController * viewController in self.navigationController.viewControllers) {
    if ([viewController isKindOfClass:[ResoModuleDeviceListViewController class]] ) {
      ResoModuleDeviceListViewController * rmdlvc = (ResoModuleDeviceListViewController*)viewController;
      [self.navigationController popToViewController:rmdlvc animated:NO];
      return;
    }
  }

  //push a new device list view onto stack
  ResoModuleDeviceListViewController * rmdlvc = [[ResoModuleDeviceListViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmdlvc animated:NO];
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
  ResoDataManager * rdm = [ResoDataManager instance];
  NSArray * sounds = [rdm soundsWithState:Completed];
  [soundsData addObjectsFromArray:sounds];
}

-(void)previewSound:(id)sender
{
  //get currently selected row index
  NSIndexPath * path = [soundsView indexPathForSelectedRow];
  int row = path ? [path row] : -1;
  
  if (row >= 0) {
    NSDictionary * sound = [soundsData objectAtIndex:[path row]];
    NSString * uuid = [sound objectForKey:@"uuid"];
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
  //get currently selected row index
  NSIndexPath * path = [soundsView indexPathForSelectedRow];
  int row = path ? [path row] : -1;
  
  if (row >= 0) {
    //get uuid for currently selected row
    NSDictionary * sound = [soundsData objectAtIndex:[path row]];
    NSString * uuid = [sound objectForKey:@"uuid"];
    
    //first test if sound already exists
    ResoDataManager * rdm = [ResoDataManager instance];
    if (![rdm soundExists:uuid withContext:[rdm managedObjectContext]]) {
      
      //download using rtm
      ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
      [rmtm initTransferOfType:SoundTransferDownload withIdentifier:uuid withObject:nil];
    }
  }
  
}

-(void)downloadComplete:(NSString*)uuid
{
  progressBar.progress = 0.0f;
  
  //remove downloaded item from list
  NSDictionary * soundToRemove = nil;
  for(NSDictionary * sound in soundsData) {
    NSString * soundUUID = [sound objectForKey:@"uuid"];
    if (soundUUID == uuid) {
      soundToRemove = sound;
      break;
    }
  }
  [soundsData removeObject:soundToRemove];
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
#pragma mark ResoMediaTransferManager Delegates
-(void) transferStarted:(ResoMediaTransfer*)t
{
  NSLog(@"transfer started");
  if (t.transferType == SoundTransferDownload) {
    progressBar.progress = 0.0f;
  }
}

-(void) transferProgressUpdated:(ResoMediaTransfer*)t
{
  NSLog(@"transfer progress");
  
  if (t.transferType == SoundTransferDownload) {
    long long tbc = t.totalByteCount;
    long long cbc = t.currentByteCount;
    float p = (float)cbc / (float)tbc;
    progressBar.progress = p;
  }
  
}

-(void) transferFinished:(ResoMediaTransfer*)t
{
  NSLog(@"transfer finished");
  
  if (t.transferType == SoundThumbnailTransfer) {
    NSLog(@"thumbnailTransfer finished");
    [soundsView reloadData];
  } else if (t.transferType == SoundPreviewTransfer) {
    [self playPreview:t.uuid];
  } else if (t.transferType == SoundTransferDownload) {
    [self downloadComplete:t.uuid];
  }
}

-(void) transferError:(ResoMediaTransfer*)t
{
  NSLog(@"transfer error");
}

- (void)calculateWidgetFrames
{
  //back button
  backButtonFrame = CGRectMake(0, 0, 50, 50);
  backButtonFrame_offscreen = CGRectMake(-(backButtonFrame.size.width), backButtonFrame.origin.y, backButtonFrame.size.width, backButtonFrame.size.height);
}

@end
