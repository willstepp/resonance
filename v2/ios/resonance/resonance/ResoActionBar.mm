//
//  ResoActionBar.mm
//  resonance
//
//  Created by Daniel Stepp on 5/31/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoActionBar.h"
#import "ResoSettings.h"

@implementation ResoActionBar
@synthesize actionButton, titleLabel, iconLabel;

- (id)initWithFrame:(CGRect)frame withText:(NSString*)text withIconText:(NSString*)iconText withIconColor:(UIColor*)iconColor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = CORNER_RADIUS * 2;
        [self setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_NORMAL]];
      
        //action button
        actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [actionButton setImage:[UIImage imageNamed:@"icon-right-chevron.png"] forState:UIControlStateNormal];
        [actionButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0]];
        actionButton.frame = CGRectMake(frame.size.width-50, 0, 50, 50);
        [self addSubview:actionButton];
      
        //icon label
        if (iconColor == nil) {
          iconColor = [UIColor blackColor];
        }
        UIColor * iconTextColor = [self changeBrightness:iconColor amount:1.25f];
        iconLabel = [[UILabel alloc] init];
        [iconLabel setFont:[UIFont systemFontOfSize:FONT_SIZE * 1.25]];
        [iconLabel setTextColor:iconTextColor];
        [iconLabel setBackgroundColor:iconColor];
        iconLabel.frame = CGRectMake(5, 5, 40, 40);
        iconLabel.layer.cornerRadius = CORNER_RADIUS * 1.25;
        [iconLabel setText:iconText];
        [iconLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:iconLabel];
      
        //title label
        titleLabel = [[UILabel alloc] init];
        [titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE*1.05]];
        [titleLabel setTextColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:1.0]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        titleLabel.frame = CGRectMake(iconLabel.frame.size.width+15, (frame.size.height / 2) - 25, frame.size.width-100, 50);
        [titleLabel setText:text];
        [self addSubview:titleLabel];
    }
    return self;
}

- (UIColor*)changeBrightness:(UIColor*)color amount:(CGFloat)amount
{
  
  CGFloat hue, saturation, brightness, alpha;
  if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
    brightness += (amount-1.0);
    brightness = MAX(MIN(brightness, 1.0), 0.0);
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
  }
  
  CGFloat white;
  if ([color getWhite:&white alpha:&alpha]) {
    white += (amount-1.0);
    white = MAX(MIN(white, 1.0), 0.0);
    return [UIColor colorWithWhite:white alpha:alpha];
  }
  
  return nil;
}

@end
