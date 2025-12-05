//
//  ImageCollectionCell.h
//  cutout
//
//  Created by ZB_Mac on 15-3-23.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewImageCollectionCell : UICollectionViewCell
-(void)setImage:(UIImage *)image;
-(void)setTitle:(NSString *)title;
-(void)setRightBottomImage:(UIImage *)image;
-(void)setRightTopImage:(UIImage *)image;
-(void)setCenterImage:(UIImage *)image;
-(void)setImageContentMode:(UIViewContentMode)mode;

@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, readwrite) BOOL shouldShowSelectedStatus;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, readwrite) CGFloat titleRatio;
@property (nonatomic, readwrite) CGFloat fontRatio;
@end
