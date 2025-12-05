//
//  ZoomView.h
//  eyeColorPlus
//
//  Created by shen on 14-7-21.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomView : UIView
-(id)initWithCircleRadius:(CGFloat)radius;
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, strong) UIColor *innerColor;
@property (nonatomic, strong) UIColor *crossColor;

@property (nonatomic, readwrite) CGFloat circleLineWidth;
@property (nonatomic, readwrite) BOOL circleLineDashed;
@property (nonatomic, readwrite) CGFloat circleRadius;
@property (nonatomic, readwrite) BOOL hasCross;
@property (nonatomic, readwrite) CGFloat crossLineWidth;
@end
