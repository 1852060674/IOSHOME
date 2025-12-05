//
//  ZBTemplate5_4_View.m
//  Collage
//
//  Created by shen on 13-7-9.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBTemplate5_4_View.h"
#import "ZBIrregularCollageScrollView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBTemplate5_4_View()<UIScrollViewDelegate>
{
    float _currentWidth;
    float _currentHeight;
    
    float _middleImageWidth;
    float _middleImageHeight;
    
    float _firtWidth;
    float _firtHeight;
    
//    float _secondWidth;
//    float _secondHeight;
    
    float _minusHeight;
    float _minusWidth;
    
    float _upAndDownImageHeight;
    float _upAndDownImageMinusWidth;
    
    float _leftAndRightImageWidth;
    float _leftAndRightImageMinusHeight;
    
    float _gap;
    BOOL _isFirstLoad;
    
    UIImage *_upImage;
    UIImage *_leftImage;
    UIImage *_rightImage;
    UIImage *_downImage;
    UIImage *_middleImage;
    
    float _tan ;
    float _cos ;
    float _sin ;
}

@property (nonatomic,strong)NSMutableArray *imagesArray;
@property (nonatomic,strong)NSMutableArray *upPointArray;
@property (nonatomic,strong)NSMutableArray *leftPointArray;
@property (nonatomic,strong)NSMutableArray *rightPointArray;
@property (nonatomic,strong)NSMutableArray *downPointArray;
@property (nonatomic,strong)NSMutableArray *middlePointArray;

@end

@implementation ZBTemplate5_4_View

@synthesize imagesArray = _imagesArray;
@synthesize upPointArray;
@synthesize leftPointArray;
@synthesize rightPointArray;
@synthesize downPointArray;
@synthesize middlePointArray;

- (id)initWithFrame:(CGRect)frame withImagesArray:(NSArray*)images
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kIrregularCollageColor;
        _isFirstLoad = YES;
        self.imagesArray = [[NSMutableArray alloc] initWithArray:images];
        
        self.upPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.leftPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.rightPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.downPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.middlePointArray = [[NSMutableArray alloc] initWithCapacity:2];
        
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
    _currentWidth = self.frame.size.width-2*_gap;
    _currentHeight = self.frame.size.height-2*_gap;
    /**** 角度计算 *****/
    _tan = _currentWidth/_currentHeight;
    _cos = 1/sqrt(1+_tan*_tan);
    _sin = sqrt(1-_cos*_cos);
    
//    = sqrt(_currentWidth*_currentWidth*0.25+_currentHeight*_currentHeight*0.25);
//    _minusHeight = _gap*(_currentWidth*0.5)/l;
//    _minusWidth = _gap*_currentHeight*0.5/l
    
    float l = sqrt(_currentHeight*_currentHeight+_currentWidth*_currentWidth);
    _minusWidth = 0.5*_gap*l/_currentHeight;
    _minusHeight = 0.5*_gap*l/_currentWidth;
    
    _middleImageWidth = _currentWidth*0.5;
    _middleImageHeight = _currentHeight*0.5;
    
//    float a = -0.25*_currentHeight;
//    float b = 0.5*_currentHeight;
//    a += _gap/_cos;
//    b += _gap/_sin;
//    
//    _secondWidth = (b-a)*0.5*_tan;
//    _secondHeight = _currentHeight*0.5 - (a+b)*0.5;
    
    _firtWidth = _currentWidth*0.25-_gap*l/_currentHeight;
    _firtHeight = _currentHeight*0.25-_gap*l/_currentWidth;
    
    float _incr2 = _gap/_sin;
    _upAndDownImageHeight = (1.25*_currentHeight+_incr2*1.5)*0.5;
    _upAndDownImageHeight = _currentHeight - _upAndDownImageHeight;
    _upAndDownImageMinusWidth = 0.375*_currentWidth-_incr2*_currentWidth*0.25/_currentHeight;
    
    _leftAndRightImageWidth = 0.375*_currentWidth-0.75*_incr2*_currentWidth/_currentHeight;
    _leftAndRightImageMinusHeight = (1.25*_currentHeight+0.5*_incr2)*0.5;

}


- (void)loadImages
{
    _upImage = [self.imagesArray objectAtIndex:0];
    _leftImage = [self.imagesArray objectAtIndex:1];
    _rightImage = [self.imagesArray objectAtIndex:2];
    _downImage = [self.imagesArray objectAtIndex:3];
    _middleImage = [self.imagesArray objectAtIndex:4];
    
    _upImage = [ImageUtil getScaleImage:_upImage withWidth:_currentWidth-2*_minusWidth andHeight:_upAndDownImageHeight];
    _leftImage = [ImageUtil getScaleImage:_leftImage withWidth:_leftAndRightImageWidth andHeight:_currentHeight-2*_minusHeight];
    _rightImage = [ImageUtil getScaleImage:_rightImage withWidth:_leftAndRightImageWidth andHeight:_currentHeight-2*_minusHeight];
    _downImage = [ImageUtil getScaleImage:_downImage withWidth:_currentWidth-2*_minusWidth andHeight:_upAndDownImageHeight];
    _middleImage = [ImageUtil getScaleImage:_middleImage withWidth:_middleImageWidth andHeight:_middleImageHeight];
}

