//
//  EarthquakeTableViewCell.m
//  EarthQuake
//
//  Created by Liu Zhe on 12/17/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#import "EarthquakeTableViewCell.h"

@implementation EarthquakeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    if (IOS9_UP)
    {
        self.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17.0f];
        self.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    }
    self.textLabel.numberOfLines = 1;
    self.detailTextLabel.numberOfLines = 1;
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpwithEarthquake:(EarthQuake *)earthquake
{
    [self.textLabel setText:[earthquake getTitle]];
    [self.detailTextLabel setText:[earthquake getTime]];
}

@end
