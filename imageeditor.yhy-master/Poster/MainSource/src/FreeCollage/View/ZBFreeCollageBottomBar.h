//
//  ZBFreeCollageBottomBar.h
//  Collage
//
//  Created by shen on 13-6-25.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZBFreeCollageBottomBarDelegate <NSObject>

@optional


- (void)showSmilingFaceView:(BOOL)isShow;

//- (void)showAspectView:(BOOL)isShow;

- (void)showBackGroundImageView:(BOOL)isShow;

- (void)showBorderAndColorView:(BOOL)isShow;

- (void)hiddenAllDeleteSmilingFaceIcon;

@end

@interface ZBFreeCollageBottomBar : UIView

@property (nonatomic, assign)id<ZBFreeCollageBottomBarDelegate> delegate;



@end
