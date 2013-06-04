//
//  ResoDataManager.h
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResoDataManager : NSObject
+(ResoDataManager*)instance;

@property (readonly, strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel * managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;

- (void)saveContext;

//sound data methods
- (void)clearSounds;
- (void)addSoundWithIdentifier:(NSString*)uuid;
- (void)setSoundFromData:(NSDictionary*)d;
- (bool)soundExists:(NSString*)uuid withContext:(NSManagedObjectContext*)context;
- (NSArray*)soundsWithState:(int)s;
- (int)getStateForSound:(NSString*)uuid;
- (void)setStateforSound:(NSString*)uuid newState:(int)s;
- (void)removeSoundWithIdentifier:(NSString*)uuid;
-(NSMutableDictionary*)soundWithIdentifier:(NSString*)uuid;

//mix data methods
- (void)clearMixes;
- (void)addMixWithId:(NSString*)uuid name:(NSString*)n state:(int)state sounds:(NSArray*)sounds shared:(bool)shared;
- (bool)mixExists:(NSString*)uuid withContext:(NSManagedObjectContext*)context;
- (bool)mixAlreadyShared:(NSString*)uuid;
- (NSString*)getMixUUID;
- (void)setStateforMix:(NSString*)uuid newState:(int)s;
- (void)setSharedforMix:(NSString*)uuid shared:(bool)s;
- (NSArray*)mixesWithState:(int)s;
- (void)removeMixWithIdentifier:(NSString*)uuid;
-(NSMutableDictionary*)mixWithIdentifier:(NSString*)uuid;
@end
