//
//  ResoAppDelegate.h
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoTypes.h"

@protocol IResoVisualization;

@interface ResoAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) NSString * currentModule;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSURL*)resonanceAppSubDirectory:(NSString*)subdir;

@property (readonly, nonatomic) id<IResoVisualization> visualization;
@property (assign, nonatomic) PlayerState currPlayerState;

@end
