//
//  MyScrollView.h
//  PhotoBooth
//
//  Created by  on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyScrollViewDelegate;

@interface MyScrollView : UIScrollView
{
    id<MyScrollViewDelegate> MyDelegate_;
    UIImageView *image_view;
    UIView      *mask_view;
    
    // 用于处理滑动翻页的
    CGPoint startLoc;
    CGPoint endLoc;
}

@property (nonatomic, assign) id<MyScrollViewDelegate> MyDelegate;
@property (nonatomic, retain) UIImageView *image_view;
@property (nonatomic, retain) UIView      *mask_view;

@end


@protocol MyScrollViewDelegate <UIScrollViewDelegate>

@optional
- (void) MyScrollView:(MyScrollView *)scroll touchBegin:(NSSet *)touches withEvent:(UIEvent *)event;

- (void) MyScrollView:(MyScrollView *)scroll touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void) MyScrollView:(MyScrollView *)scroll touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
@end

