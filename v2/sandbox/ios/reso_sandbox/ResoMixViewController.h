//
//  ResoMixViewController.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/7/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoMediaTransferManager.h"

@interface ResoMixViewController : UIViewController <UIAlertViewDelegate, ResoMediaTransferDelegate>
@property (nonatomic, retain) UIButton * backButton;
@property (nonatomic, retain) UIButton * saveMixButton;
@property (nonatomic, retain) UIButton * loadMixButton;
@property (nonatomic, retain) UIButton * shareMixButton;
@end
