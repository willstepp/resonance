//
//  ResoTableViewCell.m
//  resonance
//
//  Created by Daniel Stepp on 6/10/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import "ResoTableViewCell.h"
#import "ResoSettings.h"

@implementation ResoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  self.imageView.frame = CGRectMake(5, 5, 50, 50);
}

@end
