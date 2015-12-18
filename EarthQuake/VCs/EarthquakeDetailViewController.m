//
//  EarthquakeDetailViewController.m
//  EarthQuake
//
//  Created by Liu Zhe on 12/17/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#define segmentHeight               50.0f
#define pagerHeight                 300.0f
#define gapHeight                   20.0f
#define sectionLabelHeight          35.0f
#define lineGap                     15.0f
#define gapHeight                   20.0f
#define lineHeight                  3.0f

#import "EarthquakeDetailViewController.h"
#import <MapKit/MapKit.h>
#import "HMSegmentedControl.h"

@interface EarthquakeDetailViewController ()

@property (nonatomic, strong) EarthQuake *theEarthequake;
@property (nonatomic, strong) MKMapView *locationMapView;
@property (nonatomic, strong) HMSegmentedControl *topSegment;

@end

@implementation EarthquakeDetailViewController

- (instancetype)initWithEarthquake:(EarthQuake *)earthquake
{
    self = [super init];
    if (self)
    {
        _theEarthequake = earthquake;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
