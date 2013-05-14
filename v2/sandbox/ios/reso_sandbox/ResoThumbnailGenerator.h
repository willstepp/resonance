//
//  ResoThumbnailGenerator.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/14/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResoThumbnailGenerator : NSObject
-(UIImage*)generateMixThumbnail:(NSArray*)uuids;
@end
