//
//  ZBBorderView.m
//  Collage
//
//  Created by shen on 13-7-1.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBBorderView.h"
#import "KZColorPicker.h"
#import "BHShowBackgroundImagesView.h"
#import "ZBCommonDefine.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageUtil.h"
#import "ZBDeleteButton.h"
#import "ZBColorDefine.h"

@interface ZBBorderView()
{
    KZColorPicker *_colorPicker;
    
    BHShowBackgroundImagesView *_bgImageView;
    CGFloat _buttonGap;
    
    UISlider *cornerRadiusSlider;
    UISlider *borderWidthSlider;
    UILabel *_cornerLabel;
    UILabel *_borderLabel;
}

- (void)initCornerAndBorderView;

@end


@implementation ZBBorderView

@synthesize delegate;
@synthesize segmentedCtrl = _segmentedCtrl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //        self.layer.cornerRadius = 3;
        //        self.layer.masksToBounds = YES;
        CGFloat _buttonWidth = 0;
        CGFloat _buttonHeight = 0;
        if (IS_IPAD) {
            _buttonWidth = 80;
            _buttonHeight = 60;
        }
        else
        {
            _buttonWidth = 40;
            _buttonHeight = 30;
        }
        
        self.backgroundColor = kTransparentColor;
        
        NSArray *items = [NSArray arrayWithObjects:
                          @"Color",
                          @"Pattern",
                          @"Corner",
                          @"Border",
                          nil];
        float factor = 1.0;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            factor = 2.0;
        
        self.segmentedCtrl=[[UISegmentedControl alloc] initWithItems:items];
        self.segmentedCtrl.frame = CGRectMake((frame.size.width-200*factor)/2, 0.0f, 200.0*factor, 35.0);
        self.segmentedCtrl.segmentedControlStyle = UISegmentedControlStyleBar;
        
        self.segmentedCtrl.tintColor= kBorderColor;
        [self.segmentedCtrl setSelectedSegmentIndex:0];
        self.segmentedCtrl.multipleTouchEnabled=NO;
        [self.segmentedCtrl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.segmentedCtrl];
        self.segmentedCtrl.backgroundColor = [UIColor whiteColor];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,  [UIFont systemFontOfSize:12],UITextAttributeFont ,nil];
        [self.segmentedCtrl setTitleTextAttributes:dic forState:UIControlStateNormal];
        
        UIView *_secondView = [[UIView alloc] initWithFrame:CGRectMake(0, 34, frame.size.width, frame.size.height-30)];
        [self addSubview:_secondView];
        _secondView.backgroundColor = kBorderColor;
        
        _buttonGap = (self.frame.size.height - 2*_buttonHeight)/3;
        _colorPicker = [[KZColorPicker alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-35)];
        _colorPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _colorPicker.selectedColor = [UIColor whiteColor];
        [_colorPicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
        [_secondView addSubview:_colorPicker];
        
        _bgImageView = [[BHShowBackgroundImagesView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-35)];
        _bgImageView.hidden = YES;
        [_secondView addSubview:_bgImageView];
        
      //  ZBDeleteButton *_deleteButton = [[ZBDeleteButton alloc] initWithFrame:CGRectMake(-10, -10, 50, 50)];
       // [_deleteButton addTarget:self action:@selector(hiddenSelfFromSuperView) //forControlEvents:UIControlEventTouchUpInside];
       // [self addSubview:_deleteButton];
        
        [self initCornerAndBorderView];
    }
    return self;
}

