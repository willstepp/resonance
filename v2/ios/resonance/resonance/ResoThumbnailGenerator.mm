//
//  ResoThumbnailGenerator.m
//  resonance
//
//  Created by Daniel Stepp on 6/15/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoAppDelegate.h"
#import "ResoFileManager.h"
#import "ResoThumbnailGenerator.h"

@implementation ResoThumbnailGenerator
-(UIImage*)generateMixThumbnail:(NSArray*)uuids
{
  NSMutableArray * mixImages = [[NSMutableArray alloc] initWithCapacity:[uuids count]];
  
  //1) load all sound images into an array
  for (NSString * uuid in uuids) {
    NSString * mixImagePath = [[ResoFileManager resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/img_blur", uuid]] path];
    UIImage * mixImage = [UIImage imageWithContentsOfFile:mixImagePath];
    [mixImages addObject:mixImage];
  }
  
  //3) create new 300X300 image
  CGRect rect = CGRectMake(0.0f, 0.0f, 300.0f, 300.0f);
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
  CGContextFillRect(context, rect);
  
  //4) 25 times, grab a random 60X60 square from a random uiimage blur
  int xo = 0;
  int yo = 0;
  for (int i = 1; i <= 25; i++) {
    
    //5) write random image slice into the new 300X300 thumbnail
    UIImage * img = [mixImages objectAtIndex:(arc4random() % [mixImages count])];
    int maxX = img.size.width - 60;
    int maxY = img.size.height - 60;
    CGRect sliceRect = CGRectMake(arc4random() % maxX, arc4random() % maxY, 60, 60);
    CGImageRef drawImage = CGImageCreateWithImageInRect(img.CGImage, sliceRect);
    CGContextDrawImage(context, CGRectMake(xo * 60, yo * 60, 60, 60), drawImage);
    xo++;
    if (i % 5 == 0) {
      yo++;
      xo = 0;
    }
  }
  
  //6) return new uiimage thumbnail
  UIImage * mixThumbnail = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return mixThumbnail;
}
@end