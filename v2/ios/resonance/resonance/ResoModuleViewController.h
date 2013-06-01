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
@property (nonatomic, retain) UIButton * loadSoundButton;
@property (nonatomic, retain) ResoActionBar * settingsBar;
@property (nonatomic, retain) ResoActionBar * changeSoundBar;
@end
