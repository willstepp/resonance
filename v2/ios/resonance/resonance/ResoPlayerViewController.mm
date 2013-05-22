//
//  ResoPlayerViewController.m
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoAppDelegate.h"
#import "ResoPlayerViewController.h"

#import "ResoModuleViewController.h"
#import "ResoMixViewController.h"
#import "ResoTimerViewController.h"
#import "ResoVisualViewController.h"
#import "ResoMenuViewController.h"

#import "ResoTypes.h"
#import "ResoSettings.h"
#import "IResoVisualization.h"

#import "ResoPanelWidget.h"
#import "ResoPlayerWidget.h"

@interface ResoPlayerViewController ()
{
  int moduleCount;
  PlayerState currPlayerState;
  PlayerState transitionState;
  
  NSMutableDictionary * playerWidgets;
  
  //frames
  CGRect menuButtonFrame;
  CGRect menuButtonFrame_offscreen;
  
  CGRect visualButtonFrame;
  CGRect visualButtonFrame_offscreen;
  
  CGRect addModuleButtonFrame;
  CGRect addModuleButtonFrame_offscreen;
  
  CGRect playerWidgetFrame;
  CGRect playerWidgetFrame_offscreen;
  
  CGRect menuPanelWidgetFrame;
  CGRect menuPanelWidgetFrame_offscreen;
  
  CGRect mixPanelWidgetFrame;
  CGRect mixPanelWidgetFrame_offscreen;
  
  CGRect timerPanelWidgetFrame;
  CGRect timerPanelWidgetFrame_offscreen;
  
  CGRect overlayPanelWidgetFrame;
  CGRect overlayPanelWidgetFrame_offscreen;
}
@end

