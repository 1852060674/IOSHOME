//
//  ZBTemplate3_1_View.m
//  Collage
//
//  Created by shen on 13-7-5.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBTemplate3_1_View.h"
#import "ZBIrregularCollageScrollView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBTemplate3_1_View()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    float _currentWidth;
    float _currentHeight;
    
    float _minusHeight;
    float _minusWidth;
    float _middleMinus;
    
    UIImage *_upImage;
    UIImage *_downImage;
    UIImage *_rightImage;
    
    BOOL _isFirstLoad;
    BOOL _isReplace;
    float _gap;
    CGPoint _beforeZoomingContentOffset;
}

@property (nonatomic,strong)NSMutableArray *imagesArray;
@property (nonatomic,strong)NSMutableArray *upPointArray;
@property (nonatomic,strong)NSMutableArray *donwPointArray;
@property (nonatomic,strong)NSMutableArray *rightPointArray;

@end

@implementation ZBTemplate3_1_View
@synthesize imagesArray = _imagesArray;
@synthesize upPointArray;
@synthesize donwPointArray;
@synthesize rightPointArray;

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
        self.rightPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        
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
    
    float l = sqrt(_currentWidth*_currentWidth*0.25+_currentHeight*_currentHeight*0.25);
    _minusHeight = _gap*(_currentWidth*0.5)/l;
    _minusWidth = _gap*_currentHeight*0.5/l;
    _middleMinus = _gap*0.5*sqrt(3)*0.5;
}

- (void)loadImages
{
    _upImage = [self.imagesArray objectAtIndex:0];
    _downImage = [self.imagesArray objectAtIndex:1];
    _rightImage = [self.imagesArray objectAtIndex:2];
    
    _upImage = [ImageUtil getScaleImage:_upImage withWidth:_currentWidth-_minusWidth andHeight:(_currentHeight-_gap)*0.5];
    _downImage = [ImageUtil getScaleImage:_downImage withWidth:_currentWidth-_minusWidth andHeight:(_currentHeight-_gap)*0.5];
    _rightImage = [ImageUtil getScaleImage:_rightImage withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight-2*_minusHeight];
}

