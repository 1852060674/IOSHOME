//
//  ZBBottomBar.h
//  Collage
//
//  Created by shen on 13-6-24.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZBBottomBarDelegate <NSObject>

@optional

- (void)showSpecificTemplateView:(BOOL)isShow;

- (void)showSmilingFaceView:(BOOL)isShow;

- (void)showAspectView:(BOOL)isShow;

//- (void)showPhotoFrameView:(BOOL)isShow;

- (void)hiddenAllDeleteSmilingFaceIcon;

- (void)showBorderAndColorView:(BOOL)isShow;

@end

@interface ZBBottomBar : UIView

@property (nonatomic, assign)id<ZBBottomBarDelegate> delegate;

@end
