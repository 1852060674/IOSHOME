//
//  ZBPosterCollageBottomBar.h
//  Collage
//
//  Created by shen on 13-7-22.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZBPosterCollageBottomBarDelegate <NSObject>

@optional


- (void)showSelectPosterView:(BOOL)isShow;

//- (void)showPhotoFrameView:(BOOL)isShow;

//- (void)showAddImageView:(BOOL)isShow;

- (void)hiddenPromptView;

@end

@interface ZBPosterCollageBottomBar : UIView

@property (nonatomic, assign)id<ZBPosterCollageBottomBarDelegate> delegate;

@end
