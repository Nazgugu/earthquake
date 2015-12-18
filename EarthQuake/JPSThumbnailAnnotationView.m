//
//  JPSThumbnailAnnotationView.m
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

@import QuartzCore;
#import "JPSThumbnailAnnotationView.h"
#import "JPSThumbnail.h"

NSString * const kJPSThumbnailAnnotationViewReuseID = @"JPSThumbnailAnnotationView";

static CGFloat const kJPSThumbnailAnnotationViewStandardWidth     = 50.0f;
static CGFloat const kJPSThumbnailAnnotationViewStandardHeight    = 65.0f;
static CGFloat const kJPSThumbnailAnnotationViewExpandOffset      = 200.0f;
static CGFloat const kJPSThumbnailAnnotationViewVerticalOffset    = 25.0f;
static CGFloat const kJPSThumbnailAnnotationViewAnimationDuration = 0.25f;

@interface JPSThumbnailAnnotationView ()

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UILabel *magnitudeLabel;
//@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) ActionBlock disclosureBlock;

@property (nonatomic, strong) CAShapeLayer *bgLayer;
@property (nonatomic, strong) UIButton *disclosureButton;
@property (nonatomic, assign) JPSThumbnailAnnotationViewState state;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation JPSThumbnailAnnotationView

#pragma mark - Setup

- (id)initWithAnnotation:(id<MKAnnotation>)annotation {
    self = [super initWithAnnotation:annotation reuseIdentifier:kJPSThumbnailAnnotationViewReuseID];
    
    if (self) {
        self.canShowCallout = NO;
        self.frame = CGRectMake(0, 0, kJPSThumbnailAnnotationViewStandardWidth, kJPSThumbnailAnnotationViewStandardHeight);
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(0, -kJPSThumbnailAnnotationViewVerticalOffset);
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapDisclosureButton)];
        
        _state = JPSThumbnailAnnotationViewStateCollapsed;
        
        [self setupView];
    }
    
    return self;
}

- (void)setupView {
    [self setUpOccupencyLabel];
//    [self setupImageView];
    [self setupTitleLabel];
    [self setupSubtitleLabel];
    [self setupDisclosureButton];
    [self setLayerProperties];
    [self setDetailGroupAlpha:0.0f];
}

- (void)setUpOccupencyLabel
{
    _magnitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
    [_magnitudeLabel setBackgroundColor:[UIColor colorWithRed:0.471 green:0.318 blue:0.604 alpha:1.00]];
    _magnitudeLabel.layer.cornerRadius = 3.0f;
    _magnitudeLabel.layer.borderWidth = 1.0f;
    _magnitudeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    _magnitudeLabel.layer.masksToBounds = YES;
    [_magnitudeLabel setTextAlignment:NSTextAlignmentCenter];
    _magnitudeLabel.textColor = [UIColor whiteColor];
    _magnitudeLabel.numberOfLines = 1;
    _magnitudeLabel.adjustsFontSizeToFitWidth = YES;
    if (IOS8)
    {
        _magnitudeLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    else
    {
        _magnitudeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
    }
    [self addSubview:_magnitudeLabel];
}

//- (void)setupImageView {
//    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.5f, 12.5f, 50.0f, 47.0f)];
//    _imageView.layer.cornerRadius = 4.0f;
//    _imageView.layer.masksToBounds = YES;
//    _imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    _imageView.layer.borderWidth = 0.5f;
//    [self addSubview:_imageView];
//}

- (void)setupTitleLabel {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-48.0f, 4.0f, 160.0f, 20.0f)];
    _titleLabel.textColor = [UIColor colorWithRed:0.161 green:0.161 blue:0.161 alpha:1.00];
    if (IOS8)
    {
        _titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    else
    {
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17.0f];
    }
    _titleLabel.minimumScaleFactor = 0.8f;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_titleLabel];
}

- (void)setupSubtitleLabel {
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-48.0f, 28.0f, 160.0f, 15.0f)];
    _subtitleLabel.textColor = [UIColor lightGrayColor];
    _subtitleLabel.numberOfLines = 1;
    _subtitleLabel.minimumScaleFactor = 0.5f;
    _subtitleLabel.adjustsFontSizeToFitWidth = YES;
    if (IOS8)
    {
        _subtitleLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    else
    {
        _subtitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
    }
    [self addSubview:_subtitleLabel];
}

