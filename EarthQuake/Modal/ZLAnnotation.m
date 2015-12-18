//
//  ZLAnnotation.m
//  EarthQuake
//
//  Created by Liu Zhe on 12/18/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#import "ZLAnnotation.h"

@interface ZLAnnotation()

@end

@implementation ZLAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)earthquakeCoordinate
{
    self = [super init];
    if (self)
    {
        _coordinate = earthquakeCoordinate;
    }
    return self;
}

@end
