//
//  BHShowBackgroundImagesView.m
//  PicFrame
//
//  Created by shen on 13-6-18.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHShowBackgroundImagesView.h"
#import "ImageUtil.h"
#import "ZBCommonDefine.h"
#import "ZBCommonMethod.h"
#import "AdUtility.h"
#import "GlobalSettingManger.h"

#define kCountOfBackgroundImages     82
#define kButtonGap   8
#define kButtonEdge  40
#define kButtonsInPerLine   4
#define kBackgroundImageButtonStartTag  5000

@interface BHShowBackgroundImagesView()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    NSUInteger _buttonsInPerLine;
    float _buttonEdge;
    float _buttonGap;
}

@end

@implementation BHShowBackgroundImagesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _buttonsInPerLine = kButtonsInPerLine;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        float x=0;
        float y=0;
        float w=kButtonEdge;
        float h=kButtonEdge;
        
        NSUInteger _indexLine = 0;
        NSUInteger _indexInPerLine = 0;
        if (IS_IPAD) {
            _buttonEdge = kButtonEdge;
            w = kButtonEdge*2;
            h = w;
            _buttonGap = (frame.size.width-w*4)/5;
        }
        else
        {
            _buttonEdge = kButtonEdge;
            _buttonGap = (frame.size.width-_buttonEdge*4)/5;
        }
        
        for (NSUInteger i=0; i<kCountOfBackgroundImages; i++) {
            UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
            _indexLine = i/_buttonsInPerLine;
            _indexInPerLine = i%_buttonsInPerLine;
            x = _buttonGap*(_indexInPerLine+1)+_indexInPerLine*w;
            y = _buttonGap*(_indexLine+1)+_indexLine*w;
            _button.frame = CGRectMake(x, y, w, h);
            _button.tag = kBackgroundImageButtonStartTag+i;
            if (IS_IPAD) {
                UIImage *image = [ImageUtil loadResourceImage:[NSString stringWithFormat:@"bg%d@2x.png",(i+1)]];
                if (image == nil) {
                    image = [ImageUtil loadResourceImage:[NSString stringWithFormat:@"bg%d.png",(i+1)]];
                }
                
                [_button setImage:image forState:UIControlStateNormal];
            } else {
                [_button setImage:[ImageUtil loadResourceImage:[NSString stringWithFormat:@"bg%d.png",(i+1)]] forState:UIControlStateNormal];
            }
            
            [_button addTarget:self action:@selector(changeBackgroundImage:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:_button];
        }
        _scrollView.contentSize = CGSizeMake(frame.size.width, (_indexLine+2)*_buttonGap+(_indexLine+1)*h);
    }
    return self;
}

- (void)changeBackgroundImage:(id)sender
{
    UIButton *_selectedButton = (UIButton*)sender;
    if (nil != _selectedButton)
    {
        NSUInteger _selectedImageIndex = _selectedButton.tag - kBackgroundImageButtonStartTag+1;
        
        NSDictionary *_postInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInteger:_selectedImageIndex],@"imageIndex",
                                      [NSNumber numberWithInteger:[ZBCommonMethod getCurrentCollageType]],@"CollageType",
                                      nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kChangeBackGroundImage object:_postInfoDic];
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
