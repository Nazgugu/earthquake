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
#define propertyIconHeight          65.0f

#define earthquakeAnnotaionReuseID      @"earthquakeAnno"

#import "EarthquakeDetailViewController.h"
#import <MapKit/MapKit.h>
#import "HMSegmentedControl.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "FlexibleAlignButton.h"
#import "SVWebViewController.h"
#import "ZLAnnotation.h"
#import "SVPulsingAnnotationView.h"

@interface EarthquakeDetailViewController ()<MKMapViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat currentYPosition;
@property (nonatomic, strong) EarthQuake *theEarthequake;
@property (nonatomic, strong) MKMapView *earthquakeMap;
@property (nonatomic, strong) HMSegmentedControl *topSegment;
@property (nonatomic, strong) UIScrollView *contentScroll;
@property (nonatomic, strong) UIScrollView *dataScrollView;
@property (nonatomic, strong) HMSegmentedControl *sectionSegmentedControl;
//four labels for detail
@property (nonatomic, strong) UILabel *locationAddressLabel;
@property (nonatomic, strong) UILabel *significanceLabel;
@property (nonatomic, strong) UILabel *intensityLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) FlexibleAlignButton *alertIcon;
@property (nonatomic, strong) FlexibleAlignButton *tsunamiIcon;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *detailButton;

@end

@implementation EarthquakeDetailViewController

- (instancetype)initWithEarthquake:(EarthQuake *)earthquake
{
    self = [super init];
    if (self)
    {
        _theEarthequake = earthquake;
        _currentYPosition = 0.0f;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.fd_prefersNavigationBarHidden = YES;
    self.view.backgroundColor = [UIColor colorWithRed:0.067f green:0.071f blue:0.071f alpha:1.00f];
    [self setUpNavigationBar];
    [self setUpViews];
    [self initButtons];
    [self setUpEarthquakeDetail];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.earthquakeMap setRegion:MKCoordinateRegionMake([self.theEarthequake getLocation], MKCoordinateSpanMake(0.1f, 0.1f)) animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)setUpNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)setUpEarthquakeDetail
{
    [self.locationAddressLabel setText:[self.theEarthequake getAddress]];
    [self.significanceLabel setText:[NSString stringWithFormat:@"%ld",[self.theEarthequake getSignificance]]];
    [self.intensityLabel setText:[NSString stringWithFormat:@"%.2lf", [self.theEarthequake getIntensity]]];
    [self.timeLabel setText:[self.theEarthequake getTime]];
    NSString *alert = [self.theEarthequake getAlert];
    if ([alert isEqual: [NSNull null]])
    {
        //four case: green, red, orange, red
        [self.alertIcon setTintColor:[UIColor grayColor]];
        [self.alertIcon.titleLabel setTextColor:[UIColor grayColor]];
    }
    else
    {
        if (alert && ![alert isEqualToString:@""])
        {
            if ([alert isEqualToString:@"green"])
            {
                [self.alertIcon setTintColor:[UIColor greenColor]];
                [self.alertIcon.titleLabel setTextColor:[UIColor greenColor]];
            }
            else if ([alert isEqualToString:@"yellow"])
            {
                [self.alertIcon setTintColor:[UIColor yellowColor]];
                [self.alertIcon.titleLabel setTextColor:[UIColor yellowColor]];
            }
            else if ([alert isEqualToString:@"orange"])
            {
                [self.alertIcon setTintColor:[UIColor orangeColor]];
                [self.alertIcon.titleLabel setTextColor:[UIColor orangeColor]];
            }
            else if ([alert isEqualToString:@"red"])
            {
                [self.alertIcon setTintColor:[UIColor redColor]];
                [self.alertIcon.titleLabel setTextColor:[UIColor redColor]];
            }
        }
    }
    
    if ([self.theEarthequake doesHaveTsunami])
    {
        [self.tsunamiIcon setTintColor:[UIColor blueColor]];
        [self.tsunamiIcon.titleLabel setTextColor:[UIColor blueColor]];
    }
    else
    {
        [self.tsunamiIcon setTintColor:[UIColor grayColor]];
        [self.tsunamiIcon.titleLabel setTextColor:[UIColor grayColor]];
    }
}

- (void)setUpViews
{
    [self setUpScrollView];
    [self setUpMapView];
    [self setUpStrip];
    [self setUpSegmentControl];
    [self setUpPager];
    [self setUpLabelWithText:@"Properties"];
    [self setUpLine];
    [self setUpPropertyView];
}

- (void)initButtons
{
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 28, 22, 22)];
    UIImage *backImage = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.backButton setImage:backImage forState:UIControlStateNormal];
    [self.backButton setTintColor:[UIColor colorWithRed:0.498f green:0.227f blue:0.780f alpha:1.00f]];
    [self.backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    _detailButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 15 - 22, 28, 22, 22)];
    UIImage *webImage = [[UIImage imageNamed:@"website"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.detailButton setImage:webImage forState:UIControlStateNormal];
    [self.detailButton setTintColor:[UIColor colorWithRed:0.498f green:0.227f blue:0.780f alpha:1.00f]];
    [self.detailButton addTarget:self action:@selector(goToWebsite:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.detailButton];
}

- (void)setUpScrollView
{
    _contentScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -[UIApplication sharedApplication].statusBarFrame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT + [UIApplication sharedApplication].statusBarFrame.size.height)];
    [self.contentScroll setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT/3.0f + segmentHeight + pagerHeight + gapHeight + sectionLabelHeight + lineHeight + lineGap + propertyIconHeight)];
    self.contentScroll.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.contentScroll];
}

