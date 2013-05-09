//
//  ResoTimerViewController.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/8/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoTimer.h"
#import "ResoAlarm.h"

@interface ResoTimerViewController : UIViewController <ResoTimerDelegate, ResoAlarmDelegate>
@property (nonatomic, retain) UIButton * backButton;

@property (nonatomic, retain) UIButton * timerButton;
@property (nonatomic, retain) UILabel * timerLabel;

@property (nonatomic, retain) UIButton * alarmButton;
@property (nonatomic, retain) UILabel * alarmLabel;
@end
