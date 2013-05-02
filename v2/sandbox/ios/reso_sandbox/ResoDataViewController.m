//
//  ResoDataViewController.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 4/29/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "ResoDataViewController.h"
#import "ResoAppDelegate.h"
#import "ResoTypes.h"

#define bgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define soundsUrl [NSURL URLWithString:@"http://resoapp.com/sounds.json"]

@interface ResoDataViewController ()
{
  UITableView * soundsView;
  NSMutableArray * soundsData;
  
  dispatch_queue_t thumbnail_queue;
  dispatch_queue_t preview_queue;
}
@end

@implementation ResoDataViewController
@synthesize backButton, previewButton, downloadButton;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
      ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
      
      soundsData = [[NSMutableArray alloc] init];
      [self loadAvailableSoundsFromDevice];
      
      //set up table view
      soundsView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height - 120) style:UITableViewStylePlain];
      soundsView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
      soundsView.delegate = self;
      soundsView.dataSource = self;
      [soundsView reloadData];
      
      [self.view addSubview:soundsView];
      
      //initiate background queue to retreive thumbnails
      thumbnail_queue = dispatch_queue_create("com.resonance.thumbnail_fetch", NULL);
      //initiate background queue to retreive preview clips
      preview_queue = dispatch_queue_create("com.resonance.preview_fetch", NULL);
      
      //get list of sounds on background thread
      dispatch_async(bgQueue, ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
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
            
            //create sound directory under resonance/sounds
            [ad ensureDirectoryExists:[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]]];
            
            //save sound record on main thread
            [self performSelectorOnMainThread:@selector(saveSound:)
                                   withObject:sound waitUntilDone:YES];
            
            //download preview and thumbnail, in a separate thread
            dispatch_async(thumbnail_queue, ^{
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
              NSString * url = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/%@.thumb", uuid, uuid];
              NSData * thumb = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
              NSString * file_path = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.thumb", uuid, uuid]] path];
              [thumb writeToFile:file_path atomically:NO];
              [self performSelectorOnMainThread:@selector(addSoundToTable:)
                                     withObject:sound waitUntilDone:YES];
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
          }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
      previewButton.frame = CGRectMake(5, self.view.bounds.size.height - 55, (self.view.bounds.size.width / 2) - 5, 44);
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
      downloadButton.frame = CGRectMake(previewButton.frame.size.width + 10, self.view.bounds.size.height - 55, (self.view.bounds.size.width / 2) - 5, 44);
      [self.view addSubview:downloadButton];
      
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
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  [ad addSoundFromData:sound];
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
  NSArray * sounds = [ad soundsWithState:Cloud];
  [soundsData addObjectsFromArray:sounds];
}

-(void)previewSound:(id)sender
{
  //get currently selected row index
  NSIndexPath * path = [soundsView indexPathForSelectedRow];
  int row = path ? [path row] : -1;
  NSLog(@"selected row: %i", row);
  
  if (row >= 0) {
    NSDictionary * sound = [soundsData objectAtIndex:[path row]];
    NSString * uuid = [sound objectForKey:@"uuid"];
    NSLog(@"preview uuid: %s", [uuid UTF8String]);
    ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString * pp = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.preview", uuid, uuid]] path];
    bool exists = [[NSFileManager defaultManager] fileExistsAtPath:pp];
    if (exists) {
      NSLog(@"preview file exists");
      [self playPreview:pp];
    } else {
      NSLog(@"preview file does not exist");
      dispatch_async(thumbnail_queue, ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSString * url = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/%@.preview", uuid, uuid];
        NSData * preview = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        NSString * file_path = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.preview", uuid, uuid]] path];
        [preview writeToFile:file_path atomically:NO];
        [self performSelectorOnMainThread:@selector(playPreview:)
                               withObject:file_path waitUntilDone:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
      });
    }
  }
}

-(void)playPreview:(NSString*)filePath
{
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  [ad playPreview:filePath];
  
  NSLog(@"playing %s", [filePath UTF8String]);
}

-(void)downloadSound:(id)sender
{
  NSLog(@"downloadSound()");
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
  //[[[cell contentView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
  
  cell.textLabel.text = [NSString stringWithFormat:@"%@", [sound objectForKey:@"name"]];
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  cell.imageView.image = [UIImage imageWithContentsOfFile:[[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.thumb", uuid, uuid]] path]];
  
  return cell;
}

@end
