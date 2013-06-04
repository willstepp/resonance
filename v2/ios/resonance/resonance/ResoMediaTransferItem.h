//
//  ResoMediaTransferItem.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/3/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResoTypes.h"

@interface ResoMediaTransferItem : NSObject
@property (nonatomic, readwrite) MediaTransfer transferType;
@property (nonatomic, readwrite) NSString * sourceUrl;
@property (nonatomic, readwrite) NSString * destinationUrl;
@end
