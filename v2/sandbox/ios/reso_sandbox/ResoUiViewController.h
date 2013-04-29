//
//  RESOViewController.h
//  gl_sandbox
//
//  Created by Daniel Stepp on 9/1/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "ResoTypes.h"

@interface ResoUiViewController : GLKViewController
    @property (nonatomic, retain) IBOutlet UIButton * mirButton;
    @property (nonatomic, retain) IBOutlet UIButton * mirButton2;
    @property (nonatomic, retain) IBOutlet UIButton * mirButton3;

    @property (nonatomic, retain) IBOutlet UIButton * visualButton;
    @property (nonatomic, retain) UIButton * backButton;

    @property (nonatomic, retain) IBOutlet UIImageView * overlay;
    - (IBAction) toggleModule:(id)sender;
    - (IBAction) toggleVisualState;

    - (void) changeAppToState:(ResoAppState)state;
@end
