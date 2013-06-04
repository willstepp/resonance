//
//  ResoFileManager.mm
//  resonance
//
//  Created by Daniel Stepp on 6/2/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoFileManager.h"

@implementation ResoFileManager

+ (void)ensureResonanceAppDirectoryExists
{
  NSURL * rad = [self resonanceAppDirectory];
  if (![[NSFileManager defaultManager] fileExistsAtPath:[rad path]]) {
    BOOL success = [self ensureDirectoryExists:rad];
    if (success) {
      success = [self addSkipBackupAttributeToItemAtURL:rad];
    }
  }
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
  assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
  
  NSError *error = nil;
  BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                forKey: NSURLIsExcludedFromBackupKey error: &error];
  if(!success){
  }
  return success;
}

+ (NSURL *)applicationDocumentsDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSURL*)resonanceAppDirectory
{
  NSURL * url = [[self applicationCachesDirectory] URLByAppendingPathComponent:@"resonance"];
  return url;
}

+ (NSURL*)resonanceAppSubDirectory:(NSString*)subdir
{
  NSURL * url = [[self resonanceAppDirectory] URLByAppendingPathComponent:subdir];
  return url;
}

+ (NSURL *)applicationCachesDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (bool)ensureDirectoryExists:(NSURL*)path
{
  return [[NSFileManager defaultManager] createDirectoryAtURL:path withIntermediateDirectories:YES attributes:nil error:nil];
}

@end
