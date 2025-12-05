//
//  ZBTemplate2_1_View.m
//  Collage
//
//  Created by shen on 13-7-5.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBTemplate2_1_View.h"
#import "ZBIrregularCollageScrollView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBTemplate2_1_View()<UIScrollViewDelegate>
{
    float _currentWidth;
    float _currentHeight;
    
    float _minusHeight;
    float _minusWidth;
    
    float _gap;
    BOOL _isFirstLoad;
    BOOL _isReplace;
    
    UIImage *_upImage;
    UIImage *_downImage;
}

@property (nonatomic,strong)NSMutableArray *imagesArray;
@property (nonatomic,strong)NSMutableArray *upPointArray;
@property (nonatomic,strong)NSMutableArray *donwPointArray;

@end

@implementation ZBTemplate2_1_View

@synthesize imagesArray;
@synthesize upPointArray;
@synthesize donwPointArray;

- (id)initWithFrame:(CGRect)frame withImagesArray:(NSArray*)images
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kIrregularCollageColor;
        _isFirstLoad = YES;
        _isReplace = YES;
        self.imagesArray = [[NSMutableArray alloc] initWithArray:images];
        self.upPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.donwPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        
        /**** 角度计算 *****/
        _gap = kIrregularTemplateGap;
        
        [self calculatedParameters];
        
        [self loadImages];
        [self createScrollView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (!_isFirstLoad) {
        [self calculatedParameters];
        [self loadImages];
        [self loadScrollViews];
    }
    else
        _isFirstLoad = NO;
}

- (void)calculatedParameters
{
    /**** 角度计算 *****/
    _currentWidth = self.frame.size.width-2*_gap;
    _currentHeight = self.frame.size.height-2*_gap;
    
    float l = sqrt(_currentWidth*_currentWidth*0.25+_currentHeight*_currentHeight);
    _minusHeight = _gap*l/(_currentWidth*0.5);
    _minusWidth = _gap*l/_currentHeight;
}

- (void)loadImages
{
    if (self.imagesArray.count<2) {
        return;
    }
    _upImage = [self.imagesArray objectAtIndex:0];
    _downImage = [self.imagesArray objectAtIndex:1];
    
    _upImage = [ImageUtil getScaleImage:_upImage withWidth:_currentWidth andHeight:_currentHeight*0.6-0.5*_gap];
    _downImage = [ImageUtil getScaleImage:_downImage withWidth:_currentWidth andHeight:_currentHeight*0.6-0.5*_gap];
}

