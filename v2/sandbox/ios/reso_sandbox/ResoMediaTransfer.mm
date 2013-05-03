//
//  ResoMediaTransfer.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/2/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoMediaTransfer.h"
#import "ResoUrlConnection.h"

@interface ResoMediaTransfer() {
  NSMutableDictionary * media;
}

@property (nonatomic, readwrite) bool transferring;
@property (nonatomic, readwrite) bool finished;
@property (nonatomic, readwrite) long long totalByteCount;
@property (nonatomic, readwrite) long long currentByteCount;
@property (nonatomic, readwrite) long long totalByteCountReceived;

@end

@implementation ResoMediaTransfer
@synthesize uuid, transferType, totalByteCount, currentByteCount, totalByteCountReceived, transferring, finished;

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
  NSURL * sourceUrl = [NSURL URLWithString:[rmti sourceUrl]];
  NSURLRequest * request = [NSURLRequest requestWithURL:sourceUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
  ResoUrlConnection * connection = [[ResoUrlConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
  connection.tag = [media count];
  NSMutableData * data = [[NSMutableData alloc] init];
  
  long long totalBytes = 0;
  long long currentBytes = 0;
  
  bool currFinished = false;
  
  NSMutableDictionary * item = [[NSMutableDictionary alloc] initWithCapacity:6];
  [item setObject:connection forKey:@"connection"];
  [item setObject:data forKey:@"data"];
  [item setObject:rmti forKey:@"transferItem"];
  [item setObject:[NSNumber numberWithLongLong:totalBytes] forKey:@"totalBytes"];
  [item setObject:[NSNumber numberWithLongLong:currentBytes] forKey:@"currentBytes"];
  [item setObject:[NSNumber numberWithBool:currFinished] forKey:@"finished"];
  
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
    [conn start];
    NSLog(@"start() for connection (%@)", [NSNumber numberWithInt:conn.tag]);
  }
  transferring = true;
  [self notifyStarted];
}

#pragma mark -
#pragma mark NSURLConnection Delegates
- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
  ResoUrlConnection * c = (ResoUrlConnection*)conn;
  
  NSMutableDictionary * dict = [media objectForKey:[NSNumber numberWithInt:c.tag]];
  NSNumber * totalBytes = [dict objectForKey:@"totalBytes"];
  totalBytes = [NSNumber numberWithLongLong:[response expectedContentLength]];
  [dict setObject:totalBytes forKey:@"totalBytes"];
  
  self.totalByteCount += [totalBytes longLongValue];
  
  NSMutableData * data = [dict objectForKey:@"data"];
  [data setLength:0];
  
  if ([self allTotalByteCountsReceived]) {
    totalByteCountReceived = true;
    NSLog(@"ALL BYTE COUNTS RECEIVED");
  }
  
  NSLog(@"didReceiveResponse() for connection (%@) Expected Length: %@", [NSNumber numberWithInt:c.tag], totalBytes);
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

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
  ResoUrlConnection * c = (ResoUrlConnection*)conn;
  
  //write to file
  NSMutableDictionary * dict = [media objectForKey:[NSNumber numberWithInt:c.tag]];
  NSMutableData * currData = [dict objectForKey:@"data"];
  ResoMediaTransferItem * rmti = [dict objectForKey:@"transferItem"];
  [currData writeToFile:rmti.destinationUrl atomically:YES];
  
  //set state to finished
  [dict setObject:[NSNumber numberWithBool:YES] forKey:@"finished"];
  
  if ([self allFinished]) {
    finished = true;
    [self notifyFinished];
    NSLog(@"ALL FINISHED");
  }
  
	NSLog(@"Transfer finished for connection (%@): %lld of %lld", [NSNumber numberWithInt:c.tag], currentByteCount, totalByteCount);
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
  ResoUrlConnection * c = (ResoUrlConnection*)conn;
  
  for(id tag in media) {
    NSMutableDictionary * dict = [media objectForKey:tag];
    NSMutableData * data = [dict objectForKey:@"data"];
    [data setLength:0];
  }
  
  //cancel other transfers
  
  transferring = false;
  [self notifyError];
  
  NSLog(@"Transfer error for connection (%@): %s", [NSNumber numberWithInt:c.tag], [[error localizedDescription] UTF8String]);
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