- (void)setUpMapView
{
    _earthquakeMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, self.currentYPosition, SCREEN_WIDTH, SCREEN_HEIGHT/3.0f)];
    self.earthquakeMap.showsUserLocation = NO;
    self.earthquakeMap.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.earthquakeMap.clipsToBounds = YES;
    self.earthquakeMap.delegate = self;
    [self.contentScroll addSubview:self.earthquakeMap];
    self.currentYPosition += SCREEN_HEIGHT/3.0f;
}

- (void)setUpStrip
{
//    CGFloat width = SCREEN_WIDTH * 3 / 4;
    UIView *stripe = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentYPosition + 47, SCREEN_WIDTH, 3)];
    [stripe setBackgroundColor:[UIColor colorWithRed:0.612f green:0.612f blue:0.612f alpha:1.00f]];
    [self.contentScroll addSubview:stripe];
}

- (void)setUpSegmentControl
{
//    CGFloat width = SCREEN_WIDTH * 3 / 4;
    _sectionSegmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, self.currentYPosition, SCREEN_WIDTH, segmentHeight)];
    self.sectionSegmentedControl.sectionTitles = @[@"Location", @"Time", @"Significance", @"Intensity"];
    self.sectionSegmentedControl.selectedSegmentIndex = 0;
    self.sectionSegmentedControl.backgroundColor = [UIColor clearColor];
    if (IOS8)
    {
        self.sectionSegmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0.612f green:0.612f blue:0.612f alpha:1.00f], NSFontAttributeName: [UIFont systemFontOfSize:15.0f]};
        self.sectionSegmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:15.0f]};
    }
    else
    {
        self.sectionSegmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0.612f green:0.612f blue:0.612f alpha:1.00f], NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:15.0f]};
        self.sectionSegmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:15.0f]};
    }
    self.sectionSegmentedControl.selectionIndicatorColor = [UIColor colorWithRed:0.498f green:0.227f blue:0.780f alpha:1.00f];
    self.sectionSegmentedControl.userDraggable = YES;
    self.sectionSegmentedControl.selectionStyle  = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.sectionSegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.sectionSegmentedControl.selectionIndicatorHeight = 3.0f;
    __weak typeof(self) weakSelf = self;
    [self.sectionSegmentedControl setIndexChangeBlock:^(NSInteger index) {
        [weakSelf.dataScrollView scrollRectToVisible:CGRectMake(SCREEN_WIDTH * index, 0, SCREEN_WIDTH, pagerHeight) animated:YES];
    }];
    [self.contentScroll addSubview:self.sectionSegmentedControl];
    self.currentYPosition += segmentHeight;
}

- (void)setUpPager
{
    _dataScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.currentYPosition, SCREEN_WIDTH, pagerHeight)];
    self.dataScrollView.backgroundColor = [UIColor clearColor];
    self.dataScrollView.pagingEnabled = YES;
    self.dataScrollView.showsHorizontalScrollIndicator = NO;
    [self.dataScrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 4, pagerHeight)];
    self.dataScrollView.delegate = self;
    [self.dataScrollView scrollRectToVisible:CGRectMake(0, 0, SCREEN_WIDTH, pagerHeight) animated:NO];
    //first is location address label
    _locationAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 40, pagerHeight)];
    self.locationAddressLabel.textColor = [UIColor whiteColor];
    self.locationAddressLabel.textAlignment = NSTextAlignmentCenter;
    self.locationAddressLabel.numberOfLines = 1;
    self.locationAddressLabel.adjustsFontSizeToFitWidth = YES;
    if (IOS8)
    {
        self.locationAddressLabel.font = [UIFont systemFontOfSize:20.0f];
    }
    else
    {
        self.locationAddressLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20.0f];
    }
    [self.dataScrollView addSubview:self.locationAddressLabel];
    //time label
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 + SCREEN_WIDTH, 0, SCREEN_WIDTH - 40, pagerHeight)];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.numberOfLines = 1;
    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    if (IOS8)
    {
        self.timeLabel.font = [UIFont systemFontOfSize:20.0f];
    }
    else
    {
        self.timeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20.0f];
    }
    [self.dataScrollView addSubview:self.timeLabel];
    //Significance Label
    _significanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 + SCREEN_WIDTH * 2, 0, SCREEN_WIDTH - 40, pagerHeight)];
    self.significanceLabel.textColor = [UIColor whiteColor];
    self.significanceLabel.textAlignment = NSTextAlignmentCenter;
    if (IOS8)
    {
        self.significanceLabel.font = [UIFont systemFontOfSize:20.0f];
    }
    else
    {
        self.significanceLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20.0f];
    }
    [self.dataScrollView addSubview:self.significanceLabel];
    //Intensity Label
    _intensityLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 + SCREEN_WIDTH * 3, 0, SCREEN_WIDTH - 40, pagerHeight)];
    self.intensityLabel.textColor = [UIColor whiteColor];
    self.intensityLabel.textAlignment = NSTextAlignmentCenter;
    if (IOS8)
    {
        self.intensityLabel.font = [UIFont systemFontOfSize:20.0f];
    }
    else
    {
        self.intensityLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20.0f];
    }
    [self.dataScrollView addSubview:self.intensityLabel];
    [self.contentScroll addSubview:self.dataScrollView];
    self.currentYPosition += pagerHeight;
    self.currentYPosition += gapHeight;
}

