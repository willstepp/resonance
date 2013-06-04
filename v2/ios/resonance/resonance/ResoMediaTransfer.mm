//
//  ResoMediaTransfer.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/2/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ResoAppDelegate.h"
#import "ResoDataManager.h"
#import "ResoMediaTransfer.h"
#import "ResoUrlConnection.h"

@interface ResoMediaTransfer() {
  NSMutableDictionary * media;
}

@property (nonatomic, readwrite) bool transferring;
@property (nonatomic, readwrite) bool finished;
@property (nonatomic, readwrite) long long totalByteCount;
@property (nonatomic, readwrite) long long currentByteCount;
@property (nonatomic, readwrite) bool totalByteCountReceived;

@end

@implementation ResoMediaTransfer
@synthesize uuid, ownerUUID, transferType, totalByteCount, currentByteCount, totalByteCountReceived, transferring, finished, backgroundTaskId;

- (NSMutableArray*)delegates
{
  return delegates;
}

- (void)addDelegate:(id<ResoMediaTransferDelegate>)d
{
  [delegates addObject:d];
}

- (void)removeDelegate:(id<ResoMediaTransferDelegate>)d
{
  [delegates removeObject:d];
}

- (void)addItem:(ResoMediaTransferItem*)rmti
{
  NSMutableDictionary * item;
  ResoUrlConnection * connection;
  long long totalBytes = 0;
  long long currentBytes = 0;
  bool currFinished = false;
  
  if (rmti.transferType == MixTransferUpload) {

    NSData * mixData = [[NSFileManager defaultManager] contentsAtPath:[rmti sourceUrl]];
    NSURLRequest * request = [self createMixUploadRequest:mixData fileName:@"mix.zip"];
    connection = [[ResoUrlConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    NSMutableData * data = [[NSMutableData alloc] init];
    connection.tag = [media count];
    
    item = [[NSMutableDictionary alloc] initWithCapacity:6];
    [item setObject:connection forKey:@"connection"];
    [item setObject:rmti forKey:@"transferItem"];
    [item setObject:data forKey:@"data"];
    [item setObject:[NSNumber numberWithLongLong:totalBytes] forKey:@"totalBytes"];
    [item setObject:[NSNumber numberWithLongLong:currentBytes] forKey:@"currentBytes"];
    [item setObject:[NSNumber numberWithBool:currFinished] forKey:@"finished"];
    
  } else {
    
    NSURL * sourceUrl = [NSURL URLWithString:[rmti sourceUrl]];
    NSURLRequest * request = [NSURLRequest requestWithURL:sourceUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    connection = [[ResoUrlConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    connection.tag = [media count];
    NSMutableData * data = [[NSMutableData alloc] init];
    
    item = [[NSMutableDictionary alloc] initWithCapacity:6];
    [item setObject:connection forKey:@"connection"];
    [item setObject:data forKey:@"data"];
    [item setObject:rmti forKey:@"transferItem"];
    [item setObject:[NSNumber numberWithLongLong:totalBytes] forKey:@"totalBytes"];
    [item setObject:[NSNumber numberWithLongLong:currentBytes] forKey:@"currentBytes"];
    [item setObject:[NSNumber numberWithBool:currFinished] forKey:@"finished"];
    
  }

  [media setObject:item forKey:[NSNumber numberWithInt:connection.tag]];
}

- (id)init {
  self = [super init];
  
  totalByteCountReceived = false;
  totalByteCount = 0;
  currentByteCount = 0;
  delegates = [[NSMutableArray alloc] init];
  media = [[NSMutableDictionary alloc] init];
  
  return self;
}

- (void)start
{
  for(id tag in media) {
    NSMutableDictionary * dict = [media objectForKey:tag];
    ResoUrlConnection * conn = [dict objectForKey:@"connection"];
    NSLog(@"REQUEST URL: %@", [conn.currentRequest.URL absoluteString]);
    NSLog(@"REQUEST METHOD: %@", conn.currentRequest.HTTPMethod);
    [conn start];
    NSLog(@"starting RMT (%@)", tag);
  }
  
  self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    //cancel media transfer here
    NSLog(@"beginBackgroundTaskWithExpirationHandler called()");
  }];
  
  transferring = true;
  [self notifyStarted];
}

- (NSURLRequest *)createMixUploadRequest:(NSData *)mixData fileName:(NSString *)name
{
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
  NSURL * url = [NSURL URLWithString:@"http://resoapp.com/mixes.json"];
  [request setURL:url];
  [request setHTTPMethod:@"POST"];
  
  NSString *boundary = @"0xReS0bOuNdArY";
  NSString *endBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
  
  NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, boundary];
  [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
  
  NSMutableData *tempPostData = [NSMutableData data];
  [tempPostData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  
  //get data from mix uuid
  ResoDataManager * rdm = [ResoDataManager instance];
  NSDictionary * mix = [rdm mixWithIdentifier:self.uuid];
  
  //name
  [tempPostData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"name"] dataUsingEncoding:NSUTF8StringEncoding]];
  [tempPostData appendData:[[mix objectForKey:@"name"] dataUsingEncoding:NSUTF8StringEncoding]];
  [tempPostData appendData:[endBoundary dataUsingEncoding:NSUTF8StringEncoding]];
  
  //sounds
  [tempPostData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"sounds"] dataUsingEncoding:NSUTF8StringEncoding]];
  [tempPostData appendData:[[mix objectForKey:@"sounds"] dataUsingEncoding:NSUTF8StringEncoding]];
  [tempPostData appendData:[endBoundary dataUsingEncoding:NSUTF8StringEncoding]];
  
  //uuid
  [tempPostData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"uuid"] dataUsingEncoding:NSUTF8StringEncoding]];
  [tempPostData appendData:[self.uuid dataUsingEncoding:NSUTF8StringEncoding]];
  [tempPostData appendData:[endBoundary dataUsingEncoding:NSUTF8StringEncoding]];
  
  //attach mix zip file
  [tempPostData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
  [tempPostData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [tempPostData appendData:mixData];
  [tempPostData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

  [request setHTTPBody:tempPostData];
  
  return request;
}

#pragma mark -
#pragma mark NSURLConnection Delegates
- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
  ResoUrlConnection * c = (ResoUrlConnection*)conn;
  NSMutableDictionary * dict = [media objectForKey:[NSNumber numberWithInt:c.tag]];
  ResoMediaTransferItem * rmti = [dict objectForKey:@"transferItem"];
  
  if (rmti.transferType != MixTransferUpload) {
    NSNumber * totalBytes = [dict objectForKey:@"totalBytes"];
    totalBytes = [NSNumber numberWithLongLong:[response expectedContentLength]];
    [dict setObject:totalBytes forKey:@"totalBytes"];
    
    self.totalByteCount += [totalBytes longLongValue];
    
    NSMutableData * data = [dict objectForKey:@"data"];
    [data setLength:0];
    
    if ([self allTotalByteCountsReceived]) {
      totalByteCountReceived = true;
      NSLog(@"ResoMediaTransfer->allTotalByteCountsReceived");
    }
    
    NSLog(@"didReceiveResponse() for connection (%@) Expected Length: %@", [NSNumber numberWithInt:c.tag], totalBytes);
  }
}

- (BOOL)allTotalByteCountsReceived
{
  bool allReceived = true;
  for(id tag in media) {
    NSMutableDictionary * dict = [media objectForKey:tag];
    NSNumber * totalBytes = [dict objectForKey:@"totalBytes"];
    if ([totalBytes longLongValue] <= 0) {
      allReceived = false;
      break;
    }
  }
  return allReceived;
}

- (BOOL)allFinished
{
  bool allFinished = true;
  for(id tag in media) {
    NSMutableDictionary * dict = [media objectForKey:tag];
    NSNumber * f = [dict objectForKey:@"finished"];
    BOOL currFinished = [f boolValue];
    
    if (!currFinished) {
      allFinished = false;
      break;
    }
  }
  return allFinished;
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
  ResoUrlConnection * c = (ResoUrlConnection*)conn;
  NSMutableDictionary * dict = [media objectForKey:[NSNumber numberWithInt:c.tag]];
  ResoMediaTransferItem * rmti = [dict objectForKey:@"transferItem"];
  
  if (rmti.transferType != MixTransferUpload) {
    //update byte counts
    NSNumber * currBytes = [dict objectForKey:@"currentBytes"];
    currBytes = [NSNumber numberWithLongLong:([currBytes longLongValue] + [data length])];
    [dict setObject:currBytes forKey:@"currentBytes"];
    
    self.currentByteCount += [data length];
    
    //write data
    NSMutableData * currData = [dict objectForKey:@"data"];
    [currData appendData:data];
    
    if (totalByteCountReceived) {
      [self notifyProgressUpdated];
    }
    
    NSLog(@"didReceiveData() for connection (%@). Item (%lld of %lld) - Media Transfer (%lld of %lld)", [NSNumber numberWithInt:c.tag], [[dict objectForKey:@"currentBytes"] longLongValue], [[dict objectForKey:@"totalBytes"] longLongValue], self.currentByteCount, self.totalByteCount);
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
  ResoUrlConnection * c = (ResoUrlConnection*)conn;
  NSMutableDictionary * dict = [media objectForKey:[NSNumber numberWithInt:c.tag]];
  ResoMediaTransferItem * rmti = [dict objectForKey:@"transferItem"];
  
  if (rmti.transferType != MixTransferUpload) {
    //write to file
    NSMutableData * currData = [dict objectForKey:@"data"];
    [currData writeToFile:rmti.destinationUrl atomically:YES];
  }

  //set state to finished
  [dict setObject:[NSNumber numberWithBool:YES] forKey:@"finished"];
  
  NSLog(@"Transfer finished for connection (%@): %lld of %lld", [NSNumber numberWithInt:c.tag], currentByteCount, totalByteCount);
  
  if ([self allFinished]) {
    finished = true;
    [self notifyFinished];
    NSLog(@"notifyFinished()");
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
  }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
  ResoUrlConnection * c = (ResoUrlConnection*)conn;
  NSMutableDictionary * dict = [media objectForKey:[NSNumber numberWithInt:c.tag]];
  
  for(id tag in media) {
    NSMutableData * data = [dict objectForKey:@"data"];
    [data setLength:0];
  }
  
  //cancel other transfers
  
  transferring = false;
  [self notifyError];
  
  [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
  
  NSLog(@"Transfer error for connection (%@): %s", [NSNumber numberWithInt:c.tag], [[error localizedDescription] UTF8String]);
}

- (void)connection:(NSURLConnection *)conn didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
  self.totalByteCountReceived = true;
    
  self.totalByteCount = totalBytesExpectedToWrite;
  self.currentByteCount = totalBytesWritten;
  
  if (totalByteCountReceived) {
    [self notifyProgressUpdated];
  }
  
  NSLog(@"didSendBodyData()");
  NSLog(@"bytesWritten: %i", bytesWritten);
  NSLog(@"totalBytesWritten: %i", totalBytesWritten);
  NSLog(@"totalBytesExpectedToWrite: %i", totalBytesExpectedToWrite);
}

#pragma mark delegate notifications

- (void) notifyStarted
{
  for(id<ResoMediaTransferDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(transferStarted:)] ) {
      [delegate performSelector:@selector(transferStarted:) withObject:self];
    }
  }
}

- (void) notifyProgressUpdated
{
  for(id<ResoMediaTransferDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(transferProgressUpdated:)] ) {
      [delegate performSelector:@selector(transferProgressUpdated:) withObject:self];
    }
  }
}

- (void) notifyError
{
  for(id<ResoMediaTransferDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(transferError:)] ) {
      [delegate performSelector:@selector(transferError:) withObject:self];
    }
  }
}

- (void) notifyFinished
{
  for(id<ResoMediaTransferDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(transferFinished:)] ) {
      [delegate performSelector:@selector(transferFinished:) withObject:self];
    }
  }
}
@end
