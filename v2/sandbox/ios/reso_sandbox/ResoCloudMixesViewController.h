//
//  ResoCloudMixesViewController.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/17/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoMediaTransferManager.h"

@interface ResoCloudMixesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ResoMediaTransferManagerDelegate>
@property (nonatomic, retain) UIButton * backButton;
@property (nonatomic, retain) UIButton * previewButton;
@property (nonatomic, retain) UIButton * downloadButton;
@property (nonatomic, retain) UIProgressView * progressBar;

#pragma mark -
#pragma mark ResoMediaTransfer Delegates
-(void) transferStarted:(ResoMediaTransfer*)t;
-(void) transferProgressUpdated:(ResoMediaTransfer*)t;
-(void) transferFinished:(ResoMediaTransfer*)t;
-(void) mixFinished:(NSString *)uuid;
-(void) transferError:(ResoMediaTransfer*)t;
@end
