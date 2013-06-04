//
//  ResoSlider.h
//  resonance
//
//  Created by Daniel Stepp on 5/23/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoTypes.h"

@interface ResoSlider : UIControl

@property (nonatomic,assign) int minValue;
@property (nonatomic,assign) int maxValue;
@property (nonatomic,assign) int value;

-(void)updateValue:(int)value;
- (id)initWithFrame:(CGRect)frame withOrientation:(ResoOrientation)o withCornerRadius:(float)cr;
@end