@implementation ResoPlayerViewController
@synthesize mixButton, timerButton, moduleButton;
@synthesize menuButton, visualButton, addModuleButton;
@synthesize playerWidget, menuPanelWidget, mixPanelWidget, timerPanelWidget;
@synthesize overlayPanelWidget;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self calculateWidgetFrames];
    
    playerWidgets = [[NSMutableDictionary alloc] init];
    
    moduleCount = 0;
    currPlayerState = PlayerState_Visual;
    transitionState = PlayerState_Visual;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    //module button
    moduleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moduleButton setTitle:@"Disable Input" forState:UIControlStateNormal];
    [moduleButton addTarget:self action:@selector(toggleInput:) forControlEvents:UIControlEventTouchUpInside];
    [moduleButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [moduleButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
    
    moduleButton.layer.borderColor = [UIColor blackColor].CGColor;
    moduleButton.layer.borderWidth = 0.0f;
    moduleButton.layer.cornerRadius = 4.0f;
    moduleButton.frame = CGRectMake(10, 100, self.view.bounds.size.width - 20, 50);
    //[self.view addSubview:moduleButton];
    
    //mix button
    mixButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mixButton setTitle:@"Show Foreground" forState:UIControlStateNormal];
    [mixButton addTarget:self action:@selector(toggleVisualState:) forControlEvents:UIControlEventTouchUpInside];
    [mixButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [mixButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
    
    mixButton.layer.borderColor = [UIColor blackColor].CGColor;
    mixButton.layer.borderWidth = 0.0f;
    mixButton.layer.cornerRadius = 4.0f;
    mixButton.frame = CGRectMake(10, 170, self.view.bounds.size.width - 20, 50);
    //[self.view addSubview:mixButton];
    
    //timer button
    timerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [timerButton setTitle:@"Show Nebula" forState:UIControlStateNormal];
    [timerButton addTarget:self action:@selector(toggleActiveSound:) forControlEvents:UIControlEventTouchUpInside];
    [timerButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [timerButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
    
    timerButton.layer.borderColor = [UIColor blackColor].CGColor;
    timerButton.layer.borderWidth = 0.0f;
    timerButton.layer.cornerRadius = CORNER_RADIUS;
    timerButton.frame = CGRectMake(10, 240, self.view.bounds.size.width - 20, 50);
    //[self.view addSubview:timerButton];
  
    //menu button
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setTitle:@"Me" forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
    [menuButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
    menuButton.layer.borderWidth = 0.0f;
    menuButton.layer.cornerRadius = CORNER_RADIUS;
    menuButton.frame = menuButtonFrame_offscreen;
    [self.view addSubview:menuButton];
  
    //visual button
    visualButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [visualButton setTitle:@"Vi" forState:UIControlStateNormal];
    [visualButton addTarget:self action:@selector(showVisual:) forControlEvents:UIControlEventTouchUpInside];
    [visualButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
    [visualButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
    visualButton.layer.borderWidth = 0.0f;
    visualButton.layer.cornerRadius = CORNER_RADIUS;
    visualButton.frame = visualButtonFrame_offscreen;
    [self.view addSubview:visualButton];
  
    //add module button
    addModuleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addModuleButton setTitle:@"Add Module" forState:UIControlStateNormal];
    [addModuleButton addTarget:self action:@selector(addModule:) forControlEvents:UIControlEventTouchUpInside];
    [addModuleButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
    [addModuleButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA]];
    addModuleButton.layer.borderWidth = 0.0f;
    addModuleButton.layer.cornerRadius = CORNER_RADIUS;
    addModuleButton.frame = addModuleButtonFrame_offscreen;
    [self.view addSubview:addModuleButton];
  
    //mix panel
    mixPanelWidget = [[ResoPanelWidget alloc] initWithFrame:mixPanelWidgetFrame_offscreen];
    [mixPanelWidget setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA]];
    mixPanelWidget.layer.borderWidth = 0.0f;
    mixPanelWidget.layer.cornerRadius = CORNER_RADIUS;
    [self.view addSubview:mixPanelWidget];
  
    //timer panel
    timerPanelWidget = [[ResoPanelWidget alloc] initWithFrame:timerPanelWidgetFrame_offscreen];
    [timerPanelWidget setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA]];
    timerPanelWidget.layer.borderWidth = 0.0f;
    timerPanelWidget.layer.cornerRadius = CORNER_RADIUS;
    [self.view addSubview:timerPanelWidget];
  
    //player widget
    playerWidget = [[ResoPlayerWidget alloc] initWithFrame:playerWidgetFrame_offscreen];
    [playerWidget setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA]];
    playerWidget.layer.borderWidth = 0.0f;
    [playerWidget.timerButton addTarget:self action:@selector(showTimer:) forControlEvents:UIControlEventTouchUpInside];
    [playerWidget.mixButton addTarget:self action:@selector(showMix:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playerWidget];
  
    //overlay
    overlayPanelWidget = [[ResoPanelWidget alloc] initWithFrame:overlayPanelWidgetFrame_offscreen];
    [overlayPanelWidget setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA]];
    overlayPanelWidget.layer.borderWidth = 0.0f;
    [self.view addSubview:overlayPanelWidget];
}

- (void)viewWillAppear:(BOOL)animated
{
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  [self setPlayerToState:ad.currPlayerState];
  [self transitionPlayerToState:PlayerState_Main];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)toggleInput:(id)sender
{
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  if ([ad.visualization inputEnabled]) {
    [moduleButton setTitle:@"Enable Input" forState:UIControlStateNormal];
    [ad.visualization setInputEnabled:false];
  } else {
    [moduleButton setTitle:@"Disable Input" forState:UIControlStateNormal];
    [ad.visualization setInputEnabled:true];
  }
}

-(void)toggleVisualState:(id)sender
{
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  if ([ad.visualization visualizationState] != Transitioning) {
    if ([ad.visualization visualizationState] == Foreground) {
      [mixButton setTitle:@"Show Foreground" forState:UIControlStateNormal];
      [ad.visualization setVisualizationState:Background];
    } else if ([ad.visualization visualizationState] == Background) {
      [mixButton setTitle:@"Show Background" forState:UIControlStateNormal];
      [ad.visualization setVisualizationState:Foreground];
    }
  }
}

-(void)toggleActiveSound:(id)sender
{
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  if ([ad.visualization visualizationState] != Transitioning) {
    if ([[ad.visualization activeSound] isEqualToString:@"oceanblue"]) {
      [timerButton setTitle:@"Show Ocean" forState:UIControlStateNormal];
      [ad.visualization setActiveSound:@"nebulaorange"];
    } else if ([[ad.visualization activeSound] isEqualToString:@"nebulaorange"]) {
      [timerButton setTitle:@"Show Nebula" forState:UIControlStateNormal];
      [ad.visualization setActiveSound:@"oceanblue"];
    }
  }
}

-(void)showMenu:(id)sender
{
  [self transitionPlayerToState:PlayerState_Menu];
}

-(void)showVisual:(id)sender
{
  [self transitionPlayerToState:PlayerState_Visual];
}

-(void)showMix:(id)sender
{
  [self transitionPlayerToState:PlayerState_Mix];
}

-(void)showModule:(id)sender
{
  ResoModuleViewController * rmvc = [[ResoModuleViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rmvc animated:YES];
}

-(void)showTimer:(id)sender
{
  [self transitionPlayerToState:PlayerState_Timer];
}

- (void) setPlayerToState:(PlayerState)state
{
  switch (state)
  {
    case PlayerState_Main:
      menuButton.frame = menuButtonFrame;
      visualButton.frame = visualButtonFrame;
      addModuleButton.frame = addModuleButtonFrame;
      mixPanelWidget.frame = mixPanelWidgetFrame_offscreen;
      timerPanelWidget.frame = timerPanelWidgetFrame_offscreen;
      playerWidget.frame = playerWidgetFrame;
      break;
    case PlayerState_Visual:
      menuButton.frame = menuButtonFrame_offscreen;
      visualButton.frame = visualButtonFrame_offscreen;
      addModuleButton.frame = addModuleButtonFrame_offscreen;
      mixPanelWidget.frame = mixPanelWidgetFrame_offscreen;
      timerPanelWidget.frame = timerPanelWidgetFrame_offscreen;
      playerWidget.frame = playerWidgetFrame_offscreen;
      break;
    case PlayerState_Module:
      break;
    case PlayerState_Timer:
      overlayPanelWidget.frame = overlayPanelWidgetFrame;
      menuButton.frame = menuButtonFrame_offscreen;
      visualButton.frame = visualButtonFrame_offscreen;
      addModuleButton.frame = addModuleButtonFrame_offscreen;
      mixPanelWidget.frame = mixPanelWidgetFrame_offscreen;
      timerPanelWidget.frame = timerPanelWidgetFrame_offscreen;
      playerWidget.frame = playerWidgetFrame_offscreen;
      break;
    case PlayerState_Menu:
      overlayPanelWidget.frame = overlayPanelWidgetFrame;
      menuButton.frame = menuButtonFrame_offscreen;
      visualButton.frame = visualButtonFrame_offscreen;
      addModuleButton.frame = addModuleButtonFrame_offscreen;
      mixPanelWidget.frame = mixPanelWidgetFrame_offscreen;
      timerPanelWidget.frame = timerPanelWidgetFrame_offscreen;
      playerWidget.frame = playerWidgetFrame_offscreen;
      break;
    case PlayerState_Mix:
      overlayPanelWidget.frame = overlayPanelWidgetFrame;
      menuButton.frame = menuButtonFrame_offscreen;
      visualButton.frame = visualButtonFrame_offscreen;
      addModuleButton.frame = addModuleButtonFrame_offscreen;
      mixPanelWidget.frame = mixPanelWidgetFrame_offscreen;
      timerPanelWidget.frame = timerPanelWidgetFrame_offscreen;
      playerWidget.frame = playerWidgetFrame_offscreen;
      break;
    default:
      break;
  }
  currPlayerState = state;
}

- (void) transitionPlayerToState:(PlayerState)state
{
  if ([self canChangeToState:state]) {
    switch (state)
    {
      case PlayerState_Main:
      {
        if (currPlayerState == PlayerState_Visual)
        {
          transitionState = state;
          currPlayerState = PlayerState_Transitioning;
          
          ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
          [ad.visualization setVisualizationState:Background];
          [ad.visualization setInputEnabled:false];
          
          [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                  delay:0.00
                  options:UIViewAnimationOptionCurveEaseOut
                  animations:^{
                    menuButton.frame = menuButtonFrame;
                    visualButton.frame = visualButtonFrame;
                    addModuleButton.frame = addModuleButtonFrame;
                    playerWidget.frame = playerWidgetFrame;
                  } completion:^(BOOL finished) {
                   if (finished) {
                     [self completeTransition];
                   }
                  }];
        }
        if (currPlayerState == PlayerState_Menu || currPlayerState == PlayerState_Mix || currPlayerState == PlayerState_Timer)
        {
          transitionState = state;
          currPlayerState = PlayerState_Transitioning;
                    
          [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                                delay:0.00
                              options:UIViewAnimationOptionCurveEaseOut
                           animations:^{
                             overlayPanelWidget.alpha = 0.0f;
                             menuButton.frame = menuButtonFrame;
                             visualButton.frame = visualButtonFrame;
                             addModuleButton.frame = addModuleButtonFrame;
                             playerWidget.frame = playerWidgetFrame;
                           } completion:^(BOOL finished) {
                             if (finished) {
                               [self completeTransition];
                             }
                           }];

        }
        break;
      }
      case PlayerState_Visual:
      {
        transitionState = state;
        currPlayerState = PlayerState_Transitioning;
        
        ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
        [ad.visualization setVisualizationState:Foreground];
        [ad.visualization setInputEnabled:true];
        
        [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                              delay:0.00
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                           menuButton.frame = menuButtonFrame_offscreen;
                           visualButton.frame = visualButtonFrame_offscreen;
                           addModuleButton.frame = addModuleButtonFrame_offscreen;
                           playerWidget.frame = playerWidgetFrame_offscreen;
                         } completion:^(BOOL finished) {
                           if (finished) {
                             [self completeTransition];
                           }
                         }];
        break;
      }
      case PlayerState_Module:
        break;
      case PlayerState_Timer:
      {
        transitionState = state;
        currPlayerState = PlayerState_Transitioning;
        
        overlayPanelWidget.frame = overlayPanelWidgetFrame;
        overlayPanelWidget.alpha = 0.0f;
        
        [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                              delay:0.00
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                           overlayPanelWidget.alpha = 1.0f;
                           menuButton.frame = menuButtonFrame_offscreen;
                           visualButton.frame = visualButtonFrame_offscreen;
                           addModuleButton.frame = addModuleButtonFrame_offscreen;
                           playerWidget.frame = playerWidgetFrame_offscreen;
                         } completion:^(BOOL finished) {
                           if (finished) {
                             [self completeTransition];
                           }
                         }];
        break;
      }
      case PlayerState_Menu:
      {
        transitionState = state;
        currPlayerState = PlayerState_Transitioning;
        
        overlayPanelWidget.frame = overlayPanelWidgetFrame;
        overlayPanelWidget.alpha = 0.0f;
        
        [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                              delay:0.00
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                           overlayPanelWidget.alpha = 1.0f;
                           menuButton.frame = menuButtonFrame_offscreen;
                           visualButton.frame = visualButtonFrame_offscreen;
                           addModuleButton.frame = addModuleButtonFrame_offscreen;
                           playerWidget.frame = playerWidgetFrame_offscreen;
                         } completion:^(BOOL finished) {
                           if (finished) {
                             [self completeTransition];
                           }
                         }];
        break;
      }
      case PlayerState_Mix:
      {
        transitionState = state;
        currPlayerState = PlayerState_Transitioning;
        
        overlayPanelWidget.frame = overlayPanelWidgetFrame;
        overlayPanelWidget.alpha = 0.0f;
        
        [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                              delay:0.00
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                           overlayPanelWidget.alpha = 1.0f;
                           menuButton.frame = menuButtonFrame_offscreen;
                           visualButton.frame = visualButtonFrame_offscreen;
                           addModuleButton.frame = addModuleButtonFrame_offscreen;
                           playerWidget.frame = playerWidgetFrame_offscreen;
                         } completion:^(BOOL finished) {
                           if (finished) {
                             [self completeTransition];
                           }
                         }];
        break;
      }
      default:
        break;
    }
  }
}

