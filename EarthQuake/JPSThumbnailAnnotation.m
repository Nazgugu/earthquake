//
//  JPSThumbnailAnnotation.m
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import "JPSThumbnailAnnotation.h"

@interface JPSThumbnailAnnotation ()<JPSThumbnailAnnotationViewProtocol>

@property (nonatomic, readwrite) JPSThumbnailAnnotationView *view;
@property (nonatomic, readonly) JPSThumbnail *thumbnail;

@end

@implementation JPSThumbnailAnnotation

+ (instancetype)annotationWithThumbnail:(JPSThumbnail *)thumbnail {
    return [[self alloc] initWithThumbnail:thumbnail];
}

- (id)initWithThumbnail:(JPSThumbnail *)thumbnail {
    self = [super init];
    if (self) {
        _coordinate = [thumbnail getLocationCoordinate];
        _thumbnail = thumbnail;
    }
    return self;
}

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView {
    if (!self.view) {
        self.view = (JPSThumbnailAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kJPSThumbnailAnnotationViewReuseID];
        if (!self.view) self.view = [[JPSThumbnailAnnotationView alloc] initWithAnnotation:self];
    } else {
        self.view.annotation = self;
    }
    self.view.delegate = self;
    [self updateThumbnail:self.thumbnail animated:NO];
    return self.view;
}

- (void)updateThumbnail:(JPSThumbnail *)thumbnail animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.33f animations:^{
            _coordinate = [thumbnail getLocationCoordinate]; // use ivar to avoid triggering setter
        }];
    } else {
        _coordinate = [thumbnail getLocationCoordinate]; // use ivar to avoid triggering setter
    }
    
    [self.view updateWithThumbnail:thumbnail];
}

- (EarthQuake *)getAnnotationLocation
{
    return [self.thumbnail getLocation];
}

#pragma mark - JPSThumbnailAnotaionViewDelegate

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView
{
//    NSLog(@"selected");
}

- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView
{
//    NSLog(@"deselected");
}

@end
