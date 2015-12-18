//
//  ZLAnnotation.h
//  EarthQuake
//
//  Created by Liu Zhe on 12/18/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "EarthQuake.h"

@interface ZLAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)earthquakeCoordinate;


@end
