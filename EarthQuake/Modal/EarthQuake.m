//
//  EarthQuake.m
//  EarthQuake
//
//  Created by Liu Zhe on 12/17/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#import "EarthQuake.h"
#import "ValueKeyDefine.h"

@interface EarthQuake()

@property (nonatomic, assign) CLLocationCoordinate2D locationCoord;
//in KM
@property (nonatomic, assign) CGFloat depth;
@property (nonatomic, strong) NSString *locationAddress;
@property (nonatomic, assign) CGFloat magnitude;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *webURL;
//how important this event is (1 ~ 1000)
@property (nonatomic, assign) NSInteger  significance;
@property (nonatomic, assign) BOOL hasTsunami;
@property (nonatomic, assign) CGFloat maxInstrumentalIntensity;
@property (nonatomic, strong) NSString *alert;
@property (nonatomic, strong) NSDate *time;

@end

@implementation EarthQuake

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        NSDictionary *geoDict  = [dict objectForKey:kGeo];
        NSDictionary *propertyDict = [dict objectForKey:kPeoperty];
        _locationCoord = CLLocationCoordinate2DMake([[[geoDict objectForKey:kCoord] objectAtIndex:0] floatValue], [[[geoDict objectForKey:kCoord] objectAtIndex:1] floatValue]);
        _depth = [[[geoDict objectForKey:kCoord] objectAtIndex:2] floatValue];
        _locationAddress = [propertyDict objectForKey:kAddress];
        _magnitude = [[propertyDict objectForKey:kMagnitude] floatValue];
        _title = [propertyDict objectForKey:kTitle];
        _webURL = [propertyDict objectForKey:kURL];
        _significance = [[propertyDict objectForKey:kSignificance] integerValue];
        _hasTsunami = [[propertyDict objectForKey:kTsunami] boolValue];
        if ([propertyDict objectForKey:kAlert])
        {
            _alert = [propertyDict objectForKey:kAlert];
        }
        else
        {
            _alert = nil;
        }
        [self convertTime:[[propertyDict objectForKey:kTime] doubleValue]];
    }
    return self;
}

- (void)convertTime:(double)epochTime
{
    NSTimeInterval seconds = epochTime;
    _time = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
}

@end
