//
//  ResoMixListViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoMixDeviceListViewController.h"
#import "ResoMixDetailsViewController.h"
#import "ResoSettings.h"

#import "ResoAppDelegate.h"
#import "ResoDataManager.h"
#import "ResoFileManager.h"

#import "ResoTypes.h"

#import "ResoMediaTransfer.h"
#import "ResoMediaTransferItem.h"
#import "ResoMediaTransferManager.h"

#import "ResoMixManager.h"

@interface ResoMixDeviceListViewController ()
{
  UITableView * mixesView;
  NSMutableArray * mixesData;
  
  ResoMediaTransfer * mediaTransfer;
}
@end

@implementation ResoMixDeviceListViewController
@synthesize backButton, removeButton, shareButton, loadButton, progressBar;

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
  
  [self loadAvailableMixesFromDevice];
  
  //set up table view
  mixesView = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, self.view.bounds.size.width, self.view.bounds.size.height - 210) style:UITableViewStylePlain];
  mixesView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
  mixesView.delegate = self;
  mixesView.dataSource = self;
  [mixesView reloadData];
  
  [self.view addSubview:mixesView];
  
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
  [removeButton addTarget:self action:@selector(removeMix:) forControlEvents:UIControlEventTouchUpInside];
  [removeButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [removeButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
  
  removeButton.layer.borderColor = [UIColor blackColor].CGColor;
  removeButton.layer.borderWidth = 0.0f;
  removeButton.layer.cornerRadius = 4.0f;
  removeButton.frame = CGRectMake(5, self.view.bounds.size.height - 110, (self.view.bounds.size.width / 2) - 10, 44);
  [self.view addSubview:removeButton];
  
  //redownload
  shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [shareButton setTitle:@"Share" forState:UIControlStateNormal];
  [shareButton addTarget:self action:@selector(shareMix:) forControlEvents:UIControlEventTouchUpInside];
  [shareButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [shareButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
  
  shareButton.layer.borderColor = [UIColor blackColor].CGColor;
  shareButton.layer.borderWidth = 0.0f;
  shareButton.layer.cornerRadius = 4.0f;
  shareButton.frame = CGRectMake(removeButton.frame.size.width + 15, self.view.bounds.size.height - 110, (self.view.bounds.size.width / 2) - 10, 44);
  [self.view addSubview:shareButton];
  
  //load
  loadButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [loadButton setTitle:@"Load" forState:UIControlStateNormal];
  [loadButton addTarget:self action:@selector(loadMix:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)loadMix:(id)sender
{
  //get currently selected row index
  NSIndexPath * path = [mixesView indexPathForSelectedRow];
  int row = path ? [path row] : -1;
  
  if (row >= 0) {
    NSDictionary * mix = [mixesData objectAtIndex:[path row]];
    NSString * uuid = [mix objectForKey:@"uuid"];
    ResoMixManager * rmm = [ResoMixManager instance];
    [rmm loadMix:uuid];
  }
}

-(void)goBack:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadAvailableMixesFromDevice
{
  [mixesData removeAllObjects];
  ResoDataManager * rdm = [ResoDataManager instance];
  NSArray * completedMixes = [rdm mixesWithState:Completed];
  NSArray * transferringMixes = [rdm mixesWithState:Transferring];
  [mixesData addObjectsFromArray:completedMixes];
  [mixesData addObjectsFromArray:transferringMixes];
}

-(void)removeMix:(id)sender
{
  //get currently selected row index
  NSIndexPath * path = [mixesView indexPathForSelectedRow];
  int row = path ? [path row] : -1;
  
  if (row >= 0) {
    NSDictionary * mix = [mixesData objectAtIndex:[path row]];
    NSString * uuid = [mix objectForKey:@"uuid"];
    
    ResoMixManager * rmm = [ResoMixManager instance];
    [rmm removeMix:uuid];
    
    //reload
    [self loadAvailableMixesFromDevice];
    [mixesView reloadData];
  }
}

-(void)shareMix:(id)sender
{
  //get currently selected row index
  NSIndexPath * path = [mixesView indexPathForSelectedRow];
  int row = path ? [path row] : -1;
  
  if (row >= 0) {
    //get uuid and shared state for currently selected row
    NSDictionary * mix = [mixesData objectAtIndex:[path row]];
    NSString * uuid = [mix objectForKey:@"uuid"];
    bool shared = [[mix objectForKey:@"shared"] boolValue];
    
    if (!shared) {
      ResoMixManager * rmm = [ResoMixManager instance];
      [rmm shareMix:uuid];
    } else {
      NSLog(@"mix already shared");
    }
  }
}

-(void)uploadComplete:(NSString*)uuid
{
  progressBar.progress = 0.0f;
  [self loadAvailableMixesFromDevice];
  [mixesView reloadData];
}

#pragma mark - TableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return mixesData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary * sound = [mixesData objectAtIndex:indexPath.row];
  
  static NSString * cellIdentifier = @"";
  NSString * uuid = [sound objectForKey:@"uuid"];
  cellIdentifier = uuid;
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  
  cell.backgroundView = [[UIView alloc] init];
  [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
  
  cell.textLabel.text = [NSString stringWithFormat:@"%@", [sound objectForKey:@"name"]];
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
#pragma mark ResoMediaTransferManager Delegates
-(void) transferStarted:(ResoMediaTransfer*)t
{
  progressBar.progress = 0.0f;
}

-(void) transferProgressUpdated:(ResoMediaTransfer*)t
{
  if (t.transferType == MixTransferUpload) {
    long long tbc = t.totalByteCount;
    long long cbc = t.currentByteCount;
    float p = (float)cbc / (float)tbc;
    progressBar.progress = p;
  }
}

-(void) transferFinished:(ResoMediaTransfer*)t
{
  if (t.transferType == MixTransferUpload) {
    [self uploadComplete:t.uuid];
  }
}

-(void) transferError:(ResoMediaTransfer*)t
{
}
@end
