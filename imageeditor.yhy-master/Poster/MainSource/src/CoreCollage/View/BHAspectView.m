//
//  BHAspectView.m
//  PicFrame
//
//  Created by shen Lv on 13-6-5.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHAspectView.h"
#import "ImageUtil.h"
#import "BHPromptFrameView.h"
#import "ZBColorDefine.h"

#define kCountOfAspect   11

#define kAspectButtonEdge        50

#define kButtonWidth           60
#define kButtonGap             (kScreenWidth-4*kButtonWidth)/5

@interface BHAspectView()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    NSInteger _photoFrameButtonEdge;
    NSInteger _originY;
    float _scrollViewHeight;
    float _segmentItemWidth;
    float _segmentWidth;
}

@end

@implementation BHAspectView

@synthesize delegate = _delegate;


- (void)dealloc
{
    for (UIView *_aView in [_scrollView subviews]) {
        [_aView removeFromSuperview];
    }
    _scrollView.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            _scrollViewHeight = 86;
            _photoFrameButtonEdge = 50;
            _originY = 5;
            _segmentItemWidth = 75;
            _segmentWidth = kBottomBarWidth;
        }
        else
        {
            _scrollViewHeight = 110;
            _photoFrameButtonEdge = 80;
            _originY = 10;
            _segmentItemWidth = 100;
            _segmentWidth = 400;
        }
        self.backgroundColor = [UIColor clearColor];
        
        BHPromptFrameView *_promptFrame = [[BHPromptFrameView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.frame.size.height)];
        _promptFrame.arrowDirection = 2;
        _promptFrame.arrowPosition = 0;
        _promptFrame.arrowPoint = CGPointMake((kScreenWidth-_segmentWidth)/2+2.5*_segmentItemWidth, frame.size.height);
        _promptFrame.cornerRadius = 3;
        _promptFrame.baseColor = kPromptFrameViewBaseColor;
        [self addSubview:_promptFrame];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _scrollViewHeight)];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        [self loadAspects];
        
     }
    return self;
}

- (void)loadAspects
{
//    NSInteger _gapBetweenAspects = 10;
    for (NSInteger i=0; i<kCountOfAspect; i++)
    {
        UIButton *_aspectButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _aspectButton.frame = CGRectMake(50*i, 15, 50, 50);
        _aspectButton.frame = CGRectMake(_photoFrameButtonEdge*i, _originY, _photoFrameButtonEdge, _photoFrameButtonEdge);

        [_aspectButton addTarget:self action:@selector(changeTemplateAspect:) forControlEvents:UIControlEventTouchUpInside];
        _aspectButton.tag = kAspectButtonStartTag+i;
        [_scrollView addSubview:_aspectButton];
        
        switch (i) {
            case 0:
            {
                [_aspectButton setImage:[ImageUtil loadResourceImage:@"aspect_1x1_icon-iphone"] forState:UIControlStateNormal];
            }
                break;
            case 1:
            {
                [_aspectButton setImage:[ImageUtil loadResourceImage:@"aspect_2x3_icon-iphone"] forState:UIControlStateNormal];
            }
                break;
            case 2:
            {
                [_aspectButton setImage:[ImageUtil loadResourceImage:@"aspect_3x2_icon-iphone"] forState:UIControlStateNormal];
            }
                break;
            case 3:
            {
                [_aspectButton setImage:[ImageUtil loadResourceImage:@"aspect_3x4_icon-iphone"] forState:UIControlStateNormal];
            }
                break;
            case 4:
            {
                [_aspectButton setImage:[ImageUtil loadResourceImage:@"aspect_4x3_icon-iphone"] forState:UIControlStateNormal];
            }
                break;
            case 5:
            {
                [_aspectButton setImage:[ImageUtil loadResourceImage:@"aspect_4x5_icon-iphone"] forState:UIControlStateNormal];
            }
                break;
            case 6:
            {
                [_aspectButton setImage:[ImageUtil loadResourceImage:@"aspect_5x4_icon-iphone"] forState:UIControlStateNormal];
            }
                break;
            case 7:
            {
                [_aspectButton setImage:[ImageUtil loadResourceImage:@"aspect_5x7_icon-iphone"] forState:UIControlStateNormal];
            }
                break;
            case 8:
            {
                [_aspectButton setImage:[ImageUtil loadResourceImage:@"aspect_7x5_icon-iphone"] forState:UIControlStateNormal];
            }
                break;
            case 9:
            {
                [_aspectButton setImage:[ImageUtil loadResourceImage:@"aspect_9x16_icon-iphone"] forState:UIControlStateNormal];
            }
                break;
            case 10:
            {
                [_aspectButton setImage:[ImageUtil loadResourceImage:@"aspect_16x9_icon-iphone"] forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
    }
    _scrollView.contentSize = CGSizeMake(kCountOfAspect*_photoFrameButtonEdge,  _scrollViewHeight);
}

#pragma mark -- button method
- (void)changeTemplateAspect:(id)sender
{
    UIButton *_selectedButton = (UIButton*)sender;
    AspectType _selectedType = _selectedButton.tag - kAspectButtonStartTag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedAspectType:)]) {
        [self.delegate selectedAspectType:_selectedType];
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
