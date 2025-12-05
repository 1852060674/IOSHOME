//
//  BHSelectColorAndBackgroundImageView.m
//  PicFrame
//
//  Created by shen on 13-6-17.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHSelectColorAndBackgroundImageView.h"
#import "KZColorPicker.h"
#import "BHShowBackgroundImagesView.h"
#import "ZBCommonDefine.h"
#import "ZBColorDefine.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageUtil.h"
#import "ZBDeleteButton.h"

@interface BHSelectColorAndBackgroundImageView()
{
    KZColorPicker *_colorPicker;
    
    BHShowBackgroundImagesView *_bgImageView;
    CGFloat _buttonGap;
}

@end

@implementation BHSelectColorAndBackgroundImageView
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
        
        self.backgroundColor = [UIColor clearColor];
        
        NSArray *items = [NSArray arrayWithObjects:
                          @"Color",
                          @"Pattern",
                          nil];
    
        self.segmentedCtrl=[[UISegmentedControl alloc] initWithItems:items];
        self.segmentedCtrl.frame = CGRectMake((frame.size.width-120)/2, 0.0f, 120.0f, 35.0f);
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
        
        ZBDeleteButton *_deleteButton = [[ZBDeleteButton alloc] initWithFrame:CGRectMake(-25, 10, 50, 50)];
        [_deleteButton addTarget:self action:@selector(hiddenSelfFromSuperView) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_deleteButton];
        
    }
    return self;
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
        }
            break;
        case 1:
        {
            _colorPicker.hidden = YES;
            _bgImageView.hidden = NO;
        }
            break;
        default:
            break;
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
