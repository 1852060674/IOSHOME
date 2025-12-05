//
//  BHSelectColorAndBackgroundImageView.h
//  PicFrame
//
//  Created by shen on 13-6-17.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBCommonDefine.h"

@protocol BHSelectColorAndBackgroundImageViewDelegate <NSObject>

@optional

- (void)selectedColor:(UIColor*)color;

- (void)selectedAnImage:(UIImage*)image;

- (void)hiddenFromSuperView;

@end

@interface BHSelectColorAndBackgroundImageView : UIView

@property (nonatomic, assign)id<BHSelectColorAndBackgroundImageViewDelegate> delegate;
@property (nonatomic, strong)UISegmentedControl *segmentedCtrl;

@end
