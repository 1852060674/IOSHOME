//
//  ZBHomePageView.h
//  Poster
//
//  Created by shen on 13-8-2.
//  Copyright (c) 2013年 ZBNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZBHomePageViewDelegate <NSObject>

@optional

- (void)editImage;

- (void)collage;

- (void)more_app;

- (void)update_pro;

@end

@interface ZBHomePageView : UIView

@property (nonatomic, assign) id<ZBHomePageViewDelegate> delegate;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *upgradeButton;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *feedbackButton;


@end
