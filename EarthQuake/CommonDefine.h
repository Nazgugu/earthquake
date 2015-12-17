//
//  AppDelegate.h
//  EarthQuake
//
//  Created by Liu Zhe on 12/16/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#ifndef jiechu_CommonDefine_h
#define jiechu_CommonDefine_h


#define IOS7_UP                ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0 ? YES : NO )
#define IOS8_UP                ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0 ? YES : NO )
#define IOS9_UP                ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 9.0 ? YES : NO )

#define IOS7                (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0 && [[[UIDevice currentDevice] systemVersion] doubleValue] < 8.0) ? YES : NO )
#define IOS7BASE (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0 && [[[UIDevice currentDevice] systemVersion] doubleValue] < 7.1) ? YES : NO )
#define IOS8                (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0 && [[[UIDevice currentDevice] systemVersion] doubleValue] < 9.0) ? YES : NO )

#define IPHONE5             ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define screenBounds [[UIScreen mainScreen] bounds]

#define DEFAULT_FONT        @"STHeitiSC-Medium"
#define DEFAULT_FONT_LIGHT  @"STHeitiSC-Light"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_TRUE_6P ([UIScreen mainScreen].scale > 2.9 ? YES : NO)
#define IS_TRUE_6 ([UIScreen mainScreen].scale < 2.1 ? YES : NO)
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0 && IS_TRUE_6)
#define IS_IPHONE_6P (IS_IPHONE && IS_TRUE_6P)

#define locationGPS @"locationGPS"
#define locationObtained @"gotGPS"

#define COID @"us-east-1:36b72770-a78b-4777-a817-a20ba8a40f96"

#define PFAPPID @"1EA9tlCTlM4xxhbFvAYaywBW7gttLviUJhCyZTfV"
#define PFCLIENTKEY @"yU2jQt39VRcpWv8078sl6xF4Z3Kp3ePAyoSesh1o"
#define GOOGLEAPI @"AIzaSyB4BZiadVUvRiYiR-ACuHtkXY4_hCvKAaM"
#define SEARCHTYPES @"050000|060000|070000|080000|100000|110000|120000|140000|170000"

#endif
