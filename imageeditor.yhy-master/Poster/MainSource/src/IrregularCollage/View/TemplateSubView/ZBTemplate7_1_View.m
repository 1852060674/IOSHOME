//
//  ZBTemplate7_1_View.m
//  Collage
//
//  Created by shen on 13-7-9.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBTemplate7_1_View.h"
#import "ZBIrregularCollageScrollView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBTemplate7_1_View()<UIScrollViewDelegate>
{
    float _currentWidth;
    float _currentHeight;
    
    float _middleImageWidth;
    float _middleImageHeight;
    
    float _firtImageHeight;
    float _firtImageSecondHeight;
    float _secondImageWidth;
    
    float _h1;
    float _h2;
    float _w1;
    float _w2;
    float _middleWidth;
    
    UIImage *_leftUpImage;
    UIImage *_leftDownImage;
    UIImage *_leftMiddleImage;
    UIImage *_rightUpImage;
    UIImage *_rightMiddleImage;
    UIImage *_rightDownImage;
    UIImage *_middleImage;
    
    float _gap;
    BOOL _isFirstLoad;
}

@property (nonatomic,strong)NSMutableArray *imagesArray;
@property (nonatomic,strong)NSMutableArray *leftUpPointArray;
@property (nonatomic,strong)NSMutableArray *leftMiddlePointArray;
@property (nonatomic,strong)NSMutableArray *leftDownPointArray;
@property (nonatomic,strong)NSMutableArray *rightUpPointArray;
@property (nonatomic,strong)NSMutableArray *rightMiddlePointArray;
@property (nonatomic,strong)NSMutableArray *rightDownPointArray;
@property (nonatomic,strong)NSMutableArray *middlePointArray;

@end

@implementation ZBTemplate7_1_View

@synthesize imagesArray = _imagesArray;
@synthesize leftUpPointArray;
@synthesize leftMiddlePointArray;
@synthesize leftDownPointArray;
@synthesize rightUpPointArray;
@synthesize rightMiddlePointArray;
@synthesize rightDownPointArray;
@synthesize middlePointArray;

- (id)initWithFrame:(CGRect)frame withImagesArray:(NSArray*)images
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kIrregularCollageColor;
        _isFirstLoad = YES;
        self.imagesArray = [[NSMutableArray alloc] initWithArray:images];
        
        self.leftUpPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.leftMiddlePointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.leftDownPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.rightUpPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.rightMiddlePointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.rightDownPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.middlePointArray = [[NSMutableArray alloc] initWithCapacity:2];
        
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
    _middleImageWidth = _currentWidth*0.5;
//    _middleImageHeight = _currentHeight*0.5;
//    if (_middleImageWidth<=_middleImageHeight) {
        _middleImageHeight = sqrtf(3)*_middleImageWidth*0.5;
//    }
//    else
//    {
//        _middleImageWidth = _middleImageHeight*sqrtf(3)*0.5;
//    }
    
    _firtImageHeight = (_currentHeight*0.5-_middleImageHeight/3);
    _firtImageSecondHeight = (_currentHeight-_middleImageHeight)*0.5-_gap;
    _secondImageWidth = (_currentWidth*0.5-_gap)*0.5;
    
    _h1 = _currentHeight*0.5-(_currentWidth*0.5+2*_gap)*0.5;
    _firtImageHeight = _currentHeight*0.5 - sqrt(3)*0.125*(_currentWidth*0.5+2*_gap);
    _h2 = _currentHeight*0.5 - sqrt(3)*0.5*(_currentWidth*0.5+2*_gap)*0.5;
    
    _w1 = _currentWidth*0.5 - 0.375*(_currentWidth*0.5+2*_gap);
    _w2 = _currentWidth*0.5 - 0.25*(_currentWidth*0.5+2*_gap);
    _middleWidth = _currentWidth*0.5 - 0.5*(_currentWidth*0.5+2*_gap);}


