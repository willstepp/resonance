//
//  ResoMediaTransferQueue.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/2/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoMediaTransferQueue.h"

@implementation ResoMediaTransferQueue
//a class which allows you to add resofiletransfers to a queue and it will
//process them in sequence, in batches, based on settings
//app delegate should store a dictionary of transfer queue instances with types
//sound download, thumbnail download
//should have a maxTransfers, transferring?, run(), suspend(), cancelAllTransfers()
@end
