//
//  IResoVisualization.h
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResoTypes.h"

@protocol IResoVisualization <NSObject>

-(void)setVisualizationState:(VisualizationState)vs;
-(VisualizationState)visualizationState;

-(NSArray*)sounds;
-(void)addSound:(NSString*)uuid;
-(void)removeSound:(NSString*)uuid;

-(NSString*)activeSound;
-(void)setActiveSound:(NSString*)uuid;

@end