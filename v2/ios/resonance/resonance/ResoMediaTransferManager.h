//
//  ResoMediaTransferManager.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/3/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResoTypes.h"
#import "ResoMediaTransfer.h"

@class ResoMediaTransfer;

@protocol ResoMediaTransferManagerDelegate <NSObject>
@optional
-(void) transferStarted:(ResoMediaTransfer*)t;
-(void) transferProgressUpdated:(ResoMediaTransfer*)t;
-(void) transferFinished:(ResoMediaTransfer*)t;
-(void) mixFinished:(NSString*)uuid;
-(void) transferError:(ResoMediaTransfer*)t;
@end

@interface ResoMediaTransferManager : NSObject <ResoMediaTransferDelegate> {
  NSMutableArray * delegates;
}

- (NSMutableArray*)delegates;
- (void)addDelegate:(id<ResoMediaTransferManagerDelegate>)d;
- (void)removeDelegate:(id<ResoMediaTransferManagerDelegate>)d;

+(ResoMediaTransferManager*)instance;
-(void)initTransferOfType:(MediaTransfer)mt withIdentifier:(NSString*)uuid withObject:(id)object;

@property (readonly) NSMutableDictionary * transfers;
@end
