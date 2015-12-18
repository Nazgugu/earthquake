//
//  EarthQuakeFetchManager.m
//  EarthQuake
//
//  Created by Liu Zhe on 12/17/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#import "EarthQuakeFetchManager.h"
#import <AFNetworking/AFNetworking.h>
#import "ValueKeyDefine.h"
#import "EarthQuake.h"

@implementation EarthQuakeFetchManager

//singleton
//use dispatch_once over @synthesized is that it is faster 
+ (instancetype)sharedManager
{
    static EarthQuakeFetchManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)fetchEarthquakesWithLocation:(CLLocationCoordinate2D)locationCoord andRadiusInKM:(CGFloat)radius withPage:(NSInteger)pageNum inBackgroundWithBlock:(EarthquakesBlock)block
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.operationQueue cancelAllOperations];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSMutableArray *searchResult = [NSMutableArray new];
    NSString *urlString = [NSString stringWithFormat:@"http://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=2014-01-01&endtime=2014-10-02&latitude=%lf&longitude=%lf&maxradiuskm=%lf&minmagnitude=3.0&limit=10&offset=%ld&orderby=time",locationCoord.latitude,locationCoord.longitude,radius,pageNum * 10];
    NSLog(@"url = %@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    [manager GET:url.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject)
        {
//            NSLog(@"GOT RESPONSE");
            NSArray *events = [responseObject objectForKey:@"features"];
//            if ([[responseObject objectForKey:@"features"] isKindOfClass:[NSArray class]])
//            {
//                NSLog(@"yes it is array");
//            }
//             NSLog(@"%@", events);
            if (events.count > 0)
            {
                for (NSDictionary *dict in events)
                {
                    EarthQuake *earthquake = [[EarthQuake alloc] initWithDictionary:dict];
                    [searchResult addObject:earthquake];
                }
            }
            block(searchResult, nil);
        }
       
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil, error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

@end
