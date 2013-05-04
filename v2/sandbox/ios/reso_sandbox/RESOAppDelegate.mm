//
//  RESOAppDelegate.m
//  gl_sandbox
//
//  Created by Daniel Stepp on 9/1/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <sys/utsname.h>

#import "ResoAppDelegate.h"
#import "ResoPortalViewController.h"
#import "ResoTypes.h"

@implementation ResoAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  ResoPortalViewController * rvc = [[ResoPortalViewController alloc] init];
  UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:rvc];
  [navController setNavigationBarHidden:YES];
  
  [self.window setRootViewController:navController];
  [self.window addSubview:navController.view];
  
  [self.window makeKeyAndVisible];
  
  [self ensureResonanceAppDirectoryExists];
  [self ensureDirectoryExists:[self resonanceAppSubDirectory:@"sounds"]];
  [self ensureDirectoryExists:[self resonanceAppSubDirectory:@"mixes"]];
  
  //clean out any existing sounds
  [self clearSounds];
  
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
  [[AVAudioSession sharedInstance] setActive: YES error: nil];
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Saves changes in the application's managed object context before the application terminates.
  [self saveContext];
}

- (void)saveContext
{
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil) {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  NSURL * modelURL = [[NSBundle mainBundle] URLForResource:@"reso_sandbox" withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
  if (_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }
  
  NSURL * storeURL = [[self resonanceAppDirectory] URLByAppendingPathComponent:@"reso_sandbox.sqlite"];
  
  NSError * error = nil;
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    /*
     Replace this implementation with code to handle the error appropriately.
     
     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     
     Typical reasons for an error here include:
     * The persistent store is not accessible;
     * The schema for the persistent store is incompatible with current managed object model.
     Check the error message to determine what the actual problem was.
     
     
     If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
     
     If you encounter schema incompatibility errors during development, you can reduce their frequency by:
     * Simply deleting the existing store:
     [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
     
     * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
     @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
     
     Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
     
     */
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
  
  return _persistentStoreCoordinator;
}

#pragma mark - Application directories

-(void)ensureResonanceAppDirectoryExists
{
  NSURL * rad = [self resonanceAppDirectory];
  if (![[NSFileManager defaultManager] fileExistsAtPath:[rad path]]) {
    BOOL success = [self ensureDirectoryExists:rad];
    NSLog(@"Resonance App Directory Created: %i", success);
    if (success) {
      success = [self addSkipBackupAttributeToItemAtURL:rad];
      NSLog(@"Add Skip Backup Attribute: %i", success);
    }
  }
}

-(BOOL)ensureDirectoryExists:(NSURL*)path
{
  return [[NSFileManager defaultManager] createDirectoryAtURL:path withIntermediateDirectories:YES attributes:nil error:nil];
}

-(NSURL*)resonanceAppDirectory
{
  NSURL * url = [[self applicationCachesDirectory] URLByAppendingPathComponent:@"resonance"];
  return url;
}

-(NSURL*)resonanceAppSubDirectory:(NSString*)subdir
{
  NSURL * url = [[self resonanceAppDirectory] URLByAppendingPathComponent:subdir];
  return url;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// Returns the URL to the application's Caches directory.
- (NSURL *)applicationCachesDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)clearSounds
{
  [[NSFileManager defaultManager] removeItemAtPath:[[self resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds"]] path] error:nil];
  
  NSManagedObjectContext * context = [self managedObjectContext];
  NSFetchRequest * allSounds = [[NSFetchRequest alloc] init];
  [allSounds setEntity:[NSEntityDescription entityForName:@"Sound" inManagedObjectContext:context]];
  [allSounds setIncludesPropertyValues:NO]; //only fetch the managedObjectID
  
  NSError * error = nil;
  NSArray * sounds = [context executeFetchRequest:allSounds error:&error];

  //error handling goes here
  for (NSManagedObject * sound in sounds) {
    NSString * uuid = [sound valueForKey:@"uuid"];
    [[NSFileManager defaultManager] removeItemAtPath:[[self resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]] path] error:nil];
    NSLog(@"%@ deleted", uuid);
    [context deleteObject:sound];
    NSLog(@"Deleted Sound");
  }
  NSError * saveError = nil;
  [context save:&saveError];
  //more error handling here
}

- (void)addSoundFromData:(NSDictionary*)d
{
  NSString * name = [d objectForKey:@"name"];
  NSString * desc = [d objectForKey:@"description"];
  NSString * uuid = [d objectForKey:@"uuid"];
  
  if (![self soundExists:uuid withContext:[self managedObjectContext]]) {
    NSLog(@"Sound does not yet exist!");
    
    NSManagedObjectContext * context = [self managedObjectContext];
    NSManagedObject * sound = [NSEntityDescription
                               insertNewObjectForEntityForName:@"Sound"
                               inManagedObjectContext:context];
    [sound setValue:name forKey:@"name"];
    [sound setValue:desc forKey:@"desc"];
    [sound setValue:uuid forKey:@"uuid"];
    [sound setValue:[NSNumber numberWithInt:(int)Cloud] forKey:@"state"];
    
    NSError * error;
    if (![context save:&error]) {
      NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
  } else {
    NSLog(@"Sound exists!");
  }
}

-(BOOL)soundExists:(NSString*)uuid withContext:(NSManagedObjectContext*)context
{
  NSEntityDescription * ed = [NSEntityDescription
                                            entityForName:@"Sound" inManagedObjectContext:context];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:ed];

  NSPredicate * p = [NSPredicate predicateWithFormat:@"(uuid == %@)", uuid];
  [request setPredicate:p];
  
  NSError * error;
  NSArray * array = [context executeFetchRequest:request error:&error];
  
  NSLog(@"%i",[array count]);
  return [array count] > 0;
}

-(NSArray*)soundsWithState:(int)s
{
  NSManagedObjectContext * context = [self managedObjectContext];
  
  NSEntityDescription * ed = [NSEntityDescription
                              entityForName:@"Sound" inManagedObjectContext:context];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:ed];
  
  NSPredicate * p = [NSPredicate predicateWithFormat:@"(state == %i)", s];
  [request setPredicate:p];
  
  NSError * error;
  NSArray * array = [context executeFetchRequest:request error:&error];
  
  NSMutableArray * sounds  = [[NSMutableArray alloc] init];
  for (NSManagedObject * sound in array) {
    NSMutableDictionary * s = [[NSMutableDictionary alloc] init];
    [s setValue:[sound valueForKey:@"name"] forKey:@"name"];
    [s setValue:[sound valueForKey:@"desc"] forKey:@"desc"];
    [s setValue:[sound valueForKey:@"uuid"] forKey:@"uuid"];
    [sounds addObject:s];
  }
  return sounds;
}

- (int)getStateForSound:(NSString*)uuid
{
  int state = -1;
  
  NSManagedObjectContext * context = [self managedObjectContext];
  
  NSEntityDescription * ed = [NSEntityDescription
                              entityForName:@"Sound" inManagedObjectContext:context];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:ed];
  
  NSPredicate * p = [NSPredicate predicateWithFormat:@"(uuid == %@)", uuid];
  [request setPredicate:p];
  
  NSError * error;
  NSArray * array = [context executeFetchRequest:request error:&error];
  if (array.count > 0) {
    NSManagedObject * sound = [array objectAtIndex:0];
    state = [[sound valueForKey:@"state"] intValue];
  }
  return state;
}

- (void)setStateforSound:(NSString*)uuid newState:(int)s
{
  NSManagedObjectContext * context = [self managedObjectContext];
  NSEntityDescription * ed = [NSEntityDescription entityForName:@"Sound" inManagedObjectContext:context];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:ed];
  
  NSPredicate * p = [NSPredicate predicateWithFormat:@"(uuid == %@)", uuid];
  [request setPredicate:p];
  
  NSError * error;
  NSArray * array = [context executeFetchRequest:request error:&error];
  if (array.count > 0) {
    NSManagedObject * sound = [array objectAtIndex:0];
    [sound setValue:[NSNumber numberWithInt:s] forKey:@"state"];
    NSError * error;
    if (![context save:&error]) {
      NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
  }
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
  assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
  
  NSError *error = nil;
  BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                forKey: NSURLIsExcludedFromBackupKey error: &error];
  if(!success){
    NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
  }
  return success;
}

