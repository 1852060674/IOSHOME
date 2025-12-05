//
//  ContinousSlider.h
//  ThinBooth
//
//  Created by ZB_Mac on 14-9-19.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContinousSlider : UIControl
-(id)initWithFrame:(CGRect)frame
          andTitle:(NSString *)title
       andMinValue:(CGFloat)min
       andMaxValue:(CGFloat)max
    andNormalColor:(UIColor *)normalColor
 andHighlightColor:(UIColor *)highlightColor
   andPointerImage:(UIImage *)image;

-(id)initWithFrame:(CGRect)frame
          andTitle:(NSString *)title
       andMinValue:(CGFloat)min
       andMaxValue:(CGFloat)max
    andNormalColor:(UIColor *)normalColor
 andHighlightColor:(UIColor *)highlightColor
   andPointerColor:(UIColor *)pointerColor;

@property (readwrite, nonatomic) CGFloat maxValue;
@property (readwrite, nonatomic) CGFloat minValue;
@property (readwrite, nonatomic) CGFloat selectedValue;
@property (readwrite, nonatomic) BOOL instanceValueChanged;
@end
