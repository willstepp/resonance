//
//  ResoMixListViewController.h
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoMediaTransferManager.h"

@interface ResoMixDeviceListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ResoMediaTransferManagerDelegate>
@property (nonatomic, retain) UIButton * backButton;

@property (nonatomic, retain) UIButton * removeButton;
@property (nonatomic, retain) UIButton * shareButton;
@property (nonatomic, retain) UIButton * loadButton;

@property (nonatomic, assign) bool refreshView;

@property (nonatomic, retain) UIButton * deviceButton;
@property (nonatomic, retain) UIButton * cloudButton;

@property (nonatomic, retain) UIProgressView * progressBar;

#pragma mark -
#pragma mark ResoMediaTransferManager Delegates
-(void) transferStarted:(ResoMediaTransfer*)t;
-(void) transferProgressUpdated:(ResoMediaTransfer*)t;
-(void) transferFinished:(ResoMediaTransfer*)t;
-(void) transferError:(ResoMediaTransfer*)t;
@end