- (void)loadImages
{
    _leftUpImage = [self.imagesArray objectAtIndex:0];
    _leftMiddleImage = [self.imagesArray objectAtIndex:1];
    _leftDownImage = [self.imagesArray objectAtIndex:2];
    _rightUpImage = [self.imagesArray objectAtIndex:3];
    _rightMiddleImage = [self.imagesArray objectAtIndex:4];
    _rightDownImage = [self.imagesArray objectAtIndex:5];
    _middleImage = [self.imagesArray objectAtIndex:6];
    
    _leftUpImage = [ImageUtil getScaleImage:_leftUpImage withWidth:(_currentWidth-_gap)*0.5 andHeight:_firtImageHeight];
    _leftMiddleImage = [ImageUtil getScaleImage:_leftMiddleImage withWidth:_w1-0.5*_gap andHeight:_currentHeight-_h1*2-2*_gap];
    _leftDownImage = [ImageUtil getScaleImage:_leftDownImage withWidth:(_currentWidth-_gap)*0.5 andHeight:_firtImageHeight];
    
    _rightUpImage = [ImageUtil getScaleImage:_rightUpImage withWidth:(_currentWidth-_gap)*0.5 andHeight:_firtImageHeight];
    _rightMiddleImage = [ImageUtil getScaleImage:_rightMiddleImage withWidth:_w1-0.5*_gap andHeight:_currentHeight-_h1*2-2*_gap];
    _rightDownImage = [ImageUtil getScaleImage:_rightDownImage withWidth:(_currentWidth-_gap)*0.5 andHeight:_firtImageHeight];
    
    _middleImage = [ImageUtil getScaleImage:_middleImage withWidth:_middleImageWidth andHeight:_middleImageHeight];
}

