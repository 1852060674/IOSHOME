//
//  TwoStateButtonWithTitle.h
//  EyeColor4.0
//
//  Created by ZB_Mac on 15-1-20.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwoStateButtonWithTitle : UIControl
-(instancetype)initWithFrame:(CGRect)frame
              andState0Image:(UIImage*)image0
              andState1Image:(UIImage *)image1
                   andTitle0:(NSString*)title0
                   andTitle1:(NSString *)title1
             andTitle0Insets:(UIEdgeInsets)title0Insets
             andTitle1Insets:(UIEdgeInsets)title1Insets
              andTitle0Color:(UIColor *)color0
              andTitle1Color:(UIColor *)color1
             andContentRatio:(CGFloat)ratio;

@property (readwrite, nonatomic) BOOL zoomEnable;
@property (readwrite, nonatomic) CGFloat zoomScale;

// 0 or 1
@property (readwrite, nonatomic) NSUInteger buttonState;
@end
