//
//  ZBBackgroundImageView.h
//  Collage
//
//  Created by shen on 13-6-26.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHPromptFrameView.h"

@protocol ZBBackgroundImageViewDelegate <NSObject>

@optional

//选中某个相框
- (void)selectedABackgroundImage:(NSString*)imageName atIndex:(NSInteger)index;;

@end

@interface ZBBackgroundImageView : UIView

@property (nonatomic, assign) id<ZBBackgroundImageViewDelegate> delegate;
@property (nonatomic, strong)BHPromptFrameView *promptFrame;

@end
