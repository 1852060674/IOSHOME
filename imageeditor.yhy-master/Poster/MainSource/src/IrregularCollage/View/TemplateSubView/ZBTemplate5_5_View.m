//
//  ZBTemplate5_5_View.m
//  Collage
//
//  Created by shen on 13-7-10.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBTemplate5_5_View.h"
#import "ZBIrregularCollageScrollView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBTemplate5_5_View()<UIScrollViewDelegate>
{
    float _currentWidth;
    float _currentHeight;
    
    float _radius;
    float _gap;
    BOOL _isFirstLoad;
    
    float _middleMinusWidth;
    float _middleMinusHeight;
    
    float _upAndDonwImageHeight;
    float _leftAndRightImageWidth;
    float _w1;
    float _h1;
    float _atan;
    
    float _minusHeight;
    float _minusWidth;
    
    UIImage *_leftUpImage;
    UIImage *_leftDownImage;
    UIImage *_rightUpImage;
    UIImage *_rightDownImage;
    UIImage *_middleImage;
}

@property (nonatomic,strong)NSMutableArray *imagesArray;
@property (nonatomic,strong)NSMutableArray *leftUpPointArray;
@property (nonatomic,strong)NSMutableArray *leftDownPointArray;
@property (nonatomic,strong)NSMutableArray *rightUpPointArray;
@property (nonatomic,strong)NSMutableArray *rightDownPointArray;

@end


@implementation ZBTemplate5_5_View

@synthesize imagesArray = _imagesArray;
@synthesize leftUpPointArray;
@synthesize leftDownPointArray;
@synthesize rightUpPointArray;
@synthesize rightDownPointArray;

- (id)initWithFrame:(CGRect)frame withImagesArray:(NSArray*)images
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kIrregularCollageColor;
        _isFirstLoad = YES;
        self.imagesArray = [[NSMutableArray alloc] initWithArray:images];
        
        self.leftUpPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.leftDownPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.rightUpPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.rightDownPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        
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
    _currentWidth = self.frame.size.width-2*_gap;
    _currentHeight = self.frame.size.height-2*_gap;
    /**** 角度计算 *****/
//    float l = sqrt(_currentWidth*_currentWidth*0.25+_currentHeight*_currentHeight*0.25);
//    _minusHeight = _gap*(_currentWidth*0.5)/l;
//    _minusWidth = _gap*_currentHeight*0.5/l;
    float l = sqrt(_currentHeight*_currentHeight+_currentWidth*_currentWidth);
    _minusWidth = 0.5*_gap*l/_currentHeight;
    _minusHeight = 0.5*_gap*l/_currentWidth;
    
    _radius = _currentWidth*0.25;
    
    float _tan = _currentWidth/_currentHeight;
    float _cos = 1/sqrt(1+_tan*_tan);
    float _sin = sqrt(1-_cos*_cos);
    _atan = atan(_tan);
    
//    _upAndDonwImageHeight = _currentHeight*0.5 - _sin*0.5*_gap - _cos*0.5*(0.5*_currentWidth+2*_gap);
//    _w1 = _currentWidth*0.5 - _sin*(0.5*_currentWidth+2*_gap)*0.5 + 0.5*_gap*_cos-_minusWidth;
    
    _leftAndRightImageWidth = _currentWidth*0.5-_sin*(0.5*_currentWidth+2*_gap)*0.5-0.5*_gap*_cos;
    _h1 = _currentHeight*0.5 + _sin*0.5*_gap - _cos*0.5*(0.5*_currentWidth+2*_gap);
    
    
    _middleMinusWidth = _currentWidth*0.5 - _radius - _gap;
    _middleMinusHeight = _currentHeight*0.5 - _radius - _gap;
    
    float _h = (sqrt((0.5*_currentWidth+2*_gap)*(0.5*_currentWidth+2*_gap)*0.25-0.25*_gap*_gap)+0.5*_gap*_tan)*_cos;
    _upAndDonwImageHeight = _currentHeight*0.5-_h;
    _w1 = _currentWidth*0.5-(_h*_tan-0.5*_gap/_cos)-_minusWidth;
    
    
}

