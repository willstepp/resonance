//
//  ResoMediaTransfer.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/2/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResoMediaTransferItem.h"

@class ResoMediaTransfer;

@protocol ResoMediaTransferDelegate <NSObject>

-(void) transferStarted:(ResoMediaTransfer*)t;
-(void) transferProgressUpdated:(ResoMediaTransfer*)t;
-(void) transferFinished:(ResoMediaTransfer*)t;
-(void) transferError:(ResoMediaTransfer*)t;

@end

@interface ResoMediaTransfer : NSObject {
  id delegate;
}
  - (id<ResoMediaTransferDelegate>)delegate;
  - (void)setDelegate:(id<ResoMediaTransferDelegate>)newDelegate;

  @property (nonatomic, readwrite) NSString * uuid;

  @property (readonly) bool transferring;
  @property (readonly) bool finished;
  @property (readonly) long long totalByteCount;
  @property (readonly) long long currentByteCount;
  @property (readonly) long long totalByteCountReceived;

  - (void)addItem:(ResoMediaTransferItem*)rmti;
  - (void)start;

  #pragma mark -
  #pragma mark NSURLConnection Delegates
  - (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response;
  - (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data;
  - (void)connectionDidFinishLoading:(NSURLConnection *)conn;
  - (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error;
@end