- (void)createScrollView
{
    if (self.imagesArray.count == 5) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_minusWidth, _gap, _currentWidth-2*_minusWidth, _upAndDownImageHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag;
        _scrollView.originImage = [self.imagesArray objectAtIndex:0];
        
        CGPoint p = CGPointMake(0, _upImage.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_upAndDownImageMinusWidth-_minusWidth, _upImage.size.height-_scrollView.frame.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.5, _upImage.size.height-_firtHeight);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_upAndDownImageMinusWidth+_minusWidth, _upImage.size.height-_scrollView.frame.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _upImage.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        
//        _scrollView.imageView.image = [ImageUtil getSpecialImage:_upImage withPoints:self.upPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _upImage.size.width, _upImage.size.height);
        _scrollView.contentSize = CGSizeMake(_upImage.size.width, _upImage.size.height);
        [self addSubview:_scrollView];
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the second image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_minusHeight, _leftAndRightImageWidth, _currentHeight-2*_minusHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+1;
        _scrollView.originImage = [self.imagesArray objectAtIndex:1];
        
        p = CGPointMake(0, _leftImage.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftImage.size.height-_scrollView.frame.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_leftAndRightImageWidth, _leftImage.size.height-(_leftAndRightImageMinusHeight-_minusHeight));
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_firtWidth, _leftImage.size.height-_scrollView.frame.size.height*0.5);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_leftAndRightImageWidth, _leftImage.size.height-(_scrollView.frame.size.height-(_leftAndRightImageMinusHeight-_minusHeight)));
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftImage withPoints:self.leftPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftImage.size.width, _leftImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftImage.size.width, _leftImage.size.height);
        [self addSubview:_scrollView];
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the third image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_currentWidth-_leftAndRightImageWidth, _gap+_minusHeight,  _leftAndRightImageWidth, _currentHeight-2*_minusHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+2;
        _scrollView.originImage = [self.imagesArray objectAtIndex:2];
        
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height-(_scrollView.frame.size.height-(_leftAndRightImageMinusHeight-_minusHeight)));
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_firtWidth, _rightImage.size.height-_scrollView.frame.size.height*0.5);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height-(_leftAndRightImageMinusHeight-_minusHeight));
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height-_scrollView.frame.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightImage withPoints:self.rightPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightImage.size.width, _rightImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightImage.size.width, _rightImage.size.height);
        [self addSubview:_scrollView];
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the fourth image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_minusWidth, _gap+_currentHeight-_upAndDownImageHeight, _currentWidth-2*_minusWidth, _upAndDownImageHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+3;
        _scrollView.originImage = [self.imagesArray objectAtIndex:3];
        
        p = CGPointMake(0, _downImage.size.height-_scrollView.frame.size.height);
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _downImage.size.height - _scrollView.frame.size.height);
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_upAndDownImageMinusWidth+_minusWidth, _downImage.size.height);
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.5, _downImage.size.height-(_scrollView.frame.size.height-_firtHeight));
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_upAndDownImageMinusWidth-_minusWidth, _downImage.size.height);
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_downImage withPoints:self.downPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _downImage.size.width, _downImage.size.height);
        _scrollView.contentSize = CGSizeMake(_downImage.size.width, _downImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the fifth image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_firtWidth+_gap/_cos, _gap+_firtHeight+_gap/_sin, _middleImageWidth, _middleImageHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+4;
        _scrollView.originImage = [self.imagesArray objectAtIndex:4];
        
        p = CGPointMake(0, _middleImage.size.height-_scrollView.frame.size.height*0.5);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.5, _middleImage.size.height - _scrollView.frame.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _middleImage.size.height - _scrollView.frame.size.height*0.5);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.5, _middleImage.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_middleImage withPoints:self.middlePointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _middleImage.size.width, _middleImage.size.height);
        _scrollView.contentSize = CGSizeMake(_middleImage.size.width, _middleImage.size.height);
        [self addSubview:_scrollView];
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
    }
}

