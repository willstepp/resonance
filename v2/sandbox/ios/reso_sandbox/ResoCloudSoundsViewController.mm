//
//  ResoDataViewController.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 4/29/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "SSZipArchive.h"

#import "ResoCloudSoundsViewController.h"
#import "ResoAppDelegate.h"
#import "ResoTypes.h"

#import "FMODSoundEngine.h"

#import "ResoMediaTransfer.h"
#import "ResoMediaTransferItem.h"
#import "ResoMediaTransferManager.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"

#define soundsUrl [NSURL URLWithString:@"http://resoapp.com/sounds.json"]

@interface ResoCloudSoundsViewController ()
{
  UITableView * soundsView;
  NSMutableArray * soundsData;
  
  dispatch_queue_t global_queue;
  dispatch_queue_t thumbnail_queue;
  dispatch_queue_t preview_queue;
  
  ResoMediaTransfer * mediaTransfer;
}
@end

@implementation ResoCloudSoundsViewController
@synthesize backButton, previewButton, downloadButton, progressBar;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
      mediaTransfer = nil;
      ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
      
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
        NSPersistentStoreCoordinator * coordinator = [ad persistentStoreCoordinator];
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
          if(![ad soundExists:uuid withContext:context]) {
            
            //save sound record on main thread
            [self performSelectorOnMainThread:@selector(saveSound:)
                                   withObject:sound waitUntilDone:NO];
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

- (void)saveSound:(NSDictionary*)sound {
  NSString * uuid = [sound objectForKey:@"uuid"];
  
  //preview image download
  ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
  [rmtm initTransferOfType:ThumbnailTransfer withIdentifier:uuid];
  
  //hook up to delegate
  ResoMediaTransfer * rtm = [rmtm.transfers objectForKey:uuid];
  [rtm addDelegate:self];
  
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
  [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadAvailableSoundsFromDevice
{
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  NSArray * sounds = [ad soundsWithState:Completed];
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
    ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString * pp = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/preview", uuid]] path];
    bool exists = [[NSFileManager defaultManager] fileExistsAtPath:pp];
    if (exists) {
      [self playPreview:uuid];
    } else {
      
      //enqueue preview download
      ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
      [rmtm initTransferOfType:PreviewTransfer withIdentifier:uuid];
      
      //hook up to delegate
      ResoMediaTransfer * rtm = [rmtm.transfers objectForKey:uuid];
      [rtm addDelegate:self];
    }
  }
}

-(void)playPreview:(NSString*)uuid
{
  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoModule * rm = [rmm.modules objectForKey:[NSNumber numberWithInt:Preview]];
  [rm loadPreview:uuid looped:false];
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
    ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
    if (![ad soundExists:uuid withContext:[ad managedObjectContext]]) {
      
      //download using rtm
      ResoMediaTransferManager * rmtm = [ResoMediaTransferManager instance];
      [rmtm initTransferOfType:SoundTransferDownload withIdentifier:uuid];
      
      //hook up to delegate
      ResoMediaTransfer * rtm = [rmtm.transfers objectForKey:uuid];
      [rtm addDelegate:self];
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
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  cell.imageView.image = [UIImage imageWithContentsOfFile:[[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/thumb", uuid]] path]];
  
  return cell;
}

#pragma mark -
#pragma mark ResoMediaTransfer Delegates
-(void) transferStarted:(ResoMediaTransfer*)t
{
  progressBar.progress = 0.0f;
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
  if (t.transferType == ThumbnailTransfer) {
    NSLog(@"thumbnailTransfer finished");
    [soundsView reloadData];
  } else if (t.transferType == PreviewTransfer) {
    [self playPreview:t.uuid];
  } else if (t.transferType == SoundTransferDownload) {
    [self downloadComplete:t.uuid];
  }
}

-(void) transferError:(ResoMediaTransfer*)t
{
}

@end
