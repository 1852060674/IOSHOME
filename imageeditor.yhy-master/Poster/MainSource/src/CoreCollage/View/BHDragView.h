//
//  BHDragView.h
//  PicFrame
//
//  Created by shen Lv on 13-6-7.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BHDragViewDelegate <NSObject>

@optional
- (void)deleteSeletedSmilingIcon:(NSUInteger)tag;

- (void)adjustDragViewFrame:(CGRect)rect withDragViewTag:(NSUInteger)tag andRadians:(CGFloat)radians;

@end

@interface BHDragView: UIView
{
    UIImageView *imageView;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) id<BHDragViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame withImage:(UIImage*)image andTag:(NSUInteger)tag;

//隐藏删除按钮
- (void)hiddenDeleteButtonIcon:(BOOL)flag;

@end
