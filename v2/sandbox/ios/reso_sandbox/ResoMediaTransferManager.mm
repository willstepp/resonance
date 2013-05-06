//
//  ResoMediaTransferManager.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/3/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SSZipArchive.h"

#import "ResoMediaTransferManager.h"
#import "ResoMediaTransferQueue.h"
#import "ResoAppDelegate.h"

@interface ResoMediaTransferManager()
{
  NSMutableDictionary * queues;
  ResoAppDelegate * app;
}
@property (nonatomic, readwrite) NSMutableDictionary *  transfers;
@end

@implementation ResoMediaTransferManager
@synthesize transfers;
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
    app = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
    queues = [[NSMutableDictionary alloc] initWithCapacity:4];
    transfers = [[NSMutableDictionary alloc] init];
    
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

-(void)initTransferOfType:(MediaTransfer)mt withIdentifier:(NSString*)uuid;
{
  //1) setup transfer object
  ResoMediaTransfer * rmt = [self setupTransferOfType:mt withIdentifier:uuid];
  
  //2) add self as delegate to be notified of status change
  [rmt addDelegate:self];
  
  //3) add coredata record if necessary (Sound)
  if (mt == SoundTransfer) {
    [app addSoundWithIdentifier:uuid];
    [app setStateforSound:uuid newState:Downloading];
  }
  
  //4) add to public transfers dictionary, keyed under uuid
  [transfers setObject:rmt forKey:uuid];
  
  //5) ensure sound directory exists
  //TODO: extend for other folders
  [app ensureDirectoryExists:[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]]];
  
  //6) enqueue for processing
  [self enqueueWithMediaTransfer:rmt ofType:mt];
}

-(void)enqueueWithMediaTransfer:(ResoMediaTransfer*)rmt ofType:(MediaTransfer)mt
{
  MediaTransferQueue mtq;
  switch (mt) {
    case SoundTransfer:
      mtq = SoundQueue;
      break;
    case MixTransfer:
      mtq = MixQueue;
      break;
    case ThumbnailTransfer:
      mtq = ThumbnailQueue;
      break;
    case PreviewTransfer:
      mtq = PreviewQueue;
      break;
    default:
      return;
  }
  ResoMediaTransferQueue * queue = [queues objectForKey:[NSNumber numberWithInt:mtq]];
  [queue enqueueWithMediaTransfer:rmt];
}

-(ResoMediaTransfer*)setupTransferOfType:(MediaTransfer)mt withIdentifier:(NSString*)uuid
{
  ResoMediaTransfer * rmt = [[ResoMediaTransfer alloc] init];
  rmt.uuid = uuid;
  rmt.transferType = mt;
  
  switch (mt) {
    case SoundTransfer:
    {
      NSString * version = [app iosVersionForDownload];
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/%@.%@", uuid, uuid, version];
      rmti.destinationUrl = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.install", uuid, uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    case MixTransfer:
      break;
    case ThumbnailTransfer:
    {
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/%@.thumb", uuid, uuid];
      rmti.destinationUrl = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.thumb", uuid, uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    case PreviewTransfer:
    {
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/%@.preview", uuid, uuid];
      rmti.destinationUrl = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.preview", uuid, uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    default:
      break;
  }
  
  return rmt;
}

#pragma mark -
#pragma mark ResoMediaTransfer Delegates

-(void) transferFinished:(ResoMediaTransfer*)t
{
  //remove from transfers dictionary
  [transfers removeObjectForKey:t.uuid];
  
  //if sound, unzip files
  if (t.transferType == SoundTransfer) {
    NSString * installFilePath = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/%@.install", t.uuid, t.uuid]] path];
    NSString * destinationPath = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", t.uuid]] path];
    [SSZipArchive unzipFileAtPath:installFilePath toDestination:destinationPath];
    
    [[NSFileManager defaultManager] removeItemAtPath:installFilePath error:nil];
    [app setStateforSound:t.uuid newState:Completed];
  
    //read in metadata from file, populate Sound record
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  }
}

-(void) transferError:(ResoMediaTransfer*)t
{
  [transfers removeObjectForKey:t.uuid];
  [app setStateforSound:t.uuid newState:Failed];
}

@end
