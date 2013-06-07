//
//  ResoPlayerBar.m
//  resonance
//
//  Created by Daniel Stepp on 5/22/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoPlayerWidget.h"
#import "ResoSlider.h"
#import "ResoSettings.h"
#import "ResoAppDelegate.h"
#import "ResoModuleManager.h"
#import "ResoModule.h"

@interface ResoPlayerWidget()
{
  
}
@end

@implementation ResoPlayerWidget
@synthesize timerButton, mixButton, playButton, volumeSlider;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      //mix button
      mixButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [mixButton setImage:[UIImage imageNamed:@"icon-mix-small.png"] forState:UIControlStateNormal];
       [mixButton setAdjustsImageWhenHighlighted:NO];
      [mixButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
      [mixButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
      mixButton.layer.borderWidth = 0.0f;
      mixButton.layer.cornerRadius = CORNER_RADIUS;
      mixButton.alpha = PLAYER_ICON_OPACITY;
      mixButton.frame = CGRectMake(frame.size.width-50, frame.size.height-50, 50, 50);
      [self addSubview:mixButton];
      
      //timer button
      timerButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [timerButton setImage:[UIImage imageNamed:@"icon-clock-small.png"] forState:UIControlStateNormal];
      [timerButton setAdjustsImageWhenHighlighted:NO];
      [timerButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
      [timerButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
      timerButton.layer.borderWidth = 0.0f;
      timerButton.alpha = PLAYER_ICON_OPACITY;
      timerButton.frame = CGRectMake(0, frame.size.height-50, 50, 50);
      [self addSubview:timerButton];
      
      //play button
      playButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [playButton setImage:[UIImage imageNamed:@"icon-play-large.png"] forState:UIControlStateNormal];
      [playButton setAdjustsImageWhenHighlighted:YES];
      [playButton addTarget:self action:@selector(togglePlayPause:) forControlEvents:UIControlEventTouchUpInside];
      [playButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
      [playButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
      playButton.layer.borderWidth = 0.0f;
      playButton.alpha = WIDGET_ALPHA_DARK;
      playButton.frame = CGRectMake((frame.size.width / 2.0f) - 25, frame.size.height-50, 50, 50);
      [self addSubview:playButton];
      
      int width = self.bounds.size.width;
      int height = 44;
      volumeSlider = [[ResoSlider alloc]initWithFrame:CGRectMake(0, -20, width, height) withOrientation:Horizontal withCornerRadius:1.0f];
      volumeSlider.minValue = 0;
      volumeSlider.maxValue = 100;
      [volumeSlider addTarget:self action:@selector(volumeChanged:) forControlEvents:UIControlEventValueChanged];
      [volumeSlider setValue:50];
      [self addSubview:volumeSlider];
    }
    return self;
}

-(void)togglePlayPause:(id)sender
{
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  ResoModuleManager * rmm = [ResoModuleManager instance];
  if (ad.playing)
  {
    [playButton setImage:[UIImage imageNamed:@"icon-play-large.png"] forState:UIControlStateNormal];
    [rmm pauseModules];
  }
  else
  {
    [playButton setImage:[UIImage imageNamed:@"icon-pause-large.png"] forState:UIControlStateNormal];
    [rmm playModules];
  }
  ad.playing = !ad.playing;
}

-(void)volumeChanged:(id)sender
{
  //update master volume
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  ad.masterVolume = volumeSlider.value;
  NSLog(@"masterVolume: %i", ad.masterVolume);
  
  //update all current modules based on new volume
  ResoModuleManager * rmm = [ResoModuleManager instance];
  for (id key in rmm.modules) {
    ResoModule * rm = [rmm.modules objectForKey:key];
    int moduleVolume = rm.volume;
    NSLog(@"moduleVolume: %i", moduleVolume);
    float actualVolume = [ad calculateActualVolume:rm.volume];
    NSLog(@"actualVolume: %f", actualVolume);
    [rm updateVolume:actualVolume];
  }
}

@end