- (void)setUpPropertyView
{
    CGFloat horizontalGap = (SCREEN_WIDTH - propertyIconHeight * 2) / 3;
    
    _alertIcon = [[FlexibleAlignButton alloc] initWithFrame:CGRectMake(horizontalGap, self.currentYPosition, propertyIconHeight, propertyIconHeight)];
    _tsunamiIcon = [[FlexibleAlignButton alloc] initWithFrame:CGRectMake(horizontalGap * 2 + propertyIconHeight, self.currentYPosition, propertyIconHeight, propertyIconHeight)];
    self.alertIcon.userInteractionEnabled = NO;
    self.tsunamiIcon.userInteractionEnabled = NO;
    
    self.alertIcon.alignment = kButtonAlignmentImageTop;
    self.tsunamiIcon.alignment = kButtonAlignmentImageTop;
    
    if (IOS8)
    {
        self.alertIcon.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        self.tsunamiIcon.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    else
    {
        self.alertIcon.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
        self.tsunamiIcon.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    }
    
    [self.alertIcon setTitle:@"Alert" forState:UIControlStateNormal];
    [self.tsunamiIcon setTitle:@"Tsunami" forState:UIControlStateNormal];
    
    self.alertIcon.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.alertIcon.imageView.clipsToBounds = YES;
    
    self.tsunamiIcon.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.tsunamiIcon.imageView.clipsToBounds = YES;
    
    UIImage *alertImage = [[UIImage imageNamed:@"alert"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *tsunamiImage = [[UIImage imageNamed:@"tsunami"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.alertIcon setImage:alertImage forState:UIControlStateNormal];
    [self.tsunamiIcon setImage:tsunamiImage forState:UIControlStateNormal];
    
    self.alertIcon.gap = 5.0f;
    self.tsunamiIcon.gap = 5.0f;
    [self.contentScroll addSubview:self.alertIcon];
    [self.contentScroll addSubview:self.tsunamiIcon];
    self.currentYPosition += propertyIconHeight;
}

- (void)setUpLabelWithText:(NSString *)labelTitle
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.currentYPosition, SCREEN_WIDTH, sectionLabelHeight)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor colorWithRed:0.612f green:0.612f blue:0.612f alpha:1.00f]];
    if (IOS8)
    {
        [label setFont:[UIFont systemFontOfSize:15.0f]];
    }
    else
    {
        [label setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15.0f]];
    }
    [label setText:labelTitle];
    [self.contentScroll addSubview:label];
    self.currentYPosition += sectionLabelHeight;
}

- (void)setUpLine
{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - SCREEN_WIDTH / 4) / 2, self.currentYPosition, SCREEN_WIDTH / 4, lineHeight)];
    [lineView setBackgroundColor:[UIColor colorWithRed:0.498f green:0.227f blue:0.780f alpha:1.00f]];
    [self.contentScroll addSubview:lineView];
    self.currentYPosition += lineHeight;
    self.currentYPosition += lineGap;
}

#pragma mark - MKMapViewDelegate

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    ZLAnnotation *earthquakeAnnotation = [[ZLAnnotation alloc] initWithCoordinate:[self.theEarthequake getLocation]];
    earthquakeAnnotation.title = [NSString stringWithFormat:@"Magnitude: %.1lf",[self.theEarthequake getMagnitude]];
    earthquakeAnnotation.subtitle = [NSString stringWithFormat:@"Depth: %.3f km", [self.theEarthequake getDepth]];
    [self.earthquakeMap addAnnotation:earthquakeAnnotation];
    [mapView selectAnnotation:earthquakeAnnotation animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[ZLAnnotation class]])
    {
        SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:earthquakeAnnotaionReuseID];
        if (!pulsingView)
        {
            pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:earthquakeAnnotaionReuseID];
            pulsingView.annotationColor = [UIColor colorWithRed:0.678431 green:0 blue:0 alpha:1];
            pulsingView.canShowCallout = YES;
        }
        return pulsingView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [mapView selectAnnotation:view.annotation animated:NO];
}

#pragma mark - button action
- (void)goBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goToWebsite:(UIButton *)sender
{
    SVWebViewController *earthquakeDetail = [[SVWebViewController alloc] initWithURL:[self.theEarthequake getDetailWebAddress]];
    [self.navigationController pushViewController:earthquakeDetail animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    
    [self.sectionSegmentedControl setSelectedSegmentIndex:page animated:YES];
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
