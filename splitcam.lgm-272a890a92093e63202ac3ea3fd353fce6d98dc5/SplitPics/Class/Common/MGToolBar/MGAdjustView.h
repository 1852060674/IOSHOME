//
//  MGAdjustView.h
//  SplitPics
//
//  Created by tangtaoyu on 15-3-12.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSlider.h"

typedef void (^SliderBlock)(float value);
typedef void (^ConfirmBlock)(float value);
typedef void (^CancelBlock)();

@interface MGAdjustView : UIView

@property (strong,nonatomic) MGSlider *slider;
@property (strong,nonatomic) UILabel *label;
@property (strong,nonatomic) NSString *titleStr;
@property (copy) SliderBlock sliderBlock;
@property (copy) ConfirmBlock confirmBlock;
@property (copy) CancelBlock cancelBlock;


- (void)hideSelf;
- (void)showSelf;

@end
