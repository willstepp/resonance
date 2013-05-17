//
//  ResoDeviceMixesViewController.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/17/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoMediaTransfer.h"

@interface ResoDeviceMixesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ResoMediaTransferDelegate>
@property (nonatomic, retain) UIButton * backButton;

@property (nonatomic, retain) UIButton * removeButton;
@property (nonatomic, retain) UIButton * shareButton;
@property (nonatomic, retain) UIButton * loadButton;

@property (nonatomic, retain) UIProgressView * progressBar;

#pragma mark -
#pragma mark ResoMediaTransfer Delegates
-(void) transferStarted:(ResoMediaTransfer*)t;
-(void) transferProgressUpdated:(ResoMediaTransfer*)t;
-(void) transferFinished:(ResoMediaTransfer*)t;
-(void) transferError:(ResoMediaTransfer*)t;
@end