- (void)loadImages
{
    _leftUpImage = [self.imagesArray objectAtIndex:0];
    _leftDownImage = [self.imagesArray objectAtIndex:1];
    _rightUpImage = [self.imagesArray objectAtIndex:2];
    _rightDownImage = [self.imagesArray objectAtIndex:3];
    _middleImage = [self.imagesArray objectAtIndex:4];
    
    _leftUpImage = [ImageUtil getScaleImage:_leftUpImage withWidth:_currentWidth-2*_minusWidth andHeight:_upAndDonwImageHeight];
    _leftDownImage = [ImageUtil getScaleImage:_leftDownImage withWidth:_leftAndRightImageWidth andHeight:_currentHeight-2*_minusHeight];
    _rightUpImage = [ImageUtil getScaleImage:_rightUpImage withWidth:_leftAndRightImageWidth andHeight:_currentHeight-2*_minusHeight];
    _rightDownImage = [ImageUtil getScaleImage:_rightDownImage withWidth:_currentWidth-2*_minusWidth andHeight:_upAndDonwImageHeight];
    _middleImage = [ImageUtil getScaleImage:_middleImage withWidth:2*_radius andHeight:2*_radius];
}

- (void)createScrollView
{
    if (self.imagesArray.count == 5) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_minusWidth, _gap, _currentWidth-2*_minusWidth, _upAndDonwImageHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag;
        _scrollView.originImage = [self.imagesArray objectAtIndex:0];
        
        CGPoint p = CGPointMake(_w1, _leftUpImage.size.height-_scrollView.frame.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftUpImage.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_w1, _leftUpImage.size.height-_scrollView.frame.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil draw5_1_Image:_leftUpImage withPoints:self.leftUpPointArray withCenter:CGPointMake(_scrollView.frame.size.width*0.5, _leftUpImage.size.height-_currentHeight*0.5) radius:_radius+_gap startAngle:-_atan+M_PI_2 endAngle:_atan+M_PI_2 clockwise:YES];
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftUpImage.size.width, _leftUpImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftUpImage.size.width, _leftUpImage.size.height);
        [self addSubview:_scrollView];
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the second image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_minusHeight, _leftAndRightImageWidth, _currentHeight-2*_minusHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+1;
        _scrollView.originImage = [self.imagesArray objectAtIndex:1];
        
        p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-(_scrollView.frame.size.height-_h1+_minusHeight));
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftDownImage.size.height-_scrollView.frame.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftDownImage.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-_h1+_minusHeight);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil draw5_1_Image:_leftDownImage withPoints:self.leftDownPointArray withCenter:CGPointMake(_currentWidth*0.5, _leftDownImage.size.height - _scrollView.frame.size.height*0.5) radius:_radius+_gap startAngle:_atan-M_PI_2+M_PI endAngle:M_PI_2-_atan+M_PI clockwise:YES];
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftDownImage.size.width, _leftDownImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftDownImage.size.width, _leftDownImage.size.height);
        [self addSubview:_scrollView];
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the third image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_currentWidth-_leftAndRightImageWidth, _gap+_minusHeight, _leftAndRightImageWidth, _currentHeight-2*_minusHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+2;
        _scrollView.originImage = [self.imagesArray objectAtIndex:2];
        
        p = CGPointMake(0, _rightUpImage.size.height- _h1+_minusHeight);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height-_scrollView.frame.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightUpImage.size.height-_scrollView.frame.size.height+_h1-_minusHeight);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil draw5_1_Image:_rightUpImage withPoints:self.rightUpPointArray withCenter:CGPointMake(-(_currentWidth*0.5-_leftAndRightImageWidth), _rightUpImage.size.height-_scrollView.frame.size.height*0.5) radius:_radius+_gap startAngle:_atan-M_PI_2 endAngle:M_PI_2-_atan clockwise:YES];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightUpImage.size.width, _rightUpImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightUpImage.size.width, _rightUpImage.size.height);
        [self addSubview:_scrollView];
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the fourth image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_minusWidth, _gap+_currentHeight-_upAndDonwImageHeight, _currentWidth-2*_minusWidth, _upAndDonwImageHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+3;
        _scrollView.originImage = [self.imagesArray objectAtIndex:3];
        
        p = CGPointMake(_scrollView.frame.size.width-_w1, _rightDownImage.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height - _scrollView.frame.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightDownImage.size.height- _scrollView.frame.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_w1, _rightDownImage.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil draw5_1_Image:_rightDownImage withPoints:self.rightDownPointArray withCenter:CGPointMake(_scrollView.frame.size.width*0.5, _rightDownImage.size.height-(_upAndDonwImageHeight-_currentHeight*0.5)) radius:_radius+_gap startAngle:-_atan+M_PI_2*3 endAngle:_atan+M_PI_2*3 clockwise:YES];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightDownImage.size.width, _rightDownImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightDownImage.size.width, _rightDownImage.size.height);
        [self addSubview:_scrollView];
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the fifth image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_middleMinusWidth+_gap, _gap+_middleMinusHeight+_gap, 2*_radius, 2*_radius)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+4;
        _scrollView.originImage = [self.imagesArray objectAtIndex:4];
        
        _scrollView.imageView.image = [ImageUtil drawCircle:_middleImage withCenter:CGPointMake(_scrollView.frame.size.width*0.5, _middleImage.size.height-_scrollView.frame.size.height*0.5) radius:_radius startAngle:0 endAngle:2*M_PI clockwise:YES];
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
    [self.leftUpPointArray removeAllObjects];
    [self.leftDownPointArray removeAllObjects];
    [self.rightUpPointArray removeAllObjects];
    [self.rightDownPointArray removeAllObjects];
    
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset;

    if (self.imagesArray.count == 5) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag];
        _scrollView.frame = CGRectMake(_gap+_minusWidth, _gap, _currentWidth-2*_minusWidth, _upAndDonwImageHeight);
        _scrollView.delegate = self;
        
        CGPoint p = CGPointMake(_w1, _leftUpImage.size.height-_scrollView.frame.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftUpImage.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_w1, _leftUpImage.size.height-_scrollView.frame.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        for (NSUInteger i=0; i<self.leftUpPointArray.count; i++) {
            NSValue *_value = [self.leftUpPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil draw5_1_Image:_leftUpImage withPoints:_pointArray withCenter:CGPointMake(_scrollView.frame.size.width*0.5+_currentOffset.x, _leftUpImage.size.height-_currentHeight*0.5-_currentOffset.y) radius:_radius+_gap startAngle:-_atan+M_PI_2 endAngle:_atan+M_PI_2 clockwise:YES];

        _scrollView.imageView.frame = CGRectMake(0, 0, _leftUpImage.size.width, _leftUpImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftUpImage.size.width, _leftUpImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the second image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+1];
        _scrollView.frame = CGRectMake(_gap, _gap+_minusHeight, _leftAndRightImageWidth, _currentHeight-2*_minusHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-(_scrollView.frame.size.height-_h1+_minusHeight));
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftDownImage.size.height-_scrollView.frame.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftDownImage.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-_h1+_minusHeight);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        [_pointArray removeAllObjects];
        for (NSUInteger i=0; i<self.leftDownPointArray.count; i++) {
            NSValue *_value = [self.leftDownPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil draw5_1_Image:_leftDownImage withPoints:_pointArray withCenter:CGPointMake(_currentWidth*0.5+_gap*0.5+_currentOffset.x, _leftDownImage.size.height - _scrollView.frame.size.height*0.5-_currentOffset.y) radius:_radius+_gap startAngle:_atan-M_PI_2+M_PI endAngle:M_PI_2-_atan+M_PI clockwise:YES];
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftDownImage.size.width, _leftDownImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftDownImage.size.width, _leftDownImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the third image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
        _scrollView.frame = CGRectMake(_gap+_currentWidth-_leftAndRightImageWidth, _gap+_minusHeight, _leftAndRightImageWidth, _currentHeight-2*_minusHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _rightUpImage.size.height- _h1+_minusHeight);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height-_scrollView.frame.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightUpImage.size.height-_scrollView.frame.size.height+_h1-_minusHeight);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        [_pointArray removeAllObjects];
        
        for (NSUInteger i=0; i<self.rightUpPointArray.count; i++) {
            NSValue *_value = [self.rightUpPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil draw5_1_Image:_rightUpImage withPoints:_pointArray withCenter:CGPointMake(-(_currentWidth*0.5-_leftAndRightImageWidth)+_currentOffset.x, _rightUpImage.size.height-_scrollView.frame.size.height*0.5-_currentOffset.y) radius:_radius+_gap startAngle:_atan-M_PI_2 endAngle:M_PI_2-_atan clockwise:YES];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightUpImage.size.width, _rightUpImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightUpImage.size.width, _rightUpImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the fourth image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+3];
        _scrollView.frame = CGRectMake(_gap+_minusWidth, _gap+_currentHeight-_upAndDonwImageHeight, _currentWidth-2*_minusWidth, _upAndDonwImageHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(_scrollView.frame.size.width-_w1, _rightDownImage.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height - _scrollView.frame.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightDownImage.size.height- _scrollView.frame.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_w1, _rightDownImage.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        [_pointArray removeAllObjects];
        
        for (NSUInteger i=0; i<self.rightDownPointArray.count; i++) {
            NSValue *_value = [self.rightDownPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil draw5_1_Image:_rightDownImage withPoints:_pointArray withCenter:CGPointMake(_scrollView.frame.size.width*0.5+_currentOffset.x, _rightDownImage.size.height-(_upAndDonwImageHeight-_currentHeight*0.5)-_currentOffset.y) radius:_radius+_gap startAngle:-_atan+M_PI_2*3 endAngle:_atan+M_PI_2*3 clockwise:YES];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightDownImage.size.width, _rightDownImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightDownImage.size.width, _rightDownImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the fifth image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+4];
        _scrollView.frame = CGRectMake(_gap+_middleMinusWidth+_gap, _gap+_middleMinusHeight+_gap, 2*_radius, 2*_radius);
        _scrollView.delegate = self;
        
        _currentOffset = _scrollView.contentOffset;
        _scrollView.imageView.image = [ImageUtil drawCircle:_middleImage withCenter:CGPointMake(_scrollView.frame.size.width*0.5+_currentOffset.x, _middleImage.size.height-_scrollView.frame.size.height*0.5-_currentOffset.y) radius:_radius startAngle:0 endAngle:2*M_PI clockwise:YES];
        
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
            _leftUpImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-2*_minusWidth andHeight:_upAndDonwImageHeight];
            [self.leftUpPointArray removeAllObjects];
            
            p = CGPointMake(_w1, _leftUpImage.size.height-_scrollView.frame.size.height);
            [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _leftUpImage.size.height);
            [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height);
            [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width-_w1, _leftUpImage.size.height-_scrollView.frame.size.height);
            [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _currentOffset = _scrollView.contentOffset;
            for (NSUInteger i=0; i<self.leftUpPointArray.count; i++) {
                NSValue *_value = [self.leftUpPointArray objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            
            _scrollView.imageView.image = [ImageUtil draw5_1_Image:_leftUpImage withPoints:_pointArray withCenter:CGPointMake(_scrollView.frame.size.width*0.5+_currentOffset.x, _leftUpImage.size.height-_currentHeight*0.5-_currentOffset.y) radius:_radius+_gap startAngle:-_atan+M_PI_2 endAngle:_atan+M_PI_2 clockwise:YES];
            
            _scrollView.imageView.frame = CGRectMake(0, 0, _leftUpImage.size.width, _leftUpImage.size.height);
            _scrollView.contentSize = CGSizeMake(_leftUpImage.size.width, _leftUpImage.size.height);
            
            self.selectedIndex = 0;
        }
            break;
        case 1:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+1];
            [self.imagesArray replaceObjectAtIndex:1 withObject:image];
            _scrollView.originImage = image;
            _leftDownImage = [ImageUtil getScaleImage:image withWidth:_leftAndRightImageWidth andHeight:_currentHeight-2*_minusHeight];
            [self.leftDownPointArray removeAllObjects];
            
            p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-(_scrollView.frame.size.height-_h1+_minusHeight));
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _leftDownImage.size.height-_scrollView.frame.size.height);
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _leftDownImage.size.height);
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-_h1+_minusHeight);
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _currentOffset = _scrollView.contentOffset;
            [_pointArray removeAllObjects];
            for (NSUInteger i=0; i<self.leftDownPointArray.count; i++) {
                NSValue *_value = [self.leftDownPointArray objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            
            _scrollView.imageView.image = [ImageUtil draw5_1_Image:_leftDownImage withPoints:_pointArray withCenter:CGPointMake(_currentWidth*0.5+_gap*0.5+_currentOffset.x, _leftDownImage.size.height - _scrollView.frame.size.height*0.5-_currentOffset.y) radius:_radius+_gap startAngle:_atan-M_PI_2+M_PI endAngle:M_PI_2-_atan+M_PI clockwise:YES];
            _scrollView.imageView.frame = CGRectMake(0, 0, _leftDownImage.size.width, _leftDownImage.size.height);
            _scrollView.contentSize = CGSizeMake(_leftDownImage.size.width, _leftDownImage.size.height);
            
            self.selectedIndex = 1;
        }
            break;
        case 2:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
            [self.imagesArray replaceObjectAtIndex:2 withObject:image];
            _scrollView.originImage = image;
            _rightUpImage = [ImageUtil getScaleImage:image withWidth:_leftAndRightImageWidth andHeight:_currentHeight-2*_minusHeight];
            [self.rightUpPointArray removeAllObjects];
            
            p = CGPointMake(0, _rightUpImage.size.height- _h1+_minusHeight);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height-_scrollView.frame.size.height);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _rightUpImage.size.height-_scrollView.frame.size.height+_h1-_minusHeight);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _currentOffset = _scrollView.contentOffset;
            [_pointArray removeAllObjects];
            
            for (NSUInteger i=0; i<self.rightUpPointArray.count; i++) {
                NSValue *_value = [self.rightUpPointArray objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            
            _scrollView.imageView.image = [ImageUtil draw5_1_Image:_rightUpImage withPoints:_pointArray withCenter:CGPointMake(-(_currentWidth*0.5-_leftAndRightImageWidth)+_currentOffset.x, _rightUpImage.size.height-_scrollView.frame.size.height*0.5-_currentOffset.y) radius:_radius+_gap startAngle:_atan-M_PI_2 endAngle:M_PI_2-_atan clockwise:YES];
            _scrollView.imageView.frame = CGRectMake(0, 0, _rightUpImage.size.width, _rightUpImage.size.height);
            _scrollView.contentSize = CGSizeMake(_rightUpImage.size.width, _rightUpImage.size.height);
            
            self.selectedIndex = 2;
        }
            break;
        case 3:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+3];
            [self.imagesArray replaceObjectAtIndex:3 withObject:image];
            _scrollView.originImage = image;
            _rightDownImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-2*_minusWidth andHeight:_upAndDonwImageHeight];
            [self.rightDownPointArray removeAllObjects];
            
            p = CGPointMake(_scrollView.frame.size.width-_w1, _rightDownImage.size.height);
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height - _scrollView.frame.size.height);
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _rightDownImage.size.height- _scrollView.frame.size.height);
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_w1, _rightDownImage.size.height);
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _currentOffset = _scrollView.contentOffset;
            [_pointArray removeAllObjects];
            
            for (NSUInteger i=0; i<self.rightDownPointArray.count; i++) {
                NSValue *_value = [self.rightDownPointArray objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            
            _scrollView.imageView.image = [ImageUtil draw5_1_Image:_rightDownImage withPoints:_pointArray withCenter:CGPointMake(_scrollView.frame.size.width*0.5+_currentOffset.x, _rightDownImage.size.height-(_upAndDonwImageHeight-_currentHeight*0.5)-_currentOffset.y) radius:_radius+_gap startAngle:-_atan+M_PI_2*3 endAngle:_atan+M_PI_2*3 clockwise:YES];
            _scrollView.imageView.frame = CGRectMake(0, 0, _rightDownImage.size.width, _rightDownImage.size.height);
            _scrollView.contentSize = CGSizeMake(_rightDownImage.size.width, _rightDownImage.size.height);
            
            self.selectedIndex = 3;
        }
            break;
        case 4:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+4];
            [self.imagesArray replaceObjectAtIndex:4 withObject:image];
            _scrollView.originImage = image;
            _middleImage = [ImageUtil getScaleImage:image withWidth:2*_radius andHeight:2*_radius];
            
            _currentOffset = _scrollView.contentOffset;
            _scrollView.imageView.image = [ImageUtil drawCircle:_middleImage withCenter:CGPointMake(_scrollView.frame.size.width*0.5+_currentOffset.x, _middleImage.size.height-_scrollView.frame.size.height*0.5-_currentOffset.y) radius:_radius startAngle:0 endAngle:2*M_PI clockwise:YES];
            
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
        
        
        for (NSUInteger i=0; i<self.leftUpPointArray.count; i++) {
            NSValue *_value = [self.leftUpPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil draw5_1_Image:_leftUpImage withPoints:_pointArray withCenter:CGPointMake(scrollView.frame.size.width*0.5+_currentOffset.x, _leftUpImage.size.height-_currentHeight*0.5-_currentOffset.y) radius:_radius+_gap startAngle:-_atan+M_PI_2 endAngle:_atan+M_PI_2 clockwise:YES];
        
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+1)
    {
        
        for (NSUInteger i=0; i<self.leftDownPointArray.count; i++) {
            NSValue *_value = [self.leftDownPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil draw5_1_Image:_leftDownImage withPoints:_pointArray withCenter:CGPointMake(_currentWidth*0.5+_currentOffset.x, _leftDownImage.size.height - scrollView.frame.size.height*0.5-_currentOffset.y) radius:_radius+_gap startAngle:_atan-M_PI_2+M_PI endAngle:M_PI_2-_atan+M_PI clockwise:YES];
        
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+2)
    {
        for (NSUInteger i=0; i<self.rightUpPointArray.count; i++) {
            NSValue *_value = [self.rightUpPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        } 
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil draw5_1_Image:_rightUpImage withPoints:_pointArray withCenter:CGPointMake(-(_currentWidth*0.5-_leftAndRightImageWidth)+_currentOffset.x, _rightUpImage.size.height-scrollView.frame.size.height*0.5-_currentOffset.y) radius:_radius+_gap startAngle:_atan-M_PI_2 endAngle:M_PI_2-_atan clockwise:YES];
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+3)
    {
        for (NSUInteger i=0; i<self.rightDownPointArray.count; i++) {
            NSValue *_value = [self.rightDownPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }

        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil draw5_1_Image:_rightDownImage withPoints:_pointArray withCenter:CGPointMake(scrollView.frame.size.width*0.5+_currentOffset.x, _rightDownImage.size.height-(_upAndDonwImageHeight-_currentHeight*0.5)-_currentOffset.y) radius:_radius+_gap startAngle:-_atan+M_PI_2*3 endAngle:_atan+M_PI_2*3 clockwise:YES];
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+4)
    {
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil drawCircle:_middleImage withCenter:CGPointMake(scrollView.frame.size.width*0.5+_currentOffset.x, _middleImage.size.height-scrollView.frame.size.height*0.5-_currentOffset.y) radius:_radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    }
}
@end
