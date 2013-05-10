//
//  RESOAppDelegate.h
//  gl_sandbox
//
//  Created by Daniel Stepp on 9/1/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ISound.h"
#import "ITone.h"
#import "ISoundEngine.h"

@interface ResoAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

//core data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationCachesDirectory;

//sound data methods
- (void)clearSounds;
- (void)addSoundWithIdentifier:(NSString*)uuid;
- (void)setSoundFromData:(NSDictionary*)d;
- (BOOL)soundExists:(NSString*)uuid withContext:(NSManagedObjectContext*)context;
- (NSArray*)soundsWithState:(int)s;
- (int)getStateForSound:(NSString*)uuid;
- (void)setStateforSound:(NSString*)uuid newState:(int)s;
- (void)removeSoundWithIdentifier:(NSString*)uuid;
-(NSMutableDictionary*)soundWithIdentifier:(NSString*)uuid;

//mix data methods
- (void)clearMixes;
- (void)addMixWithId:(NSString*)uuid name:(NSString*)n state:(int)s;
- (BOOL)mixExists:(NSString*)uuid withContext:(NSManagedObjectContext*)context;
- (void)removeMixWithIdentifier:(NSString*)uuid;
- (NSString*)getMixUUID;

- (BOOL)ensureDirectoryExists:(NSURL*)path;
- (NSURL*)resonanceAppSubDirectory:(NSString*)subdir;

-(NSString*)iosVersionForDownload;
@end
