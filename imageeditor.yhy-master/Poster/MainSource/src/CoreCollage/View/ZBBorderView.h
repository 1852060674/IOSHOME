//
//  ZBBorderView.h
//  Collage
//
//  Created by shen on 13-7-1.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBCommonDefine.h"

@protocol ZBBorderViewDelegate <NSObject>

@optional

- (void)selectedColor:(UIColor*)color;

- (void)selectedAnImage:(UIImage*)image;

- (void)hiddenFromSuperView;

- (void)changeBorderOrCorner:(CGFloat)value withChangedType:(SliderChangeType)type;

@end

@interface ZBBorderView : UIView

@property (nonatomic, assign)id<ZBBorderViewDelegate> delegate;
@property (nonatomic, strong)UISegmentedControl *segmentedCtrl;

@end
