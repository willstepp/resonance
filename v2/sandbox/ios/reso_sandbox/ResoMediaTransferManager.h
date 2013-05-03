//
//  ResoMediaTransferManager.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/3/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResoTypes.h"

@class ResoMediaTransfer;

@interface ResoMediaTransferManager : NSObject

+(ResoMediaTransferManager*)instance;
-(void)enqueueWithMediaTransfer:(ResoMediaTransfer*)mt forQueue:(MediaTransferQueue)mtq;

@end
