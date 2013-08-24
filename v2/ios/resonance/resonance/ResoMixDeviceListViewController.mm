//
//  ResoMixListViewController.mm
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoMixDeviceListViewController.h"
#import "ResoMixCloudListViewController.h"
#import "ResoMixDetailsViewController.h"
#import "ResoMixViewController.h"
#import "ResoSettings.h"

#import "ResoAppDelegate.h"
#import "ResoDataManager.h"
#import "ResoFileManager.h"
#import "ResoTableViewCell.h"

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
  
  CGRect backButtonFrame;
  CGRect backButtonFrame_offscreen;
}
@end

@implementation ResoMixDeviceListViewController
@synthesize backButton, removeButton, shareButton, loadButton, progressBar, deviceButton, cloudButton;
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
  [self loadAvailableMixesFromDevice];
  
  //set up table view
  mixesView = [[UITableView alloc] initWithFrame:CGRectMake(0, backButtonFrame.size.height+10, [ResoAppDelegate windowWidth], [ResoAppDelegate windowHeight]-(backButtonFrame.size.height-10)) style:UITableViewStylePlain];
  mixesView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
  mixesView.delegate = self;
  mixesView.dataSource = self;
  mixesView.separatorColor = [UIColor clearColor];
  [mixesView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.05]];
  [mixesView reloadData];
  
  [self.view addSubview:mixesView];
  
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
  [deviceButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
  [deviceButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1]];
  deviceButton.layer.borderWidth = 0.0f;
  deviceButton.layer.cornerRadius = CORNER_RADIUS;
  deviceButton.frame = CGRectMake([ResoAppDelegate windowWidth] - (sourceButtonWidth * 2) - (sourceButtonGap), sourceButtonGap, sourceButtonWidth, sourceButtonHeight);
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
  cloudButton.layer.cornerRadius = CORNER_RADIUS;
  cloudButton.frame = CGRectMake(deviceButton.frame.origin.x+sourceButtonWidth, sourceButtonGap, sourceButtonWidth, sourceButtonHeight);
  [self.view addSubview:cloudButton];
  
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
  //[self.view addSubview:removeButton];
  
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
  //[self.view addSubview:shareButton];
  
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
  //[self.view addSubview:loadButton];
  
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
    [self loadAvailableMixesFromDevice];
    [mixesView reloadData];
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

- (void)showCloudList:(id)sender
{
  //iterate through navigation list, if cloud list view is found, pop to that one
  for (UIViewController * viewController in self.navigationController.viewControllers) {
    if ([viewController isKindOfClass:[ResoMixCloudListViewController class]] ) {
      ResoMixCloudListViewController * rmclvc = (ResoMixCloudListViewController*)viewController;
      [self.navigationController popToViewController:rmclvc animated:NO];
      return;
    }
  }
  
  //push a new cloud list view onto stack
  ResoMixCloudListViewController * rmclvc = [[ResoMixCloudListViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmclvc animated:NO];
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
  //iterate through navigation list, if mix view is found, pop to that one
  for (UIViewController * viewController in self.navigationController.viewControllers) {
    if ([viewController isKindOfClass:[ResoMixViewController class]] ) {
      ResoMixViewController * rmvc = (ResoMixViewController*)viewController;
      [self.navigationController popToViewController:rmvc animated:YES];
      return;
    }
  }
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
  rmdvc.soundDetails = mix;
  rmdvc.downloaded = true;
  
  [self ensureCloudListIsOnNavigationStack];
  
  //push new view onto nav stack
  [self.navigationController pushViewController:rmdvc animated:YES];
}

-(void) ensureCloudListIsOnNavigationStack
{
  //ensure cloud list view is on stack
  bool found = false;
  for (UIViewController * viewController in self.navigationController.viewControllers) {
    if ([viewController isKindOfClass:[ResoMixCloudListViewController class]] ) {
      found = true;
      break;
    }
  }
  if (!found) {
    ResoMixCloudListViewController * rmclvc = [[ResoMixCloudListViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:rmclvc animated:NO];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 60.0;
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
