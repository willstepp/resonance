//
//  ResoPlayerBar.m
//  resonance
//
//  Created by Daniel Stepp on 5/22/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoPlayerWidget.h"
#import "ResoSettings.h"

@interface ResoPlayerWidget()
{
  
}
@end

@implementation ResoPlayerWidget
@synthesize timerButton, mixButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      //mix button
      mixButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [mixButton setTitle:@"Mi" forState:UIControlStateNormal];
      [mixButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
      [mixButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
      mixButton.layer.borderWidth = 0.0f;
      mixButton.layer.cornerRadius = CORNER_RADIUS;
      mixButton.frame = CGRectMake(0, 0, 50, frame.size.height);
      [self addSubview:mixButton];
      
      //timer button
      timerButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [timerButton setTitle:@"Ti" forState:UIControlStateNormal];
      [timerButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
      [timerButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
      timerButton.layer.borderWidth = 0.0f;
      timerButton.layer.cornerRadius = CORNER_RADIUS;
      timerButton.frame = CGRectMake(frame.size.width-50, 0, 50, frame.size.height);
      [self addSubview:timerButton];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
