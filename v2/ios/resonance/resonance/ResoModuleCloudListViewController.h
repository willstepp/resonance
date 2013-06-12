//
//  ResoModuleSoundListViewController.h
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoActionBar.h"
#import "ResoMediaTransferManager.h"

@interface ResoModuleCloudListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ResoMediaTransferManagerDelegate>
@property (nonatomic, retain) UIButton * backButton;
@property (nonatomic, retain) ResoActionBar * soundDetailsBar;
@property (nonatomic, retain) UIButton * previewButton;
@property (nonatomic, retain) UIButton * downloadButton;
@property (nonatomic, retain) UIProgressView * progressBar;
@property (nonatomic, retain) UIButton * deviceButton;
@property (nonatomic, retain) UIButton * cloudButton;

@property (nonatomic, assign) bool refreshView;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

#pragma mark -
#pragma mark ResoMediaTransferManager Delegates
-(void) transferStarted:(ResoMediaTransfer*)t;
-(void) transferProgressUpdated:(ResoMediaTransfer*)t;
-(void) transferFinished:(ResoMediaTransfer*)t;
-(void) transferError:(ResoMediaTransfer*)t;
@end
