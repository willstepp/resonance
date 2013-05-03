//
//  ResoDataViewController.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 4/29/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "SSZipArchive.h"

#import "ResoDataViewController.h"
#import "ResoAppDelegate.h"
#import "ResoTypes.h"

#import "FMODSoundEngine.h"
#import "ResoMediaTransfer.h"

#define soundsUrl [NSURL URLWithString:@"http://resoapp.com/sounds.json"]

@interface ResoDataViewController ()
{
  UITableView * soundsView;
  NSMutableArray * soundsData;
  
  dispatch_queue_t global_queue;
  dispatch_queue_t thumbnail_queue;
  dispatch_queue_t preview_queue;
  
  ResoMediaTransfer * mediaTransfer;
}
@end

@implementation ResoDataViewController
@synthesize backButton, previewButton, downloadButton;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
      mediaTransfer = nil;
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
      
      //initate background queue for global tasks
      global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
      //initiate background queue to retreive thumbnails
      thumbnail_queue = dispatch_queue_create("com.resonance.thumbnail_fetch", NULL);
      //initiate background queue to retreive preview clips
      preview_queue = dispatch_queue_create("com.resonance.preview_fetch", NULL);
      
      //get list of sounds on background thread
      dispatch_async(global_queue, ^{
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
                                   withObject:sound waitUntilDone:NO];
            
            //download preview and thumbnail, in a separate thread
            dispatch_async(thumbnail_queue, ^{
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
              NSString * url = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/%@.thumb", uuid, uuid];
              NSData * thumb = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
              NSString * file_path = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.thumb", uuid, uuid]] path];
              [thumb writeToFile:file_path atomically:NO];
              [self performSelectorOnMainThread:@selector(addSoundToTable:)
                                     withObject:sound waitUntilDone:NO];
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
                               withObject:file_path waitUntilDone:NO];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
      });
    }
  }
}

-(void)playPreview:(NSString*)filePath
{
  id<ISoundEngine> player = [FMODSoundEngine instance];
  id<ISound> sound = [player getSoundForId:Preview];
  [sound load:filePath looped:false];
  [sound play];
  
  NSLog(@"playing %s", [filePath UTF8String]);
}

-(void)downloadSound:(id)sender
{
  //get currently selected row index
  NSIndexPath * path = [soundsView indexPathForSelectedRow];
  int row = path ? [path row] : -1;
  NSLog(@"selected row: %i", row);
  
  if (row >= 0) {
    
    //get uuid for currently selected row
    NSDictionary * sound = [soundsData objectAtIndex:[path row]];
    NSString * uuid = [sound objectForKey:@"uuid"];
    NSLog(@"download uuid: %s", [uuid UTF8String]);
    
    ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
    SoundState ss = (SoundState)[ad getStateForSound:uuid];
    if (ss != Device) {
      
      //sound is not downloaded to device, so begin download process
      NSLog(@"Download started: %s", [uuid UTF8String]);
      
      //1) set sound state to downloading
      [ad setStateforSound:uuid newState:Downloading];
      
      mediaTransfer = nil;
      NSString * version = [ad iosVersionForDownload];
      mediaTransfer = [[ResoMediaTransfer alloc] initWithUrl:[NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/%@.%@", uuid, uuid, version]];
      mediaTransfer.uuid = uuid;
      [mediaTransfer start];
      
      /*
      //2) download file on main background queue
      dispatch_async(global_queue, ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSString * version = [ad iosVersionForDownload];
        NSString * url = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/%@.%@", uuid, uuid, version];
        NSData * soundFile = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        NSString * file_path = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.install", uuid, uuid]] path];
        [soundFile writeToFile:file_path atomically:NO];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self performSelectorOnMainThread:@selector(downloadComplete:)
                               withObject:uuid waitUntilDone:NO];
      });
       */
      
    } else {
      NSLog(@"Sound is already downloaded to device");
    }
  }

}

-(void)downloadComplete:(NSString*)uuid
{
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  [ad setStateforSound:uuid newState:Device];
  
  NSString * installFilePath = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.install", uuid, uuid]] path];
  NSString * destinationPath = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]] path];
  [SSZipArchive unzipFileAtPath:installFilePath toDestination:destinationPath];
  
  [[NSFileManager defaultManager] removeItemAtPath:installFilePath error:nil];
  
  NSLog(@"Download complete: %s", [uuid UTF8String]);
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
  cell.imageView.image = [UIImage imageWithContentsOfFile:[[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.thumb", uuid, uuid]] path]];
  
  return cell;
}

@end
