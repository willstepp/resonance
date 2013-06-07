//
//  ResoModuleViewController.h
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoActionBar.h"

@interface ResoModuleViewController : UIViewController
@property (nonatomic, retain) UIButton * playerButton;
@property (nonatomic, retain) ResoActionBar * settingsBar;
@property (nonatomic, retain) ResoActionBar * changeSoundBar;

@property (nonatomic, retain) UIView * propertiesPanel;
@property (nonatomic, retain) UILabel * soundTitleLabel;
@property (nonatomic, retain) UIImageView * soundImageView;
@property (nonatomic, retain) UITextView * descriptionTextView;
@end