NSString * deviceName()
{
  struct utsname systemInfo;
  uname(&systemInfo);
  
  return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

/*
 @"i386"      on the simulator
 @"iPod1,1"   on iPod Touch
 @"iPod2,1"   on iPod Touch Second Generation
 @"iPod3,1"   on iPod Touch Third Generation
 @"iPod4,1"   on iPod Touch Fourth Generation
 @"iPod5,1"   on iPod Touch Fifth Generation
 @"iPhone1,1" on iPhone
 @"iPhone1,2" on iPhone 3G
 @"iPhone2,1" on iPhone 3GS
 @"iPad1,1"   on iPad
 @"iPad2,1"   on iPad 2
 @"iPad3,1"   on 3rd Generation iPad
 @"iPhone3,1" on iPhone 4
 @"iPhone4,1" on iPhone 4S
 @"iPhone5,1" on iPhone 5 (model A1428, AT&T/Canada)
 @"iPhone5,2" on iPhone 5 (model A1429, everything else)
 @"iPad3,4" on 4th Generation iPad
 @"iPad2,5" on iPad Mini
 */

-(NSString*)iosVersionForDownload
{
  NSString * version;
  NSString * deviceVersion = deviceName();
  NSLog(@"deviceVersion: %s", [deviceVersion UTF8String]);
  
  if(([deviceVersion rangeOfString:@"iPhone5"].location != NSNotFound) ||
     ([deviceVersion rangeOfString:@"iPod5"].location != NSNotFound) ) {
    version = @"iphone5";
  } else if (([deviceVersion rangeOfString:@"iPhone4,1"].location != NSNotFound) ||
             ([deviceVersion rangeOfString:@"iPhone3,1"].location != NSNotFound) ||
             ([deviceVersion rangeOfString:@"iPod4"].location != NSNotFound)) {
    version = @"iphone4";
  } else if (([deviceVersion rangeOfString:@"iPhone1,1"].location != NSNotFound) ||
             ([deviceVersion rangeOfString:@"iPhone1,2"].location != NSNotFound) ||
             ([deviceVersion rangeOfString:@"iPhone2,1"].location != NSNotFound) ||
             ([deviceVersion rangeOfString:@"iPod"].location != NSNotFound) ||
             ([deviceVersion rangeOfString:@"86"].location != NSNotFound)) {
    version = @"iphone";
  } else {
    version = @"";
  }
  
  return version;
}

@end