- (void)initCornerAndBorderView
{
    float _sliderLength = 140;
    float _sliderHeight = 20;
    float _labelFontSize = 14;
    if (IS_IPAD) {
        _sliderLength = 280;
        _sliderHeight = 40;
        _labelFontSize = 16;
    }
    
    double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
    
    
    
    // Initialization code
    _cornerLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-100)/2, 50, 100, _labelFontSize+4)];
    _cornerLabel.text = @"Corner";
    if(version>=6.0f){
        _cornerLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
        _cornerLabel.textAlignment = UITextAlignmentCenter;
    
    _cornerLabel.font = [UIFont systemFontOfSize:_labelFontSize];
    _cornerLabel.textColor = [UIColor blackColor];
    _cornerLabel.backgroundColor = kTransparentColor;
    _cornerLabel.hidden = YES;
    [self addSubview:_cornerLabel];
    
    cornerRadiusSlider = [[UISlider alloc] initWithFrame:CGRectMake((self.frame.size.width-_sliderLength)/2, 80, _sliderLength, _sliderHeight)]; //初始化
    cornerRadiusSlider.minimumValue = 0;//指定可变最小值
    cornerRadiusSlider.maximumValue = 20;//指定可变最大值
    cornerRadiusSlider.value = 0;//指定初始值
    cornerRadiusSlider.hidden = YES;
    [cornerRadiusSlider addTarget:self action:@selector(updateCornerValue:) forControlEvents:UIControlEventValueChanged];//设置响应事件
    [self addSubview:cornerRadiusSlider];
    
    _borderLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-100)/2, 50, 100, _labelFontSize+4)];
    _borderLabel.text = @"Border";
    if(version>=6.0f)
    {
        _cornerLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
        _cornerLabel.textAlignment = UITextAlignmentCenter;
    _borderLabel.backgroundColor = kTransparentColor;
    _borderLabel.font = [UIFont systemFontOfSize:_labelFontSize];
    _borderLabel.textColor = [UIColor blackColor];
    _borderLabel.hidden = YES;
    [self addSubview:_borderLabel];
    
    borderWidthSlider = [[UISlider alloc] initWithFrame:CGRectMake((self.frame.size.width-_sliderLength)/2, 80, _sliderLength, _sliderHeight)]; //初始化
    borderWidthSlider.minimumValue = 0;//指定可变最小值
    borderWidthSlider.maximumValue = 30;//指定可变最大值
    borderWidthSlider.value = 10;//指定初始值
    borderWidthSlider.hidden = YES;
    [borderWidthSlider addTarget:self action:@selector(updateBorderValue:) forControlEvents:UIControlEventValueChanged];//设置响应事件
    [self addSubview:borderWidthSlider];
}

- (void) pickerChanged:(KZColorPicker *)cp
{
    //    self.selectedColor = cp.selectedColor;
    //	[delegate defaultColorController:self didChangeColor:cp.selectedColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedColor:)]) {
        [self.delegate selectedColor:cp.selectedColor];
    }
}

- (void)hiddenSelfFromSuperView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenFromSuperView)]) {
        [self.delegate hiddenFromSuperView];
    }
}

- (void)segmentedControlDidChange:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            _colorPicker.hidden = NO;
            _bgImageView.hidden = YES;
            _cornerLabel.hidden = YES;
            cornerRadiusSlider.hidden = YES;
            _borderLabel.hidden = YES;
            borderWidthSlider.hidden = YES;
        }
            break;
        case 1:
        {
            _colorPicker.hidden = YES;
            _bgImageView.hidden = NO;
            _cornerLabel.hidden = YES;
            cornerRadiusSlider.hidden = YES;
            _borderLabel.hidden = YES;
            borderWidthSlider.hidden = YES;
        }
            break;
        case 2:
        {
            _colorPicker.hidden = YES;
            _bgImageView.hidden = YES;
            _cornerLabel.hidden = NO;
            cornerRadiusSlider.hidden = NO;
            _borderLabel.hidden = YES;
            borderWidthSlider.hidden = YES;
        }
            break;
        case 3:
        {
            _colorPicker.hidden = YES;
            _bgImageView.hidden = YES;
            _cornerLabel.hidden = YES;
            cornerRadiusSlider.hidden = YES;
            _borderLabel.hidden = NO;
            borderWidthSlider.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)updateCornerValue:(id)sender
{
    CGFloat _value = (NSUInteger)[(UISlider *)sender value];
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeBorderOrCorner: withChangedType:)]) {
        [self.delegate changeBorderOrCorner:_value withChangedType:SliderChangeTypeCorner];
    }
}

- (void)updateBorderValue:(id)sender
{
    CGFloat _value = (NSUInteger)[(UISlider *)sender value];
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeBorderOrCorner: withChangedType:)]) {
        [self.delegate changeBorderOrCorner:_value withChangedType:SliderChangeTypeBorder];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
