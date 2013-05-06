//
//  ResoMediaTransferViewController.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/6/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoMediaTransfer.h"

@interface ResoMediaTransferViewController : UIViewController <ResoMediaTransferDelegate>
@property (nonatomic, retain) UIButton * backButton;
@property (nonatomic, retain) UIButton * monitorButton;

#pragma mark -
#pragma mark ResoMediaTransfer Delegates
-(void) transferStarted:(ResoMediaTransfer*)t;
-(void) transferProgressUpdated:(ResoMediaTransfer*)t;
-(void) transferFinished:(ResoMediaTransfer*)t;
-(void) transferError:(ResoMediaTransfer*)t;
@end
