//
//  ResoMediaTransferQueue.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/2/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoMediaTransferQueue.h"
#import "NSMutableArray+QueueAdditions.h"

@interface ResoMediaTransferQueue () {
  int numProcessing;
  NSMutableArray * queue;
}
@end

@implementation ResoMediaTransferQueue
@synthesize maxBatchCount;

-(id)init
{
  if (self = [super init]) {
    numProcessing = 0;
    queue = [[NSMutableArray alloc] init];
  }
  return self;
}

-(void)enqueueWithMediaTransfer:(ResoMediaTransfer*)mt
{
  [mt addDelegate:self];
  [queue enqueue:mt];
  
  [self processQueue];
}

-(void)processQueue
{
  while (numProcessing < maxBatchCount) {
    ResoMediaTransfer * mt = [queue dequeue];
    if (mt != nil) {
      [mt start];
      numProcessing++;
    } else {
      break; //stop processing
    }
  }
}

#pragma mark -
#pragma mark ResoMediaTransfer Delegates

-(void) transferFinished:(ResoMediaTransfer*)t
{
  numProcessing--;
  [self processQueue];
}

-(void) transferError:(ResoMediaTransfer*)t
{
  numProcessing--;
  [self processQueue];
}

@end
