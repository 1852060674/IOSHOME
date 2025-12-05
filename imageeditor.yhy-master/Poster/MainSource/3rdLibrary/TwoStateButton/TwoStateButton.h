//
//  TwoStateButton.h
//  cloneCamera
//
//  Created by ZB_Mac on 14-10-13.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwoStateButton : UIControl
-(instancetype)initWithFrame:(CGRect)frame andState0Image:(UIImage*)image0 andState1Image:(UIImage *)image1;
-(instancetype)initWithFrame:(CGRect)frame andState0Image:(UIImage*)image0 andState1Image:(UIImage *)image1 andContentRatio:(CGFloat) ratio;
@property (readwrite, nonatomic) BOOL zoomEnable;
@property (readwrite, nonatomic) CGFloat zoomScale;

// 0 or 1
@property (readwrite, nonatomic) NSUInteger buttonState;
@end
