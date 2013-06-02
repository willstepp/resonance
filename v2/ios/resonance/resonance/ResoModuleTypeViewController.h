//
//  ResoModuleTypeViewController.h
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoActionBar.h"

@interface ResoModuleTypeViewController : UIViewController
@property (nonatomic, retain) UIButton * backButton;
@property (nonatomic, retain) ResoActionBar * soundLibraryBar;
@property (nonatomic, retain) ResoActionBar * toneGeneratorBar;
@end
