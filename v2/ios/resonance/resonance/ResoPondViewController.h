//
//  ResoPondVisualization.h
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "IResoVisualization.h"

@interface ResoPondViewController : GLKViewController <IResoVisualization> {
  NSMutableArray * delegates;
}

- (NSArray*)delegates;
- (void)addDelegate:(id<ResoVisualizationDelegate>)d;
- (void)removeDelegate:(id<ResoVisualizationDelegate>)d;

-(VisualizationState)visualizationState;
-(void)setVisualizationState:(VisualizationState)vs;

-(NSArray*)sounds;
-(void)addSound:(NSString*)uuid;
-(void)removeSound:(NSString*)uuid;

-(NSString*)activeSound;
-(void)setActiveSound:(NSString*)uuid;

-(bool)inputEnabled;
-(void)setInputEnabled:(bool)enabled;

@end
