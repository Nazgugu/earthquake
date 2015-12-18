//
//  EarthQuakeFetchManager.h
//  EarthQuake
//
//  Created by Liu Zhe on 12/17/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^EarthquakesBlock)(NSArray *earthquakesArray, NSError *error);

@interface EarthQuakeFetchManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchEarthquakesWithLocation:(CLLocationCoordinate2D)locationCoord andRadiusInKM:(CGFloat)radius withPage:(NSInteger)pageNum inBackgroundWithBlock:(EarthquakesBlock)block;

@end