- (void)createScrollView
{
    if (self.imagesArray.count == 2) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, _currentWidth, _currentHeight*0.6-0.5*_gap)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag;
        _scrollView.originImage = [self.imagesArray objectAtIndex:0];
        
        CGPoint p = CGPointMake(0, _upImage.size.height);;
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _upImage.size.height-_scrollView.frame.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _upImage.size.height-_currentHeight*0.4+0.5*_gap);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _upImage.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.frame = CGRectMake(0, 0, _upImage.size.width, _upImage.size.height);
        _scrollView.contentSize = CGSizeMake(_upImage.size.width, _upImage.size.height);
        
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        
        /********* the second image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_currentHeight*0.4+0.5*_gap, _currentWidth, _currentHeight*0.6-0.5*_gap)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+1;
        _scrollView.originImage = [self.imagesArray objectAtIndex:1];
        
        p = CGPointMake(0, _downImage.size.height-_currentHeight*0.2);;
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _downImage.size.height-_scrollView.frame.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth, _downImage.size.height-_scrollView.frame.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth, _downImage.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];

        _scrollView.imageView.image = [ImageUtil getSpecialImage:_downImage withPoints:self.donwPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _downImage.size.width, _downImage.size.height);
        _scrollView.contentSize = CGSizeMake(_downImage.size.width, _downImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

#pragma mark -- change frame
- (void)loadScrollViews
{
    for (NSUInteger i=0; i<2; i++) {
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+i];
        _scrollView.delegate = nil;
    }
    [self.upPointArray removeAllObjects];
    [self.donwPointArray removeAllObjects];
    
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset;
    if (self.imagesArray.count == 2) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag];
        _scrollView.frame = CGRectMake(_gap, _gap, _currentWidth, _currentHeight*0.6-0.5*_gap);
        _scrollView.delegate = self;
        
        CGPoint p = CGPointMake(0, _upImage.size.height);;
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _upImage.size.height-_scrollView.frame.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _upImage.size.height-_currentHeight*0.4+0.5*_gap);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _upImage.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];

        _currentOffset = _scrollView.contentOffset;
        
        for (NSUInteger i=0; i<self.upPointArray.count; i++) {
            NSValue *_value = [self.upPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_upImage withPoints:_pointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _upImage.size.width, _upImage.size.height);
        _scrollView.contentSize = CGSizeMake(_upImage.size.width, _upImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the second image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+1];
        _scrollView.frame = CGRectMake(_gap, _gap+_currentHeight*0.4+0.5*_gap, _currentWidth, _currentHeight*0.6-0.5*_gap);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _downImage.size.height-_currentHeight*0.2);;
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _downImage.size.height-_scrollView.frame.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth, _downImage.size.height-_scrollView.frame.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth, _downImage.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        [_pointArray removeAllObjects];
        for (NSUInteger i=0; i<self.donwPointArray.count; i++) {
            NSValue *_value = [self.donwPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_downImage withPoints:_pointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _downImage.size.width, _downImage.size.height);
        _scrollView.contentSize = CGSizeMake(_downImage.size.width, _downImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

#pragma mark -- reselect image, or edit image

- (void)setSelectedImage:(UIImage*)image
{
    if (image == nil) {
        _isReplace = YES;
        return;
    }
    ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag];
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset;
    CGPoint p;
    NSLog(@"%f,%f",image.size.width,image.size.height);
    UIImage *_image = [self.imagesArray objectAtIndex:0];
    NSLog(@"_image : %f,%f",_image.size.width,_image.size.height);
    if (_scrollView.isSelected) {
        if (_isReplace) {
            [self.imagesArray replaceObjectAtIndex:0 withObject:image];
            _upImage = [ImageUtil getScaleImage:image withWidth:_currentWidth andHeight:_currentHeight*0.6-_gap*0.5];
        }
        else
        {
            
            if (image.size.width<_scrollView.frame.size.width || image.size.height<_scrollView.frame.size.height) {
                _upImage = [ImageUtil getScaleImage:image withWidth:_currentWidth andHeight:_currentHeight*0.6-_gap*0.5];
            }
            else
                _upImage = image;
        }
        _scrollView.originImage = image;
        
        [self.upPointArray removeAllObjects];
        
        CGPoint p = CGPointMake(0, _upImage.size.height);;
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _upImage.size.height-_scrollView.frame.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _upImage.size.height-_currentHeight*0.4+0.5*_gap);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _upImage.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        
        for (NSUInteger i=0; i<self.upPointArray.count; i++) {
            NSValue *_value = [self.upPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_upImage withPoints:_pointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _upImage.size.width, _upImage.size.height);
        _scrollView.contentSize = CGSizeMake(_upImage.size.width, _upImage.size.height);
        
        _scrollView.isSelected = NO;
        self.selectedIndex = 0;
    }
    else
    {
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+1];
        if (_scrollView.isSelected) {
            if (_isReplace) {
                [self.imagesArray replaceObjectAtIndex:1 withObject:image];
                _downImage = [ImageUtil getScaleImage:image withWidth:_currentWidth andHeight:_currentHeight*0.6-_gap*0.5];
            }
            else
            {
                
                if (image.size.width<_scrollView.frame.size.width || image.size.height<_scrollView.frame.size.height) {
                    _downImage = [ImageUtil getScaleImage:image withWidth:_currentWidth andHeight:_currentHeight*0.6-_gap*0.5];
                }
                else
                    _downImage = image;
            }
            _scrollView.originImage = image;
            
            [self.donwPointArray removeAllObjects];
            
            p = CGPointMake(0, _downImage.size.height-_currentHeight*0.2);;
            [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _downImage.size.height-_scrollView.frame.size.height);
            [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_currentWidth, _downImage.size.height-_scrollView.frame.size.height);
            [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_currentWidth, _downImage.size.height);
            [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _currentOffset = _scrollView.contentOffset;
            [_pointArray removeAllObjects];
            for (NSUInteger i=0; i<self.donwPointArray.count; i++) {
                NSValue *_value = [self.donwPointArray objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            
            _scrollView.imageView.image = [ImageUtil getSpecialImage:_downImage withPoints:_pointArray];
            _scrollView.imageView.frame = CGRectMake(0, 0, _downImage.size.width, _downImage.size.height);
            _scrollView.contentSize = CGSizeMake(_downImage.size.width, _downImage.size.height);
            
            _scrollView.isSelected = NO;
            self.selectedIndex = 1;
        }
        
    }
    _isReplace = YES;
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}


#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset = scrollView.contentOffset;
    if (scrollView.tag == kIrregularScrollViewStartTag) {
            
        for (NSUInteger i=0; i<self.upPointArray.count; i++) {
            NSValue *_value = [self.upPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_upImage withPoints:_pointArray];
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+1)
    {
        for (NSUInteger i=0; i<self.donwPointArray.count; i++) {
            NSValue *_value = [self.donwPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_downImage withPoints:_pointArray];
    }
}

//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//     NSLog(@"viewForZoomingInScrollView");
//    for (UIView *aView in scrollView.subviews) {
//        if ([aView isKindOfClass:[UIImageView class]]) {
//            return aView;
//        }
//    }
//    return nil;
//}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    //缩放操作中被调用
//    NSLog(@"scrollViewDidZoom");
}


//用户进行缩放时会得到通知，缩放比例表示为一个浮点数，作为参数传递
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
//    NSLog(@"scale %f",scale);
//    _upImage = [ImageUtil scaleImage:_upImage toScale:scale];
//    [scrollView setZoomScale:scale animated:NO];
//    CGPoint _currentOffset = scrollView.contentOffset;
//    if (scrollView.tag == kIrregularScrollViewStartTag) {
//        [_pointArray removeAllObjects];
//        
//        CGPoint p = CGPointMake(_currentOffset.x, _upImage.size.height-_currentOffset.y);;
//        [_pointArray addObject:[NSValue valueWithCGPoint:p]];
//        p = CGPointMake(+_currentOffset.x, _upImage.size.height-_currentHeight*0.6-_currentOffset.y);
//        [_pointArray addObject:[NSValue valueWithCGPoint:p]];
//        p = CGPointMake(_currentWidth+_currentOffset.x, _upImage.size.height-_currentHeight*0.4-_currentOffset.y);
//        [_pointArray addObject:[NSValue valueWithCGPoint:p]];
//        p = CGPointMake(_currentWidth+_currentOffset.x, _upImage.size.height-_currentOffset.y);
//        [_pointArray addObject:[NSValue valueWithCGPoint:p]];
//        
//        _upImageView.image = [ImageUtil getSpecialImage:_upImage withPoints:_pointArray andWidth:_currentWidth andHeight:_currentHeight];
//        
//    }
//    else if(scrollView.tag == kIrregularScrollViewStartTag+1)
//    {
//        [_pointArray removeAllObjects];
//        
//        [_pointArray removeAllObjects];
//        CGPoint p = CGPointMake(0+_currentOffset.x, _downImage.size.height-_currentOffset.y);;
//        [_pointArray addObject:[NSValue valueWithCGPoint:p]];
//        p = CGPointMake(0+_currentOffset.x, _downImage.size.height-(_currentHeight-_minusHeight)-_currentOffset.y);
//        [_pointArray addObject:[NSValue valueWithCGPoint:p]];
//        p = CGPointMake(_currentWidth*0.5-_minusWidth+_currentOffset.x, _downImage.size.height-(_currentHeight-_minusHeight)-_currentOffset.y);
//        [_pointArray addObject:[NSValue valueWithCGPoint:p]];
//        
//        _downImageView.image = [ImageUtil getSpecialImage:_downImage withPoints:_pointArray andWidth:_currentWidth*0.5-15 andHeight:_currentHeight*0.7-5];
//        
//    }

}



@end
