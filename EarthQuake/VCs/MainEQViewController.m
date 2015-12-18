//
//  MainEQViewController.m
//  EarthQuake
//
//  Created by Liu Zhe on 12/17/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#define earthquakeCellId  @"earthquake"

#import "MainEQViewController.h"
#import "ContentScrollView.h"
#import "HMSegmentedControl.h"
#import <MapKit/MapKit.h>
#import "EarthquakeTableViewCell.h"
#import "MJRefresh.h"
#import "WSProgressHUD.h"
#import "THDatePickerViewController.h"
#import "EarthQuakeFetchManager.h"
#import "RangeSelectionView.h"
#import "EarthquakeDetailViewController.h"
#import "JPSThumbnailAnnotation.h"

typedef NS_OPTIONS(NSInteger, sectionType) {
    sectionTypeTable = 0,
    sectionTypeMap = 1
};

typedef NS_OPTIONS(NSInteger, dateType) {
    dateTypeStart = 0,
    dateTypeEnd = 1
};

@interface MainEQViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, THDatePickerDelegate, RangeSelectionViewDelegate>

@property (nonatomic, strong) UITableView *earthquakeTable;
@property (nonatomic, assign) NSUInteger currentPageNum;
@property (nonatomic, strong) MKMapView *earthquakeMap;
@property (nonatomic, assign) CLLocationCoordinate2D userCoordinate;
@property (nonatomic, assign) BOOL hasLocation;
@property (nonatomic, strong) HMSegmentedControl *topSegment;
@property (nonatomic, strong) ContentScrollView *contentScroll;
@property (nonatomic, assign) sectionType currentType;
@property (nonatomic, strong) THDatePickerViewController * datePicker;
@property (nonatomic, strong) NSMutableArray *earthquakeTableData;
@property (nonatomic, strong) NSMutableArray *earthquakeMapData;
@property (nonatomic, strong) UIBarButtonItem *startCalendarItem;
@property (nonatomic, strong) UIBarButtonItem *magnitudeItem;
@property (nonatomic, strong) UIBarButtonItem *endCalendarItem;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) NSInteger dateType;
@property (nonatomic, strong) UILabel *noDataLabel;

//for map
@property (nonatomic, assign) CLLocationCoordinate2D userCoord;
@property (nonatomic, assign) CLLocationCoordinate2D previousLocation;
@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property (nonatomic, assign) BOOL firstOccuring;
@property (nonatomic, assign) BOOL nextRegionChangeIsFromUserInteraction;
@property (nonatomic, assign) BOOL selectAnnotation;
@property (nonatomic, assign) MKMapRect currentRect;
@property (nonatomic, strong) NSMutableArray *annotationArr;
@property (nonatomic, assign) BOOL userLocated;

@end

@implementation MainEQViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _hasLocation = NO;
        _userLocated = NO;
        _selectAnnotation = NO;
        _firstOccuring = YES;
        _currentType = sectionTypeTable;
        _earthquakeTableData = [NSMutableArray new];
        _earthquakeMapData = [NSMutableArray new];
        _annotationArr = [NSMutableArray new];
        _currentPageNum = 1;
        _endDate = [NSDate date];
        _startDate = [_endDate dateByAddingTimeInterval:- 30 * 24 * 60 * 60];//one month period before
        _radius = 300;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpNavigationTitle];
    [self setUpNavigationBarButton];
    self.title = @"Earthquake";
    [self setUpViews];
    [self setUpDatePicker];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:locationGPS])
    {
        NSArray *userCoord = [[NSUserDefaults standardUserDefaults] objectForKey:locationGPS];
        _userCoordinate = CLLocationCoordinate2DMake([userCoord[0] doubleValue], [userCoord[1] doubleValue]);
        _hasLocation = YES;
        [WSProgressHUD showWithMaskType:WSProgressHUDMaskTypeGradient];
        [self retriveData];
//        NSLog(@"this case");
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotLocation) name:locationObtained object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUpDatePicker
{
    _datePicker = [THDatePickerViewController datePicker];
    _datePicker.delegate = self;
    [self.datePicker setAllowClearDate:NO];
    [self.datePicker setClearAsToday:NO];
    [self.datePicker setAutoCloseOnSelectDate:YES];
    [self.datePicker setAllowSelectionOfSelectedDate:YES];
    [self.datePicker setDisableYearSwitch:NO];
    [self.datePicker setDisableHistorySelection:NO];
    [self.datePicker setDisableFutureSelection:YES];
    [self.datePicker setSelectedBackgroundColor:[UIColor colorWithRed:125/255.0 green:208/255.0 blue:0/255.0 alpha:1.0]];
    [self.datePicker setCurrentDateColor:[UIColor colorWithRed:242/255.0 green:121/255.0 blue:53/255.0 alpha:1.0]];
    [self.datePicker setCurrentDateColorSelected:[UIColor yellowColor]];
}

