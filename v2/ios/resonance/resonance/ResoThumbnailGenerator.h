//
//  ResoThumbnailGenerator.h
//  resonance
//
//  Created by Daniel Stepp on 6/15/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResoThumbnailGenerator : NSObject
-(UIImage*)generateMixThumbnail:(NSArray*)uuids;
@end
