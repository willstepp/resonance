//
//  ResoActionBar.h
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoTypes.h"

@interface ResoActionBar : UIView
- (id)initWithFrame:(CGRect)frame withText:(NSString*)text withIconText:(NSString*)iconText withIconColor:(UIColor*)iconColor withDirection:(WidgetDirection)wd;

@property (nonatomic, retain) UILabel * iconLabel;
@property (nonatomic, retain) UILabel * titleLabel;
@property (nonatomic, retain) UIButton * actionButton;
@property (nonatomic, retain) UIImageView * actionImage;
@end
