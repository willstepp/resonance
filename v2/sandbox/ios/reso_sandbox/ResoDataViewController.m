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

#define bgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define soundsUrl [NSURL URLWithString:@"http://resoapp.com/sounds.json"]

@interface ResoDataViewController ()
@end

@implementation ResoDataViewController
@synthesize backButton;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
      ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
      NSURL * appUrl = [ad applicationDocumentsDirectory];
      NSURL * cacheUrl = [ad applicationCachesDirectory];
      NSLog(@"%s", [[appUrl absoluteString] UTF8String]);
      NSLog(@"%s", [[cacheUrl absoluteString] UTF8String]);
      
      //get list of sounds on background thread
      dispatch_async(bgQueue, ^{
        NSData * data = [NSData dataWithContentsOfURL:
                        soundsUrl];
        
        //parse into json array
        //iterate through list
        //create new managed object context, retrieve whether sound already exists
        //if not
          //create directory for sound files
            //check to see if directory for current sound exists
          //download preview and thumbnail, here in a separate thread
          //add sound model, on main thread
          [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
      });
      
      /*
      NSManagedObjectContext * context = [ad managedObjectContext];
      NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
      NSEntityDescription *entity = [NSEntityDescription
                                     entityForName:@"Sound" inManagedObjectContext:context];
      [fetchRequest setEntity:entity];
      NSError * error;
      NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
      for (NSManagedObject *info in fetchedObjects) {
        NSLog(@"Name: %@", [info valueForKey:@"name"]);
        NSLog(@"Description: %@", [info valueForKey:@"desc"]);
        NSLog(@"Length: %@", [info valueForKey:@"length"]);
      }
       */
      
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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchedData:(NSData *)responseData {
  //parse out the json data
  NSError * error;
  NSArray * sounds = [NSJSONSerialization
                        JSONObjectWithData:responseData //1
                        options:kNilOptions
                        error:&error];
  
  NSDictionary * sound = [sounds objectAtIndex:0];
  
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  [ad addSoundFromData:sound];
}

-(void)goBack:(id)sender
{
  // goes back to the last view controller in the stack
  [self.navigationController popViewControllerAnimated:YES];
}

@end
