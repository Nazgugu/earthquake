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

typedef NS_OPTIONS(NSInteger, sectionType) {
    sectionTypeTable = 0,
    sectionTypeMap = 1
};

@interface MainEQViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (nonatomic, strong) UITableView *earthquakeTable;
@property (nonatomic, assign) NSUInteger currentPageNum;
@property (nonatomic, strong) MKMapView *earthquakeMap;
@property (nonatomic, strong) HMSegmentedControl *topSegment;
@property (nonatomic, strong) ContentScrollView *contentScroll;
@property (nonatomic, assign) sectionType currentType;
@property (nonatomic, strong) NSMutableArray *earthquakeTableData;
@property (nonatomic, strong) NSMutableArray *earthquakeMapData;

@end

@implementation MainEQViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _currentType = sectionTypeTable;
        _earthquakeTableData = [NSMutableArray new];
        _earthquakeMapData = [NSMutableArray new];
        _currentPageNum = 1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpNavigationTitle];
    self.title = @"Earthquake";
    [self setUpViews];
}

- (void)setUpNavigationTitle
{
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"JCfg" size:18]}];
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
    _contentScroll = [[ContentScrollView alloc] initWithFrame:CGRectMake(0, self.topSegment.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - self.topSegment.frame.size.height) tableView:_earthquakeTable andMapView:_earthquakeMap];
    [self.view addSubview:self.contentScroll];
    self.earthquakeTable.dataSource = self;
    self.earthquakeTable.delegate = self;
    self.earthquakeMap.delegate = self;
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
    return 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EarthquakeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:earthquakeCellId];
    if (!cell)
    {
        cell = [[EarthquakeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:earthquakeCellId];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
