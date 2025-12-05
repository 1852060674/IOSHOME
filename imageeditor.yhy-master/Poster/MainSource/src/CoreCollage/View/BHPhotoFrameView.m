//
//  BHPhotoFrameView.m
//  PicFrame
//
//  Created by shen Lv on 13-6-3.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHPhotoFrameView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBButtonWithImageName.h"
#import "BHImageDataModeld.h"
#import "PhotoFrame.h"
#import "ZBColorDefine.h"


#define kPhotoFrameButtonEdge        44
#define kPhotoFrameButtonGap         6
#define kCountOfPhotoFrame     43

#define kButtonWidth           60
#define kButtonGap             (kScreenWidth-4*kButtonWidth)/5

@interface BHPhotoFrameView()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    NSInteger _photoFrameButtonEdge;
    NSInteger _photoFrameButtonGap;
    NSInteger _originY;
    float _scrollViewHeight;
    BHImageDataModeld *_dataModeld;
    float _segmentItemWidth;
    float _segmentWidth;
}

@end

@implementation BHPhotoFrameView

@synthesize delegate;
@synthesize promptFrameView = _promptFrameView;

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
//            _aspectBackgroundImage = [ImageUtil loadResourceImage:@"aspect_toolbar_back-iphone"];
            _scrollViewHeight = 80;
            _photoFrameButtonEdge = 44;
            _photoFrameButtonGap = 6;
            _originY = 8;
            _segmentItemWidth = 60;
            _segmentWidth = kBottomBarWidth;
        }
        else
        {
//            _aspectBackgroundImage = [ImageUtil loadResourceImage:@"aspect_toolbar_back_v-ipad"];
            _scrollViewHeight = 110;
            _photoFrameButtonEdge = 70;
            _photoFrameButtonGap  = 10;
            _originY = 10;
            _segmentItemWidth = 100;
            _segmentWidth = 600;
        }
//        self.backgroundColor = [UIColor colorWithPatternImage:_aspectBackgroundImage];
        
        _promptFrameView = [[BHPromptFrameView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.frame.size.height)];
        _promptFrameView.arrowDirection = 2;
        _promptFrameView.arrowPosition = 0;
        _promptFrameView.arrowPoint = CGPointMake((kScreenWidth-_segmentWidth)/2+3.5*_segmentItemWidth, frame.size.height);
        _promptFrameView.cornerRadius = 3;
        _promptFrameView.baseColor = kPromptFrameViewBaseColor;
        
        [self addSubview:_promptFrameView];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _scrollViewHeight)];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        [self loadPhotoFrames];
    }
    return self;
}

#pragma mark -- custom method
- (void)loadPhotoFrames
{
    NSArray *_photoFrameArray = [_dataModeld queryFrameFromDB];
    NSInteger _offset = 0;
    if (nil == _photoFrameArray || _photoFrameArray.count==0)
    {
        //animal
        for (NSInteger i=0; i<kCountOfPhotoFrame; i++)
        {
            ZBButtonWithImageName *_photoFrameButton = [ZBButtonWithImageName buttonWithType:UIButtonTypeCustom];
            _photoFrameButton.frame = CGRectMake((_photoFrameButtonEdge + _photoFrameButtonGap)*_offset, _originY, _photoFrameButtonEdge, _photoFrameButtonEdge);
            
            
            [_photoFrameButton addTarget:self action:@selector(changePhotoFrameType:) forControlEvents:UIControlEventTouchUpInside];
            _photoFrameButton.tag = kPhotoFrameButtonStartTag+_offset;
            
            NSString *_imageName = _imageName = [NSString stringWithFormat:@"fme%d",(i+1)];
                        
            CGRect rect;
            rect.origin = CGPointZero;
            rect.size.width = _photoFrameButtonEdge;
            rect.size.height = _photoFrameButtonEdge;
            
            UIImage *_smallImage = [self scaleFromImage:[ImageUtil loadResourceImage:_imageName] toSize:rect.size];
            _photoFrameButton.imageName = _imageName;
            [_photoFrameButton setImage:_smallImage forState:UIControlStateNormal];
            [_scrollView addSubview:_photoFrameButton];
            _offset++;
        }
    }
    else
    {
        //第一张图片为取消画框
        ZBButtonWithImageName *_photoFrameButton = [ZBButtonWithImageName buttonWithType:UIButtonTypeCustom];
        _photoFrameButton.frame = CGRectMake(0, _originY, _photoFrameButtonEdge, _photoFrameButtonEdge);
        
        
        [_photoFrameButton addTarget:self action:@selector(changePhotoFrameType:) forControlEvents:UIControlEventTouchUpInside];
        _photoFrameButton.tag = kPhotoFrameButtonStartTag+_offset;
        
        NSString *_imageName = @"fme1";
        
        CGRect rect;
        rect.origin = CGPointZero;
        rect.size.width = _photoFrameButtonEdge;
        rect.size.height = _photoFrameButtonEdge;
        
        UIImage *_smallImage = [self scaleFromImage:[ImageUtil loadResourceImage:_imageName] toSize:rect.size];
        _photoFrameButton.imageName = _imageName;
        [_photoFrameButton setImage:_smallImage forState:UIControlStateNormal];
        [_scrollView addSubview:_photoFrameButton];
        _offset++;
        
        for (NSInteger i=0; i<_photoFrameArray.count; i++)
        {
            
            PhotoFrame *_entry = [_photoFrameArray objectAtIndex:i];
            if ([_entry.frameName isEqualToString:@"fme1"]) {
                continue;
            }
            ZBButtonWithImageName *_photoFrameButton = [ZBButtonWithImageName buttonWithType:UIButtonTypeCustom];
            _photoFrameButton.frame = CGRectMake((_photoFrameButtonEdge + _photoFrameButtonGap)*_offset, _originY, _photoFrameButtonEdge, _photoFrameButtonEdge);
            
            
            [_photoFrameButton addTarget:self action:@selector(changePhotoFrameType:) forControlEvents:UIControlEventTouchUpInside];
            _photoFrameButton.tag = kPhotoFrameButtonStartTag+_offset;
            
            NSString *_imageName = _entry.frameName;
                        
            CGRect rect;
            rect.origin = CGPointZero;
            rect.size.width = _photoFrameButtonEdge;
            rect.size.height = _photoFrameButtonEdge;
            
            UIImage *_smallImage = [self scaleFromImage:[ImageUtil loadResourceImage:_imageName] toSize:rect.size];
            _photoFrameButton.imageName = _imageName;
            [_photoFrameButton setImage:_smallImage forState:UIControlStateNormal];
            [_scrollView addSubview:_photoFrameButton];
            _offset++;
        }
    }
    _scrollView.contentSize = CGSizeMake(_offset*(_photoFrameButtonEdge + _photoFrameButtonGap),  _scrollViewHeight);
}

- (void)changePhotoFrameType:(id)sender
{
    ZBButtonWithImageName *_selectedButton = (ZBButtonWithImageName*)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedAPhotoFrame:)]) {
        [self.delegate selectedAPhotoFrame:_selectedButton.imageName];
        [_dataModeld updateFrameInfoForImageName:_selectedButton.imageName];
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
