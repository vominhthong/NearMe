//
//  ListViewCell.m
//  NearMeT3H
//
//  Created by MC372 on 5/23/13.
//  Copyright (c) 2013 MC372. All rights reserved.
//

#import "ListViewCell.h"

@implementation ListViewCell

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

@end
