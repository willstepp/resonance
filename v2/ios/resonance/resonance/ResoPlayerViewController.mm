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
#import "ResoClocksViewController.h"
#import "ResoVisualViewController.h"
#import "ResoMenuViewController.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"
#import "ResoSlider.h"

#import "ResoModuleWidget.h"

#import "ISound.h"
#import "ITone.h"

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
  
  CGRect moduleWidgetFrame_offscreen;
  NSMutableDictionary * moduleWidgetFrames;
  NSMutableArray * moduleWidgets;
  
  CGRect expandedModuleFrame;
  
  NSString * currentUuid;
}
@end

@implementation ResoPlayerViewController
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
  
    moduleWidgetFrames = [[NSMutableDictionary alloc] init];
    [self calculateWidgetFrames];
    moduleWidgets = [[NSMutableArray alloc] init];
  
    playerWidgets = [[NSMutableDictionary alloc] init];
  
    moduleCount = 0;
    currPlayerState = PlayerState_Visual;
    transitionState = PlayerState_Visual;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
  
    //overlay
    overlayPanelWidget = [[ResoPanelWidget alloc] initWithFrame:overlayPanelWidgetFrame_offscreen];
    [overlayPanelWidget setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_NORMAL]];
    overlayPanelWidget.layer.borderWidth = 0.0f;
    [self.view addSubview:overlayPanelWidget];

    //menu button
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"icon-menu-small.png"] forState:UIControlStateNormal];
    [menuButton setAdjustsImageWhenHighlighted:NO];
    [menuButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
    [menuButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
    menuButton.layer.borderWidth = 0.0f;
    menuButton.alpha = WIDGET_ALPHA_DARK * 0.65;
    menuButton.frame = menuButtonFrame_offscreen;
    [self.view addSubview:menuButton];
  
    //visual button
    visualButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [visualButton setImage:[UIImage imageNamed:@"icon-visual-small.png"] forState:UIControlStateNormal];
    [visualButton setAdjustsImageWhenHighlighted:NO];
    [visualButton addTarget:self action:@selector(showVisual:) forControlEvents:UIControlEventTouchUpInside];
    [visualButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
    [visualButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:0.0f]];
    visualButton.layer.borderWidth = 0.0f;
    visualButton.alpha = WIDGET_ALPHA_DARK * 0.65;
    visualButton.layer.cornerRadius = CORNER_RADIUS;
    visualButton.frame = visualButtonFrame_offscreen;
    [self.view addSubview:visualButton];
  
    //add module button
    addModuleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addModuleButton setTitle:@"Add Sound" forState:UIControlStateNormal];
    [addModuleButton addTarget:self action:@selector(addSound:) forControlEvents:UIControlEventTouchUpInside];
    [addModuleButton.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE]];
    [addModuleButton setTitleColor:[UIColor colorWithRed:FONT_RED green:FONT_GREEN blue:FONT_BLUE alpha:FONT_ALPHA] forState:UIControlStateNormal];
    [addModuleButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_LIGHT]];
    addModuleButton.layer.borderWidth = 0.0f;
    addModuleButton.layer.cornerRadius = CORNER_RADIUS;
    addModuleButton.frame = addModuleButtonFrame_offscreen;
    [self.view addSubview:addModuleButton];
  
    //mix panel
    mixPanelWidget = [[ResoPanelWidget alloc] initWithFrame:mixPanelWidgetFrame_offscreen];
    [mixPanelWidget setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_NORMAL]];
    mixPanelWidget.layer.borderWidth = 0.0f;
    mixPanelWidget.layer.cornerRadius = CORNER_RADIUS;
    [self.view addSubview:mixPanelWidget];
  
    //timer panel
    timerPanelWidget = [[ResoPanelWidget alloc] initWithFrame:timerPanelWidgetFrame_offscreen];
    [timerPanelWidget setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_NORMAL]];
    timerPanelWidget.layer.borderWidth = 0.0f;
    timerPanelWidget.layer.cornerRadius = CORNER_RADIUS;
    [self.view addSubview:timerPanelWidget];
  
    //player widget
    playerWidget = [[ResoPlayerWidget alloc] initWithFrame:playerWidgetFrame_offscreen];
    [playerWidget setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_NORMAL]];
    playerWidget.layer.borderWidth = 0.0f;
    [playerWidget.timerButton addTarget:self action:@selector(showTimer:) forControlEvents:UIControlEventTouchUpInside];
    [playerWidget.mixButton addTarget:self action:@selector(showMix:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playerWidget];
}

