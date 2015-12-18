//
//  JPSThumbnail.h
//  JPSThumbnailAnnotation
//
//  Created by Jean-Pierre Simard on 4/22/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EarthQuake.h"
@import MapKit;

typedef void (^ActionBlock)();

@interface JPSThumbnail : NSObject


@property (nonatomic, copy) ActionBlock disclosureBlock;

- (instancetype)initWithLocation:(EarthQuake *)location;

//@property (nonatomic, strong) UIImage *image;

- (NSString *)getTime;

- (NSString *)getAddress;

- (CLLocationCoordinate2D)getLocationCoordinate;

- (EarthQuake *)getLocation;

- (NSString *)getMagnitude;

@end
