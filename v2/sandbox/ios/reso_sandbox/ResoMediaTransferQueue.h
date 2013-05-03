//
//  ResoFileTransferQueue.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/2/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResoMediaTransfer.h"

@interface ResoMediaTransferQueue : NSObject <ResoMediaTransferDelegate>

@property (nonatomic, assign) int maxBatchCount;

-(id)init;
-(void)enqueueWithMediaTransfer:(ResoMediaTransfer*)mt;

@end
