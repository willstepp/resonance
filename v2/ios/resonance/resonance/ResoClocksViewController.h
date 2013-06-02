//
//  ResoClocksViewController.h
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoActionBar.h"

@interface ResoClocksViewController : UIViewController
@property (nonatomic, retain) UIButton * playerButton;
@property (nonatomic, retain) ResoActionBar * alarmBar;
@property (nonatomic, retain) ResoActionBar * timerBar;
@end
