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
#import "ResoDataManager.h"
#import "ResoFileManager.h"

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
    
    delegates = [[NSMutableArray alloc] init];
    
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

- (NSMutableArray*)delegates
{
  return delegates;
}

- (void)addDelegate:(id<ResoMediaTransferManagerDelegate>)d
{
  [delegates addObject:d];
}

- (void)removeDelegate:(id<ResoMediaTransferManagerDelegate>)d
{
  [delegates removeObject:d];
}

-(void)initTransferOfType:(MediaTransfer)mt withIdentifier:(NSString*)uuid withObject:(id)object;
{
  NSString * owner = nil;
  ResoDataManager * rdm = [ResoDataManager instance];
  
  //1) sound transfer prep
  if (mt == SoundTransferDownload) {
    if (object != nil) {
      owner = (NSString*)object;
    }
    [rdm addSoundWithIdentifier:uuid];
    [rdm setStateforSound:uuid newState:Transferring];
    [ResoFileManager ensureDirectoryExists:[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]]];
  }
  
  //2) thumbnail transfer prep
  if (mt == SoundThumbnailTransfer) {
    [ResoFileManager ensureDirectoryExists:[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]]];
  }
  if (mt == MixThumbnailTransfer) {
    [ResoFileManager ensureDirectoryExists:[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@", uuid]]];
  }
  
  //3) preview transfer prep
  if (mt == SoundPreviewTransfer) {
    [ResoFileManager ensureDirectoryExists:[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]]];
  }
  if (mt == MixPreviewTransfer) {
    [ResoFileManager ensureDirectoryExists:[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@", uuid]]];
  }
  
  //4) mix transfer prep
  if (mt == MixTransferUpload) {

    //generate mix zip file for transfer
    NSString * mixZipPath = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/%@.zip", uuid, uuid]] path];
    
    NSString * mix = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix", uuid]] path];
    NSString * mixJson = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix.json", uuid]] path];
    [[NSFileManager defaultManager] copyItemAtPath:mix toPath:mixJson error:nil];
    
    NSString * preview = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview", uuid]] path];
    NSString * previewWav = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview.wav", uuid]] path];
    [[NSFileManager defaultManager] copyItemAtPath:preview toPath:previewWav error:nil];

    NSString * thumb = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb", uuid]] path];
    NSString * thumbJpg = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb.jpg", uuid]] path];
    [[NSFileManager defaultManager] copyItemAtPath:thumb toPath:thumbJpg error:nil];
    
    NSArray * mixFiles = [[NSArray alloc] initWithObjects:mixJson, previewWav, thumbJpg, nil];
    
    [SSZipArchive createZipFileAtPath:mixZipPath withFilesAtPaths:mixFiles];

    //set state of mix to transferring, set shared to true
    [rdm setStateforMix:uuid newState:Transferring];
    [rdm setSharedforMix:uuid shared:YES];
  }
  if (mt == MixTransferDownload) {
    owner = uuid;
    NSDictionary * mix = (NSDictionary*)object;
    NSString * name = [mix objectForKey:@"name"];
    NSArray * soundsList = [[mix objectForKey:@"sounds"] componentsSeparatedByString:@";"];
    
    [rdm addMixWithId:uuid name:name state:Transferring sounds:soundsList shared:YES];
    [ResoFileManager ensureDirectoryExists:[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@", uuid]]];
    
    //download any missing sounds as well
    for (NSString * sound in soundsList) {
      if (![rdm soundExists:sound withContext:[rdm managedObjectContext]]) {
        [self initTransferOfType:SoundTransferDownload withIdentifier:sound withObject:uuid];
      }
    }
  }
  
  //3) setup transfer object
  ResoMediaTransfer * rmt = [self setupTransferOfType:mt withIdentifier:uuid withOwner:owner];
  
  //4) add self as delegate to be notified of status change as well as argument delegate
  [rmt addDelegate:self];

  //5) add to public transfers dictionary, keyed under uuid
  [transfers setObject:rmt forKey:uuid];
  
  //6) enqueue for processing
  [self enqueueWithMediaTransfer:rmt ofType:mt];
}

-(void)enqueueWithMediaTransfer:(ResoMediaTransfer*)rmt ofType:(MediaTransfer)mt
{
  MediaTransferQueue mtq;
  switch (mt) {
    case SoundTransferDownload:
      mtq = SoundQueue;
      break;
    case MixTransferUpload:
      mtq = MixQueue;
      break;
    case MixTransferDownload:
      mtq = MixQueue;
      break;
    case SoundThumbnailTransfer:
      mtq = ThumbnailQueue;
      break;
    case MixThumbnailTransfer:
      mtq = ThumbnailQueue;
      break;
    case SoundPreviewTransfer:
      mtq = PreviewQueue;
      break;
    case MixPreviewTransfer:
      mtq = PreviewQueue;
      break;
    default:
      return;
  }
  ResoMediaTransferQueue * queue = [queues objectForKey:[NSNumber numberWithInt:mtq]];
  [queue enqueueWithMediaTransfer:rmt];
}

-(ResoMediaTransfer*)setupTransferOfType:(MediaTransfer)mt withIdentifier:(NSString*)uuid withOwner:(NSString*)owner
{
  ResoMediaTransfer * rmt = [[ResoMediaTransfer alloc] init];
  rmt.uuid = uuid;
  rmt.ownerUUID = owner;
  rmt.transferType = mt;
  
  switch (mt) {
    case SoundTransferDownload:
    {
      NSString * version = [app iosVersionForDownload];
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/%@", uuid, version];
      rmti.destinationUrl = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/install", uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    case MixTransferDownload:
    {
      //mix
      ResoMediaTransferItem * mixItem = [[ResoMediaTransferItem alloc] init];
      mixItem.transferType = mt;
      mixItem.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/mixes/%@/mix", uuid];
      mixItem.destinationUrl = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix", uuid]] path];
      [rmt addItem:mixItem];
      
      //preview
      ResoMediaTransferItem * previewItem = [[ResoMediaTransferItem alloc] init];
      previewItem.transferType = mt;
      previewItem.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/mixes/%@/preview", uuid];
      previewItem.destinationUrl = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview", uuid]] path];
      [rmt addItem:previewItem];

      //thumb
      ResoMediaTransferItem * thumbItem = [[ResoMediaTransferItem alloc] init];
      thumbItem.transferType = mt;
      thumbItem.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/mixes/%@/thumb", uuid];
      thumbItem.destinationUrl = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb", uuid]] path];
      [rmt addItem:thumbItem];
      
      break;
    }
    case MixTransferUpload:
    {
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.destinationUrl = @"http://resoapp.com/mixes.json";
      rmti.sourceUrl = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/%@.zip", uuid, uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    case SoundThumbnailTransfer:
    {
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/thumb", uuid];
      rmti.destinationUrl = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/thumb", uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    case MixThumbnailTransfer:
    {
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/mixes/%@/thumb", uuid];
      rmti.destinationUrl = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb", uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    case SoundPreviewTransfer:
    {
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/preview", uuid];
      rmti.destinationUrl = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/preview", uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    case MixPreviewTransfer:
    {
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/mixes/%@/preview", uuid];
      rmti.destinationUrl = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview", uuid]] path];
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

-(void) transferStarted:(ResoMediaTransfer*)t
{
  [self notifyStartedWithTransfer:t];
}

-(void) transferProgressUpdated:(ResoMediaTransfer*)t
{
  [self notifyProgressUpdatedWithTransfer:t];
}

-(void) transferFinished:(ResoMediaTransfer*)t
{
  ResoDataManager * rdm = [ResoDataManager instance];
  
  //remove from transfers dictionary
  [self.transfers removeObjectForKey:t.uuid];
  
  if (t.transferType == SoundTransferDownload) {
    
    NSString * installFilePath = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/install", t.uuid]] path];
    NSString * destinationPath = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", t.uuid]] path];
    [SSZipArchive unzipFileAtPath:installFilePath toDestination:destinationPath];
    
    [[NSFileManager defaultManager] removeItemAtPath:installFilePath error:nil];
    
    [self loadSoundMetadata:t.uuid];
    [rdm setStateforSound:t.uuid newState:Completed];
    if (t.ownerUUID != nil) {
      bool completed = [self mixCompleted:t.ownerUUID];
      if (completed) {
        [rdm setStateforMix:t.ownerUUID newState:Completed];
        [self notifyMixFinishedWithId:t.ownerUUID];
      }
    }
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
  } else if (t.transferType == MixTransferDownload) {
    
    [rdm setStateforMix:t.uuid newState:CompleteButWaiting];
    bool completed = [self mixCompleted:t.uuid];
    if (completed) {
      [rdm setStateforMix:t.uuid newState:Completed];
      [self notifyMixFinishedWithId:t.uuid];
      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
  } else if (t.transferType == MixTransferUpload) {
    
    NSString * mixZipPath = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/%@.zip", t.uuid, t.uuid]] path];
    [[NSFileManager defaultManager] removeItemAtPath:mixZipPath error:nil];

    NSString * mixJson = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix.json", t.uuid]] path];
    [[NSFileManager defaultManager] removeItemAtPath:mixJson error:nil];
    
    NSString * previewWav = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview.wav", t.uuid]] path];
    [[NSFileManager defaultManager] removeItemAtPath:previewWav error:nil];
    
    NSString * thumbJpg = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb.jpg", t.uuid]] path];
    [[NSFileManager defaultManager] removeItemAtPath:thumbJpg error:nil];

    [rdm setStateforMix:t.uuid newState:Completed];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
  }
  [self notifyFinishedWithTransfer:t];
}

-(bool)mixCompleted:(NSString*)uuid
{
  bool completed = true;
  ResoDataManager * rdm = [ResoDataManager instance];
  
  NSDictionary * mix = [rdm mixWithIdentifier:uuid];
  TransferState mixStatus = (TransferState)[[mix objectForKey:@"state"] intValue];
  completed = (mixStatus == CompleteButWaiting);
  if (!completed) {
    return completed;
  }
  NSArray * sounds = [[mix objectForKey:@"sounds"] componentsSeparatedByString:@";"];
  for (NSString * sound in sounds) {
    NSDictionary * s = [rdm soundWithIdentifier:sound];
    TransferState soundStatus = (TransferState)[[s objectForKey:@"state"] intValue];
    completed = (soundStatus == Completed);
    if (!completed)
      break;
  }
  
  return completed;
}

-(void)loadSoundMetadata:(NSString*)uuid
{
  ResoDataManager * rdm = [ResoDataManager instance];
  
  //1) get path of metadata file
  NSString * metadataFilePath = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/meta", uuid]] path];

  //2) read json
  NSData * metadata = [NSData dataWithContentsOfFile:metadataFilePath];
  
  //3) parse json
  NSDictionary * sound = [NSJSONSerialization
                          JSONObjectWithData:metadata
                          options:kNilOptions
                          error:nil];
  //4) update sound data
  [rdm setSoundFromData:sound];
}

-(void) transferError:(ResoMediaTransfer*)t
{
  ResoDataManager * rdm = [ResoDataManager instance];
  
  [self.transfers removeObjectForKey:t.uuid];
  if (t.transferType == SoundTransferDownload) {
    [rdm setStateforSound:t.uuid newState:Failed];
  }
  if (t.transferType == MixTransferUpload || t.transferType == MixTransferDownload) {
    [rdm setStateforMix:t.uuid newState:Failed];
  }
  [self notifyErrorWithTransfer:t];
}

#pragma mark manager delegate notifications

- (void) notifyStartedWithTransfer:(ResoMediaTransfer*)t
{
  for(id<ResoMediaTransferManagerDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(transferStarted:)] ) {
      [delegate performSelector:@selector(transferStarted:) withObject:t];
    }
  }
}

- (void) notifyProgressUpdatedWithTransfer:(ResoMediaTransfer*)t
{
  for(id<ResoMediaTransferManagerDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(transferProgressUpdated:)] ) {
      [delegate performSelector:@selector(transferProgressUpdated:) withObject:t];
    }
  }
}

- (void) notifyErrorWithTransfer:(ResoMediaTransfer*)t
{
  for(id<ResoMediaTransferManagerDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(transferError:)] ) {
      [delegate performSelector:@selector(transferError:) withObject:t];
    }
  }
}

- (void) notifyFinishedWithTransfer:(ResoMediaTransfer*)t
{
  for(id<ResoMediaTransferManagerDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(transferFinished:)] ) {
      [delegate performSelector:@selector(transferFinished:) withObject:t];
    }
  }
}

- (void) notifyMixFinishedWithId:(NSString*)uuid
{
  for(id<ResoMediaTransferManagerDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(mixFinished:)] ) {
      [delegate performSelector:@selector(mixFinished:) withObject:uuid];
    }
  }
}

@end
