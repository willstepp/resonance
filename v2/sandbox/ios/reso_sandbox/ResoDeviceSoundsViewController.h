//
//  ResoDeviceSoundsViewController.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 4/29/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoMediaTransferManager.h"

@interface ResoDeviceSoundsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ResoMediaTransferManagerDelegate>
@property (nonatomic, retain) UIButton * backButton;

@property (nonatomic, retain) UIButton * removeButton;
@property (nonatomic, retain) UIButton * redownloadButton;
@property (nonatomic, retain) UIButton * loadButton;

@property (nonatomic, retain) UIProgressView * progressBar;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

#pragma mark -
#pragma mark ResoMediaTransferManager Delegates
-(void) transferStarted:(ResoMediaTransfer*)t;
-(void) transferProgressUpdated:(ResoMediaTransfer*)t;
-(void) transferFinished:(ResoMediaTransfer*)t;
-(void) transferError:(ResoMediaTransfer*)t;
@end
