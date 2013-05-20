//
//  ResoPondVisualization.mm
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoPondVisualization.h"

@implementation ResoPondVisualization

- (void)baseInit {
  [self setBackgroundColor:[UIColor redColor]];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self baseInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    [self baseInit];
  }
  return self;
}
@end