- (void)setUpNavigationTitle
{
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"JCfg" size:18]}];
}

- (void)setUpNavigationBarButton
{
    UIButton *startButton = [[UIButton alloc] init];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton setImage:[UIImage imageNamed:@"calendar"] forState:UIControlStateNormal];
    [startButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
    [startButton sizeToFit];
    [startButton addTarget:self action:@selector(chooseDateStart) forControlEvents:UIControlEventTouchUpInside];
    _startCalendarItem = [[UIBarButtonItem alloc] initWithCustomView:startButton];
    self.navigationItem.leftBarButtonItem = self.startCalendarItem;
    UIButton *endButton = [[UIButton alloc] init];
    [endButton setTitle:@"End" forState:UIControlStateNormal];
    [endButton setImage:[UIImage imageNamed:@"calendar"] forState:UIControlStateNormal];
    [endButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
    [endButton sizeToFit];
    [endButton addTarget:self action:@selector(chooseDateEnd) forControlEvents:UIControlEventTouchUpInside];
    _endCalendarItem = [[UIBarButtonItem alloc] initWithCustomView:endButton];
    UIButton *sliderButton = [[UIButton alloc] init];
    [sliderButton setImage:[UIImage imageNamed:@"sliderIcon"] forState:UIControlStateNormal];
    [sliderButton sizeToFit];
    [sliderButton addTarget:self action:@selector(showSliderView) forControlEvents:UIControlEventTouchUpInside];
    _magnitudeItem = [[UIBarButtonItem alloc] initWithCustomView:sliderButton];
    self.navigationItem.rightBarButtonItems = @[self.endCalendarItem, self.magnitudeItem];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpViews
{
    [self setUpSegmentControl];
    [self setUpContentScrollView];
}

- (void)setUpSegmentControl
{
    _topSegment = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    self.topSegment.sectionTitles = @[@"Table", @"Map"];
    self.topSegment.selectedSegmentIndex = 0;
    self.currentType = self.topSegment.selectedSegmentIndex;
    self.topSegment.backgroundColor = [UIColor colorWithRed:0.169f green:0.090f blue:0.239f alpha:1.00f];
    if (IOS8)
    {
        self.topSegment.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:16.0f]};
    }
    else
    {
        self.topSegment.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f]};
    }
    self.topSegment.selectionIndicatorColor = [UIColor colorWithRed:0.749f green:0.549f blue:0.922f alpha:1.00f];
    self.topSegment.selectionIndicatorHeight = 5.0f;
    self.topSegment.userDraggable = YES;
    self.topSegment.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.topSegment.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    __weak typeof(self) weakSelf = self;
    [self.topSegment setIndexChangeBlock:^(NSInteger index) {
        weakSelf.currentType = index;
        [weakSelf.contentScroll changeSectionWithType:weakSelf.currentType];
        [weakSelf changeNavBarButton];
        if (index == sectionTypeMap)
        {
            [weakSelf retriveDataForMap];
        }
        else if (index == sectionTypeTable)
        {
            [weakSelf.annotationArr removeAllObjects];
            [weakSelf removeAllPinsButUserLocation];
        }
    }];
    [self.view addSubview:self.topSegment];
}

