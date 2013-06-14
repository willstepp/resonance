//
//  ResoModuleSoundDetailsViewController.h
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoActionBar.h"
#import "ResoAppDelegate.h"
#import "ResoSlider.h"
#import "ResoMediaTransferManager.h"

@interface ResoModuleSoundDetailsViewController : UIViewController <ResoMediaTransferManagerDelegate>

@property (nonatomic, retain) UIButton * backButton;

@property (nonatomic, retain) NSMutableDictionary * soundDetails;
@property (nonatomic, assign) bool downloaded;

@property (nonatomic, retain) UIView * viewPanel;

@property (nonatomic, retain) UIView * titlePanel;
@property (nonatomic, retain) UILabel * soundTitleLabel;
@property (nonatomic, retain) UIImageView * soundImageView;

@property (nonatomic, retain) UIView * devicePanel;
@property (nonatomic, retain) UIButton * devicePreviewButton;
@property (nonatomic, retain) UIButton * removeButton;
@property (nonatomic, retain) UITextView * deviceDescriptionTextView;
@property (nonatomic, retain) UIButton * loadButton;
@property (nonatomic, retain) UIButton * returnButton;

@property (nonatomic, retain) UIView * storePanel;
@property (nonatomic, retain) ResoSlider * downloadProgress;
@property (nonatomic, retain) UITextView * storeDescriptionTextView;
@property (nonatomic, retain) UIButton * storePreviewButton;
@property (nonatomic, retain) UIButton * downloadButton;

#pragma mark -
#pragma mark ResoMediaTransferManager Delegates
-(void) transferStarted:(ResoMediaTransfer*)t;
-(void) transferProgressUpdated:(ResoMediaTransfer*)t;
-(void) transferFinished:(ResoMediaTransfer*)t;
-(void) transferError:(ResoMediaTransfer*)t;
@end