- (void)loadScrollViews
{
    for (NSUInteger i=0; i<5; i++) {
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+i];
        _scrollView.delegate = nil;
    }
    [self.upPointArray removeAllObjects];
    [self.leftPointArray removeAllObjects];
    [self.rightPointArray removeAllObjects];
    [self.downPointArray removeAllObjects];
    [self.middlePointArray removeAllObjects];
    
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset;

    if (self.imagesArray.count == 5) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag];
        _scrollView.frame = CGRectMake(_gap+_minusWidth, _gap, _currentWidth-2*_minusWidth, _upAndDownImageHeight);
        _scrollView.delegate = self;
        
        CGPoint p = CGPointMake(0, _upImage.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_upAndDownImageMinusWidth-_minusWidth, _upImage.size.height-_scrollView.frame.size.height);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.5, _upImage.size.height-_firtHeight);
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_upAndDownImageMinusWidth+_minusWidth, _upImage.size.height-_scrollView.frame.size.height);
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
        _scrollView.frame = CGRectMake(_gap, _gap+_minusHeight, _leftAndRightImageWidth, _currentHeight-2*_minusHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _leftImage.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftImage.size.height-_scrollView.frame.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_leftAndRightImageWidth, _leftImage.size.height-(_leftAndRightImageMinusHeight-_minusHeight));
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_firtWidth, _leftImage.size.height-_scrollView.frame.size.height*0.5);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_leftAndRightImageWidth, _leftImage.size.height-(_scrollView.frame.size.height-(_leftAndRightImageMinusHeight-_minusHeight)));
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftImage.size.width, _leftImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftImage.size.width, _leftImage.size.height);
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the third image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
        _scrollView.frame = CGRectMake(_gap+_currentWidth-_leftAndRightImageWidth, _gap+_minusHeight,  _leftAndRightImageWidth, _currentHeight-2*_minusHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height-(_scrollView.frame.size.height-(_leftAndRightImageMinusHeight-_minusHeight)));
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_firtWidth, _rightImage.size.height-_scrollView.frame.size.height*0.5);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height-(_leftAndRightImageMinusHeight-_minusHeight));
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height-_scrollView.frame.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightImage.size.width, _rightImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightImage.size.width, _rightImage.size.height);
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the fourth image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+3];
        _scrollView.frame = CGRectMake(_gap+_minusWidth, _gap+_currentHeight-_upAndDownImageHeight, _currentWidth-2*_minusWidth, _upAndDownImageHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _downImage.size.height-_scrollView.frame.size.height);
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _downImage.size.height - _scrollView.frame.size.height);
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_upAndDownImageMinusWidth+_minusWidth, _downImage.size.height);
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.5, _downImage.size.height-(_scrollView.frame.size.height-_firtHeight));
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_upAndDownImageMinusWidth-_minusWidth, _downImage.size.height);
        [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.frame = CGRectMake(0, 0, _downImage.size.width, _downImage.size.height);
        _scrollView.contentSize = CGSizeMake(_downImage.size.width, _downImage.size.height);
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the fifth image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+4];
        _scrollView.frame = CGRectMake(_gap+_firtWidth+_gap/_cos, _gap+_firtHeight+_gap/_sin, _middleImageWidth, _middleImageHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _middleImage.size.height-_scrollView.frame.size.height*0.5);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.5, _middleImage.size.height - _scrollView.frame.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _middleImage.size.height - _scrollView.frame.size.height*0.5);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.5, _middleImage.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        [_pointArray removeAllObjects];
        for (NSUInteger i=0; i<self.middlePointArray.count; i++) {
            NSValue *_value = [self.middlePointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_middleImage withPoints:_pointArray];        
        _scrollView.imageView.frame = CGRectMake(0, 0, _middleImage.size.width, _middleImage.size.height);
        _scrollView.contentSize = CGSizeMake(_middleImage.size.width, _middleImage.size.height);
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    }
}

