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

typedef NS_OPTIONS(NSInteger, sectionType) {
    sectionTypeTable = 0,
    sectionTypeMap = 1
};

typedef NS_OPTIONS(NSInteger, dateType) {
    dateTypeStart = 0,
    dateTypeEnd = 1
};

@interface MainEQViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, THDatePickerDelegate>

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
@property (nonatomic, strong) UIBarButtonItem *endCalendarItem;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) NSInteger dateType;

@end

@implementation MainEQViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _hasLocation = NO;
        _currentType = sectionTypeTable;
        _earthquakeTableData = [NSMutableArray new];
        _earthquakeMapData = [NSMutableArray new];
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
    self.navigationItem.rightBarButtonItem = self.endCalendarItem;

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
    }];
    [self.view addSubview:self.topSegment];
}

- (void)setUpContentScrollView
{
    _contentScroll = [[ContentScrollView alloc] initWithFrame:CGRectMake(0, self.topSegment.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - self.topSegment.frame.size.height)];
    [self.view addSubview:self.contentScroll];
    [self setUpTableView];
    [self setUpMapView];
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

- (void)gotLocation
{
//    NSLog(@"here");
    NSArray *userCoord = [[NSUserDefaults standardUserDefaults] objectForKey:locationGPS];
    self.userCoordinate = CLLocationCoordinate2DMake([userCoord[0] doubleValue], [userCoord[1] doubleValue]);
    self.hasLocation = YES;
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
                NSLog(@"count = %ld",earthquakesArray.count);
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
                    }
                    else
                    {
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
        self.currentPageNum = 1;
        [WSProgressHUD showWithMaskType:WSProgressHUDMaskTypeGradient];
        [self retriveData];
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
            [self presentSemiViewController:self.datePicker withOptions:@{
                                                                          KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                          KNSemiModalOptionKeys.animationDuration : @(0.3),
                                                                          KNSemiModalOptionKeys.shadowOpacity     : @(0.2),
                                                                          }];
        });
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
