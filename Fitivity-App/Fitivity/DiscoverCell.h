//
//  DiscoverCell.h
//  Fitivity
//
//  Created by Nathaniel Doe on 7/16/12.
//  Copyright (c) 2012 Fitivity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "OHAttributedLabel.h"

@interface DiscoverCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet OHAttributedLabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *milesAwayLabel;
@property (weak, nonatomic) IBOutlet PFImageView *pictureView;
@property (weak, nonatomic) IBOutlet UIImageView *todayIndicator;

@end
