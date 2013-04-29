//
//  ResoDataViewController.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 4/29/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResoDataViewController : UIViewController
  @property (nonatomic, retain) UIButton * backButton;
  @property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@end
