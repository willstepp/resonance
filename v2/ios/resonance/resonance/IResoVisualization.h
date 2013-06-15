//
//  IResoVisualization.h
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResoTypes.h"

@protocol ResoVisualizationDelegate <NSObject>

-(void)visualizationStateChanged:(int)newState;
-(void)activeSoundChanged:(NSString*)newSound;

@end

@protocol IResoVisualization <NSObject>

- (NSArray*)delegates;
- (void)addDelegate:(id<ResoVisualizationDelegate>)d;
- (void)removeDelegate:(id<ResoVisualizationDelegate>)d;

-(VisualizationState)visualizationState;
-(void)setVisualizationState:(VisualizationState)vs;

-(NSString*)activeSound;
-(void)setActiveSound:(NSString*)uuid;

-(void)enableAnimations:(bool)enable;

-(void)enableTransitions:(bool)enable;
-(void)refreshVisual;

-(NSArray*)sounds;
-(void)addSound:(NSString*)uuid;
-(void)removeSound:(NSString*)uuid;
-(void)clearSounds;

-(bool)inputEnabled;
-(void)setInputEnabled:(bool)enabled;

@end