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

@end
