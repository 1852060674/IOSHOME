//
//  MGAdjustView.m
//  SplitPics
//
//  Created by tangtaoyu on 15-3-12.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGAdjustView.h"
#import "MGDefine.h"

@implementation MGAdjustView{
    CGRect originRect;
    
    NSInteger sliderCount;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.clipsToBounds = YES;
    originRect = frame;
    
    [self dataInit];
    [self widgetsInit];
    
    return self;
}

- (void)dataInit
{
    sliderCount = 0;
    self.backgroundColor = MGTBBgColor;
}

- (void)widgetsInit
{
    float sliderW = kDevice2(250, 600);
    _slider = [[MGSlider alloc] initWithFrame:CGRectMake((self.bounds.size.width-sliderW)/2, 0, sliderW, self.bounds.size.height/2)];
    _slider.maximumValue = 0.5;
    _slider.minimumValue = -0.5;
    _slider.value = 0.0;
    [_slider addTarget:self action:@selector(changeValue) forControlEvents:UIControlEventValueChanged];
    [_slider setMinimumTrackTintColor:HEXCOLOR(0xd8d8d8ff)];
    [_slider setMaximumTrackTintColor:HEXCOLOR(0x4f4f4fff)];
    [self addSubview:_slider];
    
    UIView *CtlView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height/2, self.bounds.size.width, self.bounds.size.height/2)];
    [self addSubview:CtlView];
    
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(CtlView.bounds.size.width/4, 0, CtlView.bounds.size.width/2, CtlView.bounds.size.height);
    _label.font = [UIFont systemFontOfSize:20];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    [CtlView addSubview:_label];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, CtlView.bounds.size.height, CtlView.bounds.size.height);
    [leftBtn setImage:[UIImage imageNamed:@"btn_cancel"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.tag = 0;
    [CtlView addSubview:leftBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(CtlView.bounds.size.width-CtlView.bounds.size.height, 0, CtlView.bounds.size.height, CtlView.bounds.size.height);
    [rightBtn setImage:[UIImage imageNamed:@"btn_ok"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.tag = 1;
    [CtlView addSubview:rightBtn];
    
    self.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
    self.hidden = YES;
}

- (void)setTitleStr:(NSString *)titleStr
{
    self.label.text = titleStr;
}

- (void)changeValue
{
    float value = _slider.value;
    
    if(sliderCount%5 == 0){
        if(self.sliderBlock){
            self.sliderBlock(value);
        }
    }
    sliderCount++;
}

- (void)clickBtn:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSInteger index = btn.tag;
    
    if(index == 0){
        if(self.cancelBlock){
            self.cancelBlock();
        }
        [self hideSelf];
    }else{
        if(self.confirmBlock){
            self.confirmBlock(_slider.value);
        }
        [self hideSelf];
    }
}

- (void)showSelf
{
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = originRect;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideSelf
{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
    } completion:^(BOOL finished) {
        //[self removeFromSuperview];
        self.hidden = YES;
    }];
}

@end
