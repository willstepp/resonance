//
//  ResoModuleWidget.h
//  resonance
//
//  Created by Daniel Stepp on 5/22/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResoModuleWidget : UIView
@property (nonatomic, retain) UIButton * expandButton;
@property (nonatomic, retain) UIButton * toggleRemoveButton;
@property (nonatomic, retain) UIView * removePanel;
@property (nonatomic, retain) UIButton * removeButton;
@property (nonatomic, retain) UILabel * titleLabel;

@property (nonatomic, assign) NSString * uuid;
@end
