//
//  ImageCollectionCell.m
//  cutout
//
//  Created by ZB_Mac on 15-3-23.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "ShareViewImageCollectionCell.h"

@interface ShareViewImageCollectionCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *RBImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *RTImageView;
@end

@implementation ShareViewImageCollectionCell
-(UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.bounds)*self.titleRatio, 0))];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
    }
    return _imageView;
}

-(void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

-(UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(CGRectGetHeight(self.bounds)*(1.0 - self.titleRatio), 0, 0, 0))];
        _titleLabel.font = [UIFont systemFontOfSize:CGRectGetHeight(_titleLabel.bounds)*0.8];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

-(void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

-(void)setFontRatio:(CGFloat)fontRatio
{
    _fontRatio = fontRatio;
    self.titleLabel.font = [UIFont systemFontOfSize:CGRectGetHeight(self.titleLabel.bounds)*fontRatio];
}

-(UIImageView *)RBImageView
{
    if (_RBImageView == nil) {
        CGFloat size = self.bounds.size.width * 0.4;
        _RBImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-size, self.bounds.size.height-size, size, size)];
        _RBImageView.contentMode = UIViewContentModeScaleAspectFit;
        _RBImageView.clipsToBounds = YES;
        [self addSubview:_RBImageView];
    }
    return _RBImageView;
}

-(void)setRightBottomImage:(UIImage *)image
{
    self.RBImageView.image = image;
}


-(UIImageView *)centerImageView
{
    if (_centerImageView == nil) {
        CGFloat size = MIN(self.imageView.bounds.size.width, self.imageView.bounds.size.height) * 0.5;
        _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        CGPoint center = self.imageView.center;
        center.x -= MIN(CGRectGetWidth(self.imageView.frame), CGRectGetHeight(self.imageView.frame))*0.03;
        center.y -= MIN(CGRectGetWidth(self.imageView.frame), CGRectGetHeight(self.imageView.frame))*0.03;
        _centerImageView.center = center;
        _centerImageView.contentMode = UIViewContentModeScaleAspectFit;
        _centerImageView.clipsToBounds = YES;
        if (self.shouldShowSelectedStatus) {
            _centerImageView.hidden = !self.selected;
        }
        else
        {
            _centerImageView.hidden = YES;
        }
        [self addSubview:_centerImageView];
    }
    return _centerImageView;
}

-(void)setCenterImage:(UIImage *)image
{
    self.centerImageView.image = image;
}

-(UIImageView *)RTImageView
{
    if (_RTImageView == nil) {
        CGFloat size = self.bounds.size.width * 0.25;
        _RTImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        CGPoint center = self.imageView.center;
        center.x -= MIN(CGRectGetWidth(self.imageView.frame), CGRectGetHeight(self.imageView.frame))*0.03;
        center.y -= MIN(CGRectGetWidth(self.imageView.frame), CGRectGetHeight(self.imageView.frame))*0.03;
        _RTImageView.center = center;
        _RTImageView.contentMode = UIViewContentModeScaleAspectFit;
        _RTImageView.clipsToBounds = YES;
        [self addSubview:_RTImageView];
    }
    return _RTImageView;
}

-(void)setRightTopImage:(UIImage *)image
{
    self.RTImageView.image = image;
}

-(void)setImageContentMode:(UIViewContentMode)mode
{
    self.imageView.contentMode = mode;
}

-(void)setShouldShowSelectedStatus:(BOOL)shouldShowSelectedStatus
{
    _shouldShowSelectedStatus = shouldShowSelectedStatus;
    if (_shouldShowSelectedStatus) {
        self.selected = self.selected;
    }
}

-(void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    
    self.titleLabel.textColor = titleColor;
}
@end
