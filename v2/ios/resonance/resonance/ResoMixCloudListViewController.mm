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

#import "ResoAppDelegate.h"
#import "ResoFileManager.h"
#import "ResoDataManager.h"
#import "ResoTypes.h"

#import "ResoMediaTransfer.h"
#import "ResoMediaTransferItem.h"
#import "ResoMediaTransferManager.h"

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
}
@end

@implementation ResoMixCloudListViewController
@synthesize backButton, previewButton, downloadButton, progressBar;

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
  
  //set up table view
  mixesView = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, self.view.bounds.size.width, self.view.bounds.size.height - 150) style:UITableViewStylePlain];
  mixesView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
  mixesView.delegate = self;
  mixesView.dataSource = self;
  
  [self.view addSubview:mixesView];
  
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
  
  [self.view setBackgroundColor:[UIColor darkGrayColor]];
  
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
  [self.view addSubview:previewButton];
  
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
  [self.view addSubview:downloadButton];
  
  //progress bar
  progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
  progressBar.progress = 0.0f;
  progressBar.frame = CGRectMake(10, 65, self.view.bounds.size.width - 20, 25);
  [self.view addSubview:progressBar];
}

- (void)viewWillAppear:(BOOL)animated
{
  [[ResoMediaTransferManager instance] addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [[ResoMediaTransferManager instance] removeDelegate:self];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
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
  [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - TableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return mixesData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary * mix = [mixesData objectAtIndex:indexPath.row];
  
  static NSString * cellIdentifier = @"";
  NSString * uuid = [mix objectForKey:@"uuid"];
  cellIdentifier = uuid;
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  
  cell.backgroundView = [[UIView alloc] init];
  [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
  
  cell.textLabel.text = [NSString stringWithFormat:@"%@", [mix objectForKey:@"name"]];
  cell.imageView.image = [UIImage imageWithContentsOfFile:[[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb", uuid]] path]];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //initialize view
  //ResoMixDetailsViewController * rmdvc = [[ResoMixDetailsViewController alloc] initWithNibName:nil bundle:nil];
  
  //push new view onto nav stack
  //[self.navigationController pushViewController:rmdvc animated:YES];
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
