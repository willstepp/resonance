//
//  ResoMixCloudListViewController.m
//  resonance
//
//  Created by Daniel Stepp on 6/15/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoMixCloudListViewController.h"
#import "ResoMixDetailsViewController.h"
#import "ResoMixDeviceListViewController.h"
#import "ResoMixViewController.h"

#import "ResoAppDelegate.h"
#import "ResoFileManager.h"
#import "ResoDataManager.h"
#import "ResoTypes.h"
#import "ResoSettings.h"

#import "ResoMediaTransfer.h"
#import "ResoMediaTransferItem.h"
#import "ResoMediaTransferManager.h"

#import "ResoTableViewCell.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"

#import "ISound.h"
#import "ITone.h"

#define mixesUrl [NSURL URLWithString:@"http://resoapp.com/mixes/processed.json"]

@interface ResoMixCloudListViewController ()
{
  UITableView * mixesView;
  NSMutableArray * mixesData;
  
  ResoMediaTransfer * mediaTransfer;
  
  CGRect backButtonFrame;
  CGRect backButtonFrame_offscreen;
}
@end

@implementation ResoMixCloudListViewController
@synthesize backButton, previewButton, downloadButton, progressBar, deviceButton, cloudButton;
@synthesize refreshView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    mediaTransfer = nil;
    mixesData = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self calculateWidgetFrames];
  
  //set up table view
  mixesView = [[UITableView alloc] initWithFrame:CGRectMake(0, backButtonFrame.size.height+10, [ResoAppDelegate windowWidth], [ResoAppDelegate windowHeight]-(backButtonFrame.size.height-10)) style:UITableViewStylePlain];
  mixesView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
  mixesView.delegate = self;
  mixesView.separatorColor = [UIColor clearColor];
  [mixesView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.05]];
  mixesView.dataSource = self;
  
  [self.view addSubview:mixesView];
  
  [self loadAvailableMixesFromStore];
  
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
  backButton.frame = backButtonFrame;
  [self.view addSubview:backButton];
  
  float sourceButtonWidth = [ResoAppDelegate windowWidth] / 4.5f;
  float sourceButtonHeight = 30.0f;
  float sourceButtonGap = 10.0f;
  
  //device button
  deviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [deviceButton setTitle:@"Device" forState:UIControlStateNormal];
  [deviceButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE * 0.85]];
  [deviceButton addTarget:self action:@selector(showDeviceList:) forControlEvents:UIControlEventTouchUpInside];
  [deviceButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [deviceButton setBackgroundColor:[UIColor clearColor]];
  deviceButton.layer.borderWidth = 0.0f;
  deviceButton.layer.cornerRadius = CORNER_RADIUS;
  deviceButton.frame = CGRectMake([ResoAppDelegate windowWidth] - (sourceButtonWidth * 2) - (sourceButtonGap), sourceButtonGap, sourceButtonWidth, sourceButtonHeight);
  [self.view addSubview:deviceButton];
  
  //cloud button
  cloudButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [cloudButton setTitle:@"Cloud" forState:UIControlStateNormal];
  [cloudButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE * 0.85]];
  [cloudButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [cloudButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1]];
  
  cloudButton.layer.borderColor = [UIColor blackColor].CGColor;
  cloudButton.layer.borderWidth = 0.0f;
  cloudButton.layer.cornerRadius = CORNER_RADIUS;
  cloudButton.frame = CGRectMake(deviceButton.frame.origin.x+sourceButtonWidth, sourceButtonGap, sourceButtonWidth, sourceButtonHeight);
  [self.view addSubview:cloudButton];
  
  //preview button
  previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [previewButton setTitle:@"Preview" forState:UIControlStateNormal];
  [previewButton addTarget:self action:@selector(previewMix:) forControlEvents:UIControlEventTouchUpInside];
  [previewButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [previewButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
  
  previewButton.layer.borderColor = [UIColor blackColor].CGColor;
  previewButton.layer.borderWidth = 0.0f;
  previewButton.layer.cornerRadius = 4.0f;
  previewButton.frame = CGRectMake(5, self.view.bounds.size.height - 50, (self.view.bounds.size.width / 2) - 10, 44);
  //[self.view addSubview:previewButton];
  
  //download
  downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
  [downloadButton addTarget:self action:@selector(downloadMix:) forControlEvents:UIControlEventTouchUpInside];
  [downloadButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [downloadButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
  
  downloadButton.layer.borderColor = [UIColor blackColor].CGColor;
  downloadButton.layer.borderWidth = 0.0f;
  downloadButton.layer.cornerRadius = 4.0f;
  downloadButton.frame = CGRectMake(previewButton.frame.size.width + 15, self.view.bounds.size.height - 50, (self.view.bounds.size.width / 2) - 10, 44);
  //[self.view addSubview:downloadButton];
  
  //progress bar
  progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
  progressBar.progress = 0.0f;
  progressBar.frame = CGRectMake(10, 65, self.view.bounds.size.width - 20, 25);
  //[self.view addSubview:progressBar];
}

- (void)viewWillAppear:(BOOL)animated
{
  [[ResoMediaTransferManager instance] addDelegate:self];
  if (refreshView) {
    [self loadAvailableMixesFromStore];
  }
}

- (void)viewDidDisappear:(BOOL)animated
{
  [[ResoMediaTransferManager instance] removeDelegate:self];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

-(void)loadAvailableMixesFromStore
{
  [mixesData removeAllObjects];
  [mixesView reloadData];
    
  //get list of sounds on background thread
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //init
    NSManagedObjectContext * context;
    ResoDataManager * rdm = [ResoDataManager instance];
    NSPersistentStoreCoordinator * coordinator = [rdm persistentStoreCoordinator];
    if (coordinator != nil) {
      context = [[NSManagedObjectContext alloc] init];
      [context setPersistentStoreCoordinator:coordinator];
    }
    
    //1) fetch sounds from server
    NSData * data = [NSData dataWithContentsOfURL:mixesUrl];
    
    //2) parse into json array
    NSArray * mixes = [NSJSONSerialization
                       JSONObjectWithData:data
                       options:kNilOptions
                       error:nil];
    
    //3) iterate mixes and create new record if needed
    for(NSDictionary * mix in mixes) {
      NSString * uuid = [mix objectForKey:@"uuid"];
      if(![rdm mixExists:uuid withContext:context]) {
        
        //save mixes record on main thread
        [self performSelectorOnMainThread:@selector(saveMix:)
                               withObject:mix waitUntilDone:NO];
      }
    }
  });
  
}

- (void)showDeviceList:(id)sender
{
  //iterate through navigation list, if device list view is found, pop to that one
  for (UIViewController * viewController in self.navigationController.viewControllers) {
    if ([viewController isKindOfClass:[ResoMixDeviceListViewController class]] ) {
      ResoMixDeviceListViewController * rmdlvc = (ResoMixDeviceListViewController*)viewController;
      [self.navigationController popToViewController:rmdlvc animated:NO];
      return;
    }
  }
  
  //push a new device list view onto stack
  ResoMixDeviceListViewController * rmdlvc = [[ResoMixDeviceListViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmdlvc animated:NO];
}

- (void)saveMix:(NSDictionary*)mix {
  NSString * uuid = [mix objectForKey:@"uuid"];
  
  //preview image download
  ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
  [rmtm initTransferOfType:MixThumbnailTransfer withIdentifier:uuid withObject:nil];
  
  [mixesData addObject:mix];
  [mixesView reloadData];
}

-(void)goBack:(id)sender
{
  //iterate through navigation list, if mix view is found, pop to that one
  for (UIViewController * viewController in self.navigationController.viewControllers) {
    if ([viewController isKindOfClass:[ResoMixViewController class]] ) {
      ResoMixViewController * rmvc = (ResoMixViewController*)viewController;
      [self.navigationController popToViewController:rmvc animated:YES];
      return;
    }
  }
}

-(void)previewMix:(id)sender
{
  //get currently selected row index
  NSIndexPath * path = [mixesView indexPathForSelectedRow];
  int row = path ? [path row] : -1;
  
  if (row >= 0) {
    NSDictionary * mix = [mixesData objectAtIndex:[path row]];
    NSString * uuid = [mix objectForKey:@"uuid"];
    NSString * pp = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview", uuid]] path];
    bool exists = [[NSFileManager defaultManager] fileExistsAtPath:pp];
    if (exists) {
      [self playPreview:uuid];
    } else {
      
      //enqueue preview download
      ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
      [rmtm initTransferOfType:MixPreviewTransfer withIdentifier:uuid withObject:nil];
    }
  }
}

-(void)playPreview:(NSString*)uuid
{
  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoModule * rm = [rmm.modules objectForKey:@"preview"];
  [rm loadPreview:uuid looped:false mediaType:MediaType_Mix];
  [rm.sound play];
}

-(void)downloadMix:(id)sender
{
  //get currently selected row index
  NSIndexPath * path = [mixesView indexPathForSelectedRow];
  int row = path ? [path row] : -1;
  
  if (row >= 0) {
    //get uuid for currently selected row
    NSDictionary * mix = [mixesData objectAtIndex:[path row]];
    NSString * uuid = [mix objectForKey:@"uuid"];
    
    //first test if mix already exists
    ResoDataManager * rdm = [ResoDataManager instance];
    if (![rdm soundExists:uuid withContext:[rdm managedObjectContext]]) {
      
      //download using rtm
      ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
      [rmtm initTransferOfType:MixTransferDownload withIdentifier:uuid withObject:mix];
    }
  }
  
}

-(void)downloadComplete:(NSString*)uuid
{
  progressBar.progress = 0.0f;
  
  //remove downloaded item from list
  NSDictionary * mixToRemove = nil;
  for(NSDictionary * mix in mixesData) {
    NSString * mixUUID = [mix objectForKey:@"uuid"];
    if (mixUUID == uuid) {
      mixToRemove = mix;
      break;
    }
  }
  [mixesData removeObject:mixToRemove];
  [mixesView reloadData];
}

-(void)calculateWidgetFrames
{
  //back button
  backButtonFrame = CGRectMake(0, 0, 50, 50);
  backButtonFrame_offscreen = CGRectMake(-(backButtonFrame.size.width), backButtonFrame.origin.y, backButtonFrame.size.width, backButtonFrame.size.height);
}

#pragma mark - TableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return mixesData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary * mix = [mixesData objectAtIndex:indexPath.row];
  
  static NSString * cellIdentifier = @"";
  NSString * uuid = [mix objectForKey:@"uuid"];
  cellIdentifier = uuid;
  
  ResoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil)
    cell = [[ResoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  
  cell.selectedBackgroundView = [[UIView alloc] init];
  [cell.selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.05]];
  
  cell.layer.borderWidth = 0.0f;
  
  cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.05];
  
  cell.textLabel.text = [NSString stringWithFormat:@"%@", [mix objectForKey:@"name"]];
  [cell.textLabel setTextColor:[UIColor whiteColor]];
  [cell.textLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
  [cell.textLabel setBackgroundColor:[UIColor clearColor]];

  cell.imageView.image = [UIImage imageWithContentsOfFile:[[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb", uuid]] path]];
  cell.imageView.layer.cornerRadius = CORNER_RADIUS;
  [cell.imageView setClipsToBounds:YES];
  
  UIImageView * actionImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-chevron-right-small.png"]];
  actionImage.frame = CGRectMake(cell.frame.size.width-50, 5, 50, 50);
  actionImage.alpha = ICON_BUTTON_OPACITY / 2.0f;
  [cell.contentView addSubview:actionImage];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //get sound selected by user
  NSMutableDictionary * mix = [mixesData objectAtIndex:indexPath.row];
  
  //initialize view
  ResoMixDetailsViewController * rmdvc = [[ResoMixDetailsViewController alloc] initWithNibName:nil bundle:nil];
  
  //pass sound details to view
  [rmdvc.soundDetails removeAllObjects];
  [rmdvc.soundDetails setObject:[mix objectForKey:@"uuid"] forKey:@"uuid"];
  [rmdvc.soundDetails setObject:[mix objectForKey:@"name"] forKey:@"name"];
  [rmdvc.soundDetails setObject:[mix objectForKey:@"sounds"] forKey:@"sounds"];
  [rmdvc.soundDetails setObject:[NSNumber numberWithBool:YES] forKey:@"shared"];
  
  rmdvc.downloaded = false;
  
  [self ensureDeviceListIsOnNavigationStack];
  
  //push new view onto nav stack
  [self.navigationController pushViewController:rmdvc animated:YES];
}

-(void) ensureDeviceListIsOnNavigationStack
{
  //ensure device list view is on stack
  bool found = false;
  for (UIViewController * viewController in self.navigationController.viewControllers) {
    if ([viewController isKindOfClass:[ResoMixDeviceListViewController class]] ) {
      found = true;
      break;
    }
  }
  if (!found) {
    ResoMixDeviceListViewController * rmdlvc = [[ResoMixDeviceListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:rmdlvc animated:NO];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 60.0;
}

#pragma mark -
#pragma mark ResoMediaTransfer Delegates
-(void) transferStarted:(ResoMediaTransfer*)t
{
  if (t.transferType == MixTransferDownload) {
    progressBar.progress = 0.0f;
  }
}

-(void) transferProgressUpdated:(ResoMediaTransfer*)t
{
  //if mix or sound download transfer
  //calculate the cumulative progress update
  
  if (t.transferType == MixTransferDownload ||
      t.transferType == SoundTransferDownload) {
    
    NSString * uuid = (t.transferType == MixTransferDownload) ? t.uuid : t.ownerUUID;
    if (uuid != nil) {
      float mixProgress = 0.0f;
      
      ResoDataManager * rdm = [ResoDataManager instance];
      ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
      NSDictionary * mix = [rdm mixWithIdentifier:uuid];
      
      //get mix transfer, if nil then add progress of 1.0 for mix
      ResoMediaTransfer * mt = [rmtm.transfers objectForKey:uuid];
      float mp = (mt != nil) ? [self calculateProgress:mt] : 1.0f;
      mixProgress += mp;
      
      NSArray * soundsList = [[mix objectForKey:@"sounds"] componentsSeparatedByString:@";"];
      for (NSString * sound in soundsList) {
        ResoMediaTransfer * rtm = [rmtm.transfers objectForKey:sound];
        if (rtm != nil) {
          mixProgress += [self calculateProgress:rtm];
        } else {
          mixProgress += 1.0f;
        }
      }
      
      float p = mixProgress / (float)(1 + [soundsList count]);
      progressBar.progress = p;
    }
    
  }
}

-(float)calculateProgress:(ResoMediaTransfer*)rtm
{
  long long tbc = rtm.totalByteCount;
  long long cbc = rtm.currentByteCount;
  float progress = (tbc > 0 && cbc > 0) ? (float)cbc / (float)tbc : 0;
  return progress;
}

-(void) transferFinished:(ResoMediaTransfer*)t
{
  if (t.transferType == MixThumbnailTransfer) {
    [mixesView reloadData];
  } else if (t.transferType == MixPreviewTransfer) {
    [self playPreview:t.uuid];
  } else if (t.transferType == MixTransferDownload ||
             t.transferType == SoundTransferDownload) {
    
  }
}

-(void) mixFinished:(NSString *)uuid
{
  [self downloadComplete:uuid];
}

-(void) transferError:(ResoMediaTransfer*)t
{
}

@end
