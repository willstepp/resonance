//
//  ResoFileManager.h
//  resonance
//
//  Created by Daniel Stepp on 6/2/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResoFileManager : NSObject
+ (void)ensureResonanceAppDirectoryExists;
+ (NSURL *)applicationDocumentsDirectory;
+ (NSURL*)resonanceAppSubDirectory:(NSString*)subdir;
+ (bool)ensureDirectoryExists:(NSURL*)path;
@end
