//
//  ResoSlider.m
//  ResoSliderSandbox
//
//  Created by Daniel Stepp on 4/27/13.
//  Copyright (c) 2013 Daniel Stepp. All rights reserved.
//

#import "ResoSlider.h"

CGMutablePathRef createRoundedRectForRect(CGRect rect, CGFloat radius)
{
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius);
  CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), radius);
  CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
  CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
  CGPathCloseSubpath(path);
  
  return path;
}

@interface ResoSlider()
{
  UIColor * trackColor;
  UIColor * slideColor;
  UIColor * handleColor;
  
  float _slideMarginX;
  float _slideMarginY;
  CGRect _baseRect;
  
  //handle animation
  float _minHandleSize;
  float _currHandleSize;
  float _maxHandleSize;
  bool _handleAnimating;
  float _handleAnimationStep;
  float _animationStep;
  float _animationDuration;
  float _animationStepValue;
  bool _handleMaxed;
  NSTimer * _handleAnimationTimer;
}
@end

@implementation ResoSlider
@synthesize minValue, maxValue, value;

- (id)initWithFrame:(CGRect)frame
{
  //height is fixed to apple's suggested touch height
  int height = 44;
  self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height)];
  
  if (self) {
    trackColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
    slideColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.15];
    handleColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.50]];
    
    _minHandleSize = 0.0f;
    _currHandleSize = _minHandleSize;
    _maxHandleSize = 20;
    _handleAnimating = false;
    _handleAnimationStep = 0.0f;
    
    //x margin needs to be half of max handle size so there is no clipping when
    //handle is at the edges of the slider
    _slideMarginX = _maxHandleSize / 2.0f;
    _slideMarginY = 20.0f;
    _baseRect = CGRectInset(self.bounds, _slideMarginX, _slideMarginY);
    
    _animationStep = 0.025f;
    _animationDuration = 0.4f;
    
    _animationStepValue = 0.0f;
    _handleMaxed = false;
  }
  
  return self;
}

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  //calculate track rect
  CGMutablePathRef trackPath = createRoundedRectForRect(_baseRect, 2.0);
  
  //calculate slide width based on current value
  float percentage = (float)self.value / (float)self.maxValue;
  float slideWidth = _baseRect.size.width * percentage;
  
  //calculate slide rect
  CGMutablePathRef slidePath = createRoundedRectForRect(CGRectMake(_baseRect.origin.x, _baseRect.origin.y, slideWidth, _baseRect.size.height), 2.0);
  
  //calculate handle rect so that it is centered at the end of the current slide rect location
  float halfHandleSize = _currHandleSize / 2.0f;
  CGMutablePathRef handlePath = createRoundedRectForRect(CGRectMake(slideWidth - halfHandleSize +_slideMarginX, (self.bounds.size.height / 2.0) - halfHandleSize, _currHandleSize, _currHandleSize), halfHandleSize);
  
  CGContextSaveGState(context);
  
  //draw track
  CGContextSetFillColorWithColor(context, trackColor.CGColor);
  CGContextAddPath(context, trackPath);
  CGContextFillPath(context);
  
  //draw slide
  CGContextSetFillColorWithColor(context, slideColor.CGColor);
  CGContextAddPath(context, slidePath);
  CGContextFillPath(context);
  
  //draw handle
  CGContextSetFillColorWithColor(context, handleColor.CGColor);
  CGContextAddPath(context, handlePath);
  CGContextFillPath(context);
  
  CGContextRestoreGState(context);
}

#pragma mark - UIControl Override -

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
  [super touchesBegan:touches withEvent:event];
  
  UITouch * touch = [touches anyObject];
  [self updateValueFromTouch:touch];
  
  [self startHandleAnimationWithDirection:true];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
  [super touchesEnded:touches withEvent:event];
  [self startHandleAnimationWithDirection:false];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
  [super touchesCancelled:touches withEvent:event];
  [_handleAnimationTimer invalidate];
}

/** Tracking is started **/
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
  [super beginTrackingWithTouch:touch withEvent:event];
  
  //We need to track continuously
  return YES;
}

/** Track continuos touch event (like drag) **/
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
  [super continueTrackingWithTouch:touch withEvent:event];
  
  [self updateValueFromTouch:touch];
  
  return YES;
}

/** Track is finished **/
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
  [super endTrackingWithTouch:touch withEvent:event];
}


#pragma mark - Handle Animation

-(void)startHandleAnimationWithDirection:(BOOL)up
{
  [_handleAnimationTimer invalidate];
  _handleAnimating = false;
  _handleAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:_animationStep target:self selector:@selector(animateHandle:) userInfo:[NSNumber numberWithBool:up] repeats:YES];
}

-(void)animateHandle:(NSTimer*)currTimer
{
  NSNumber * ui = [currTimer userInfo];
  BOOL up = [ui boolValue];
  
  if (!_handleAnimating) {
    
    float steps = _animationDuration / _animationStep;
    if (up) {
      _animationStepValue = ABS(_currHandleSize - _maxHandleSize) / steps;
    } else {
      _animationStepValue = -(ABS(_currHandleSize - _minHandleSize) / steps);
    }
    _handleMaxed = false;
    _handleAnimating = true;
  }
  
  //update value
  _currHandleSize += _animationStepValue;
  
  //if we've reached target, shut down animation
  if (up && _currHandleSize >= _maxHandleSize) {
    _currHandleSize = _maxHandleSize;
    _handleAnimating = false;
    _handleMaxed = true;
    [_handleAnimationTimer invalidate];
  } else if(!up && _currHandleSize <= _minHandleSize) {
    _currHandleSize = _minHandleSize;
    _handleAnimating = false;
    [_handleAnimationTimer invalidate];
  }
  
  //schedule redraw
  [self setNeedsDisplay];
}

-(void)updateValueFromTouch:(UITouch*)touch
{
  CGPoint lastPoint = [touch locationInView:self];
  
  float percentage = lastPoint.x / _baseRect.size.width;
  int newValue = self.maxValue * percentage;
  
  if (newValue <= self.minValue) {
    newValue = self.minValue;
  } else if (newValue >= self.maxValue) {
    newValue = self.maxValue;
  }
  
  [self updateValue:newValue];
}

-(void)updateValue:(int)v
{
  self.value = v;
  [self sendActionsForControlEvents:UIControlEventValueChanged];
  [self setNeedsDisplay];
}

@end
