//
//  CreateCustomColorView.m
//  HairColor
//
//  Created by ZB_Mac on 15/5/13.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "CreateCustomColorView.h"
#import "ILHuePickerView.h"
#import "ILSaturationBrightnessPickerView.h"

@interface CreateCustomColorView ()<ILHuePickerViewDelegate, ILSaturationBrightnessPickerViewDelegate>
{
    CGFloat _hueViewRatio;
    CGFloat _sbViewRatio;
}
@property (strong, nonatomic) UIView *brushColorTipView;
@property (strong, nonatomic) UIView *brushColorView;

@property (strong, nonatomic) ILSaturationBrightnessPickerView *sbView;
@end

@implementation CreateCustomColorView

-(UIView *)brushColorTipView
{
    if (_brushColorTipView == nil) {
        CGFloat tipSize = CGRectGetWidth(self.bounds)/4;
        _brushColorTipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tipSize, tipSize)];
        _brushColorTipView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds)*(1.0-_hueViewRatio-_sbViewRatio)*3.0/4.0);
        _brushColorTipView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        _brushColorTipView.layer.cornerRadius = tipSize/8;
        self.brushColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tipSize/2.0, tipSize/2.0)];
        self.brushColorView.center = CGPointMake(tipSize/2.0, tipSize/2.0);
        self.brushColorView.layer.cornerRadius = tipSize/4.0;
        [_brushColorTipView addSubview:self.brushColorView];
    }
    return _brushColorTipView;
}

-(CreateCustomColorView *)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _hueViewRatio = 1.0/10.0;
        _sbViewRatio = 3.0/8.0;
        
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        [self setupViews];
    }
    
    return self;
}

-(void)setupViews
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    ILHuePickerView *hueView = [[ILHuePickerView alloc] initWithFrame:CGRectMake(0, height*(1.0-_hueViewRatio), width, height*_hueViewRatio)];
    hueView.delegate = self;
    [self addSubview:hueView];
    hueView.layer.cornerRadius = 5.0;
    hueView.layer.borderColor = [UIColor whiteColor].CGColor;
    hueView.layer.borderWidth = 2.0;
    hueView.clipsToBounds = YES;
    
    ILSaturationBrightnessPickerView *sbView = [[ILSaturationBrightnessPickerView alloc] initWithFrame:CGRectMake(0, height*(1.0-_hueViewRatio-_sbViewRatio), width, height*_sbViewRatio)];
    sbView.delegate = self;
    [self addSubview:sbView];
    sbView.layer.cornerRadius = 5.0;
    sbView.layer.borderColor = [UIColor whiteColor].CGColor;
    sbView.layer.borderWidth = 2.0;
    self.sbView = sbView;
    sbView.clipsToBounds = YES;
    
    CGFloat btnPadding = 8;
    CGFloat btnSize = width/10.0;
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(btnPadding, btnPadding, btnSize, btnSize);
    [closeBtn setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
    [self addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(closeBtnHandler:) forControlEvents:UIControlEventTouchUpInside];
//    closeBtn.backgroundColor = [UIColor redColor];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(width-btnPadding-btnSize, btnPadding, btnSize, btnSize);
    [okBtn setImage:[UIImage imageNamed:@"btn_ok"] forState:UIControlStateNormal];
    [self addSubview:okBtn];
    [okBtn addTarget:self action:@selector(okBtnHandler:) forControlEvents:UIControlEventTouchUpInside];
//    okBtn.backgroundColor = [UIColor greenColor];
    
    [self addSubview:self.brushColorTipView];
    self.brushColorView.backgroundColor = self.sbView.color;
}

#pragma mark - actions
-(void)closeBtnHandler:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(createCustomColorViewDidCancel:)]) {
        [self.delegate createCustomColorViewDidCancel:self];
    }
}

-(void)okBtnHandler:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(createCustomColorView:didFinishCreateColor:)]) {
        [self.delegate createCustomColorView:self didFinishCreateColor:self.sbView.color];
    }
}
#pragma mark - ILHuePickerView Delegate
-(void)huePicked:(float)hue picker:(ILHuePickerView *)picker
{
    self.sbView.hue = hue;
    
    self.brushColorView.backgroundColor = self.sbView.color;
    [self bringSubviewToFront:self.brushColorTipView];

}

#pragma mark - ILSaturationBrightnessPickerView Delegate
-(void)colorPicked:(UIColor *)newColor forPicker:(ILSaturationBrightnessPickerView *)picker
{
    self.brushColorView.backgroundColor = newColor;
    [self bringSubviewToFront:self.brushColorTipView];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
