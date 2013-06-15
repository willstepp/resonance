//
//  ResoMixManager.h
//  resonance
//
//  Created by Daniel Stepp on 6/15/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResoMediaTransfer.h"

@interface ResoMixManager : NSObject
+(ResoMixManager*)instance;

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskId;

-(void)saveMix:(NSString*)name;
-(void)loadMix:(NSString*)uuid;
-(void)removeMix:(NSString*)uuid;
-(void)shareMix:(NSString*)uuid;
@end
