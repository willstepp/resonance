//
//  ResoMixManager.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/10/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ResoMediaTransfer;

@interface ResoMixManager : NSObject
+(ResoMixManager*)instance;

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskId;

-(void)saveMix:(NSString*)name;
-(void)loadMix:(NSString*)uuid;
-(void)removeMix:(NSString*)uuid;
-(ResoMediaTransfer*)shareMix:(NSString*)uuid;
@end
