//
//  ResoMediaTransfer.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/2/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoMediaTransfer.h"

@interface ResoMediaTransfer() {
  NSURLConnection * connection;
  NSURLRequest * request;
  NSMutableData * payload;
  
  NSMutableDictionary * media;
  bool totalByteCountReceived;
  long totalByteCount;
  long currentByteCount;
  
  //set type: sound_download, thumb_download, preview_download, mix_download, mix_upload
  //use an nsurlconnection+tag category to set an int tag on the nsurlconnection, then use
  //the tag to key on the dictionary. in the dictionary is totalbytes, bytes received,
  //mutable data, filepath to be written to
  //when responseReceived is called, we set the totalbytes, then do a scan to see if
  //all the others have totalbytes values, if so, set an instance boolean to true
  //now when bytes have been received, we can check this boolean, if true, send the
  //total number of bytes along with the current bytes as a delegate call
  //when finished, iterate through dictionary and write data to file paths, publish
  //finished delegate -- write data directly to disk
}
@end

@implementation ResoMediaTransfer
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
