//
//  ResoModuleDeviceListViewController.h
//  resonance
//
//  Created by Daniel Stepp on 6/6/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoMediaTransferManager.h"

@interface ResoModuleDeviceListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ResoMediaTransferManagerDelegate>
@property (nonatomic, retain) UIButton * backButton;

@property (nonatomic, retain) UIButton * removeButton;
@property (nonatomic, retain) UIButton * redownloadButton;
@property (nonatomic, retain) UIButton * loadButton;
@property (nonatomic, retain) UIButton * deviceButton;
@property (nonatomic, retain) UIButton * cloudButton;

@property (nonatomic, assign) bool refreshView;

@property (nonatomic, retain) UIProgressView * progressBar;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

#pragma mark -
#pragma mark ResoMediaTransferManager Delegates
-(void) transferStarted:(ResoMediaTransfer*)t;
-(void) transferProgressUpdated:(ResoMediaTransfer*)t;
-(void) transferFinished:(ResoMediaTransfer*)t;
-(void) transferError:(ResoMediaTransfer*)t;
@end
