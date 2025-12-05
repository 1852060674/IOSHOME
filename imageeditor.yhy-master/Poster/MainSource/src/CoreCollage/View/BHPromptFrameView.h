//
//  BHPromptFrameView.h
//  PicFrame
//
//  Created by shen on 13-6-11.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    TSPopoverArrowDirectionTop = 0,
	TSPopoverArrowDirectionRight,
    TSPopoverArrowDirectionBottom,
    TSPopoverArrowDirectionLeft
};
typedef NSUInteger TSPopoverArrowDirection;

enum {
    TSPopoverArrowPositionVertical = 0,
    TSPopoverArrowPositionHorizontal
};

typedef NSUInteger TSPopoverArrowPosition;

@interface BHPromptFrameView : UIView

@property (nonatomic) int cornerRadius;
@property (nonatomic) CGPoint arrowPoint;
@property (nonatomic) BOOL isGradient;
@property (nonatomic, strong) UIColor *baseColor;
@property (nonatomic, readwrite) TSPopoverArrowDirection arrowDirection;
@property (nonatomic, readwrite) TSPopoverArrowPosition arrowPosition;

@end
