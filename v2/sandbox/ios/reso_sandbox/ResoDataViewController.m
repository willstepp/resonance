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
}
@end

@implementation ResoDataViewController
@synthesize backButton;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
      ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
      
      soundsData = [[NSMutableArray alloc] init];
      [self loadAvailableSoundsFromDevice];
      
      //set up table view
      soundsView = [[UITableView alloc] initWithFrame:CGRectMake(10, 60, self.view.bounds.size.width - 20, self.view.bounds.size.height - 70) style:UITableViewStylePlain];
      
      soundsView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
      soundsView.delegate = self;
      soundsView.dataSource = self;
      [soundsView reloadData];
      
      [self.view addSubview:soundsView];
      
      //initiate background queue to retreive list of sounds
      dispatch_queue_t thumbnail_queue;
      thumbnail_queue = dispatch_queue_create("com.resonance.thumbnail_fetch", NULL);
      
      //get list of sounds on background thread
      dispatch_async(bgQueue, ^{
        
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
              NSString * url = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/%@.thumb", uuid, uuid];
              NSData * thumb = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
              NSString * file_path = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.thumb", uuid, uuid]] path];
              [thumb writeToFile:file_path atomically:NO];
              [self performSelectorOnMainThread:@selector(addSoundToTable:)
                                     withObject:sound waitUntilDone:YES];
            });
          }
        }
      });
      
      [self.view setBackgroundColor:[UIColor brownColor]];
      
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
