//
//  ResoModuleViewController.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/14/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoTypes.h"

@interface ResoModuleViewController : UIViewController
@property (nonatomic, retain) UIButton * backButton;
@property (nonatomic, retain) UIButton * soundLibraryButton;

@property (nonatomic, retain) UIButton * playButton;
@property (nonatomic, retain) UISwitch * reverbSwitch;
@end
