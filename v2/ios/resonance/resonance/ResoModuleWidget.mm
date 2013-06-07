//
//  ResoModuleWidget.mm
//  resonance
//
//  Created by Daniel Stepp on 5/22/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoAppDelegate.h"

#import "ResoModuleWidget.h"
#import "ResoSlider.h"
#import "ResoSettings.h"
#import "ResoFileManager.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"
#import "ISound.h"
#import "ITone.h"

@interface ResoModuleWidget ()
{
  CGRect removeButtonFrame;
  CGRect removeButtonFrame_offscreen;
}
@end

@implementation ResoModuleWidget
@synthesize expandButton, titleLabel, volumeSlider, toggleRemoveButton, removePanel, removeButton, uuid, soundUuid;

- (id)initWithFrame:(CGRect)frame withSound:(NSString*)s
{
    self = [super initWithFrame:frame];
    if (self) {
      soundUuid = s;
      
      [self setClipsToBounds:YES];
      
      expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [expandButton setImage:[UIImage imageNamed:@"icon-plus-small.png"] forState:UIControlStateNormal];
      expandButton.alpha = WIDGET_ALPHA_DARK * 0.5;
      [expandButton setAdjustsImageWhenHighlighted:NO];
      [expandButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
      [expandButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:0.75] forState:UIControlStateNormal];
      [expandButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0]];
      expandButton.layer.borderWidth = 0.0f;
      expandButton.layer.cornerRadius = CORNER_RADIUS / 2.0f;
      expandButton.frame = CGRectMake(frame.size.width-50, 0, 50, 50);
      [self addSubview:expandButton];
      
      toggleRemoveButton = [UIButton buttonWithType:UIButtonTypeCustom];
      NSString * imagePath = [NSString stringWithFormat:@"sounds/%@/thumb", s];
      NSString * image = [[ResoFileManager resonanceAppSubDirectory:imagePath] path];
      [toggleRemoveButton setImage:[UIImage imageWithContentsOfFile:image] forState:UIControlStateNormal];
      [toggleRemoveButton setAdjustsImageWhenHighlighted:YES];
      [toggleRemoveButton addTarget:self action:@selector(toggleRemoveModule:) forControlEvents:UIControlEventTouchUpInside];
      [toggleRemoveButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0]];
      toggleRemoveButton.layer.borderWidth = 0.0f;
      toggleRemoveButton.frame = CGRectMake(5, 5, frame.size.height-10, frame.size.height-10);
      [self addSubview:toggleRemoveButton];
      
      titleLabel = [[UILabel alloc] init];
      [titleLabel setFont:[UIFont systemFontOfSize:10]];
      [titleLabel setTextColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:0.75]];
      [titleLabel setBackgroundColor:[UIColor clearColor]];
      titleLabel.frame = CGRectMake(50, (frame.size.height / 2) - 25, frame.size.width-100, 50);
      
      //volume slider
      int width = self.bounds.size.width / 1.6f;
      int height = 44;
      volumeSlider = [[ResoSlider alloc]initWithFrame:CGRectMake(toggleRemoveButton.frame.size.width+20, (frame.size.height / 2) - 23, width, height) withOrientation:Horizontal withCornerRadius:1.0f];
      volumeSlider.minValue = 0;
      volumeSlider.maxValue = 100;
      [volumeSlider setValue:50];
      [volumeSlider addTarget:self action:@selector(volumeChanged:) forControlEvents:UIControlEventValueChanged];
      [self addSubview:volumeSlider];
      
      //remove button
      removeButtonFrame = CGRectMake(toggleRemoveButton.frame.size.width+10, 5, frame.size.width-toggleRemoveButton.frame.size.width-15, frame.size.height-10);
      removeButtonFrame_offscreen = CGRectMake(frame.size.width, 5, removeButtonFrame.size.width, removeButtonFrame.size.height);
      
      removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [removeButton setTitle:@"Remove" forState:UIControlStateNormal];
      [removeButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
      [removeButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:1.0] forState:UIControlStateNormal];
      [removeButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
      removeButton.layer.borderWidth = 0.0f;
      removeButton.layer.cornerRadius = CORNER_RADIUS;
      removeButton.frame = removeButtonFrame_offscreen;
      removeButton.alpha = 0.0f;
      [self addSubview:removeButton];

    }
    return self;
}

-(void)volumeChanged:(id)sender
{
  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoModule * rm = [rmm.modules objectForKey:uuid];
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  
  rm.volume = volumeSlider.value;
  [rm updateVolume:[ad calculateActualVolume:volumeSlider.value]];
}

-(void)toggleRemoveModule:(id)sender
{
  static bool showing = false;
  if (showing) {
    //hide remove panel
    [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                          delay:0.00
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       removeButton.frame = removeButtonFrame_offscreen;
                     } completion:^(BOOL finished){
                       if (finished) {
                         removeButton.alpha = 0.0f;
                       }
                     }];
    showing = false;
  } else {
    //show remove panel
    removeButton.alpha = 1.0f;
    [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                          delay:0.00
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       removeButton.frame = removeButtonFrame;
                     } completion:nil];
    showing = true;
  }
}
@end
