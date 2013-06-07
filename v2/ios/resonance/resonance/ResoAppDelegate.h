//
//  ResoAppDelegate.h
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResoTypes.h"

@protocol IResoVisualization;

@interface ResoAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow * window;

@property (readonly, nonatomic) id<IResoVisualization> visualization;
@property (assign, nonatomic) PlayerState currPlayerState;
@property (nonatomic, assign) NSString * currentModule;
@property (nonatomic, assign) int currentModulePosition;
@property (nonatomic, assign) bool playing;


-(NSString*)iosVersionForDownload;
@end