- (void)changeNavBarButton
{
    if (self.currentType == sectionTypeTable)
    {
        self.navigationItem.rightBarButtonItems = @[self.endCalendarItem, self.magnitudeItem];
    }
    else if (self.currentType == sectionTypeMap)
    {
        self.navigationItem.rightBarButtonItems = @[self.endCalendarItem];
    }
}

- (void)setUpContentScrollView
{
    _contentScroll = [[ContentScrollView alloc] initWithFrame:CGRectMake(0, self.topSegment.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - self.topSegment.frame.size.height)];
    [self.view addSubview:self.contentScroll];
    [self setUpNoDataLabel];
    [self setUpTableView];
    [self setUpMapView];
}

- (void)setUpNoDataLabel
{
    _noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.contentScroll.frame.size.height - 50) / 2, SCREEN_WIDTH, 50)];
    self.noDataLabel.textColor = [UIColor lightGrayColor];
    self.noDataLabel.textAlignment = NSTextAlignmentCenter;
    if (IOS9_UP)
    {
        self.noDataLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:24.0f];
    }
    else
    {
        self.noDataLabel.font = [UIFont systemFontOfSize:24.0f];
    }
    [self.noDataLabel setText:@"No Earthquake In This Area"];
    self.noDataLabel.hidden = YES;
    [self.contentScroll addSubview:self.noDataLabel];
}

- (void)setUpTableView
{
    _earthquakeTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.contentScroll.frame.size.height) style:UITableViewStylePlain];
    self.earthquakeTable.backgroundColor = [UIColor blackColor];
    self.earthquakeTable.tableFooterView  = [UIView new];
    [self.contentScroll addSubview:self.earthquakeTable];
    self.earthquakeTable.dataSource = self;
    self.earthquakeTable.delegate = self;
    [self.contentScroll addSubview:self.earthquakeTable];
    [self setUpTableViewHeaderAndFooter];
}

- (void)setUpMapView
{
    _earthquakeMap = [[MKMapView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, self.contentScroll.frame.size.height)];
    self.earthquakeMap.showsUserLocation = YES;
    self.earthquakeMap.clipsToBounds = YES;
    [self.contentScroll addSubview:self.earthquakeMap];
    self.earthquakeMap.delegate = self;
    [self.contentScroll addSubview:self.earthquakeMap];
}

- (void)setUpTableViewHeaderAndFooter
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [header setTitle:@"Pull Down To Refresh" forState:MJRefreshStateIdle];
    [header setTitle:@"Release to Refresh" forState:MJRefreshStatePulling];
    [header setTitle:@"No More Earthquakes" forState:MJRefreshStateNoMoreData];
    [header setTitle:@"Loading More Earthquakes" forState:MJRefreshStateRefreshing];
    [header.lastUpdatedTimeLabel setHidden:YES];
    if (IOS9_UP)
    {
        header.stateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.0f];
    }
    header.automaticallyChangeAlpha = YES;
    self.earthquakeTable.mj_header = header;
    //footer
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(retriveData)];
    footer.automaticallyHidden = NO;
    footer.automaticallyChangeAlpha = YES;
    footer.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    if (IOS9_UP)
    {
        footer.stateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.0f];
    }
    [footer setTitle:@"Loading More Earthquakes" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"No More Earthquakes" forState:MJRefreshStateNoMoreData];
    self.earthquakeTable.mj_footer = footer;
}

- (void)showSliderView
{
    RangeSelectionView *rangeSelection = [[RangeSelectionView alloc] init];
    rangeSelection.delegate = self;
    [rangeSelection setSliderWithCurrentRange:self.radius];
    [rangeSelection show];
}

