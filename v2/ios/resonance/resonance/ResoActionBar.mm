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
@synthesize actionButton, titleLabel, iconLabel, actionImage;

- (id)initWithFrame:(CGRect)frame withText:(NSString*)text withIconText:(NSString*)iconText withIconColor:(UIColor*)iconColor withDirection:(WidgetDirection)wd
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = CORNER_RADIUS * 2;
        [self setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.05]];
      
        //action image
        actionImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-chevron-right-small.png"]];
        actionImage.frame = CGRectMake(frame.size.width-50, 0, 50, 50);
        actionImage.alpha = ICON_BUTTON_OPACITY;
        [self addSubview:actionImage];
      
        //icon label
        if (iconColor != nil) {
          UIColor * iconTextColor = [self changeBrightness:iconColor amount:1.5f];
          iconLabel = [[UILabel alloc] init];
          [iconLabel setFont:[UIFont systemFontOfSize:FONT_SIZE * 1.25]];
          [iconLabel setTextColor:iconTextColor];
          [iconLabel setBackgroundColor:iconColor];
          iconLabel.frame = CGRectMake(5, 5, 40, 40);
          iconLabel.layer.cornerRadius = CORNER_RADIUS * 1.25;
          [iconLabel setText:iconText];
          [iconLabel setTextAlignment:NSTextAlignmentCenter];
          [self addSubview:iconLabel];
        }
      
        //title label
        titleLabel = [[UILabel alloc] init];
        [titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE*1.05]];
        [titleLabel setTextColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:1.0]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        float titleX = (iconColor != nil) ? iconLabel.frame.size.width+15 : 10;
        titleLabel.frame = CGRectMake(titleX, (frame.size.height / 2) - 25, frame.size.width-100, 50);
        [titleLabel setText:text];
        [self addSubview:titleLabel];
      
        //action button
        actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [actionButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0]];
        actionButton.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [actionButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
        [actionButton addTarget:self action:@selector(unhighlightButton:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        [self addSubview:actionButton];
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

- (void)highlightButton:(id)sender
{
  [self setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.10]];
}

- (void)unhighlightButton:(id)sender
{
  [self setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.05]];
}

@end
