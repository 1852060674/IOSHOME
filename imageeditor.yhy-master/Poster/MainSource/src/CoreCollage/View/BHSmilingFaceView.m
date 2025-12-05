//
//  BHSmilingFaceView.m
//  PicFrame
//
//  Created by shen Lv on 13-6-6.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHSmilingFaceView.h"
#import "ImageUtil.h"
#import "BHImageDataModeld.h"
#import "SmilingFace.h"
#import "ZBButtonWithImageName.h"
#import "ZBColorDefine.h"

#define kSmilingButtonEdge        44
#define kSmilingButtonGap         6

#define kButtonWidth           60
#define kButtonGap             (kScreenWidth-4*kButtonWidth)/5

@interface BHSmilingFaceView()<UIScrollViewDelegate>
{
    //    UIView *_aspectView;
    UIScrollView *_scrollView;
    NSInteger  offset;
    NSInteger _smilingFaceButtonEdge;
    NSUInteger _smilingFaceButtonGap;
    NSInteger _originY;
    float _scrollViewHeight;
    BHImageDataModeld *_dataModeld;
    float _segmentItemWidth;
    float _segmentWidth;
}

@end

@implementation BHSmilingFaceView

@synthesize delegate = _delegate;
@synthesize promptFrame = _promptFrame;

- (void)dealloc
{
    for (UIView *_aView in [_scrollView subviews]) {
        [_aView removeFromSuperview];
    }
    _scrollView.delegate = nil;
//    [_scrollView release];
//     [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _dataModeld = [[BHImageDataModeld alloc] init];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            _scrollViewHeight = 86;
            _smilingFaceButtonEdge = 44;
            _smilingFaceButtonGap = 6;
            _originY = 5;
            _segmentItemWidth = 75;
            _segmentWidth = kBottomBarWidth;
        }
        else
        {
            _scrollViewHeight = 110;
            _smilingFaceButtonEdge = 70;
            _smilingFaceButtonGap = 10;
            _originY = 7;
            _segmentItemWidth = 100;
            _segmentWidth = 400;
        }
        
        _promptFrame = [[BHPromptFrameView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.frame.size.height)];
        _promptFrame.arrowDirection = 2;
        _promptFrame.arrowPosition = 0;
        _promptFrame.arrowPoint = CGPointMake((kScreenWidth-_segmentWidth)/2+1.3*_segmentItemWidth, frame.size.height);
        _promptFrame.cornerRadius = 3;
        _promptFrame.tag = 1001;
        _promptFrame.baseColor = kPromptFrameViewBaseColor;
        
        [self addSubview:_promptFrame];
                
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _scrollViewHeight)];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        [self loadSmilingFaceIcon];
    }
    return self;
}

