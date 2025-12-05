//
//  ZBBackgroundImageView.m
//  Collage
//
//  Created by shen on 13-6-26.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBBackgroundImageView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"

#import "ZBButtonWithImageName.h"
#import "BHImageDataModeld.h"
#import "BackgroundImage.h"
#import "ZBColorDefine.h"

#define kPhotoFrameButtonEdge        44
#define kPhotoFrameButtonGap         6
#define kCountOfPhotoFrame     43


#define kButtonWidth           60
#define kButtonGap             (kScreenWidth-4*kButtonWidth)/5

@interface ZBBackgroundImageView()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    NSInteger _bgImageButtonEdge;
    NSInteger _bgImageButtonGap;
    NSInteger _originY;
    float _scrollViewHeight;
    BHImageDataModeld *_dataModeld;
    float _segmentItemWidth;
    float _segmentWidth;
}

@end

@implementation ZBBackgroundImageView
@synthesize promptFrame = _promptFrame;

@synthesize delegate;

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
        
        _dataModeld = [[BHImageDataModeld alloc] init];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            _scrollViewHeight = 80;
            _bgImageButtonEdge = 44;
            _bgImageButtonGap = 6;
            _originY = 8;
            _segmentItemWidth = 75;
            _segmentWidth = 225;
        }
        else
        {
            _scrollViewHeight = 110;
            _bgImageButtonEdge = 70;
            _bgImageButtonGap  = 10;
            _originY = 10;
            _segmentItemWidth = 100;
            _segmentWidth = 300;
        }
        
        _promptFrame = [[BHPromptFrameView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.frame.size.height)];
        _promptFrame.arrowDirection = 2;
        _promptFrame.arrowPosition = 0;
        _promptFrame.arrowPoint = CGPointMake((kScreenWidth-_segmentWidth)/2+1.5*_segmentItemWidth, frame.size.height);
        _promptFrame.cornerRadius = 3;
        _promptFrame.baseColor = kPromptFrameViewBaseColor;
        
        [self addSubview:_promptFrame];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _scrollViewHeight)];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = kTransparentColor;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        [self loadBackgroundImages];
    }
    return self;
}

#pragma mark -- custom method
- (void)loadBackgroundImages
{
    NSArray *_photoFrameArray = [_dataModeld queryBackgroundFromDB];
    NSInteger _offset = 0;
    if (nil == _photoFrameArray || _photoFrameArray.count==0)
    {
        for (NSInteger i=0; i<kCountOfBackgroundImage; i++)
        {
            ZBButtonWithImageName *_bgImageButton = [ZBButtonWithImageName buttonWithType:UIButtonTypeCustom];
            _bgImageButton.frame = CGRectMake((_bgImageButtonEdge + _bgImageButtonGap)*_offset+_bgImageButtonGap, _originY, _bgImageButtonEdge, _bgImageButtonEdge);
            
            [_bgImageButton addTarget:self action:@selector(changeBGImageType:) forControlEvents:UIControlEventTouchUpInside];
            _bgImageButton.tag = kBackgroundImageViewStartTag+_offset;
            
            NSString *_imageName = _imageName = [NSString stringWithFormat:@"free_back_%d",(i+1)];
            
            CGRect rect;
            rect.origin = CGPointZero;
            rect.size.width = _bgImageButtonEdge;
            rect.size.height = _bgImageButtonEdge;
            
//            UIImage *_smallImage = [self scaleFromImage:[ImageUtil loadResourceImage:[NSString stringWithFormat:@"free_back_thumbnail_%d",(i+1)]] toSize:rect.size];

            UIImage *_smallImage = [ImageUtil loadResourceImage:[NSString stringWithFormat:@"free_back_thumbnail_%d",(i+1)]];
            
            _bgImageButton.imageName = _imageName;
            [_bgImageButton setImage:_smallImage forState:UIControlStateNormal];
            [_scrollView addSubview:_bgImageButton];
            _offset++;
        }
    }
    else
    {
        for (NSInteger i=0; i<_photoFrameArray.count; i++)
        {
            
            BackgroundImage *_entry = [_photoFrameArray objectAtIndex:i];

            ZBButtonWithImageName *_bgImageButton = [ZBButtonWithImageName buttonWithType:UIButtonTypeCustom];
            _bgImageButton.frame = CGRectMake((_bgImageButtonEdge + _bgImageButtonGap)*_offset+_bgImageButtonGap, _originY, _bgImageButtonEdge, _bgImageButtonEdge);
            
            
            [_bgImageButton addTarget:self action:@selector(changeBGImageType:) forControlEvents:UIControlEventTouchUpInside];
            _bgImageButton.tag = kBackgroundImageViewStartTag+_offset;
            
            NSString *_imageName = _entry.imageName;
            
            CGRect rect;
            rect.origin = CGPointZero;
            rect.size.width = _bgImageButtonEdge;
            rect.size.height = _bgImageButtonEdge;
            
            UIImage *_smallImage = [self scaleFromImage:[ImageUtil loadResourceImage:_imageName] toSize:rect.size];
            _bgImageButton.imageName = _imageName;
            [_bgImageButton setImage:_smallImage forState:UIControlStateNormal];
            [_scrollView addSubview:_bgImageButton];
            _offset++;
        }
    }
    _scrollView.contentSize = CGSizeMake(_offset*(_bgImageButtonEdge + _bgImageButtonGap)+_bgImageButtonGap,  _scrollViewHeight);
}

- (void)changeBGImageType:(id)sender
{
    ZBButtonWithImageName *_selectedButton = (ZBButtonWithImageName*)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedABackgroundImage:atIndex:)]) {
        [self.delegate selectedABackgroundImage:_selectedButton.imageName atIndex:_selectedButton.tag-kBackgroundImageViewStartTag];
        [_dataModeld updateBackgroundInfoForImageName:_selectedButton.imageName];
    }
}

- (UIImage *) scaleFromImage: (UIImage *) image toSize: (CGSize) size
{
//    UIGraphicsBeginImageContext(size);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