- (void)gotLocation
{
//    NSLog(@"here");
    NSArray *userCoord = [[NSUserDefaults standardUserDefaults] objectForKey:locationGPS];
    self.userCoordinate = CLLocationCoordinate2DMake([userCoord[0] doubleValue], [userCoord[1] doubleValue]);
    self.hasLocation = YES;
    [WSProgressHUD showWithMaskType:WSProgressHUDMaskTypeGradient];
    [self retriveData];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refresh
{
    self.currentPageNum = 1;
    [self retriveData];
}


- (void)retriveData
{
    if (self.hasLocation)
    {
        [[EarthQuakeFetchManager sharedManager] fetchEarthquakesWithLocation:self.userCoordinate andRadiusInKM:self.radius withPage:self.currentPageNum withStartDate:[self stringFromDate:self.startDate] andEndDate:[self stringFromDate:self.endDate] inBackgroundWithBlock:^(NSArray *earthquakesArray, NSError *error) {
            if (earthquakesArray)
            {
//                NSLog(@"count = %ld",earthquakesArray.count);
                if (self.currentPageNum == 1)
                {
                    [self.earthquakeTableData removeAllObjects];
                    [self.earthquakeTableData addObjectsFromArray:earthquakesArray];
                    [self.earthquakeTable.mj_header endRefreshing];
                    [self.earthquakeTable reloadData];
                    [WSProgressHUD dismiss];
                    
                    if (earthquakesArray.count < 10)
                    {
                        self.earthquakeTable.mj_footer.hidden = YES;
                        if (earthquakesArray.count == 0)
                        {
                            self.earthquakeTable.hidden = YES;
                            self.noDataLabel.hidden = NO;
                        }
                        else
                        {
                            self.earthquakeTable.hidden = NO;
                            self.noDataLabel.hidden = YES;
                        }
                    }
                    else
                    {
                        self.earthquakeTable.hidden = NO;
                        self.noDataLabel.hidden = YES;
                        self.currentPageNum ++;
                    }
                }
                else
                {
                    [self.earthquakeTableData addObjectsFromArray:earthquakesArray];
                    [self.earthquakeTable.mj_footer endRefreshing];
                    [self.earthquakeTable reloadData];
                    if (earthquakesArray.count < 10)
                    {
                        [self.earthquakeTable.mj_footer endRefreshingWithNoMoreData];
                        self.earthquakeTable.mj_footer.hidden = YES;
                    }
                    else
                    {
                        self.currentPageNum ++;
                    }
                }

            }
            else
            {
                if (self.currentPageNum == 1)
                {
                    [self.earthquakeTable.mj_header endRefreshing];
                }
                else
                {
                    [self.earthquakeTable.mj_footer endRefreshing];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [WSProgressHUD showErrorWithStatus:@"Network Error"];
                });
            }
        }];
    }
    return;
}

- (void)retriveDataForMap
{
    [WSProgressHUD showWithStatus:@"Fetching" maskType:WSProgressHUDMaskTypeDefault maskWithout:WSProgressHUDMaskWithoutDefault];
    CLLocationCoordinate2D bottomLeftCoord = [self getSWCoordinate:self.currentRect];
    CLLocationCoordinate2D topRightCoord = [self getNECoordinate:self.currentRect];
    double minLat = bottomLeftCoord.latitude;
    double maxLat = topRightCoord.latitude;
    double minLong = bottomLeftCoord.longitude;
    double maxLong = topRightCoord.longitude;
    [[EarthQuakeFetchManager sharedManager] fetchEarthquakesWithMinLat:minLat maxLat:maxLat minLong:minLong maxLong:maxLong startDate:[self stringFromDate:self.startDate] endDate:[self stringFromDate:self.endDate] inBackgroundWithBlock:^(NSArray *earthquakesArray, NSError *error) {
        if (!error)
        {
            [self removeAllPinsButUserLocation];
            [self.annotationArr removeAllObjects];
            if (earthquakesArray.count > 0)
            {
                for (EarthQuake *earthquake in earthquakesArray)
                {
                    JPSThumbnail *thumbNail = [[JPSThumbnail alloc] initWithLocation:earthquake];
                    [thumbNail setDisclosureBlock:^{
                        EarthquakeDetailViewController *detail = [[EarthquakeDetailViewController alloc] initWithEarthquake:earthquake];
                        [self.navigationController pushViewController:detail animated:YES];
                    }];
                    JPSThumbnailAnnotation *annotation = [JPSThumbnailAnnotation annotationWithThumbnail:thumbNail];
                    [self.annotationArr addObject:annotation];
                }
                [WSProgressHUD dismiss];
                [self.earthquakeMap addAnnotations:self.annotationArr];
            }
            else
            {
                [WSProgressHUD dismiss];
            }
        }
        else
        {
            [WSProgressHUD showErrorWithStatus:@"Network Error"];
        }
    }];
}

