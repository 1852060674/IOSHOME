//
//  TwoLevelViewDetailCell.h
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/2.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwoLevelViewDetailCell : UICollectionViewCell
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, readwrite) CGFloat titleRatio;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *labelView;

@property (nonatomic, strong) UIImageView *lockImageView;

@end
