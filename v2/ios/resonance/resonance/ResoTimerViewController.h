//
//  ResoTimerViewController.h
//  resonance
//
//  Created by Daniel Stepp on 6/1/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoTimer.h"

@interface ResoTimerViewController : UIViewController  <ResoTimerDelegate>
@property (nonatomic, retain) UIButton * backButton;

@property (nonatomic, retain) UIView * chooseTimePanel;
@property (nonatomic, retain) UIDatePicker * timePicker;
@property (nonatomic, retain) UIButton * startTimerbutton;

@property (nonatomic, retain) UIView * countdownPanel;
@property (nonatomic, retain) UILabel * countdownLabel;
@property (nonatomic, retain) UIButton * cancelTimerbutton;
@property (nonatomic, retain) UIButton * pauseTimerbutton;
@end
