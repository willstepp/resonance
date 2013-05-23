//
//  ResoPlayerViewController.h
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ResoPlayerWidget;
@class ResoPanelWidget;

@interface ResoPlayerViewController : UIViewController

@property (nonatomic, retain) UIButton * menuButton;
@property (nonatomic, retain) UIButton * visualButton;
@property (nonatomic, retain) UIButton * addModuleButton;

@property (nonatomic, retain) ResoPlayerWidget * playerWidget;

@property (nonatomic, retain) ResoPanelWidget * mixPanelWidget;
@property (nonatomic, retain) ResoPanelWidget * timerPanelWidget;
@property (nonatomic, retain) ResoPanelWidget * menuPanelWidget;

@property (nonatomic, retain) ResoPanelWidget * overlayPanelWidget;
@end
