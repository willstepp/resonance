//
//  ResoDataManager.mm
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoDataManager.h"
#import "ResoAppDelegate.h"
#import "ResoFileManager.h"

@implementation ResoDataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static ResoDataManager * rdm = nil;

-(id)init
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"-init is not a valid initializer for the class ResoDataManager. Use -instance"
                               userInfo:nil];
  return nil;
}

+(ResoDataManager*)instance
{
  if (rdm == nil)
    rdm = [[ResoDataManager alloc] initForSingleton];
  return rdm;
}

-(id)initForSingleton
{
  if (self = [super init])
  {
  }
  return self;
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
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"resonance" withExtension:@"momd"];
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
  
  NSURL *storeURL = [[ResoFileManager applicationDocumentsDirectory] URLByAppendingPathComponent:@"resonance.sqlite"];
  
  NSError *error = nil;
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

#pragma mark sound methods

- (void)clearSounds
{
  [[NSFileManager defaultManager] removeItemAtPath:[[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds"]] path] error:nil];
  
  NSManagedObjectContext * context = [self managedObjectContext];
  NSFetchRequest * allSounds = [[NSFetchRequest alloc] init];
  [allSounds setEntity:[NSEntityDescription entityForName:@"Sound" inManagedObjectContext:context]];
  [allSounds setIncludesPropertyValues:NO]; //only fetch the managedObjectID
  
  NSError * error = nil;
  NSArray * sounds = [context executeFetchRequest:allSounds error:&error];
  
  //error handling goes here
  for (NSManagedObject * sound in sounds) {
    NSString * uuid = [sound valueForKey:@"uuid"];
    [[NSFileManager defaultManager] removeItemAtPath:[[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]] path] error:nil];
    [context deleteObject:sound];
  }
  NSError * saveError = nil;
  [context save:&saveError];
  //more error handling here
}

- (void)addSoundWithIdentifier:(NSString*)uuid
{
  if (![self soundExists:uuid withContext:[self managedObjectContext]]) {
    NSManagedObjectContext * context = [self managedObjectContext];
    NSManagedObject * sound = [NSEntityDescription
                               insertNewObjectForEntityForName:@"Sound"
                               inManagedObjectContext:context];
    [sound setValue:uuid forKey:@"uuid"];
    [sound setValue:[NSNumber numberWithInt:(int)Transferring] forKey:@"state"];
    NSError * error;
    if (![context save:&error]) {
    }
  }
}

- (void)setSoundFromData:(NSDictionary*)d
{
  NSString * name = [d objectForKey:@"name"];
  NSString * desc = [d objectForKey:@"description"];
  NSString * uuid = [d objectForKey:@"uuid"];
  
  NSManagedObjectContext * context = [self managedObjectContext];
  NSManagedObject * sound;
  if (![self soundExists:uuid withContext:[self managedObjectContext]]) {
    
    sound = [NSEntityDescription
             insertNewObjectForEntityForName:@"Sound"
             inManagedObjectContext:context];
    
  } else {
    
    //retrieve sound
    NSEntityDescription * ed = [NSEntityDescription
                                entityForName:@"Sound" inManagedObjectContext:context];
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:ed];
    
    NSPredicate * p = [NSPredicate predicateWithFormat:@"(uuid == %@)", uuid];
    [request setPredicate:p];
    
    NSError * error;
    NSArray * array = [context executeFetchRequest:request error:&error];
    
    sound = [array objectAtIndex:0];
    
  }
  
  [sound setValue:name forKey:@"name"];
  [sound setValue:desc forKey:@"desc"];
  [sound setValue:uuid forKey:@"uuid"];
  [sound setValue:[NSNumber numberWithInt:(int)Transferring] forKey:@"state"];
  
  NSError * error;
  if (![context save:&error]) {
  }
}

-(bool)soundExists:(NSString*)uuid withContext:(NSManagedObjectContext*)context
{
  NSEntityDescription * ed = [NSEntityDescription
                              entityForName:@"Sound" inManagedObjectContext:context];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:ed];
  
  NSPredicate * p = [NSPredicate predicateWithFormat:@"(uuid == %@)", uuid];
  [request setPredicate:p];
  
  NSError * error;
  NSArray * array = [context executeFetchRequest:request error:&error];
  
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
    }
  }
}

- (void)removeSoundWithIdentifier:(NSString*)uuid
{
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
    [context deleteObject:sound];
    NSError * saveError = nil;
    [context save:&saveError];
  }
}