- (void)adjustArrowPoint:(CGFloat)x
{
    BHPromptFrameView *_promptView = (BHPromptFrameView*)[self viewWithTag:1001];
    if (nil != _promptView) {
        _promptFrame.arrowPoint = CGPointMake((kScreenWidth-_segmentWidth)/2+1.5*_segmentItemWidth, self.frame.size.height);
    }
}
- (void)loadSmilingFaceIcon
{
    offset = 0;
    NSArray *_faceArray = [_dataModeld querySmilingFaceFromDB];
    if (nil == _faceArray || _faceArray.count==0)
    {
        // new
        for (NSInteger i=0; i<66; i++)
        {
            ZBButtonWithImageName *_stickerButton = [ZBButtonWithImageName buttonWithType:UIButtonTypeCustom];
            //        _aspectButton.frame = CGRectMake(kSmilingButtonEdge*offset, 15, kSmilingButtonEdge, kSmilingButtonEdge);
            _stickerButton.frame = CGRectMake((_smilingFaceButtonEdge+_smilingFaceButtonGap)*offset, _originY, _smilingFaceButtonEdge, _smilingFaceButtonEdge);
            
            [_stickerButton addTarget:self action:@selector(changeSmilingFaceType:) forControlEvents:UIControlEventTouchUpInside];
            _stickerButton.tag = kSmilingButtonStartTag+offset;
            NSString *_imageName = [NSString stringWithFormat:@"sticker_%d@2x",(int)(i)];
            _stickerButton.imageName = _imageName;
            [_stickerButton setImage:[ImageUtil loadResourceImage:_imageName] forState:UIControlStateNormal];
            [_scrollView addSubview:_stickerButton];
            offset++;
        }
        
//        //yellow
//        for (NSInteger i=0; i<48; i++)
//        {
//            ZBButtonWithImageName *_stickerButton = [ZBButtonWithImageName buttonWithType:UIButtonTypeCustom];
//            _stickerButton.backgroundColor = [UIColor clearColor];
//            _stickerButton.frame = CGRectMake((_smilingFaceButtonEdge+_smilingFaceButtonGap)*offset, _originY, _smilingFaceButtonEdge, _smilingFaceButtonEdge);
//            [_stickerButton addTarget:self action:@selector(changeSmilingFaceType:) forControlEvents:UIControlEventTouchUpInside];
//            _stickerButton.tag = kSmilingButtonStartTag+offset;
//            NSString *_imageName;
//            if (i<9) {
//                _imageName = [NSString stringWithFormat:@"stk00%d",(i+1)];
//            }
//            else
//                _imageName = [NSString stringWithFormat:@"stk0%d",(i+1)];
//            _stickerButton.imageName = _imageName;
//            [_stickerButton setImage:[ImageUtil loadResourceImage:_imageName] forState:UIControlStateNormal];
//            [_scrollView addSubview:_stickerButton];
//            offset++;
//        }
//        
//        //love
//        for (NSInteger i=0; i<24; i++)
//        {
//            ZBButtonWithImageName *_stickerButton = [ZBButtonWithImageName buttonWithType:UIButtonTypeCustom];
//            //        _aspectButton.frame = CGRectMake(kSmilingButtonEdge*offset, 15, kSmilingButtonEdge, kSmilingButtonEdge);
//            _stickerButton.frame = CGRectMake((_smilingFaceButtonEdge+_smilingFaceButtonGap)*offset, _originY, _smilingFaceButtonEdge, _smilingFaceButtonEdge);
//            
//            [_stickerButton addTarget:self action:@selector(changeSmilingFaceType:) forControlEvents:UIControlEventTouchUpInside];
//            _stickerButton.tag = kSmilingButtonStartTag+offset;
//            NSString *_imageName = [NSString stringWithFormat:@"icons-6-%d",(i+1)];
//            _stickerButton.imageName = _imageName;
//            [_stickerButton setImage:[ImageUtil loadResourceImage:_imageName] forState:UIControlStateNormal];
//            [_scrollView addSubview:_stickerButton];
//            offset++;
//        }
    }
    else
    {
        for (NSUInteger i=0; i<_faceArray.count; i++)
        {
            SmilingFace *_entry = [_faceArray objectAtIndex:i];
            ZBButtonWithImageName *_stickerButton = [ZBButtonWithImageName buttonWithType:UIButtonTypeCustom];
            _stickerButton.backgroundColor = [UIColor clearColor];
            _stickerButton.frame = CGRectMake((_smilingFaceButtonEdge+_smilingFaceButtonGap)*offset, _originY, _smilingFaceButtonEdge, _smilingFaceButtonEdge);
            [_stickerButton addTarget:self action:@selector(changeSmilingFaceType:) forControlEvents:UIControlEventTouchUpInside];
            _stickerButton.tag = kSmilingButtonStartTag+offset;
            NSString *_imageName = _entry.imageName;
            _stickerButton.imageName = _imageName;
            [_stickerButton setImage:[ImageUtil loadResourceImage:_imageName] forState:UIControlStateNormal];
            [_scrollView addSubview:_stickerButton];
            offset++;

        }
    }
     _scrollView.contentSize = CGSizeMake(offset*(_smilingFaceButtonEdge+_smilingFaceButtonGap),  _scrollViewHeight);
}

- (void)changeSmilingFaceType:(id)sender
{
    ZBButtonWithImageName *_selectedButton = (ZBButtonWithImageName*)sender;
    NSString* indexstr = [[_selectedButton.imageName stringByReplacingOccurrencesOfString:@"sticker_" withString:@""] stringByReplacingOccurrencesOfString:@"@2x.png" withString:@""];
    
    if(self.delegate
       && [self.delegate respondsToSelector:@selector(canAddSmilingFace:)]
       && ![self.delegate canAddSmilingFace:[indexstr intValue]]) {
        return;
    }
    
    
//    AspectType _selectedType = _selectedButton.tag - kSmilingButtonStartTag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedSmilingFaceType:atIndex:)]) {
        [self.delegate selectedSmilingFaceType:_selectedButton.imageView.image atIndex:_selectedButton.tag-kSmilingButtonStartTag];
        
        //可在这里保存face icon的使用次数
        [_dataModeld updateSmilingFaceInfoForImageName:_selectedButton.imageName];
    }
    [self adjustArrowPoint:0];
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