- (void)setupDisclosureButton {
    BOOL iOS7 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f;
    UIButtonType buttonType = iOS7 ? UIButtonTypeSystem : UIButtonTypeCustom;
    _disclosureButton = [UIButton buttonWithType:buttonType];
    _disclosureButton.tintColor = [UIColor grayColor];
    UIImage *disclosureIndicatorImage = [JPSThumbnailAnnotationView disclosureButtonImage];
    [_disclosureButton setImage:disclosureIndicatorImage forState:UIControlStateNormal];
    _disclosureButton.frame = CGRectMake(kJPSThumbnailAnnotationViewExpandOffset/2.0f + self.frame.size.width/2.0f - 7,
                                          15.5f,
                                         disclosureIndicatorImage.size.width,
                                         disclosureIndicatorImage.size.height);
    
    [_disclosureButton addTarget:self action:@selector(didTapDisclosureButton) forControlEvents:UIControlEventTouchDown];
    [self addSubview:_disclosureButton];
}

- (void)setLayerProperties {
    _bgLayer = [CAShapeLayer layer];
    CGPathRef path = [self newBubbleWithRect:self.bounds];
    _bgLayer.path = path;
    CFRelease(path);
    _bgLayer.fillColor = [UIColor colorWithRed:0.471 green:0.318 blue:0.604 alpha:1.00].CGColor;
    
    _bgLayer.lineWidth = 1.0f;
    _bgLayer.strokeColor = [UIColor whiteColor].CGColor;
    
    _bgLayer.shadowColor = [UIColor blackColor].CGColor;
    _bgLayer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    _bgLayer.shadowRadius = 2.0f;
    _bgLayer.shadowOpacity = 0.3f;
//    _bgLayer.borderWidth = 2.0f;
//    _bgLayer.borderColor = [UIColor whiteColor].CGColor;
    
    _bgLayer.masksToBounds = NO;
    
    
    
    [_bgLayer setBackgroundColor:[UIColor whiteColor].CGColor];
    
    [self.layer insertSublayer:_bgLayer atIndex:0];
}

#pragma mark - Updating

- (void)updateWithThumbnail:(JPSThumbnail *)thumbnail {
    self.coordinate = [thumbnail getLocationCoordinate];
    self.titleLabel.text = [thumbnail getAddress];
    self.subtitleLabel.text = [thumbnail getTime];
//    self.imageView.image = thumbnail.image;
    self.magnitudeLabel.text = [thumbnail getMagnitude];
    self.disclosureBlock = thumbnail.disclosureBlock;
}

#pragma mark - JPSThumbnailAnnotationViewProtocol

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView {
    // Center map at annotation point
    if ([self.delegate respondsToSelector:@selector(didSelectAnnotationViewInMap:)])
    {
        [self.delegate didSelectAnnotationViewInMap:mapView];
    }
    [mapView setCenterCoordinate:self.coordinate animated:YES];
    [self expand];
}

- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView {
    if ([self.delegate respondsToSelector:@selector(didDeselectAnnotationViewInMap:)])
    {
        [self.delegate didDeselectAnnotationViewInMap:mapView];
    }
    [self shrink];
}

#pragma mark - Geometry

- (CGPathRef)newBubbleWithRect:(CGRect)rect {
    CGFloat stroke = 1.0f;
	CGFloat radius = 7.0f;
	CGMutablePathRef path = CGPathCreateMutable();
	CGFloat parentX = rect.origin.x + rect.size.width/2.0f;
	
	// Determine Size
	rect.size.width -= stroke + 14.0f;
	rect.size.height -= stroke + 15.0f;
	rect.origin.x += stroke / 2.0f + 0.0f;
	rect.origin.y += stroke / 2.0f + 0.0f;
    
	// Create Callout Bubble Path
	CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
	CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
	CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI_2, 1);
	CGPathAddLineToPoint(path, NULL, parentX - 14.0f, rect.origin.y + rect.size.height);
	CGPathAddLineToPoint(path, NULL, parentX, rect.origin.y + rect.size.height + 14.0f);
	CGPathAddLineToPoint(path, NULL, parentX + 14.0f, rect.origin.y + rect.size.height);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
	CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI_2, 0.0f, 1.0f);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
	CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI_2, 1.0f);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y);
	CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI_2, M_PI, 1.0f);
	CGPathCloseSubpath(path);
    return path;
}

#pragma mark - Animations

