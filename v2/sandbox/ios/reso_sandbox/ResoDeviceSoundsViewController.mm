//
//  ResoDataViewController.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 4/29/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "SSZipArchive.h"

#import "ResoDeviceSoundsViewController.h"
#import "ResoAppDelegate.h"
#import "ResoTypes.h"

#import "FMODSoundEngine.h"

#import "ResoMediaTransfer.h"
#import "ResoMediaTransferItem.h"
#import "ResoMediaTransferManager.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"

@interface ResoDeviceSoundsViewController ()
{
  UITableView * soundsView;
  NSMutableArray * soundsData;
  
  dispatch_queue_t global_queue;
  dispatch_queue_t thumbnail_queue;
  dispatch_queue_t preview_queue;
  
  ResoMediaTransfer * mediaTransfer;
}
@end

@implementation ResoDeviceSoundsViewController
@synthesize backButton, removeButton, redownloadButton, loadButton, progressBar;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
    mediaTransfer = nil;
    
    soundsData = [[NSMutableArray alloc] init];
    [self loadAvailableSoundsFromDevice];
    
    ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSLog(@"sound library for module: %i", ad.currentModule);
    
    //set up table view
    soundsView = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, self.view.bounds.size.width, self.view.bounds.size.height - 210) style:UITableViewStylePlain];
    soundsView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    soundsView.delegate = self;
    soundsView.dataSource = self;
    [soundsView reloadData];
    
    [self.view addSubview:soundsView];
    
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
    ResoModule * rm = [rmm.modules objectForKey:[NSNumber numberWithInt:ad.currentModule]];
    [rm loadSound:uuid looped:true];
    NSLog(@"sound loaded for module: %i", ad.currentModule);
  }
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
  [soundsData removeAllObjects];
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  NSArray * sounds = [ad soundsWithState:Completed];
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
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  
  //remove install folder
  NSString * soundInstallPath = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]] path];
  [[NSFileManager defaultManager] removeItemAtPath:soundInstallPath error:nil];
  
  //remove record from coredata
  [ad removeSoundWithIdentifier:uuid];
}

-(void)playPreview:(NSString*)filePath
{
  id<ISoundEngine> player = [FMODSoundEngine instance];
  id<ISound> sound = [player getSoundForId:Preview];
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
    [rmtm initTransferOfType:SoundTransfer withIdentifier:uuid];
    
    //hook up to delegate
    ResoMediaTransfer * rtm = [rmtm.transfers objectForKey:uuid];
    [rtm addDelegate:self];
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
  if (t.transferType == SoundTransfer) {
    long long tbc = t.totalByteCount;
    long long cbc = t.currentByteCount;
    float p = (float)cbc / (float)tbc;
    progressBar.progress = p;
  }
  
}

-(void) transferFinished:(ResoMediaTransfer*)t
{
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  
  if (t.transferType == ThumbnailTransfer) {
    [soundsView reloadData];
  } else if (t.transferType == PreviewTransfer) {
    NSString * file_path = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/preview", t.uuid]] path];
    [self playPreview:file_path];
  } else if (t.transferType == SoundTransfer) {
    [self downloadComplete:t.uuid];
  }
}

-(void) transferError:(ResoMediaTransfer*)t
{
}

@end
