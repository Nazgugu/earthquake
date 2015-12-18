//
//  ContentScrollView.m
//  EarthQuake
//
//  Created by Liu Zhe on 12/17/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#import "ContentScrollView.h"


@interface ContentScrollView()


@end

@implementation ContentScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setContentSize:CGSizeMake(SCREEN_WIDTH * 2, self.bounds.size.height)];
        [self setScrollEnabled:NO];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame tableView:(UITableView *)tableView andMapView:(MKMapView *)mapView
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setContentSize:CGSizeMake(SCREEN_WIDTH * 2, self.bounds.size.height)];
        [self setScrollEnabled:NO];
        [self setUpTabelView:tableView];
        [self setUpMapView:mapView];
    }
    return self;
}

- (void)setUpTabelView:(UITableView *)tableView
{
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.bounds.size.height) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor blackColor];
    tableView.tableFooterView  = [UIView new];
    [self addSubview:tableView];
}

- (void)setUpMapView:(MKMapView *)mapView
{
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, self.bounds.size.height)];
    mapView.showsUserLocation = YES;
    mapView.clipsToBounds = YES;
    [self addSubview:mapView];
}

- (void)changeSectionWithType:(NSInteger )type
{
    [self setContentOffset:CGPointMake(type * SCREEN_WIDTH, 0) animated:YES];
}

@end
