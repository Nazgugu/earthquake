//
//  RangeSelectionView.h
//  EarthQuake
//
//  Created by Liu Zhe on 12/17/15.
//  Copyright © 2015 Liu Zhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RangeSelectionViewDelegate <NSObject>

@required

- (void)didSelectRange:(CGFloat)range;

@end

@interface RangeSelectionView : UIView

@property (nonatomic, assign) id<RangeSelectionViewDelegate> delegate;

- (void)setSliderWithCurrentRange:(CGFloat)range;

- (void)show;

- (void)dismiss;

@end
