//
//  DetailsCell.h
//  NearMeT3H
//
//  Created by MC372 on 5/24/13.
//  Copyright (c) 2013 MC372. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *nameDetails;
@property (retain, nonatomic) IBOutlet UILabel *addressDetails;
@property (retain, nonatomic) IBOutlet UILabel *distane;
@property (retain, nonatomic) IBOutlet UILabel *value;

@end