- (void)viewWillAppear:(BOOL)animated
{
  [self createModuleWidgets];
  
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  [self setPlayerToState:ad.currPlayerState];
  [self transitionPlayerToState:PlayerState_Main];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

-(void)addSound:(id)sender
{
  if (currPlayerState != PlayerState_Transitioning) {
    ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    ad.currentModule = nil;
    ad.currentModulePosition = -1;
    [ad.visualization enableTransitions:false];
    
    [self transitionPlayerToState:PlayerState_Module];
  }
}

-(void)expandModule:(id)sender
{
  UIButton * moduleButton = (UIButton*)sender;
  ResoModuleWidget * rmw = (ResoModuleWidget*)moduleButton.superview;
  
  NSNumber * modulePosition = nil;
  for (int i = 0; i < [moduleWidgets count]; i++) {
    ResoModuleWidget * r = [moduleWidgets objectAtIndex:i];
    if ([r.uuid isEqualToString:rmw.uuid])
      modulePosition = [NSNumber numberWithInt:i];
  }
  
  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoModule * rm = [rmm.modules objectForKey:rmw.uuid];
  
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  ad.currentModule = rmw.uuid;
  ad.currentModulePosition = [modulePosition intValue];
  [ad.visualization enableTransitions:false];
  currentUuid = rm.soundUuid;
  
  [self transitionPlayerToState:PlayerState_Module];
}

-(void)removeModule:(id)sender
{
  UIButton * moduleButton = (UIButton*)sender;
  ResoModuleWidget * rmw = (ResoModuleWidget*)moduleButton.superview;
  
  //reset any global current module
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  ad.currentModule = nil;
  ad.currentModulePosition = -1;
  
  bool showAddModule = moduleWidgets.count >= MAX_NUM_MODULES;
  
  //remove from module manager
  ResoModuleManager * rmm = [ResoModuleManager instance];
  [rmm removeModuleWithUuid:rmw.uuid];

  rmw.removeButton.alpha = 0.0f;
  rmw.toggleRemoveButton.alpha = 0.0f;
  rmw.expandButton.alpha = 0.0f;
  rmw.volumeSlider.alpha = 0.0f;
  
  //remove sound from visualization
  [ad.visualization removeSound:rmw.soundUuid];
  if ([[ad.visualization activeSound] isEqualToString:rmw.soundUuid])
    [ad.visualization refreshVisual];

  //animate removal of widget
  [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                        delay:0.00
                      options:UIViewAnimationOptionCurveLinear
                   animations:^{
                       rmw.alpha = 0.0f;
                   } completion:^(BOOL finished) {
                     if (finished) {
                       //remove widget from view
                       [moduleWidgets removeObject:rmw];
                       [rmw removeFromSuperview];
                       [self shiftModules:showAddModule];
                       [self updateAddModuleButtonAlpha];
                     }
                   }];
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
      [self showModules];
      menuButton.frame = menuButtonFrame;
      visualButton.frame = visualButtonFrame;
      mixPanelWidget.frame = mixPanelWidgetFrame_offscreen;
      timerPanelWidget.frame = timerPanelWidgetFrame_offscreen;
      playerWidget.frame = playerWidgetFrame;
      break;
    case PlayerState_Visual:
      [self hideModules];
      menuButton.frame = menuButtonFrame_offscreen;
      visualButton.frame = visualButtonFrame_offscreen;
      mixPanelWidget.frame = mixPanelWidgetFrame_offscreen;
      timerPanelWidget.frame = timerPanelWidgetFrame_offscreen;
      playerWidget.frame = playerWidgetFrame_offscreen;
      break;
    case PlayerState_Module:
    {
      menuButton.frame = menuButtonFrame_offscreen;
      visualButton.frame = visualButtonFrame_offscreen;
      mixPanelWidget.frame = mixPanelWidgetFrame_offscreen;
      timerPanelWidget.frame = timerPanelWidgetFrame_offscreen;
      playerWidget.frame = playerWidgetFrame_offscreen;
      ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
      [self hideModulesOnscreen:ad.currentModule];
      [self showModuleExpanded:ad.currentModule];
      [self hideAddModuleButtonIfNeeded:ad.currentModule];
      break;
    }
    case PlayerState_Timer:
      [self hideModules];
      overlayPanelWidget.frame = overlayPanelWidgetFrame;
      menuButton.frame = menuButtonFrame_offscreen;
      visualButton.frame = visualButtonFrame_offscreen;
      mixPanelWidget.frame = mixPanelWidgetFrame_offscreen;
      timerPanelWidget.frame = timerPanelWidgetFrame_offscreen;
      playerWidget.frame = playerWidgetFrame_offscreen;
      break;
    case PlayerState_Menu:
      [self hideModules];
      overlayPanelWidget.frame = overlayPanelWidgetFrame;
      menuButton.frame = menuButtonFrame_offscreen;
      visualButton.frame = visualButtonFrame_offscreen;
      mixPanelWidget.frame = mixPanelWidgetFrame_offscreen;
      timerPanelWidget.frame = timerPanelWidgetFrame_offscreen;
      playerWidget.frame = playerWidgetFrame_offscreen;
      break;
    case PlayerState_Mix:
      [self hideModules];
      overlayPanelWidget.frame = overlayPanelWidgetFrame;
      menuButton.frame = menuButtonFrame_offscreen;
      visualButton.frame = visualButtonFrame_offscreen;
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
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  if ([self canChangeToState:state]) {
    switch (state)
    {
      case PlayerState_Main:
      {
        if (currPlayerState == PlayerState_Visual)
        {
          transitionState = state;
          currPlayerState = PlayerState_Transitioning;
          
          [ad.visualization setVisualizationState:Background];
          [ad.visualization setInputEnabled:false];
          
          [self transitionInModules];
          
          [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_SLOW
                  delay:0.00
                  options:UIViewAnimationOptionCurveEaseOut
                  animations:^{
                    playerWidget.frame = playerWidgetFrame;
                  } completion:nil];
          
          float delay = [moduleWidgets count] >= 2 ? 0.75f : 0.5f;
          [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                                delay:delay
                              options:UIViewAnimationOptionCurveEaseOut
                           animations:^{
                             menuButton.frame = menuButtonFrame;
                             visualButton.frame = visualButtonFrame;
                           } completion:nil];
        }
        if (currPlayerState == PlayerState_Menu || currPlayerState == PlayerState_Mix || currPlayerState == PlayerState_Timer)
        {
          transitionState = state;
          currPlayerState = PlayerState_Transitioning;
          
          [self transitionInModules];
                    
          [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_SLOW
                                delay:0.00
                              options:UIViewAnimationOptionCurveEaseOut
                           animations:^{
                             overlayPanelWidget.alpha = 0.0f;
                             playerWidget.frame = playerWidgetFrame;
                           } completion:^(BOOL finished) {
                             if (finished) {
                             }
                           }];
          
          float delay = [moduleWidgets count] >= 2 ? 0.75f : 0.5f;
          [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                                delay:delay
                              options:UIViewAnimationOptionCurveEaseOut
                           animations:^{
                             menuButton.frame = menuButtonFrame;
                             visualButton.frame = visualButtonFrame;
                           } completion:nil];

        }
        if (currPlayerState == PlayerState_Module) {
          
          transitionState = state;
          currPlayerState = PlayerState_Transitioning;
          
          [self updateAddModuleButtonAlpha];
          
          //1) transition expanded module back to normal
          [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                                delay:0.0
                              options:UIViewAnimationOptionCurveEaseOut
                           animations:^{
                             if (ad.currentModule == nil) {
                               addModuleButton.frame = expandedModuleFrame;
                             } else {
                               ResoModuleWidget * rmw = [self getModuleWithUuid:ad.currentModule];
                               rmw.frame = expandedModuleFrame;
                             }
                           } completion:^(BOOL finished) {
                             if (finished) {
                               //2) fade in other modules + transition in menu items
                               [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseOut
                                                animations:^{
                                                  if (moduleWidgets.count < MAX_NUM_MODULES) {
                                                    addModuleButton.alpha = 1.0f;
                                                    addModuleButton.titleLabel.alpha = 1.0f;
                                                  }
                                                  menuButton.frame = menuButtonFrame;
                                                  visualButton.frame = visualButtonFrame;
                                                  playerWidget.frame = playerWidgetFrame;
                                                  for(ResoModuleWidget * rmw in moduleWidgets) {
                                                    rmw.alpha = 1.0f;
                                                    rmw.expandButton.alpha = PLAYER_ICON_OPACITY;
                                                    bool activeSound = [[ad.visualization activeSound] isEqualToString:rmw.soundUuid];
                                                    rmw.toggleRemoveButton.alpha = activeSound ? MODULE_THUMB_OPACITY_ACTIVE : MODULE_THUMB_OPACITY_ACTIVE;
                                                    rmw.volumeSlider.alpha = 1.0f;
                                                  }
                                                } completion:^(BOOL finished) {
                                                  if (finished) {
                                                    [self completeTransition];
                                                  }
                                                }];
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
                           playerWidget.frame = playerWidgetFrame_offscreen;
                         } completion:nil];
        [self transitionOutModules];
        break;
      }
      case PlayerState_Module:
      {
        transitionState = state;
        currPlayerState = PlayerState_Transitioning;
        
        ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
        NSString * currentModule = ad.currentModule;
        if (currentModule == nil) {

          [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                                delay:0
                              options:UIViewAnimationOptionCurveLinear
                           animations:^{
                             menuButton.frame = menuButtonFrame_offscreen;
                             visualButton.frame = visualButtonFrame_offscreen;
                             playerWidget.frame = playerWidgetFrame_offscreen;
                             addModuleButton.titleLabel.alpha = 0.0f;
                             [addModuleButton setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_NORMAL]];
                             for(ResoModuleWidget * rmw in moduleWidgets) {
                               rmw.alpha = 0.0f;
                             }
                           } completion:^(BOOL finished){
                             [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                addModuleButton.frame = overlayPanelWidgetFrame;
                                                [ad.visualization setActiveSound:nil];
                                              } completion:^(BOOL finished) {
                                                if (finished) {
                                                  [self completeTransition];
                                                }
                                              }];
                           }];
        } else {
          [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                                delay:0.00
                              options:UIViewAnimationOptionCurveLinear
                           animations:^{
                             //fade out all elements except for current module
                             menuButton.frame = menuButtonFrame_offscreen;
                             visualButton.frame = visualButtonFrame_offscreen;
                             playerWidget.frame = playerWidgetFrame_offscreen;
                             addModuleButton.alpha = 0.0f;
                             for(ResoModuleWidget * rmw in moduleWidgets) {
                               if (currentModule != rmw.uuid) {
                                 rmw.alpha = 0.0f;
                               } else {
                                 rmw.expandButton.alpha = 0.0f;
                                 rmw.volumeSlider.alpha = 0.0f;
                                 rmw.removeButton.alpha = 0.0f;
                                 rmw.toggleRemoveButton.alpha = 0.0f;
                               }
                             }
                           } completion:^(BOOL finished){
                             [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                                                   delay:0.00
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                //expand current module to full screen
                                                for(ResoModuleWidget * rmw in moduleWidgets) {
                                                  if (currentModule == rmw.uuid) {
                                                    rmw.frame = overlayPanelWidgetFrame;
                                                  }
                                                }
                                                [ad.visualization setActiveSound:currentUuid];
                                              } completion:^(BOOL finished) {
                                                if (finished) {
                                                  [self completeTransition];
                                                }
                                              }];
                             
                           }];

        }
        break;
      }
      case PlayerState_Timer:
      {
        transitionState = state;
        currPlayerState = PlayerState_Transitioning;
        
        overlayPanelWidget.frame = overlayPanelWidgetFrame;
        overlayPanelWidget.alpha = 0.0f;
        
        [ad.visualization enableTransitions:false];
        
        [self transitionOutModules];
        
        [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                              delay:0.00
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                           menuButton.frame = menuButtonFrame_offscreen;
                           visualButton.frame = visualButtonFrame_offscreen;
                           playerWidget.frame = playerWidgetFrame_offscreen;
                           overlayPanelWidget.alpha = 1.0f;
                         } completion:^(BOOL finished){
                            [ad.visualization setActiveSound:nil];
                         }];
        break;
      }
      case PlayerState_Menu:
      {
        transitionState = state;
        currPlayerState = PlayerState_Transitioning;
        
        overlayPanelWidget.frame = overlayPanelWidgetFrame;
        overlayPanelWidget.alpha = 0.0f;
        
        [ad.visualization enableTransitions:false];
        
        [self transitionOutModules];
        
        [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                              delay:0.00
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                           overlayPanelWidget.alpha = 1.0f;
                           menuButton.frame = menuButtonFrame_offscreen;
                           visualButton.frame = visualButtonFrame_offscreen;
                           playerWidget.frame = playerWidgetFrame_offscreen;
                         } completion:^(BOOL finished){
                           [ad.visualization setActiveSound:nil];
                         }];
        break;
      }
      case PlayerState_Mix:
      {
        transitionState = state;
        currPlayerState = PlayerState_Transitioning;
        
        overlayPanelWidget.frame = overlayPanelWidgetFrame;
        overlayPanelWidget.alpha = 0.0f;
        
        [ad.visualization enableTransitions:false];
        
        [self transitionOutModules];
        
        [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                              delay:0.00
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                           overlayPanelWidget.alpha = 1.0f;
                           menuButton.frame = menuButtonFrame_offscreen;
                           visualButton.frame = visualButtonFrame_offscreen;
                           playerWidget.frame = playerWidgetFrame_offscreen;
                         } completion:^(BOOL finished) {
                           [ad.visualization setActiveSound:nil];
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
    {
      ResoModuleViewController * rmvc = [[ResoModuleViewController alloc] initWithNibName:nil bundle:nil];
      [self.navigationController pushViewController:rmvc animated:NO];
      break;
    }
    case PlayerState_Timer:
    {
      ResoClocksViewController * rcvc = [[ResoClocksViewController alloc] initWithNibName:nil bundle:nil];
      [self.navigationController pushViewController:rcvc animated:NO];
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
  [self calculateModuleWidgetFrames];
    
  //menu button
  menuButtonFrame = CGRectMake(0, 0, 50, 50);
  menuButtonFrame_offscreen = CGRectMake(-50, 0, 50, 50);
  
  //visual button
  visualButtonFrame = CGRectMake([ResoAppDelegate windowWidth]-50, 0, 50, 50);
  visualButtonFrame_offscreen = CGRectMake([ResoAppDelegate windowWidth]+50, 0, 50, 50);
  
  //add module button
  NSArray * frames = [moduleWidgetFrames objectForKey:[NSNumber numberWithInt:0]];
  addModuleButtonFrame = [[frames objectAtIndex:0] CGRectValue];
  addModuleButtonFrame_offscreen = moduleWidgetFrame_offscreen;
  
  //mix panel widget
  mixPanelWidgetFrame = [ResoAppDelegate windowFrame];
  mixPanelWidgetFrame_offscreen = CGRectMake(10, [ResoAppDelegate windowHeight] - 10, 0, 0);
  
  //timer panel widget
  timerPanelWidgetFrame = [ResoAppDelegate windowFrame];
  timerPanelWidgetFrame_offscreen = CGRectMake([ResoAppDelegate windowWidth]-10, [ResoAppDelegate windowHeight] - 10, 0, 0);
  
  //player widget
  playerWidgetFrame = CGRectMake(0, [ResoAppDelegate windowHeight] - PLAYER_WIDGET_HEIGHT, [ResoAppDelegate windowWidth], PLAYER_WIDGET_HEIGHT);
  playerWidgetFrame_offscreen = CGRectMake(0, [ResoAppDelegate windowHeight] + PLAYER_WIDGET_HEIGHT, [ResoAppDelegate windowWidth], PLAYER_WIDGET_HEIGHT);
  
  //overlay
  overlayPanelWidgetFrame = CGRectMake(0, 0, [ResoAppDelegate windowWidth], [ResoAppDelegate windowHeight]);
  overlayPanelWidgetFrame_offscreen = CGRectMake(0, 0, 0, 0);
}

-(void)calculateModuleWidgetFrames
{
  //what we want to do is center the entire block of modules in the screen no
  //matter how many elements are there
  
  // 0 - add module button is visible
  // 1 - one module + add module is visible
  // 2 - two modules + add module is visible
  // 3 - three modules + add module is visible
  // 4 - four modules is visible
  
  int moduleHeight = MODULE_HEIGHT;
  int moduleX = MODULE_X;
  int moduleWidth = [ResoAppDelegate windowWidth] - (moduleX * 2);
  int moduleGap = MODULE_GAP;
  
  //offscreen
  moduleWidgetFrame_offscreen = CGRectMake(moduleX, -(moduleHeight), moduleWidth, moduleHeight);
  
  for (int i = 0; i <= MAX_NUM_MODULES; i++) {
    
    NSMutableArray * frames = [[NSMutableArray alloc] init];
    
    int num_modules = (i < MAX_NUM_MODULES) ? i+1 : i;
    int num_module_gaps = (i < MAX_NUM_MODULES) ? i : i-1;
    
    //1) calculate block height: height of all modules + gaps
    int moduleBlockHeight = (num_modules * moduleHeight) + (num_module_gaps * moduleGap) + (moduleHeight / 2);
    
    //2) get y position of vertically centered block
    float blockY = ([ResoAppDelegate windowHeight] / 2.0f) - (moduleBlockHeight / 2.0f) - 5;
    
    //3) create frame for each module in current iteration
    for (int k = 0; k < num_modules; k++) {
      
      float moduleY = (k > 0) ? (blockY + (moduleHeight * k) + (moduleGap * k)) : blockY;
      CGRect frame = CGRectMake(moduleX, moduleY, moduleWidth, moduleHeight);
      [frames addObject:[NSValue valueWithCGRect:frame]];

    }

    //4) add frames for this module count to moduleWidgetFrames
    [moduleWidgetFrames setObject:frames forKey:[NSNumber numberWithInt:i]];
  }
}

-(void)createModuleWidgets
{
  [moduleWidgets makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [moduleWidgets removeAllObjects];
  
  ResoModuleManager * rrm = [ResoModuleManager instance];
  ResoModuleWidget * currModuleWidget = nil;
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  
  for (id key in rrm.modules) {
    ResoModule * rm = [rrm.modules objectForKey:key];
    if ([rm loaded] && ![rm.moduleUuid isEqualToString:@"preview"]) {
      ResoModuleWidget * rmw = [[ResoModuleWidget alloc] initWithFrame:moduleWidgetFrame_offscreen withSound:rm.soundUuid];
      [rmw.volumeSlider setValue:[rm.sound volume] * 100];
      [rmw.expandButton addTarget:self action:@selector(expandModule:) forControlEvents:UIControlEventTouchUpInside];
      [rmw.removeButton addTarget:self action:@selector(removeModule:) forControlEvents:UIControlEventTouchUpInside];
      rmw.uuid = rm.moduleUuid;
      [rmw.titleLabel setText:rm.moduleUuid];
      [rmw setBackgroundColor:[UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:WIDGET_ALPHA_NORMAL]];
      rmw.layer.borderWidth = 0.0f;
      rmw.layer.cornerRadius = CORNER_RADIUS;
      [self.view addSubview:rmw];
      
      if ([rm.moduleUuid isEqualToString:ad.currentModule]) {
        //don't add the current module widget to the list yet
        currModuleWidget = rmw;
      } else {
        [moduleWidgets addObject:rmw];
      }
    }
  }
  if (currModuleWidget != nil && ad.currentModulePosition < 0) {
    //module is new, so add it to the end of the list
    [moduleWidgets addObject:currModuleWidget];
  } else if (currModuleWidget != nil && ad.currentModulePosition >= 0) {
    //module existed before, so insert at previous index
    [moduleWidgets insertObject:currModuleWidget atIndex:ad.currentModulePosition];
  }
  
  //set thumb opacities based on active sound
  for(ResoModuleWidget * rmw in moduleWidgets) {
    bool activeSound = [[ad.visualization activeSound] isEqualToString:rmw.soundUuid];
    rmw.toggleRemoveButton.alpha = activeSound ? MODULE_THUMB_OPACITY_ACTIVE : MODULE_THUMB_OPACITY_ACTIVE;
  }
  
  //update add module button alpha based on number of widgets
  UIColor * addModuleColor = [UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:([moduleWidgets count] > 0 ? WIDGET_ALPHA_LIGHT : WIDGET_ALPHA_NORMAL)];
  [addModuleButton setBackgroundColor:addModuleColor];
}

-(void)transitionInModules
{
  int count = [moduleWidgets count];
  bool maxed_modules = [moduleWidgets count] == MAX_NUM_MODULES;
  NSArray * frames = [moduleWidgetFrames objectForKey:[NSNumber numberWithInt:count]];
  for (int i = 0; i < [frames count]; i++) {
    bool last = (i+1 == [frames count]);
    int delayMultiplier = [frames count] - i;
    CGRect f = [[frames objectAtIndex:i] CGRectValue];
    if ((count < MAX_NUM_MODULES) && ((i+1) == [frames count])) {
      f.size.height = f.size.height / ADD_MODULE_HEIGHT_DIVISOR;
      [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                            delay:(delayMultiplier * TRANSITION_STAGGER_OFFSET)
                          options:UIViewAnimationOptionCurveEaseOut
                       animations:^{
                         addModuleButton.frame = f;
                       } completion:^(BOOL finished) {
                         if (finished) {
                           [self completeTransition];
                         }
                       }];
    } else {
      ResoModuleWidget * rmw = [moduleWidgets objectAtIndex:i];
      [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                            delay:(delayMultiplier * TRANSITION_STAGGER_OFFSET)
                          options:UIViewAnimationOptionCurveEaseOut
                       animations:^{
                         rmw.frame = f;
                       } completion:^(BOOL finished) {
                         if (finished && last && maxed_modules) {
                           [self completeTransition];
                         }
                       }];

    }
  }
}

-(void)transitionOutModules
{
  int counter = 0;
  bool maxed_modules = [moduleWidgets count] == MAX_NUM_MODULES;
  for (ResoModuleWidget * rmw in moduleWidgets) {
    bool last = (counter+1 == [moduleWidgets count]);
    [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                          delay:(counter * TRANSITION_STAGGER_OFFSET)
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                       rmw.frame = moduleWidgetFrame_offscreen;
                     } completion:^(BOOL finished) {
                       if (finished && last && maxed_modules) {
                         [self completeTransition];
                       }
                     }];
    counter++;
  }
  //add module button
  if ([moduleWidgets count] < MAX_NUM_MODULES) {
    CGRect rect = moduleWidgetFrame_offscreen;
    rect.size.height = rect.size.height / ADD_MODULE_HEIGHT_DIVISOR;
    [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_NORMAL
                          delay:(counter * TRANSITION_STAGGER_OFFSET)
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                       addModuleButton.frame = rect;
                     } completion:^(BOOL finished) {
                       if (finished) {
                         [self completeTransition];
                       }
                     }];
  }
}

-(void)showModules
{
  //instantly set all module widgets to onscreen location
  int count = [moduleWidgets count];
  NSArray * frames = [moduleWidgetFrames objectForKey:[NSNumber numberWithInt:count]];
  for (int i = 0; i < [frames count]; i++) {
    CGRect f = [[frames objectAtIndex:i] CGRectValue];
    if ((count < MAX_NUM_MODULES) && ((i+1) == [frames count])) {
      f.size.height = f.size.height / ADD_MODULE_HEIGHT_DIVISOR;
      addModuleButton.frame = f;
    } else {
      ResoModuleWidget * rmw = [moduleWidgets objectAtIndex:i];
      rmw.frame = f;
    }
  }
}

-(void)hideModules
{
  //instantly set all module widgets to offscreen location
  for (ResoModuleWidget * rmw in moduleWidgets) {
    rmw.frame = moduleWidgetFrame_offscreen;
  }
  CGRect rect = moduleWidgetFrame_offscreen;
  rect.size.height = rect.size.height / ADD_MODULE_HEIGHT_DIVISOR;
  addModuleButton.frame = rect;
}

-(void)hideModulesOnscreen:(NSString*)uuid
{
  //setup modules to their onscreen location with an alpha of 0.0f
  //instantly set all module widgets to onscreen location
  int count = [moduleWidgets count];
  NSArray * frames = [moduleWidgetFrames objectForKey:[NSNumber numberWithInt:count]];
  for (int i = 0; i < [frames count]; i++) {
    CGRect f = [[frames objectAtIndex:i] CGRectValue];
    if ((count < MAX_NUM_MODULES) && ((i+1) == [frames count])) {
      f.size.height = f.size.height / ADD_MODULE_HEIGHT_DIVISOR;
      addModuleButton.alpha = 0.0f;
      addModuleButton.frame = f;
      if (uuid == nil) {
        expandedModuleFrame = f; //so we can later transition to this frame
      }
    } else {
      ResoModuleWidget * rmw = [moduleWidgets objectAtIndex:i];
      rmw.alpha = 0.0f;
      rmw.frame = f;
      if ([uuid isEqualToString:rmw.uuid]) {
        expandedModuleFrame = f;  //so we can later transition to this frame
      }
    }
  }
}

-(void)showModuleExpanded:(NSString*)uuid
{
  //iterate through module widgets, expand one with uuid matching argument
  if (uuid == nil) {
    addModuleButton.frame = overlayPanelWidgetFrame;
    addModuleButton.alpha = 1.0f;
  } else {
    for (ResoModuleWidget * rmw in moduleWidgets) {
      if ([uuid isEqualToString:rmw.uuid]) {
        rmw.frame = overlayPanelWidgetFrame;
        rmw.alpha = 1.0f;
        rmw.toggleRemoveButton.alpha = 0.0f;
        rmw.volumeSlider.alpha = 0.0f;
        rmw.expandButton.alpha = 0.0f;
      }
    }
  }
}

-(void)hideAddModuleButtonIfNeeded:(NSString*)uuid
{
  if (uuid != nil && moduleWidgets.count >= MAX_NUM_MODULES) {
    addModuleButton.frame = addModuleButtonFrame_offscreen;
    addModuleButton.alpha = 0.0f;
  }
}

-(void)updateAddModuleButtonAlpha
{
  //update button alpha based on number of widgets
  UIColor * addModuleColor = [UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:([moduleWidgets count] > 0 ? WIDGET_ALPHA_LIGHT : WIDGET_ALPHA_NORMAL)];
  
  //animate update
  [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseIn
                   animations:^{
                     addModuleButton.backgroundColor = addModuleColor;
                   } completion:nil];
}

-(void)shiftModules:(bool)showAddModule
{
  //get frames for current module count, animate the current widgets to those frames
  int count = [moduleWidgets count];
  NSArray * frames = [moduleWidgetFrames objectForKey:[NSNumber numberWithInt:count]];
  for (int i = 0; i < [frames count]; i++) {
    CGRect f = [[frames objectAtIndex:i] CGRectValue];
    if ((count < MAX_NUM_MODULES) && ((i+1) == [frames count])) {
      f.size.height = f.size.height / ADD_MODULE_HEIGHT_DIVISOR;
      if (showAddModule) {
        //first move to position
        addModuleButton.alpha = 0.0f;
        addModuleButton.titleLabel.alpha = 0.0f;
        addModuleButton.frame = f;
        
        //update button alpha based on number of widgets
        UIColor * addModuleColor = [UIColor colorWithRed:WIDGET_RED green:WIDGET_GREEN blue:WIDGET_BLUE alpha:([moduleWidgets count] > 0 ? WIDGET_ALPHA_LIGHT : WIDGET_ALPHA_NORMAL)];
        [addModuleButton setBackgroundColor:addModuleColor];
        
        //fade in
        [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                           addModuleButton.alpha = 1.0f;
                           addModuleButton.titleLabel.alpha = 1.0f;
                         } completion:nil];
      } else {
        
        [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                           addModuleButton.frame = f;
                           addModuleButton.alpha = 1.0f;
                         } completion:nil];
      }

    } else {
      ResoModuleWidget * rmw = [moduleWidgets objectAtIndex:i];
      [UIView animateWithDuration:PLAYER_TRANSITION_DURATION_FAST
                            delay:0.0
                          options:UIViewAnimationOptionCurveEaseIn
                       animations:^{
                         rmw.frame = f;
                       } completion:nil];
    }
  }

}

-(ResoModuleWidget*)getModuleWithUuid:(NSString*)uuid
{
  for (ResoModuleWidget * rmw in moduleWidgets) {
    if ([uuid isEqualToString:rmw.uuid])
      return rmw;
  }
  return nil;
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