#pragma mark -- reselect image, or edit image
- (void)setSelectedImage:(UIImage*)image
{
    NSUInteger _selectedIndex = 0;
    for (NSUInteger i=0; i<5; i++) {
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+i];
        if (_scrollView.isSelected) {
            _selectedIndex = i;
            break;
        }
    }
    
    ZBIrregularCollageScrollView *_scrollView;
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset;
    CGPoint p;
    
    switch (_selectedIndex) {
        case 0:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag];
            [self.imagesArray replaceObjectAtIndex:0 withObject:image];
            _scrollView.originImage = image;
            _upImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-2*_minusWidth andHeight:_upAndDownImageHeight];
            [self.upPointArray removeAllObjects];
            
            p = CGPointMake(0, _upImage.size.height);
            [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_upAndDownImageMinusWidth-_minusWidth, _upImage.size.height-_scrollView.frame.size.height);
            [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width*0.5, _upImage.size.height-_firtHeight);
            [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width-_upAndDownImageMinusWidth+_minusWidth, _upImage.size.height-_scrollView.frame.size.height);
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
            
            self.selectedIndex = 0;
        }
            break;
        case 1:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+1];
            [self.imagesArray replaceObjectAtIndex:1 withObject:image];
            _scrollView.originImage = image;
            _leftImage = [ImageUtil getScaleImage:image withWidth:_leftAndRightImageWidth andHeight:_currentHeight-2*_minusHeight];
            [self.leftPointArray removeAllObjects];
            
            p = CGPointMake(0, _leftImage.size.height);
            [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _leftImage.size.height-_scrollView.frame.size.height);
            [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_leftAndRightImageWidth, _leftImage.size.height-(_leftAndRightImageMinusHeight-_minusHeight));
            [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_firtWidth, _leftImage.size.height-_scrollView.frame.size.height*0.5);
            [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_leftAndRightImageWidth, _leftImage.size.height-(_scrollView.frame.size.height-(_leftAndRightImageMinusHeight-_minusHeight)));
            [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _currentOffset = _scrollView.contentOffset;
            [_pointArray removeAllObjects];
            for (NSUInteger i=0; i<self.leftPointArray.count; i++) {
                NSValue *_value = [self.leftPointArray objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            
            _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftImage withPoints:_pointArray];
            _scrollView.imageView.frame = CGRectMake(0, 0, _leftImage.size.width, _leftImage.size.height);
            _scrollView.contentSize = CGSizeMake(_leftImage.size.width, _leftImage.size.height);
            
            self.selectedIndex = 1;
        }
            break;
        case 2:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
            [self.imagesArray replaceObjectAtIndex:2 withObject:image];
            _scrollView.originImage = image;
            _rightImage = [ImageUtil getScaleImage:image withWidth:_leftAndRightImageWidth andHeight:_currentHeight-2*_minusHeight];
            [self.rightPointArray removeAllObjects];
            
            p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height);
            [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _rightImage.size.height-(_scrollView.frame.size.height-(_leftAndRightImageMinusHeight-_minusHeight)));
            [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width-_firtWidth, _rightImage.size.height-_scrollView.frame.size.height*0.5);
            [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _rightImage.size.height-(_leftAndRightImageMinusHeight-_minusHeight));
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
            
            self.selectedIndex = 2;
        }
            break;
        case 3:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+3];
            [self.imagesArray replaceObjectAtIndex:3 withObject:image];
            _scrollView.originImage = image;
            _downImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-2*_minusWidth andHeight:_upAndDownImageHeight];
            [self.downPointArray removeAllObjects];
            
            p = CGPointMake(0, _downImage.size.height-_scrollView.frame.size.height);
            [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _downImage.size.height - _scrollView.frame.size.height);
            [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width-_upAndDownImageMinusWidth+_minusWidth, _downImage.size.height);
            [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width*0.5, _downImage.size.height-(_scrollView.frame.size.height-_firtHeight));
            [self.downPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_upAndDownImageMinusWidth-_minusWidth, _downImage.size.height);
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
            
            self.selectedIndex = 3;
        }
            break;
        case 4:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+4];
            [self.imagesArray replaceObjectAtIndex:4 withObject:image];
            _scrollView.originImage = image;
            _middleImage = [ImageUtil getScaleImage:image withWidth:_middleImageWidth andHeight:_middleImageHeight];
            [self.middlePointArray removeAllObjects];
            
            p = CGPointMake(0, _middleImage.size.height-_scrollView.frame.size.height*0.5);
            [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width*0.5, _middleImage.size.height - _scrollView.frame.size.height);
            [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _middleImage.size.height - _scrollView.frame.size.height*0.5);
            [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width*0.5, _middleImage.size.height);
            [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _currentOffset = _scrollView.contentOffset;
            [_pointArray removeAllObjects];
            for (NSUInteger i=0; i<self.middlePointArray.count; i++) {
                NSValue *_value = [self.middlePointArray objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            
            _scrollView.imageView.image = [ImageUtil getSpecialImage:_middleImage withPoints:_pointArray];
            _scrollView.imageView.frame = CGRectMake(0, 0, _middleImage.size.width, _middleImage.size.height);
            _scrollView.contentSize = CGSizeMake(_middleImage.size.width, _middleImage.size.height);
            
            self.selectedIndex = 4;
        }
            break;
        default:
            break;
    }
    
    _scrollView.isSelected = NO;
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}


#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset = scrollView.contentOffset;
    //    NSLog(@"%f,%f",_currentOffset.x,_currentOffset.y);
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
        
        for (NSUInteger i=0; i<self.leftPointArray.count; i++) {
            NSValue *_value = [self.leftPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_leftImage withPoints:_pointArray];
        
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
    else if(scrollView.tag == kIrregularScrollViewStartTag+3)
    {
        for (NSUInteger i=0; i<self.downPointArray.count; i++) {
            NSValue *_value = [self.downPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_downImage withPoints:_pointArray];
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+4)
    {
        for (NSUInteger i=0; i<self.middlePointArray.count; i++) {
            NSValue *_value = [self.middlePointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_middleImage withPoints:_pointArray];
    }
}


@end
