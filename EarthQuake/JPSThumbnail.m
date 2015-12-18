//
//  JPSThumbnail.m
//  JPSThumbnailAnnotation
//
//  Created by Jean-Pierre Simard on 4/22/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import "JPSThumbnail.h"

@interface JPSThumbnail()

@property (nonatomic, strong) EarthQuake *theEarthquake;

@end

@implementation JPSThumbnail

- (instancetype)initWithLocation:(EarthQuake *)location
{
    self = [super init];
    if (self)
    {
        _theEarthquake = location;
    }
    return self;
}

- (NSString *)getTime
{
    return [self.theEarthquake getTime];
}

- (NSString *)getAddress
{
    return [self.theEarthquake getAddress];
}

- (CLLocationCoordinate2D)getLocationCoordinate
{
    return [self.theEarthquake getLocation];
}

- (EarthQuake *)getLocation
{
    return self.theEarthquake;
}

- (NSString *)getMagnitude
{
    return [NSString stringWithFormat:@"%.1lf",[self.theEarthquake getMagnitude]];
}

@end