- (void)setDetailGroupAlpha:(CGFloat)alpha {
    self.disclosureButton.alpha = alpha;
    self.titleLabel.alpha = alpha;
    self.subtitleLabel.alpha = alpha;
}

- (void)expand {
    if (self.state != JPSThumbnailAnnotationViewStateCollapsed) return;
    
    self.state = JPSThumbnailAnnotationViewStateAnimating;
    
    [self animateBubbleWithDirection:JPSThumbnailAnnotationViewAnimationDirectionGrow];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width+kJPSThumbnailAnnotationViewExpandOffset, self.frame.size.height);
    self.centerOffset = CGPointMake(kJPSThumbnailAnnotationViewExpandOffset/2.0f, -kJPSThumbnailAnnotationViewVerticalOffset);
    [UIView animateWithDuration:kJPSThumbnailAnnotationViewAnimationDuration/2.0f delay:kJPSThumbnailAnnotationViewAnimationDuration options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setDetailGroupAlpha:1.0f];
    } completion:^(BOOL finished) {
        self.state = JPSThumbnailAnnotationViewStateExpanded;
        [self addGestureRecognizer:self.tapGesture];
    }];
}

- (void)shrink {
    if (self.state != JPSThumbnailAnnotationViewStateExpanded) return;
    
    self.state = JPSThumbnailAnnotationViewStateAnimating;

    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width - kJPSThumbnailAnnotationViewExpandOffset,
                            self.frame.size.height);
    
    [UIView animateWithDuration:kJPSThumbnailAnnotationViewAnimationDuration/2.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setDetailGroupAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [self removeGestureRecognizer:self.tapGesture];
                         [self animateBubbleWithDirection:JPSThumbnailAnnotationViewAnimationDirectionShrink];
                         self.centerOffset = CGPointMake(0.0f, -kJPSThumbnailAnnotationViewVerticalOffset);
                     }];
}

- (void)animateBubbleWithDirection:(JPSThumbnailAnnotationViewAnimationDirection)animationDirection {
    BOOL growing = (animationDirection == JPSThumbnailAnnotationViewAnimationDirectionGrow);
    // Image
    [UIView animateWithDuration:kJPSThumbnailAnnotationViewAnimationDuration animations:^{
        CGFloat xOffset = (growing ? -1 : 1) * kJPSThumbnailAnnotationViewExpandOffset/2.0f;
//        self.imageView.frame = CGRectOffset(self.imageView.frame, xOffset, 0.0f);
        self.magnitudeLabel.frame = CGRectOffset(self.magnitudeLabel.frame, xOffset, 0.0f);
    } completion:^(BOOL finished) {
        if (animationDirection == JPSThumbnailAnnotationViewAnimationDirectionShrink) {
            self.state = JPSThumbnailAnnotationViewStateCollapsed;
        }
    }];
    
    // Bubble
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = kJPSThumbnailAnnotationViewAnimationDuration;
    
    // Stroke & Shadow From/To Values
    CGRect largeRect = CGRectInset(self.bounds, -kJPSThumbnailAnnotationViewExpandOffset/2.0f, 0.0f);
    
    CGPathRef fromPath = [self newBubbleWithRect:growing ? self.bounds : largeRect];
    animation.fromValue = (__bridge id)fromPath;
    CGPathRelease(fromPath);
    
    CGPathRef toPath = [self newBubbleWithRect:growing ? largeRect : self.bounds];
    animation.toValue = (__bridge id)toPath;
    CGPathRelease(toPath);
    
    if (growing)
    {
        [_bgLayer setFillColor:[UIColor whiteColor].CGColor];
    }
    else
    {
        [_bgLayer setFillColor:[UIColor colorWithRed:0.471 green:0.318 blue:0.604 alpha:1.00].CGColor];
    }
    
    [self.bgLayer addAnimation:animation forKey:animation.keyPath];
}

#pragma mark - Disclosure Button

- (void)didTapDisclosureButton {
    if (self.disclosureBlock) self.disclosureBlock();
}

+ (UIImage *)disclosureButtonImage {
    CGSize size = CGSizeMake(21.0f, 36.0f);
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(2.0f, 2.0f)];
    [bezierPath addLineToPoint:CGPointMake(10.0f, 10.0f)];
    [bezierPath addLineToPoint:CGPointMake(2.0f, 18.0f)];
    [[UIColor lightGrayColor] setStroke];
    bezierPath.lineWidth = 3.0f;
    [bezierPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