- (void)completeTransition
{
  currPlayerState = transitionState;
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  ad.currPlayerState = currPlayerState;
  
  switch (transitionState)
  {
    case PlayerState_Main:
      break;
    case PlayerState_Visual:
    {
      ResoVisualViewController * rvvc = [[ResoVisualViewController alloc] initWithNibName:nil bundle:nil];
      [self.navigationController pushViewController:rvvc animated:NO];
      break;
    }
    case PlayerState_Module:
      break;
    case PlayerState_Timer:
    {
      ResoTimerViewController * rtvc = [[ResoTimerViewController alloc] initWithNibName:nil bundle:nil];
      [self.navigationController pushViewController:rtvc animated:NO];
      break;
    }
    case PlayerState_Menu:
    {
      ResoMenuViewController * rmvc = [[ResoMenuViewController alloc] initWithNibName:nil bundle:nil];
      [self.navigationController pushViewController:rmvc animated:NO];
      break;
    }
    case PlayerState_Mix:
    {
      ResoMixViewController * rmvc = [[ResoMixViewController alloc] initWithNibName:nil bundle:nil];
      [self.navigationController pushViewController:rmvc animated:NO];
      break;
    }
    default:
      break;
  }
}

- (bool)canChangeToState:(PlayerState)state
{
  return currPlayerState != state && currPlayerState != PlayerState_Transitioning;
}

