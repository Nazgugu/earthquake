//
//  AppDelegate.m
//  EarthQuake
//
//  Created by Liu Zhe on 12/16/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "MainEQViewController.h"
#import "EarthQuakeFetchManager.h"

@interface AppDelegate ()<CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:locationGPS])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:locationGPS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self requestLocationService];
    [self setUpWindow];
    [self setUpNavigationBarStyle];
    [self setUpMainView];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Initialization Steps

- (void)requestLocationService
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = 25.0f;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if ([CLLocationManager locationServicesEnabled])
    {
        if (status == kCLAuthorizationStatusNotDetermined || status == kCLAuthorizationStatusDenied)
        {
            if([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            {
                [_locationManager requestWhenInUseAuthorization];
                [_locationManager startUpdatingLocation];
            }
        }
        else if (status == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            [_locationManager startUpdatingLocation];
        }
    }
}

- (void)setUpWindow
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
}

- (void)setUpNavigationBarStyle
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.227f green:0.133f blue:0.314f alpha:1.00f]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setOpaque:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)setUpMainView
{
    MainEQViewController *mainEQVC = [[MainEQViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainEQVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    CLLocation *lastLocation = [locations lastObject];
    NSArray *location = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%lf",lastLocation.coordinate.latitude], [NSString stringWithFormat:@"%lf",lastLocation.coordinate.longitude], nil];
    [[NSUserDefaults standardUserDefaults] setObject:location forKey:locationGPS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:locationObtained object:nil];
}

@end
