//
//  ZBJoinCollageBottomBar.h
//  Collage
//
//  Created by shen on 13-6-26.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZBJoinCollageBottomBarDelegate <NSObject>

@optional


- (void)showBorderAndColorView:(BOOL)isShow;

//- (void)showPhotoFrameView:(BOOL)isShow;

//- (void)showAddImageView:(BOOL)isShow;

- (void)hiddenPromptView;

@end

@interface ZBJoinCollageBottomBar : UIView

@property (nonatomic, assign)id<ZBJoinCollageBottomBarDelegate> delegate;


@end
