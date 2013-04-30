//
//  RESOAppDelegate.h
//  gl_sandbox
//
//  Created by Daniel Stepp on 9/1/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResoAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

//core data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationCachesDirectory;

- (void)clearSounds;
- (void)addSoundFromData:(NSDictionary*)d;
@end
