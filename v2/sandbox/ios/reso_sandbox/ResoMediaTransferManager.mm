//
//  ResoMediaTransferManager.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/3/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoMediaTransferManager.h"
#import "ResoMediaTransferQueue.h"

@interface ResoMediaTransferManager()
{
  NSMutableDictionary * queues;
}
@end

@implementation ResoMediaTransferManager
static  ResoMediaTransferManager * rmtm = nil;

-(id)init
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"-init is not a valid initializer for the class ResoMediaTransferManager. Use -instance"
                               userInfo:nil];
  return nil;
}

+(ResoMediaTransferManager*)instance
{
  if (rmtm == nil)
    rmtm = [[ResoMediaTransferManager alloc] initForSingleton];
  return rmtm;
}

-(id)initForSingleton
{
  if (self = [super init])
  {
    queues = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    //thumbnail
    ResoMediaTransferQueue * thumbQueue = [[ResoMediaTransferQueue alloc] init];
    thumbQueue.maxBatchCount = 10;
    [queues setObject:thumbQueue forKey:[NSNumber numberWithInt:ThumbnailQueue]];
    //preview
    ResoMediaTransferQueue * previewQueue = [[ResoMediaTransferQueue alloc] init];
    previewQueue.maxBatchCount = 5;
    [queues setObject:previewQueue forKey:[NSNumber numberWithInt:PreviewQueue]];
    //sound
    ResoMediaTransferQueue * soundQueue = [[ResoMediaTransferQueue alloc] init];
    soundQueue.maxBatchCount = 2;
    [queues setObject:soundQueue forKey:[NSNumber numberWithInt:SoundQueue]];
    //mix
    ResoMediaTransferQueue * mixQueue = [[ResoMediaTransferQueue alloc] init];
    mixQueue.maxBatchCount = 2;
    [queues setObject:mixQueue forKey:[NSNumber numberWithInt:MixQueue]];
  }
  return self;
}

-(void)enqueueWithMediaTransfer:(ResoMediaTransfer*)mt forQueue:(MediaTransferQueue)mtq
{
  ResoMediaTransferQueue * queue = [queues objectForKey:[NSNumber numberWithInt:mtq]];
  [queue enqueueWithMediaTransfer:mt];
}

@end