- (void)chooseDateStart
{
    self.dateType = dateTypeStart;
    self.datePicker.date = self.startDate;
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(0.3),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.2),
                                                                  }];
}

- (void)chooseDateEnd
{
    self.dateType = dateTypeEnd;
    self.datePicker.date = self.endDate;
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(0.3),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.2),
                                                                  }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.earthquakeTableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"i got called");
    return 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EarthquakeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:earthquakeCellId];
    if (!cell)
    {
        cell = [[EarthquakeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:earthquakeCellId];
    }
    [cell setUpwithEarthquake:[self.earthquakeTableData objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EarthquakeDetailViewController *earthquakeDetail = [[EarthquakeDetailViewController alloc] initWithEarthquake:[self.earthquakeTableData objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:earthquakeDetail animated:YES];
}

#pragma mark - RangeSelectionViewDelegate

- (void)didSelectRange:(CGFloat)range
{
//    if (self.currentType == sectionTypeTable)
//    {
        self.radius = range;
        self.currentPageNum = 1;
        [WSProgressHUD showWithMaskType:WSProgressHUDMaskTypeGradient];
        [self retriveData];
//    }
}

#pragma mark - THDatePickerDelegate

- (void)datePickerDonePressed:(THDatePickerViewController *)datePicker {
    [self dismissSemiModalView];
}

- (void)datePickerCancelPressed:(THDatePickerViewController *)datePicker {
    [self dismissSemiModalView];
}

- (void)datePicker:(THDatePickerViewController *)datePicker selectedDate:(NSDate *)selectedDate {
    if ([self verifyDate:selectedDate])
    {
        if (self.dateType == dateTypeStart)
        {
            self.startDate = selectedDate;
        }
        else if (self.dateType == dateTypeEnd)
        {
            self.endDate = selectedDate;
        }
        //now need to reset the page to 1 and fetch the data again
        if (self.currentType == sectionTypeTable)
        {
            self.currentPageNum = 1;
            [WSProgressHUD showWithMaskType:WSProgressHUDMaskTypeGradient];
            [self retriveData];
        }
        else
        {
            [self retriveDataForMap];
        }
    }
    else
    {
        if (self.dateType == dateTypeStart)
        {
            [WSProgressHUD showErrorWithStatus:@"start date could not be later than or equal to end date"];
            self.datePicker.date = self.startDate;
        }
        else if (self.dateType == dateTypeEnd)
        {
            [WSProgressHUD showErrorWithStatus:@"end date could not be earlier than or equal to start date"];
            self.datePicker.date = self.endDate;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(presentPicker) withObject:nil afterDelay:0.5f];
        });
    }
}

- (void)presentPicker
{
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(0.3),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.2),
                                                                  }];
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.firstOccuring)
    {
        if (!self.userLocated)
        {
            self.userCoord = userLocation.coordinate;
            [mapView setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.015f, 0.015f)) animated:YES];
            self.currentRect = [self MKMapRectForCoordinateRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.015f, 0.015f))];
            self.userLocated = YES;
            self.firstOccuring = NO;
            self.nextRegionChangeIsFromUserInteraction = YES;
            self.previousLocation = userLocation.location.coordinate;
            [self retriveDataForMap];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    //NSLog(@"view will");
    UIView* view = mapView.subviews.firstObject;
    //	Look through gesture recognizers to determine
    //	whether this region change is from user interaction
    for(UIGestureRecognizer* recognizer in view.gestureRecognizers)
    {
        //	The user caused of this...
        if(recognizer.state == UIGestureRecognizerStateBegan
           || recognizer.state == UIGestureRecognizerStateEnded)
        {
            self.nextRegionChangeIsFromUserInteraction = YES;
            break;
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if(self.nextRegionChangeIsFromUserInteraction)
    {
        //        NSLog(@"called");
        [self checkIfLargeSpan:_previousLocation andCurrentLocation:mapView.centerCoordinate];
        self.previousLocation = mapView.centerCoordinate;
        self.nextRegionChangeIsFromUserInteraction = NO;
        //NSLog(@"did change region from user");
        //	Perform code here
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        self.selectAnnotation = YES;
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        self.selectAnnotation = YES;
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    return nil;
}


//convenience methods
- (BOOL)verifyDate:(NSDate *)date
{
    BOOL isValid;
    if (self.dateType == dateTypeStart)
    {
        if ([date compare:self.endDate] ==  NSOrderedAscending)
        {
            isValid = YES;
        }
        else if ([date compare:self.endDate] ==  NSOrderedDescending)
        {
            isValid = NO;
        }
        else
        {
            isValid = NO;
        }
            
    }
    else if (self.dateType == dateTypeEnd)
    {
        if ([date compare:self.endDate] ==  NSOrderedAscending)
        {
            isValid = NO;
        }
        else if ([date compare:self.endDate] ==  NSOrderedDescending)
        {
            isValid = YES;
        }
        else
        {
            isValid = NO;
        }
    }
    return isValid;
}

- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *formmater = [[NSDateFormatter alloc] init];
    [formmater setDateFormat:@"yyyy-MM-dd"];
    return [formmater stringFromDate:date];
}

//convenient methods

-(CLLocationCoordinate2D)getSWCoordinate:(MKMapRect)mRect{
    return [self getCoordinateFromMapRectanglePoint:mRect.origin.x y:MKMapRectGetMaxY(mRect)];
}

-(CLLocationCoordinate2D)getNECoordinate:(MKMapRect)mRect{
    return [self getCoordinateFromMapRectanglePoint:MKMapRectGetMaxX(mRect) y:mRect.origin.y];
}

-(CLLocationCoordinate2D)getCoordinateFromMapRectanglePoint:(double)x y:(double)y{
    MKMapPoint swMapPoint = MKMapPointMake(x, y);
    return MKCoordinateForMapPoint(swMapPoint);
}

- (MKMapRect)MKMapRectForCoordinateRegion:(MKCoordinateRegion)region
{
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}

- (void)removeAllPinsButUserLocation
{
    id userLocation = [self.earthquakeMap userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.earthquakeMap annotations]];
    if ( userLocation != nil ) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }
    
    [self.earthquakeMap removeAnnotations:pins];
}

- (void)checkIfLargeSpan:(CLLocationCoordinate2D)previousLocation andCurrentLocation:(CLLocationCoordinate2D)currentLocation
{
    if (self.selectAnnotation)
    {
        self.selectAnnotation = NO;
    }
    else
    {
        float latDelta = fabs(previousLocation.latitude - currentLocation.latitude);
        //NSLog(@"lat delta = %lf",latDelta);
        float lngDelta = fabs(previousLocation.longitude - previousLocation.longitude);
        //NSLog(@"long delta = %lf",latDelta);
        //this case need to refresh the map with data
        if ((latDelta > 0.005) || (lngDelta > 0.005))
        {
//            NSLog(@"need refresh search");
            self.currentRect = self.earthquakeMap.visibleMapRect;
            [self retriveDataForMap];
        }
//        else
//        {
//            NSLog(@"no need");
//        }
    }
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
