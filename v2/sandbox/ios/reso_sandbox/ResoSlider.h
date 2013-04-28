//
//  ResoSlider.h
//  ResoSliderSandbox
//
//  Created by Daniel Stepp on 4/27/13.
//  Copyright (c) 2013 Daniel Stepp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResoSlider : UIControl

@property (nonatomic,assign) int minValue;
@property (nonatomic,assign) int maxValue;
@property (nonatomic,assign) int value;

-(void)updateValue:(int)value;
@end
