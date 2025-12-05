//
//  SimpleImageCollectionViewCell.h
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/23.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SimpleImageCollectionViewCell;

@protocol SimpleImageCollectionViewCellAdditionalDataSource <NSObject>

-(UIImage *)iconForCell:(SimpleImageCollectionViewCell *)cell selected:(BOOL)selected;
-(UIColor *)titleColorForCell:(SimpleImageCollectionViewCell *)cell selected:(BOOL)selected;
-(UIEdgeInsets) imageViewEdgeInsetsForCell:(SimpleImageCollectionViewCell *)cell;
@end

@interface SimpleImageCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, readwrite) CGFloat titleRatio;
@property (nonatomic, readwrite) NSInteger layoutMode;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UIImageView *RTImageView;

// 0 - None; 1 - Image Center Mask; 2 - border line; 3 - Image Right Top; 4 - selected icon & tint color title; 5 - tint icon & title; 6 - Image Center Mask & tint color title
@property (nonatomic, readwrite) NSInteger showSelectedMode;
@property (nonatomic, readwrite) BOOL showRTView;

@property (nonatomic, weak) id<SimpleImageCollectionViewCellAdditionalDataSource> additionalDataSource;

-(void)setupViews;
@end
