//
//  ResoFileTransferManager.m
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/2/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoFileTransfer.h"

@interface ResoFileTransfer() {
  NSURLConnection * connection;
  NSURLRequest * request;
  NSMutableData * payload;
}
@end

@implementation ResoFileTransfer
@synthesize uuid;

- (id)initWithUrl:(NSString*)url
{
  self = [super init];
  
  NSURL * downloadUrl = [NSURL URLWithString:url];
  request = [NSURLRequest requestWithURL:downloadUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
  
  payload = [[NSMutableData alloc] init];
  
  return self;
}

- (id)init {
  self = [super init];
  
  
  
  return self;
}

- (void)start
{
  [connection start];
}

#pragma mark -
#pragma mark NSURLConnection Delegates
- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"Recieved response with expected length: %ll", [response expectedContentLength]);
  
	[payload setLength:0];
}
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
	NSLog(@"Recieving data. Incoming Size: %i  Total Size: %i", [data length], [payload length]);
  
	[payload appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{  
	NSLog(@"Connection finished: %@", conn);
}
- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
  NSLog(@"error: %s", [[error localizedDescription] UTF8String]);
	[payload setLength:0];
}
@end
