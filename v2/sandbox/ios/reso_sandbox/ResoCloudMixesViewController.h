//
//  ResoCloudMixesViewController.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/17/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoMediaTransfer.h"

@interface ResoCloudMixesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ResoMediaTransferDelegate>
@property (nonatomic, retain) UIButton * backButton;
@property (nonatomic, retain) UIButton * previewButton;
@property (nonatomic, retain) UIButton * downloadButton;
@property (nonatomic, retain) UIProgressView * progressBar;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

#pragma mark -
#pragma mark ResoMediaTransfer Delegates
-(void) transferStarted:(ResoMediaTransfer*)t;
-(void) transferProgressUpdated:(ResoMediaTransfer*)t;
-(void) transferFinished:(ResoMediaTransfer*)t;
-(void) transferError:(ResoMediaTransfer*)t;
@end
