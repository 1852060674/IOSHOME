//
//  ZBTemplate3_2_View.m
//  Collage
//
//  Created by shen on 13-7-8.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBTemplate3_2_View.h"
#import "ZBIrregularCollageScrollView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBTemplate3_2_View()<UIScrollViewDelegate>
{
    float _currentWidth;
    float _currentHeight;
    
    float _minusHeight;
    float _minusWidth;
    float _middleMinus;
    
    UIImage *_leftImage;
    UIImage *_rightImage;
    UIImage *_downImage;
    
    BOOL _isFirstLoad;
    BOOL _isReplace;
    float _gap;
    CGPoint _beforeZoomingContentOffset;
}

@property (nonatomic,strong)NSMutableArray *imagesArray;
@property (nonatomic,strong)NSMutableArray *leftPointArray;
@property (nonatomic,strong)NSMutableArray *rightPointArray;
@property (nonatomic,strong)NSMutableArray *downPointArray;

@end

@implementation ZBTemplate3_2_View

@synthesize imagesArray = _imagesArray;
@synthesize leftPointArray;
@synthesize rightPointArray;
@synthesize downPointArray;

- (id)initWithFrame:(CGRect)frame withImagesArray:(NSArray*)images
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kIrregularCollageColor;
        _isFirstLoad = YES;
        _isReplace = YES;
        self.imagesArray = [[NSMutableArray alloc] initWithArray:images];
        self.leftPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.rightPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.downPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        
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
    _leftImage = [self.imagesArray objectAtIndex:0];
    _rightImage = [self.imagesArray objectAtIndex:1];
    _downImage = [self.imagesArray objectAtIndex:2];
    
    _leftImage = [ImageUtil getScaleImage:_leftImage withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight-_minusHeight];
    _rightImage = [ImageUtil getScaleImage:_rightImage withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight-_minusHeight];
    _downImage = [ImageUtil getScaleImage:_downImage withWidth:_currentWidth-2*_minusWidth andHeight:(_currentHeight-_gap)*0.5];
}