-(NSMutableDictionary*)soundWithIdentifier:(NSString*)uuid
{
  NSMutableDictionary * sound = nil;
  
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
    NSManagedObject * s = [array objectAtIndex:0];
    sound = [[NSMutableDictionary alloc] init];
    [sound setValue:[s valueForKey:@"name"] forKey:@"name"];
    [sound setValue:[s valueForKey:@"desc"] forKey:@"desc"];
    [sound setValue:[s valueForKey:@"uuid"] forKey:@"uuid"];
    [sound setValue:[s valueForKey:@"state"] forKey:@"state"];
  }
  return sound;
}

#pragma mark mix methods

- (void)clearMixes
{
  [[NSFileManager defaultManager] removeItemAtPath:[[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes"]] path] error:nil];
  
  NSManagedObjectContext * context = [self managedObjectContext];
  NSFetchRequest * allMixes = [[NSFetchRequest alloc] init];
  [allMixes setEntity:[NSEntityDescription entityForName:@"Mix" inManagedObjectContext:context]];
  [allMixes setIncludesPropertyValues:NO]; //only fetch the managedObjectID
  
  NSError * error = nil;
  NSArray * mixes = [context executeFetchRequest:allMixes error:&error];
  
  //error handling goes here
  for (NSManagedObject * mix in mixes) {
    NSString * uuid = [mix valueForKey:@"uuid"];
    [[NSFileManager defaultManager] removeItemAtPath:[[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@", uuid]] path] error:nil];
    [context deleteObject:mix];
  }
  NSError * saveError = nil;
  [context save:&saveError];
  //more error handling here
}

- (void)addMixWithId:(NSString*)uuid name:(NSString*)n state:(int)state sounds:(NSArray*)sounds shared:(bool)shared
{
  if (![self mixExists:uuid withContext:[self managedObjectContext]]) {
    NSManagedObjectContext * context = [self managedObjectContext];
    NSManagedObject * mix = [NSEntityDescription
                             insertNewObjectForEntityForName:@"Mix"
                             inManagedObjectContext:context];
    [mix setValue:uuid forKey:@"uuid"];
    [mix setValue:n forKey:@"name"];
    [mix setValue:[NSNumber numberWithInt:state] forKey:@"state"];
    [mix setValue:[NSNumber numberWithBool:shared] forKey:@"shared"];
    if (sounds != nil) {
      [mix setValue:[sounds componentsJoinedByString:@";"] forKey:@"sounds"];
    }
    NSError * error;
    if (![context save:&error]) {
    }
  }
}

-(bool)mixExists:(NSString*)uuid withContext:(NSManagedObjectContext*)context
{
  NSEntityDescription * ed = [NSEntityDescription
                              entityForName:@"Mix" inManagedObjectContext:context];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:ed];
  
  NSPredicate * p = [NSPredicate predicateWithFormat:@"(uuid == %@)", uuid];
  [request setPredicate:p];
  
  NSError * error;
  NSArray * array = [context executeFetchRequest:request error:&error];
  
  return [array count] > 0;
}

- (bool)mixAlreadyShared:(NSString*)uuid
{
  bool shared = false;
  
  NSManagedObjectContext * context = [self managedObjectContext];
  
  NSEntityDescription * ed = [NSEntityDescription
                              entityForName:@"Mix" inManagedObjectContext:context];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:ed];
  
  NSPredicate * p = [NSPredicate predicateWithFormat:@"(uuid == %@)", uuid];
  [request setPredicate:p];
  
  NSError * error;
  NSArray * array = [context executeFetchRequest:request error:&error];
  if (array.count > 0) {
    NSManagedObject * mix = [array objectAtIndex:0];
    shared = [[mix valueForKey:@"shared"] boolValue];
  }
  return shared;
}

- (NSString*)getMixUUID
{
  NSManagedObjectContext * context = [self managedObjectContext];
  NSFetchRequest * allMixes = [[NSFetchRequest alloc] init];
  [allMixes setEntity:[NSEntityDescription entityForName:@"Mix" inManagedObjectContext:context]];
  [allMixes setIncludesPropertyValues:NO];
  
  NSError * error = nil;
  NSArray * mixes = [context executeFetchRequest:allMixes error:&error];
  NSString * uuid = nil;
  if ([mixes count] > 0) {
    NSManagedObject * mix = [mixes objectAtIndex:0];
    uuid = [mix valueForKey:@"uuid"];
  }
  return uuid;
}

- (void)setStateforMix:(NSString*)uuid newState:(int)s
{
  NSManagedObjectContext * context = [self managedObjectContext];
  NSEntityDescription * ed = [NSEntityDescription entityForName:@"Mix" inManagedObjectContext:context];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:ed];
  
  NSPredicate * p = [NSPredicate predicateWithFormat:@"(uuid == %@)", uuid];
  [request setPredicate:p];
  
  NSError * error;
  NSArray * array = [context executeFetchRequest:request error:&error];
  if (array.count > 0) {
    NSManagedObject * mix = [array objectAtIndex:0];
    [mix setValue:[NSNumber numberWithInt:s] forKey:@"state"];
    NSError * error;
    if (![context save:&error]) {
    }
  }
}

- (void)setSharedforMix:(NSString*)uuid shared:(bool)s
{
  NSManagedObjectContext * context = [self managedObjectContext];
  NSEntityDescription * ed = [NSEntityDescription entityForName:@"Mix" inManagedObjectContext:context];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:ed];
  
  NSPredicate * p = [NSPredicate predicateWithFormat:@"(uuid == %@)", uuid];
  [request setPredicate:p];
  
  NSError * error;
  NSArray * array = [context executeFetchRequest:request error:&error];
  if (array.count > 0) {
    NSManagedObject * mix = [array objectAtIndex:0];
    [mix setValue:[NSNumber numberWithBool:s] forKey:@"shared"];
    NSError * error;
    if (![context save:&error]) {
    }
  }
}

-(NSArray*)mixesWithState:(int)s
{
  NSManagedObjectContext * context = [self managedObjectContext];
  
  NSEntityDescription * ed = [NSEntityDescription
                              entityForName:@"Mix" inManagedObjectContext:context];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:ed];
  
  NSPredicate * p = [NSPredicate predicateWithFormat:@"(state == %i)", s];
  [request setPredicate:p];
  
  NSError * error;
  NSArray * array = [context executeFetchRequest:request error:&error];
  
  NSMutableArray * mixes  = [[NSMutableArray alloc] init];
  for (NSManagedObject * mix in array) {
    NSMutableDictionary * m = [[NSMutableDictionary alloc] init];
    [m setValue:[mix valueForKey:@"name"] forKey:@"name"];
    [m setValue:[mix valueForKey:@"shared"] forKey:@"shared"];
    [m setValue:[mix valueForKey:@"uuid"] forKey:@"uuid"];
    [mixes addObject:m];
  }
  return mixes;
}

- (void)removeMixWithIdentifier:(NSString*)uuid
{
  NSManagedObjectContext * context = [self managedObjectContext];
  
  NSEntityDescription * ed = [NSEntityDescription
                              entityForName:@"Mix" inManagedObjectContext:context];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:ed];
  
  NSPredicate * p = [NSPredicate predicateWithFormat:@"(uuid == %@)", uuid];
  [request setPredicate:p];
  
  NSError * error;
  NSArray * array = [context executeFetchRequest:request error:&error];
  if (array.count > 0) {
    NSManagedObject * mix = [array objectAtIndex:0];
    [context deleteObject:mix];
    NSError * saveError = nil;
    [context save:&saveError];
  }
}

-(NSMutableDictionary*)mixWithIdentifier:(NSString*)uuid
{
  NSMutableDictionary * mix = nil;
  
  NSManagedObjectContext * context = [self managedObjectContext];
  
  NSEntityDescription * ed = [NSEntityDescription
                              entityForName:@"Mix" inManagedObjectContext:context];
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  [request setEntity:ed];
  
  NSPredicate * p = [NSPredicate predicateWithFormat:@"(uuid == %@)", uuid];
  [request setPredicate:p];
  
  NSError * error;
  NSArray * array = [context executeFetchRequest:request error:&error];
  if (array.count > 0) {
    NSManagedObject * m = [array objectAtIndex:0];
    mix = [[NSMutableDictionary alloc] init];
    [mix setValue:[m valueForKey:@"name"] forKey:@"name"];
    [mix setValue:[m valueForKey:@"shared"] forKey:@"shared"];
    [mix setValue:[m valueForKey:@"state"] forKey:@"state"];
    [mix setValue:[m valueForKey:@"sounds"] forKey:@"sounds"];
    [mix setValue:[m valueForKey:@"uuid"] forKey:@"uuid"];
  }
  return mix;
}
@end
