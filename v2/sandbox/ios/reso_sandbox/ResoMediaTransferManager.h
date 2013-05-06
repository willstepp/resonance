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

@interface ResoMediaTransferManager : NSObject <ResoMediaTransferDelegate>

+(ResoMediaTransferManager*)instance;
-(void)initTransferOfType:(MediaTransfer)mt withIdentifier:(NSString*)uuid;

@property (readonly) NSMutableDictionary * transfers;
@end
