//
//  RangeSelectionView.m
//  EarthQuake
//
//  Created by Liu Zhe on 12/17/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#import "RangeSelectionView.h"
#import "UIImage+ImageEffects.h"
#import "ASValueTrackingSlider.h"

@interface RangeSelectionView ()<UIGestureRecognizerDelegate, ASValueTrackingSliderDelegate>

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) ASValueTrackingSlider *rangeSlider;

@end

@implementation RangeSelectionView

- (instancetype)init
{
    self = [super initWithFrame:screenBounds];
    if (self)
    {
        self.opaque = YES;
        self.alpha = 1;
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews
{
    _backgroundView = [[UIImageView alloc] initWithFrame:screenBounds];
    self.backgroundView.tag = 1;
    self.backgroundView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.backgroundView addGestureRecognizer:tap];
    UIImage *bluredImage = [[self convertViewToImage] applyBlurWithRadius:12 tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.4f] saturationDeltaFactor:1.0f maskImage:nil];
    [self.backgroundView setImage:bluredImage];
    self.backgroundView.alpha = 0.0f;
    [self addSubview:self.backgroundView];
    [self setUpTitleLabel];
    [self setUpContainerView];
}

- (void)setUpTitleLabel
{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT - 50) / 2,  SCREEN_WIDTH, 50)];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    if (IOS9_UP)
    {
        self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:24.0f];
    }
    else
    {
        self.titleLabel.font = [UIFont systemFontOfSize:24.0f];
    }
    [self.titleLabel setText:@"Set The Radius of Search Area"];
    [self addSubview:self.titleLabel];
}

- (void)setUpContainerView
{
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 80)];
    self.containerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
    self.containerView.alpha = 0.0f;
    self.containerView.opaque = NO;
    [self setUpRangeSlider];
    [self setUpCancelButton];
    [self addSubview:self.containerView];
}

- (void)setUpRangeSlider
{
    _rangeSlider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(30, 20, SCREEN_WIDTH - 15 - 30 - 30, 40)];
    self.rangeSlider.maximumValue = 3000.0;
    self.rangeSlider.minimumValue = 10.0f;
    if (IOS9_UP)
    {
        self.rangeSlider.font = [UIFont fontWithName:@"PingFangSC-Regular" size:24.0f];
    }
    else
    {
        self.rangeSlider.font = [UIFont systemFontOfSize:24.0f];
    }
    self.rangeSlider.popUpViewAnimatedColors = @[[UIColor orangeColor], [UIColor redColor], [UIColor purpleColor]];
//    [self.rangeSlider showPopUpViewAnimated:YES];
    self.rangeSlider.delegate = self;
    [self.containerView addSubview:self.rangeSlider];
}

- (void)setUpCancelButton
{
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 27.5, 25, 25)];
    self.cancelButton.imageView.clipsToBounds = YES;
    self.cancelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *closeImage = [[UIImage imageNamed:@"smallClose"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.cancelButton.imageView setTintColor:[UIColor purpleColor]];
    [self.cancelButton setImage:closeImage forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:_cancelButton];
}

- (void)setSliderWithCurrentRange:(CGFloat)range
{
    self.rangeSlider.value = range;
}

-(UIImage *)convertViewToImage
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return capturedScreen;
}

- (void)show
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundView.alpha = 1.0f;
        [self.containerView setFrame:CGRectMake(0, SCREEN_HEIGHT - self.containerView.frame.size.height, self.containerView.frame.size.width, self.containerView.frame.size.height)];
        self.containerView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
    
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    if (!window){
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    [window addSubview:self];

}

- (void)dismiss
{
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.containerView setFrame:CGRectMake(0, SCREEN_HEIGHT, self.containerView.frame.size.width, self.containerView.frame.size.height)];
        self.containerView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished)
        {
            [UIView animateWithDuration:0.2f delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }
    }];
}

#pragma mark - ASValueTrackingSliderDelegate

- (void)sliderWillDisplayPopUpView:(ASValueTrackingSlider *)slider
{
    
}

- (void)sliderDidHidePopUpView:(ASValueTrackingSlider *)slider
{
    NSLog(@"hide");
    if ([self.delegate respondsToSelector:@selector(didSelectRange:)])
    {
        [self.delegate didSelectRange:slider.value];
    }
    [self dismiss];
}

@end