- (void)calculateWidgetFrames
{
  //menu button
  menuButtonFrame = CGRectMake(10, 10, 50, 50);
  menuButtonFrame_offscreen = CGRectMake(-50, 10, 50, 50);
  
  //visual button
  visualButtonFrame = CGRectMake(self.view.bounds.size.width-60, 10, 50, 50);
  visualButtonFrame_offscreen = CGRectMake(self.view.bounds.size.width+50, 10, 50, 50);
  
  //add module button
  addModuleButtonFrame = CGRectMake(10, (self.view.bounds.size.height / 2) - 50, self.view.bounds.size.width - 20, 50);
  addModuleButtonFrame_offscreen = CGRectMake(10, -50, self.view.bounds.size.width - 20, 50);
  
  //mix panel widget
  mixPanelWidgetFrame = self.view.bounds;
  mixPanelWidgetFrame_offscreen = CGRectMake(10, self.view.bounds.size.height - 10, 0, 0);
  
  //timer panel widget
  timerPanelWidgetFrame = self.view.bounds;
  timerPanelWidgetFrame_offscreen = CGRectMake(self.view.bounds.size.width-10, self.view.bounds.size.height - 10, 0, 0);
  
  //player widget
  playerWidgetFrame = CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50);
  playerWidgetFrame_offscreen = CGRectMake(0, self.view.bounds.size.height + 50, self.view.bounds.size.width, 50);
  
  //overlay
  overlayPanelWidgetFrame = self.view.bounds;
  overlayPanelWidgetFrame_offscreen = CGRectMake(0, 0, 0, 0);
}

#pragma mark - Touch handling methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];
}


@end
