//
//  EarthQuake.h
//  EarthQuake
//
//  Created by Liu Zhe on 12/17/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface EarthQuake : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSString *)getTitle;

- (NSString *)getTime;

- (NSString *)getAddress;

- (NSInteger)getSignificance;

- (CGFloat)getIntensity;

- (BOOL)doesHaveTsunami;

- (NSString *)getAlert;

- (CLLocationCoordinate2D)getLocation;

- (NSURL *)getDetailWebAddress;

- (CGFloat)getMagnitude;

- (CGFloat)getDepth;

@end
