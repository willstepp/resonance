//
//  ResoMediaTransfer.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/2/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

//this class is meant to be instantiated and set with a uuid.
//It instantiates an NSUrlConnection with the url and download / upload
//and publishes events when it has a progress update / error / finished
//needs to have an associated protocol which publishes upon progress and finished and error

@interface ResoMediaTransfer : NSObject
  @property (nonatomic,assign) NSString * uuid;

  - (id)initWithUrl:(NSString*)url;
  - (void)start;

  #pragma mark -
  #pragma mark NSURLConnection Delegates
  - (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response;
  - (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data;
  - (void)connectionDidFinishLoading:(NSURLConnection *)conn;
  - (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error;
@end
