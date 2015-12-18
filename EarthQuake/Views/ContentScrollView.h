//
//  ContentScrollView.h
//  EarthQuake
//
//  Created by Liu Zhe on 12/17/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ContentScrollView : UIScrollView

- (instancetype)initWithFrame:(CGRect)frame tableView:(UITableView *)tableView andMapView:(MKMapView *)mapView;

- (void)changeSectionWithType:(NSInteger )type;

@end
