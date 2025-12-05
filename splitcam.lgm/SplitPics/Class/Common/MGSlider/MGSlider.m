//
//  MGSlider.m
//  bokehPhoto
//
//  Created by tangtaoyu on 15-3-30.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import "MGSlider.h"

#define MGSliderLineH 6

@implementation MGSlider

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    [super trackRectForBounds:bounds];
    
    CGRect customBounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, MGSliderLineH);
    
    customBounds.origin.y += bounds.size.height/2-MGSliderLineH/2;
    
    return customBounds;
}


@end


//float sliderW = kDevice2(280, 640);
//blurSlider = [[MGSlider alloc] init];
//blurSlider.frame = CGRectMake((kScreenWidth-sliderW)/2, 0, sliderW, bottomH-btnH);
//blurSlider.maximumValue = 40;
//blurSlider.minimumValue = 5;
//blurSlider.value = 20;
//[blurSlider addTarget:self action:@selector(changeBrushValue:) forControlEvents:UIControlEventValueChanged];
//[blurSlider setMinimumTrackTintColor:HEXCOLOR(0xd8d8d8ff)];
//[blurSlider setMaximumTrackTintColor:HEXCOLOR(0x4f4f4fff)];
//[bottomView2 addSubview:blurSlider];