- (void)createScrollView
{
    if (self.imagesArray.count == 3) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, (_currentWidth-_gap)*0.5, _currentHeight-_minusHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag;
        _scrollView.originImage = [self.imagesArray objectAtIndex:0];
        
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftImage.size.width, _leftImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftImage.size.width, _leftImage.size.height);
        
        CGPoint p = CGPointMake(0, _leftImage.size.height);;
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftImage.size.height-_scrollView.frame.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height-(_scrollView.frame.size.height-_currentHeight*0.5+_middleMinus));
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftImage withPoints:self.leftPointArray];
        
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the second image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth+_gap)*0.5, _gap, (_currentWidth-_gap)*0.5, _currentHeight-_minusHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+1;
        _scrollView.originImage = [self.imagesArray objectAtIndex:1];
        
        p = CGPointMake(0, _rightImage.size.height);;
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height-(_scrollView.frame.size.height-_currentHeight*0.5+_middleMinus));
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height-_scrollView.frame.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightImage withPoints:self.rightPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightImage.size.width, _rightImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightImage.size.width, _rightImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the third image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_minusWidth, _gap+(_currentHeight+_gap)*0.5, _currentWidth-2*_minusWidth, (_currentHeight-_gap)*0.5)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+2;
        _scrollView.originImage = [self.imagesArray objectAtIndex:2];
        
        p = CGPointMake(_scrollView.frame.size.width*0.5, _downImage.size.height);;
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _downImage.size.height-_scrollView.frame.size.height);
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _downImage.size.height-_scrollView.frame.size.height);
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_downImage withPoints:self.downPointArray];
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
    for (NSUInteger i=0; i<3; i++) {
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+i];
        _scrollView.delegate = nil;
    }
    [self.leftPointArray removeAllObjects];
    [self.downPointArray removeAllObjects];
    [self.rightPointArray removeAllObjects];
    
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset;
    if (self.imagesArray.count == 3) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag];
        _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-_gap)*0.5, _currentHeight-_minusHeight);
        _scrollView.delegate = self;
        
        CGPoint p = CGPointMake(0, _leftImage.size.height);;
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftImage.size.height-_scrollView.frame.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height-(_scrollView.frame.size.height-_currentHeight*0.5+_middleMinus));
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        
        for (NSUInteger i=0; i<self.leftPointArray.count; i++) {
            NSValue *_value = [self.leftPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftImage withPoints:_pointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftImage.size.width, _leftImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftImage.size.width, _leftImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the second image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+1];
        _scrollView.frame = CGRectMake(_gap+(_currentWidth+_gap)*0.5, _gap, (_currentWidth-_gap)*0.5, _currentHeight-_minusHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _rightImage.size.height);;
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height-(_scrollView.frame.size.height-_currentHeight*0.5+_middleMinus));
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height-_scrollView.frame.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height);
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
        
        /********* the third image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
        _scrollView.frame = CGRectMake(_gap+_minusWidth, _gap+(_currentHeight+_gap)*0.5, _currentWidth-2*_minusWidth, (_currentHeight-_gap)*0.5);
        _scrollView.delegate = self;
        
        p = CGPointMake(_scrollView.frame.size.width*0.5, _downImage.size.height);;
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _downImage.size.height-_scrollView.frame.size.height);
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _downImage.size.height-_scrollView.frame.size.height);
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        [_pointArray removeAllObjects];
        for (NSUInteger i=0; i<self.downPointArray.count; i++) {
            NSValue *_value = [self.downPointArray objectAtIndex:i];
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
            _leftImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight-_minusHeight];
        }
        else
        {
            
            if (image.size.width<_scrollView.frame.size.width || image.size.height<_scrollView.frame.size.height) {
                _leftImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight-_minusHeight];
            }
            else
                _leftImage = image;
        }
        _scrollView.originImage = image;
        
        [self.leftPointArray removeAllObjects];
        
        CGPoint p = CGPointMake(0, _leftImage.size.height);;
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftImage.size.height-_scrollView.frame.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height-(_scrollView.frame.size.height-_currentHeight*0.5+_middleMinus));
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        
        for (NSUInteger i=0; i<self.leftPointArray.count; i++) {
            NSValue *_value = [self.leftPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftImage withPoints:_pointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftImage.size.width, _leftImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftImage.size.width, _leftImage.size.height);
        
        _scrollView.isSelected = NO;
        self.selectedIndex = 0;
    }
    else
    {
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+1];
        if (_scrollView.isSelected) {
            if (_isReplace) {
                [self.imagesArray replaceObjectAtIndex:1 withObject:image];
                _rightImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight-_minusHeight];
            }
            else
            {
                
                if (image.size.width<_scrollView.frame.size.width || image.size.height<_scrollView.frame.size.height) {
                    _rightImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight-_minusHeight];
                }
                else
                    _rightImage = image;
            }
            _scrollView.originImage = image;
            
            [self.rightPointArray removeAllObjects];
            
            p = CGPointMake(0, _rightImage.size.height);;
            [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _rightImage.size.height-(_scrollView.frame.size.height-_currentHeight*0.5+_middleMinus));
            [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height-_scrollView.frame.size.height);
            [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height);
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
            self.selectedIndex = 1;
        }
        else
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
            if (_scrollView.isSelected) {
                if (_isReplace) {
                    [self.imagesArray replaceObjectAtIndex:2 withObject:image];
                    _downImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-2*_minusWidth andHeight:(_currentHeight-_gap)*0.5];
                }
                else
                {
                    
                    if (image.size.width<_scrollView.frame.size.width || image.size.height<_scrollView.frame.size.height) {
                        _downImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-2*_minusWidth andHeight:(_currentHeight-_gap)*0.5];
                    }
                    else
                        _downImage = image;
                }
                _scrollView.originImage = image;
                
                [self.downPointArray removeAllObjects];
                
                p = CGPointMake(_scrollView.frame.size.width*0.5, _downImage.size.height);;
                [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
                p = CGPointMake(0, _downImage.size.height-_scrollView.frame.size.height);
                [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
                p = CGPointMake(_scrollView.frame.size.width, _downImage.size.height-_scrollView.frame.size.height);
                [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
                
                _currentOffset = _scrollView.contentOffset;
                [_pointArray removeAllObjects];
                for (NSUInteger i=0; i<self.downPointArray.count; i++) {
                    NSValue *_value = [self.downPointArray objectAtIndex:i];
                    CGPoint _point = [_value CGPointValue];
                    _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                    [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
                }
                
                _scrollView.imageView.image = [ImageUtil getSpecialImage:_downImage withPoints:_pointArray];
                _scrollView.imageView.frame = CGRectMake(0, 0, _downImage.size.width, _downImage.size.height);
                _scrollView.contentSize = CGSizeMake(_downImage.size.width, _downImage.size.height);
                
                
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
        
        
        for (NSUInteger i=0; i<self.leftPointArray.count; i++) {
            NSValue *_value = [self.leftPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_leftImage withPoints:_pointArray];
        
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+1)
    {
        
        for (NSUInteger i=0; i<self.rightPointArray.count; i++) {
            NSValue *_value = [self.rightPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_rightImage withPoints:_pointArray];
        
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+2)
    {
        for (NSUInteger i=0; i<self.downPointArray.count; i++) {
            NSValue *_value = [self.downPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_downImage withPoints:_pointArray];
    }
}

@end
