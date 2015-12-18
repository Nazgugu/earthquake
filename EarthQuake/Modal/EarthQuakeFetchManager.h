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

- (void)fetchEarthquakesWithLocation:(CLLocationCoordinate2D)locationCoord andRadiusInKM:(CGFloat)radius withPage:(NSInteger)pageNum withStartDate:(NSString *)startDate andEndDate:(NSString *)endDate inBackgroundWithBlock:(EarthquakesBlock)block;

- (void)fetchEarthquakesWithMinLat:(double)minLat maxLat:(double)maxLat minLong:(double)minLong maxLong:(double)maxLong startDate:(NSString *)startDate endDate:(NSString *)endDate inBackgroundWithBlock:(EarthquakesBlock)block;

@end