- (void)createScrollView
{
    if (self.imagesArray.count == 7) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, (_currentWidth-_gap)*0.5, _firtImageHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag;
        _scrollView.originImage = [self.imagesArray objectAtIndex:0];
        
        CGPoint p = CGPointMake(0, _leftUpImage.size.height);;
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftUpImage.size.height-_h1);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_w1, _leftUpImage.size.height-_scrollView.frame.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_w2, _leftUpImage.size.height-_h2);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height-_h2);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftUpImage withPoints:self.leftUpPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftUpImage.size.width, _leftUpImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftUpImage.size.width, _leftUpImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the left middle image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_h1+_gap, _w1-0.5*_gap, _currentHeight-_h1*2-2*_gap)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+1;
        _scrollView.originImage = [self.imagesArray objectAtIndex:1];
        
        p = CGPointMake(0, _leftMiddleImage.size.height);
        [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftMiddleImage.size.height-_scrollView.frame.size.height);
        [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftMiddleImage.size.height-(_scrollView.frame.size.height - (_firtImageHeight-_h1-0.5*_gap)));
        [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_middleWidth, _leftMiddleImage.size.height-_scrollView.frame.size.height*0.5);
        [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftMiddleImage.size.height-(_firtImageHeight-_h1-0.5*_gap));
        [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftMiddleImage withPoints:self.leftMiddlePointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftMiddleImage.size.width, _leftMiddleImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftMiddleImage.size.width, _leftMiddleImage.size.height);
        [self addSubview:_scrollView];

        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the left down image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_currentHeight-_firtImageHeight, (_currentWidth-_gap)*0.5, _firtImageHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+2;
        _scrollView.originImage = [self.imagesArray objectAtIndex:2];
        
        p = CGPointMake(0, _leftDownImage.size.height-(_scrollView.frame.size.height -_h1));
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftDownImage.size.height-_scrollView.frame.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-_scrollView.frame.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-(_scrollView.frame.size.height -_h2));
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_w2, _leftDownImage.size.height-(_scrollView.frame.size.height- _h2));
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_w1, _leftDownImage.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftDownImage withPoints:self.leftDownPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftDownImage.size.width, _leftDownImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftDownImage.size.width, _leftDownImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the right up image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-_gap)*0.5+_gap, _gap, (_currentWidth-_gap)*0.5, _firtImageHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+3;
        _scrollView.originImage = [self.imagesArray objectAtIndex:3];
        
        p = CGPointMake(0, _rightUpImage.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightUpImage.size.height-_h2);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_w2, _rightUpImage.size.height-_h2);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_w1, _rightUpImage.size.height-_scrollView.frame.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height-_h1);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightUpImage withPoints:self.rightUpPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightUpImage.size.width, _rightUpImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightUpImage.size.width, _rightUpImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the right middle image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_currentWidth-(_w1-0.5*_gap), _gap+_h1+_gap, _w1-0.5*_gap, _currentHeight-_h1*2-2*_gap)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+4;
        _scrollView.originImage = [self.imagesArray objectAtIndex:4];
        
        p = CGPointMake(0, _rightMiddleImage.size.height -(_firtImageHeight-_h1));
        [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake((_scrollView.frame.size.width - _middleWidth), _rightMiddleImage.size.height - _scrollView.frame.size.height*0.5);
        [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightMiddleImage.size.height - (_scrollView.frame.size.height - (_firtImageHeight-_h1-0.5*_gap)));
        [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightMiddleImage.size.height-_scrollView.frame.size.height);
        [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightMiddleImage.size.height);
        [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];

        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightMiddleImage withPoints:self.rightMiddlePointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightMiddleImage.size.width, _rightMiddleImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightMiddleImage.size.width, _rightMiddleImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the right down image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+(_currentWidth-_gap)*0.5+_gap, _gap+_currentHeight-_firtImageHeight, (_currentWidth-_gap)*0.5, _firtImageHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+5;
        _scrollView.originImage = [self.imagesArray objectAtIndex:5];
        
        p = CGPointMake(0, _rightDownImage.size.height -(_scrollView.frame.size.height -_h2));
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightDownImage.size.height - _scrollView.frame.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height - _scrollView.frame.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height-(_scrollView.frame.size.height - _h1));
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_w1, _rightDownImage.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_w2, _rightDownImage.size.height-(_scrollView.frame.size.height-_h2));
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightDownImage withPoints:self.rightDownPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightDownImage.size.width, _rightDownImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightDownImage.size.width, _rightDownImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the middle image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_currentWidth*0.5-_middleImageWidth*0.5, _gap+(_currentHeight-_middleImageHeight)*0.5, _middleImageWidth, _middleImageHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+6;
        _scrollView.originImage = [self.imagesArray objectAtIndex:6];
        
        p = CGPointMake(0, _middleImage.size.height - _scrollView.frame.size.height*0.5);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.25, _middleImage.size.height - _scrollView.frame.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.75, _middleImage.size.height - _scrollView.frame.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _middleImage.size.height-_scrollView.frame.size.height*0.5);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.75, _middleImage.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.25, _middleImage.size.height);
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
    for (NSUInteger i=0; i<7; i++) {
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+i];
        _scrollView.delegate = nil;
    }
    [self.leftUpPointArray removeAllObjects];
    [self.leftMiddlePointArray removeAllObjects];
    [self.leftDownPointArray removeAllObjects];
    [self.rightUpPointArray removeAllObjects];
    [self.rightMiddlePointArray removeAllObjects];
    [self.rightDownPointArray removeAllObjects];
    [self.middlePointArray removeAllObjects];
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset;
    
    if (self.imagesArray.count == 7) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag];
        _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-_gap)*0.5, _firtImageHeight);
        _scrollView.delegate = self;
        
        CGPoint p = CGPointMake(0, _leftUpImage.size.height);;
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftUpImage.size.height-_h1);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_w1, _leftUpImage.size.height-_scrollView.frame.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_w2, _leftUpImage.size.height-_h2);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height-_h2);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        for (NSUInteger i=0; i<self.leftUpPointArray.count; i++) {
            NSValue *_value = [self.leftUpPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftUpImage withPoints:_pointArray];
        
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftUpImage.size.width, _leftUpImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftUpImage.size.width, _leftUpImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the left middle image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+1];
        _scrollView.frame = CGRectMake(_gap, _gap+_h1+_gap, _w1-0.5*_gap, _currentHeight-_h1*2-2*_gap);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _leftMiddleImage.size.height);
        [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftMiddleImage.size.height-_scrollView.frame.size.height);
        [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftMiddleImage.size.height-(_scrollView.frame.size.height - (_firtImageHeight-_h1-0.5*_gap)));
        [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_middleWidth, _leftMiddleImage.size.height-_scrollView.frame.size.height*0.5);
        [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftMiddleImage.size.height-(_firtImageHeight-_h1-0.5*_gap));
        [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        [_pointArray removeAllObjects];
        for (NSUInteger i=0; i<self.leftMiddlePointArray.count; i++) {
            NSValue *_value = [self.leftMiddlePointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftMiddleImage withPoints:_pointArray];        
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftMiddleImage.size.width, _leftMiddleImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftMiddleImage.size.width, _leftMiddleImage.size.height);
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the left down image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
        _scrollView.frame = CGRectMake(_gap, _gap+_currentHeight-_firtImageHeight, (_currentWidth-_gap)*0.5, _firtImageHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _leftDownImage.size.height-(_scrollView.frame.size.height -_h1));
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftDownImage.size.height-_scrollView.frame.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-_scrollView.frame.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-(_scrollView.frame.size.height -_h2));
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_w2, _leftDownImage.size.height-(_scrollView.frame.size.height- _h2));
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_w1, _leftDownImage.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        [_pointArray removeAllObjects];
        for (NSUInteger i=0; i<self.leftDownPointArray.count; i++) {
            NSValue *_value = [self.leftDownPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftDownImage withPoints:_pointArray];
        
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftDownImage.size.width, _leftDownImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftDownImage.size.width, _leftDownImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the right up image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+3];
        _scrollView.frame = CGRectMake(_gap+(_currentWidth-_gap)*0.5+_gap, _gap, (_currentWidth-_gap)*0.5, _firtImageHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _rightUpImage.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightUpImage.size.height-_h2);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_w2, _rightUpImage.size.height-_h2);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_w1, _rightUpImage.size.height-_scrollView.frame.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height-_h1);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        [_pointArray removeAllObjects];
        
        for (NSUInteger i=0; i<self.rightUpPointArray.count; i++) {
            NSValue *_value = [self.rightUpPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightUpImage withPoints:_pointArray];        
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightUpImage.size.width, _rightUpImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightUpImage.size.width, _rightUpImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the right middle image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+4];
        _scrollView.frame = CGRectMake(_gap+_currentWidth-(_w1-0.5*_gap), _gap+_h1+_gap, _w1-0.5*_gap, _currentHeight-_h1*2-2*_gap);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _rightMiddleImage.size.height -(_firtImageHeight-_h1));
        [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake((_scrollView.frame.size.width - _middleWidth), _rightMiddleImage.size.height - _scrollView.frame.size.height*0.5);
        [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightMiddleImage.size.height - (_scrollView.frame.size.height - (_firtImageHeight-_h1-0.5*_gap)));
        [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightMiddleImage.size.height-_scrollView.frame.size.height);
        [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightMiddleImage.size.height);
        [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        [_pointArray removeAllObjects];
        
        for (NSUInteger i=0; i<self.rightMiddlePointArray.count; i++) {
            NSValue *_value = [self.rightMiddlePointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightMiddleImage withPoints:_pointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightMiddleImage.size.width, _rightMiddleImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightMiddleImage.size.width, _rightMiddleImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the right down image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+5];
        _scrollView.frame = CGRectMake(_gap+(_currentWidth-_gap)*0.5+_gap, _gap+_currentHeight-_firtImageHeight, (_currentWidth-_gap)*0.5, _firtImageHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _rightDownImage.size.height -(_scrollView.frame.size.height -_h2));
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightDownImage.size.height - _scrollView.frame.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height - _scrollView.frame.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height-(_scrollView.frame.size.height - _h1));
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_w1, _rightDownImage.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_w2, _rightDownImage.size.height-(_scrollView.frame.size.height-_h2));
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _currentOffset = _scrollView.contentOffset;
        [_pointArray removeAllObjects];
        
        for (NSUInteger i=0; i<self.rightDownPointArray.count; i++) {
            NSValue *_value = [self.rightDownPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightDownImage withPoints:_pointArray];        
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightDownImage.size.width, _rightDownImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightDownImage.size.width, _rightDownImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the middle image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+6];
        _scrollView.frame = CGRectMake(_gap+_currentWidth*0.5-_middleImageWidth*0.5, _gap+(_currentHeight-_middleImageHeight)*0.5, _middleImageWidth, _middleImageHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _middleImage.size.height - _scrollView.frame.size.height*0.5);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.25, _middleImage.size.height - _scrollView.frame.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.75, _middleImage.size.height - _scrollView.frame.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _middleImage.size.height-_scrollView.frame.size.height*0.5);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.75, _middleImage.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.25, _middleImage.size.height);
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
    for (NSUInteger i=0; i<7; i++) {
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
            _leftUpImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_firtImageHeight];
            [self.leftUpPointArray removeAllObjects];
            
            p = CGPointMake(0, _leftUpImage.size.height);;
            [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _leftUpImage.size.height-_h1);
            [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_w1, _leftUpImage.size.height-_scrollView.frame.size.height);
            [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_w2, _leftUpImage.size.height-_h2);
            [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height-_h2);
            [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height);
            [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _currentOffset = _scrollView.contentOffset;
            for (NSUInteger i=0; i<self.leftUpPointArray.count; i++) {
                NSValue *_value = [self.leftUpPointArray objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            
            _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftUpImage withPoints:_pointArray];
            
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
            _leftMiddleImage = [ImageUtil getScaleImage:image withWidth:_w1-0.5*_gap andHeight:_currentHeight-_h1*2-2*_gap];
            [self.leftMiddlePointArray removeAllObjects];
            
            p = CGPointMake(0, _leftMiddleImage.size.height);
            [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _leftMiddleImage.size.height-_scrollView.frame.size.height);
            [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _leftMiddleImage.size.height-(_scrollView.frame.size.height - (_firtImageHeight-_h1-0.5*_gap)));
            [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_middleWidth, _leftMiddleImage.size.height-_scrollView.frame.size.height*0.5);
            [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _leftMiddleImage.size.height-(_firtImageHeight-_h1-0.5*_gap));
            [self.leftMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _currentOffset = _scrollView.contentOffset;
            [_pointArray removeAllObjects];
            for (NSUInteger i=0; i<self.leftMiddlePointArray.count; i++) {
                NSValue *_value = [self.leftMiddlePointArray objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            
            _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftMiddleImage withPoints:_pointArray];
            _scrollView.imageView.frame = CGRectMake(0, 0, _leftMiddleImage.size.width, _leftMiddleImage.size.height);
            _scrollView.contentSize = CGSizeMake(_leftMiddleImage.size.width, _leftMiddleImage.size.height);
            
            self.selectedIndex = 1;
        }
            break;
        case 2:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
            [self.imagesArray replaceObjectAtIndex:2 withObject:image];
            _scrollView.originImage = image;
            _leftDownImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_firtImageHeight];
            [self.leftDownPointArray removeAllObjects];
            
            p = CGPointMake(0, _leftDownImage.size.height-(_scrollView.frame.size.height -_h1));
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _leftDownImage.size.height-_scrollView.frame.size.height);
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-_scrollView.frame.size.height);
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-(_scrollView.frame.size.height -_h2));
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_w2, _leftDownImage.size.height-(_scrollView.frame.size.height- _h2));
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_w1, _leftDownImage.size.height);
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _currentOffset = _scrollView.contentOffset;
            [_pointArray removeAllObjects];
            for (NSUInteger i=0; i<self.leftDownPointArray.count; i++) {
                NSValue *_value = [self.leftDownPointArray objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            
            _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftDownImage withPoints:_pointArray];
            
            _scrollView.imageView.frame = CGRectMake(0, 0, _leftDownImage.size.width, _leftDownImage.size.height);
            _scrollView.contentSize = CGSizeMake(_leftDownImage.size.width, _leftDownImage.size.height);
            
            self.selectedIndex = 2;
        }
            break;
        case 3:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+3];
            [self.imagesArray replaceObjectAtIndex:3 withObject:image];
            _scrollView.originImage = image;
            _rightUpImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_firtImageHeight];
            [self.rightUpPointArray removeAllObjects];
            
            p = CGPointMake(0, _rightUpImage.size.height);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _rightUpImage.size.height-_h2);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width-_w2, _rightUpImage.size.height-_h2);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width-_w1, _rightUpImage.size.height-_scrollView.frame.size.height);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height-_h1);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightUpImage withPoints:self.rightUpPointArray];
            _scrollView.imageView.frame = CGRectMake(0, 0, _rightUpImage.size.width, _rightUpImage.size.height);
            _scrollView.contentSize = CGSizeMake(_rightUpImage.size.width, _rightUpImage.size.height);
            [self addSubview:_scrollView];

            self.selectedIndex = 3;
        }
            break;
        case 4:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+4];
            [self.imagesArray replaceObjectAtIndex:4 withObject:image];
            _scrollView.originImage = image;
            _rightMiddleImage = [ImageUtil getScaleImage:image withWidth:_w1-0.5*_gap andHeight:_currentHeight-_h1*2-2*_gap];
            [self.rightMiddlePointArray removeAllObjects];
            
            p = CGPointMake(0, _rightMiddleImage.size.height -(_firtImageHeight-_h1));
            [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake((_scrollView.frame.size.width - _middleWidth), _rightMiddleImage.size.height - _scrollView.frame.size.height*0.5);
            [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _rightMiddleImage.size.height - (_scrollView.frame.size.height - (_firtImageHeight-_h1-0.5*_gap)));
            [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightMiddleImage.size.height-_scrollView.frame.size.height);
            [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightMiddleImage.size.height);
            [self.rightMiddlePointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _currentOffset = _scrollView.contentOffset;
            [_pointArray removeAllObjects];
            
            for (NSUInteger i=0; i<self.rightMiddlePointArray.count; i++) {
                NSValue *_value = [self.rightMiddlePointArray objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            
            _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightMiddleImage withPoints:_pointArray];
            _scrollView.imageView.frame = CGRectMake(0, 0, _rightMiddleImage.size.width, _rightMiddleImage.size.height);
            _scrollView.contentSize = CGSizeMake(_rightMiddleImage.size.width, _rightMiddleImage.size.height);
            
            self.selectedIndex = 4;
        }
            break;
        case 5:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+5];
            [self.imagesArray replaceObjectAtIndex:5 withObject:image];
            _scrollView.originImage = image;
            _rightDownImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_firtImageHeight];
            [self.rightDownPointArray removeAllObjects];
            
            p = CGPointMake(0, _rightDownImage.size.height -(_scrollView.frame.size.height -_h2));
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _rightDownImage.size.height - _scrollView.frame.size.height);
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height - _scrollView.frame.size.height);
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height-(_scrollView.frame.size.height - _h1));
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width-_w1, _rightDownImage.size.height);
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width-_w2, _rightDownImage.size.height-(_scrollView.frame.size.height-_h2));
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            
            _currentOffset = _scrollView.contentOffset;
            [_pointArray removeAllObjects];
            
            for (NSUInteger i=0; i<self.rightDownPointArray.count; i++) {
                NSValue *_value = [self.rightDownPointArray objectAtIndex:i];
                CGPoint _point = [_value CGPointValue];
                _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
            }
            
            _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightDownImage withPoints:_pointArray];
            _scrollView.imageView.frame = CGRectMake(0, 0, _rightDownImage.size.width, _rightDownImage.size.height);
            _scrollView.contentSize = CGSizeMake(_rightDownImage.size.width, _rightDownImage.size.height);
            
            self.selectedIndex = 5;
        }
            break;
        case 6:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+6];
            [self.imagesArray replaceObjectAtIndex:6 withObject:image];
            _scrollView.originImage = image;
            _middleImage = [ImageUtil getScaleImage:image withWidth:_middleImageWidth andHeight:_middleImageHeight];
            [self.middlePointArray removeAllObjects];
            
            p = CGPointMake(0, _middleImage.size.height - _scrollView.frame.size.height*0.5);
            [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width*0.25, _middleImage.size.height - _scrollView.frame.size.height);
            [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width*0.75, _middleImage.size.height - _scrollView.frame.size.height);
            [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _middleImage.size.height-_scrollView.frame.size.height*0.5);
            [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width*0.75, _middleImage.size.height);
            [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width*0.25, _middleImage.size.height);
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
            
            self.selectedIndex = 6;
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
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_leftUpImage withPoints:_pointArray];
        
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+1)
    {
        
        for (NSUInteger i=0; i<self.leftMiddlePointArray.count; i++) {
            NSValue *_value = [self.leftMiddlePointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_leftMiddleImage withPoints:_pointArray];
        
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+2)
    {
        for (NSUInteger i=0; i<self.leftDownPointArray.count; i++) {
            NSValue *_value = [self.leftDownPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_leftDownImage withPoints:_pointArray];
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+3)
    {
        for (NSUInteger i=0; i<self.rightUpPointArray.count; i++) {
            NSValue *_value = [self.rightUpPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_rightUpImage withPoints:_pointArray];
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+4)
    {
        for (NSUInteger i=0; i<self.rightMiddlePointArray.count; i++) {
            NSValue *_value = [self.rightMiddlePointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_rightMiddleImage withPoints:_pointArray];
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+5)
    {
        for (NSUInteger i=0; i<self.rightDownPointArray.count; i++) {
            NSValue *_value = [self.rightDownPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_rightDownImage withPoints:_pointArray];
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+6)
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
