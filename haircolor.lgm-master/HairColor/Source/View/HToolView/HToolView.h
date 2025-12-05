//
//  HToolView.h
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/23.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleImageCollectionViewCell.h"


@interface HToolViewCellAttributes : NSObject<SimpleImageCollectionViewCellAdditionalDataSource>
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *selectedTitleColor;

@property (nonatomic, readwrite) UIViewContentMode imageViewContentMode;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *iconPath;

@property (nonatomic, strong) UIImage *selectedIcon;
@property (nonatomic, strong) NSString *selectedIconPath;

@property (nonatomic, readwrite) BOOL loadIconFromPath;
@property (nonatomic, readwrite) BOOL delayLoadIcon;

@property (nonatomic, readwrite) UIEdgeInsets imageViewInsets;

@property (nonatomic, readwrite) BOOL showRT;
@end

@interface HToolView : UIView
// 0 - None; 1 - Image Center Mask; 2 - border line; 3 - Image Right Top; 4 - selected icon & tint color title; 5 - tint icon & title; 6 - Image Center Mask & tint color title
@property (nonatomic, readwrite) NSInteger showSelectedMode;
@property (nonatomic, strong) UIImage *selectedCenterMask;
@property (nonatomic, strong) UIColor *selectedMaskBGColor;
@property (nonatomic, readwrite) BOOL roundCorner;
@property (nonatomic, readwrite) CGFloat titleRatio;
@property (nonatomic, readwrite) CGFloat widthRatio;

@property (nonatomic, copy) void(^actions)(NSInteger index);
@property (nonatomic, copy) NSArray *cellDatas;

-(instancetype)initWithFrame:(CGRect)frame andCellDatas:(NSArray *)cellDatas;

-(void)reloadData;
-(HToolViewCellAttributes *)cellAttributesForCellIndex:(NSInteger)index;
-(UIView *)cellForCellIndex:(NSInteger)index;
-(void)selectAtIndex:(NSInteger)index;
-(void)scrollToIndex:(NSInteger)index;
-(NSInteger)selectedIndex;
-(void)updateRT;

@end
