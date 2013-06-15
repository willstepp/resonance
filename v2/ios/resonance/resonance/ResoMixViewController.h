//
//  ResoMixViewController.h
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoActionBar.h"

@interface ResoMixViewController : UIViewController <UIAlertViewDelegate>
@property (nonatomic, retain) UIButton * playerButton;

@property (nonatomic, retain) UIView * viewPanel;

@property (nonatomic, retain) UIView * currentMixPanel;
@property (nonatomic, retain) UILabel * currentMixTitle;
@property (nonatomic, retain) UIImageView * currentMixThumb;
@property (nonatomic, retain) UIButton * currentMixButton;

@property (nonatomic, retain) ResoActionBar * mixListBar;
@end
