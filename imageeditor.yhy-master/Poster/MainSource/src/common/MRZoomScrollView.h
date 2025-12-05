//
//  MRZoomScrollView.h
//  ScrollViewWithZoom
//
//  Created by xuym on 13-3-27.
//  Copyright (c) 2013年 xuym. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHDragImageView.h"

@protocol BHScrollViewDelegate;

@interface MRZoomScrollView : UIScrollView <UIScrollViewDelegate>
{
    UIImageView *imageView;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) id<BHScrollViewDelegate> myDelegate;

//加载图片，并且调整scrollview contentSize的大小
- (void)setImageViewImage:(UIImage*)image;


@end


@protocol BHScrollViewDelegate <UIScrollViewDelegate>

@optional

- (void)emergeImageView;

@end