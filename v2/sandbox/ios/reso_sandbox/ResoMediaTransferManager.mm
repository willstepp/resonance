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
  //1) sound transfer prep
  if (mt == SoundTransferDownload) {
    [app addSoundWithIdentifier:uuid];
    [app setStateforSound:uuid newState:Transferring];
    [app ensureDirectoryExists:[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]]];
  }
  
  //2) thumbnail transfer prep
  if (mt == SoundThumbnailTransfer) {
    [app ensureDirectoryExists:[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]]];
  }
  if (mt == MixThumbnailTransfer) {
    [app ensureDirectoryExists:[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@", uuid]]];
  }
  
  //3) preview transfer prep
  if (mt == SoundPreviewTransfer) {
    [app ensureDirectoryExists:[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", uuid]]];
  }
  if (mt == MixPreviewTransfer) {
    [app ensureDirectoryExists:[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@", uuid]]];
  }
  
  //4) mix transfer prep
  if (mt == MixTransferUpload) {

    //generate mix zip file for transfer
    NSString * mixZipPath = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/%@.zip", uuid, uuid]] path];
    
    NSString * mix = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix", uuid]] path];
    NSString * mixJson = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix.json", uuid]] path];
    [[NSFileManager defaultManager] copyItemAtPath:mix toPath:mixJson error:nil];
    
    NSString * preview = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview", uuid]] path];
    NSString * previewWav = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview.wav", uuid]] path];
    [[NSFileManager defaultManager] copyItemAtPath:preview toPath:previewWav error:nil];

    NSString * thumb = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb", uuid]] path];
    NSString * thumbJpg = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb.jpg", uuid]] path];
    [[NSFileManager defaultManager] copyItemAtPath:thumb toPath:thumbJpg error:nil];
    
    NSArray * mixFiles = [[NSArray alloc] initWithObjects:mixJson, previewWav, thumbJpg, nil];
    
    [SSZipArchive createZipFileAtPath:mixZipPath withFilesAtPaths:mixFiles];

    //set state of mix to transferring, set shared to true
    [app setStateforMix:uuid newState:Transferring];
    [app setSharedforMix:uuid shared:YES];
  }
  if (mt == MixTransferDownload) {
    [app addMixWithId:uuid name:@"" state:Transferring sounds:nil];
    [app ensureDirectoryExists:[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@", uuid]]];
  }
  
  //3) setup transfer object
  ResoMediaTransfer * rmt = [self setupTransferOfType:mt withIdentifier:uuid];
  
  //4) add self as delegate to be notified of status change
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

-(ResoMediaTransfer*)setupTransferOfType:(MediaTransfer)mt withIdentifier:(NSString*)uuid
{
  ResoMediaTransfer * rmt = [[ResoMediaTransfer alloc] init];
  rmt.uuid = uuid;
  rmt.transferType = mt;
  
  switch (mt) {
    case SoundTransferDownload:
    {
      NSString * version = [app iosVersionForDownload];
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/%@", uuid, version];
      rmti.destinationUrl = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/install", uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    case MixTransferDownload:
    {
      //mix
      ResoMediaTransferItem * mixItem = [[ResoMediaTransferItem alloc] init];
      mixItem.transferType = mt;
      mixItem.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/mixes/%@/mix", uuid];
      mixItem.destinationUrl = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix", uuid]] path];
      [rmt addItem:mixItem];
      
      //preview
      ResoMediaTransferItem * previewItem = [[ResoMediaTransferItem alloc] init];
      previewItem.transferType = mt;
      previewItem.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/mixes/%@/preview", uuid];
      previewItem.destinationUrl = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview", uuid]] path];
      [rmt addItem:previewItem];

      //thumb
      ResoMediaTransferItem * thumbItem = [[ResoMediaTransferItem alloc] init];
      thumbItem.transferType = mt;
      thumbItem.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/mixes/%@/thumb", uuid];
      thumbItem.destinationUrl = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb", uuid]] path];
      [rmt addItem:thumbItem];
      
      break;
    }
    case MixTransferUpload:
    {
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.destinationUrl = @"http://resoapp.com/mixes.json";
      rmti.sourceUrl = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/%@.zip", uuid, uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    case SoundThumbnailTransfer:
    {
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/thumb", uuid];
      rmti.destinationUrl = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/thumb", uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    case MixThumbnailTransfer:
    {
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/mixes/%@/thumb", uuid];
      rmti.destinationUrl = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb", uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    case SoundPreviewTransfer:
    {
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/sounds/%@/preview", uuid];
      rmti.destinationUrl = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/preview", uuid]] path];
      [rmt addItem:rmti];
      break;
    }
    case MixPreviewTransfer:
    {
      ResoMediaTransferItem * rmti = [[ResoMediaTransferItem alloc] init];
      rmti.transferType = mt;
      rmti.sourceUrl = [NSString stringWithFormat:@"https://s3.amazonaws.com/resoapp/mixes/%@/preview", uuid];
      rmti.destinationUrl = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview", uuid]] path];
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
  if (t.transferType == SoundTransferDownload) {
    
    NSString * installFilePath = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/install", t.uuid]] path];
    NSString * destinationPath = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@", t.uuid]] path];
    [SSZipArchive unzipFileAtPath:installFilePath toDestination:destinationPath];
    
    [[NSFileManager defaultManager] removeItemAtPath:installFilePath error:nil];
    
    [self loadSoundMetadata:t.uuid];
    [app setStateforSound:t.uuid newState:Completed];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  }
  
  //if mix download, unzip files
  if (t.transferType == MixTransferDownload) {
    [self loadMixMetadata:t.uuid];
    [app setStateforMix:t.uuid newState:Completed];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  }
  
  //if mix, remove transfer files, update state
  if (t.transferType == MixTransferUpload) {
    
    NSString * mixZipPath = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/%@.zip", t.uuid, t.uuid]] path];
    [[NSFileManager defaultManager] removeItemAtPath:mixZipPath error:nil];

    NSString * mixJson = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix.json", t.uuid]] path];
    [[NSFileManager defaultManager] removeItemAtPath:mixJson error:nil];
    
    NSString * previewWav = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/preview.wav", t.uuid]] path];
    [[NSFileManager defaultManager] removeItemAtPath:previewWav error:nil];
    
    NSString * thumbJpg = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/thumb.jpg", t.uuid]] path];
    [[NSFileManager defaultManager] removeItemAtPath:thumbJpg error:nil];

    [app setStateforMix:t.uuid newState:Completed];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  }
}

-(void)loadMixMetadata:(NSString*)uuid
{
  //1) get path of mix file
  NSString * mixFilePath = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"mixes/%@/mix", uuid]] path];
  
  //2) read json
  NSData * mixFile = [NSData dataWithContentsOfFile:mixFilePath];
  
  //3) parse json
  NSDictionary * mix = [NSJSONSerialization
                        JSONObjectWithData:mixFile
                        options:kNilOptions
                        error:nil];
  //4) update mix data
  [app setMixFromData:mix];
}

-(void)loadSoundMetadata:(NSString*)uuid
{
  //1) get path of metadata file
  NSString * metadataFilePath = [[app resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/meta", uuid]] path];

  //2) read json
  NSData * metadata = [NSData dataWithContentsOfFile:metadataFilePath];
  
  //3) parse json
  NSDictionary * sound = [NSJSONSerialization
                          JSONObjectWithData:metadata
                          options:kNilOptions
                          error:nil];
  //4) update sound data
  [app setSoundFromData:sound];
}

-(void) transferError:(ResoMediaTransfer*)t
{
  [transfers removeObjectForKey:t.uuid];
  if (t.transferType == SoundTransferDownload) {
    [app setStateforSound:t.uuid newState:Failed];
  }
  if (t.transferType == MixTransferUpload || t.transferType == MixTransferDownload) {
    [app setStateforMix:t.uuid newState:Failed];
  }
}

@end
