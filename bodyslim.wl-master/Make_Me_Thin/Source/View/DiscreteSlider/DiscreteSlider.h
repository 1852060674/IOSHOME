//
//  DiscreteSlider.h
//  ThinBooth
//
//  Created by ZB_Mac on 14-9-19.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscreteSlider : UIControl

-(id)initWithFrame:(CGRect)frame andMinValue:(NSInteger)min andMaxValue:(NSInteger)max andNormalColor:(UIColor *)normalColor andHighlightColor:(UIColor *)highlightColor andPointerImages:(NSArray *)images;

@property (readwrite, nonatomic) NSInteger selectedValue;
@property (readonly, nonatomic) NSInteger maxValue;
@property (readonly, nonatomic) NSInteger minValue;
@end