- (void)createScrollView
{
    if (self.imagesArray.count == 3) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, _currentWidth-_minusWidth, (_currentHeight-_gap)*0.5)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag;
        _scrollView.originImage = [self.imagesArray objectAtIndex:0];
        
        _scrollView.imageView.frame = CGRectMake(0, 0, _upImage.size.width, _upImage.size.height);
        _scrollView.contentSize = CGSizeMake(_upImage.size.width, _upImage.size.height);
        
        CGPoint p = CGPointMake(0, _upImage.size.height);;
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _upImage.size.height-_scrollView.frame.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth*0.5-_middleMinus, _upImage.size.height-_scrollView.frame.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth-_minusWidth, _upImage.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_upImage withPoints:self.upPointArray];
        
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
//        // 放大缩小手势
//        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]
//                                                     
//                                                     initWithTarget:self action:@selector(handlePinch:)];
//        [pinchRecognizer setDelegate:self];
//        [_scrollView.imageView addGestureRecognizer:pinchRecognizer];
        
        /********* the second image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_currentHeight*0.5+0.5*_gap, _currentWidth-_minusWidth, (_currentHeight-_gap)*0.5)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+1;
        _scrollView.originImage = [self.imagesArray objectAtIndex:1];
        
        p = CGPointMake(0, _downImage.size.height);;
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _downImage.size.height-_scrollView.frame.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth-_minusWidth, _downImage.size.height-_scrollView.frame.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth*0.5-_middleMinus, _downImage.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_downImage withPoints:self.donwPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _downImage.size.width, _downImage.size.height);
        _scrollView.contentSize = CGSizeMake(_downImage.size.width, _downImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the third image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_currentWidth*0.5+0.5*_gap, _gap+_minusHeight, (_currentWidth-_gap)*0.5, _currentHeight-_minusHeight*2)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+2;
        _scrollView.originImage = [self.imagesArray objectAtIndex:2];
        
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height);;
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height-_scrollView.frame.size.height*0.5);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height-_scrollView.frame.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightImage withPoints:self.rightPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightImage.size.width, _rightImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightImage.size.width, _rightImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

#pragma mark -- change frame
- (void)loadScrollViews
{
    for (NSUInteger i=0; i<3; i++) {
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+i];
        _scrollView.delegate = nil;
    }
    [self.upPointArray removeAllObjects];
    [self.rightPointArray removeAllObjects];
    [self.donwPointArray removeAllObjects];
    
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset;
    if (self.imagesArray.count == 3) {
        /********* the firt image ***************/        
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag];
        _scrollView.frame = CGRectMake(_gap, _gap, _currentWidth-_minusWidth, (_currentHeight-_gap)*0.5);
        _scrollView.delegate = self;
        
        CGPoint p = CGPointMake(0, _upImage.size.height);;
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _upImage.size.height-_scrollView.frame.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth*0.5-_middleMinus, _upImage.size.height-_scrollView.frame.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth-_minusWidth, _upImage.size.height);
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
        _scrollView.frame = CGRectMake(_gap, _gap+_currentHeight*0.5+0.5*_gap, _currentWidth-_minusWidth, (_currentHeight-_gap)*0.5);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _downImage.size.height);;
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _downImage.size.height-_scrollView.frame.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth-_minusWidth, _downImage.size.height-_scrollView.frame.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth*0.5-_middleMinus, _downImage.size.height);
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
        
        /********* the third image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
        _scrollView.frame = CGRectMake(_gap+_currentWidth*0.5+0.5*_gap, _gap+_minusHeight, (_currentWidth-_gap)*0.5, _currentHeight-_minusHeight*2);
        _scrollView.delegate = self;
        
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height);;
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height-_scrollView.frame.size.height*0.5);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height-_scrollView.frame.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        [_pointArray removeAllObjects];
        for (NSUInteger i=0; i<self.rightPointArray.count; i++) {
            NSValue *_value = [self.rightPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightImage withPoints:_pointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightImage.size.width, _rightImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightImage.size.width, _rightImage.size.height);
        
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
            _upImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-_minusWidth andHeight:(_currentHeight-_gap)*0.5];
        }
        else
        {
            
            if (image.size.width<_scrollView.frame.size.width || image.size.height<_scrollView.frame.size.height) {
                _upImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-_minusWidth andHeight:(_currentHeight-_gap)*0.5];
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
        p = CGPointMake(_currentWidth*0.5-_middleMinus, _upImage.size.height-_scrollView.frame.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_currentWidth-_minusWidth, _upImage.size.height);
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
                _downImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-_minusWidth andHeight:(_currentHeight-_gap)*0.5];
            }
            else
            {
                
                if (image.size.width<_scrollView.frame.size.width || image.size.height<_scrollView.frame.size.height) {
                    _downImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-_minusWidth andHeight:(_currentHeight-_gap)*0.5];
                }
                else
                    _downImage = image;
            }
            _scrollView.originImage = image;
            
            [self.donwPointArray removeAllObjects];
            
            p = CGPointMake(0, _downImage.size.height);;
            [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _downImage.size.height-_scrollView.frame.size.height);
            [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_currentWidth-_minusWidth, _downImage.size.height-_scrollView.frame.size.height);
            [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_currentWidth*0.5-_middleMinus, _downImage.size.height);
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
        else
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
            if (_scrollView.isSelected) {
                if (_isReplace) {
                    [self.imagesArray replaceObjectAtIndex:2 withObject:image];
                    _rightImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight-2*_minusHeight];
                }
                else
                {
                    
                    if (image.size.width<_scrollView.frame.size.width || image.size.height<_scrollView.frame.size.height) {
                        _rightImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight-2*_minusHeight];
                    }
                    else
                        _rightImage = image;
                }
                _scrollView.originImage = image;
                
                [self.rightPointArray removeAllObjects];
                
                p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height);;
                [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
                p = CGPointMake(0, _rightImage.size.height-_scrollView.frame.size.height*0.5);
                [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
                p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height-_scrollView.frame.size.height);
                [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
                
                _currentOffset = _scrollView.contentOffset;
                [_pointArray removeAllObjects];
                for (NSUInteger i=0; i<self.rightPointArray.count; i++) {
                    NSValue *_value = [self.rightPointArray objectAtIndex:i];
                    CGPoint _point = [_value CGPointValue];
                    _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                    [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
                }
                
                _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightImage withPoints:_pointArray];
                _scrollView.imageView.frame = CGRectMake(0, 0, _rightImage.size.width, _rightImage.size.height);
                _scrollView.contentSize = CGSizeMake(_rightImage.size.width, _rightImage.size.height);

                
                _scrollView.isSelected = NO;
                self.selectedIndex = 2;
            }
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
    else if(scrollView.tag == kIrregularScrollViewStartTag+2)
    {
        for (NSUInteger i=0; i<self.rightPointArray.count; i++) {
            NSValue *_value = [self.rightPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_rightImage withPoints:_pointArray];
    }
}

//拖动之前收到通知，可读取contentOffset
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}

//用户抬起手指时得到通知，还会得到一个布尔值指明在报告滚动视图最后位置之前，手否需要进行减速
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
}

//当用户抬起手指为滚动视图需要继续滚动时收到通知，可读取contentOffset属性，可判断用户抬起手指前最后一次滚动到的位置，但不是最终位置
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
}

//当前一个提到的减速完毕、滚动视图停止移动时会得到通知，收到这个通知的时刻，滚动视图contentOffset属性会反映出滚动条最终停止位置
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}


//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return  ((ZBIrregularCollageScrollView*)scrollView).imageView;
//}
//
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView
//{
//    scrollView.contentOffset = CGPointZero;
//}
//
//- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
//{
////    _beforeZoomingContentOffset = scrollView.contentOffset;
//}
//
//
////用户进行缩放时会得到通知，缩放比例表示为一个浮点数，作为参数传递
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
////    NSLog(@"scale %f",scale);
//    [scrollView setZoomScale:scale animated:YES];
//
//    //缩放操作中被调用
//    _isReplace = NO;
//    if (scrollView.tag == kIrregularScrollViewStartTag) {
//        
//        _upImage = [ImageUtil scaleImage:[self.imagesArray objectAtIndex:0] toScale:scale];
//        ((ZBIrregularCollageScrollView*)scrollView).isSelected = YES;
//        [self setSelectedImage:_upImage];
//        
//    }
//    else if(scrollView.tag == kIrregularScrollViewStartTag+1)
//    {
//        
//        _downImage = [ImageUtil scaleImage:[self.imagesArray objectAtIndex:1] toScale:scale];
//        ((ZBIrregularCollageScrollView*)scrollView).isSelected = YES;
//        [self setSelectedImage:_downImage];
//        
//    }
//    else if(scrollView.tag == kIrregularScrollViewStartTag+2)
//    {
//        _rightImage = [ImageUtil scaleImage:[self.imagesArray objectAtIndex:2] toScale:scale];
//        ((ZBIrregularCollageScrollView*)scrollView).isSelected = YES;
//        [self setSelectedImage:_rightImage];
//    }
//
//}

//#pragma mark -- touches
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    CGPoint _touchPoint = [[touches anyObject] locationInView:self];
//    NSLog(@"touchesBegan %f,%f",_touchPoint.x,_touchPoint.y);
//}

//- (void) handlePinch:(UIPinchGestureRecognizer*) recognizer
//{
//    NSLog(@"recognizer.scale %f",recognizer.scale);
//    if (recognizer.scale>2 || recognizer.scale<=1) {
//        return;
//    }
////    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
//    
//    _isReplace = NO;
//    ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag];
//    
//    [_scrollView setZoomScale:recognizer.scale animated:YES];
//    _upImage = [ImageUtil scaleImage:[self.imagesArray objectAtIndex:0] toScale:recognizer.scale];
//    _scrollView.isSelected = YES;
//    [self setSelectedImage:_upImage];
////    recognizer.scale = 1;
//}

@end
