//
//  ZBTemplate5_3_View.m
//  Collage
//
//  Created by shen on 13-7-9.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBTemplate5_3_View.h"
#import "ZBIrregularCollageScrollView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBTemplate5_3_View()<UIScrollViewDelegate>
{
    float _currentWidth;
    float _currentHeight;
    
    float _middleImageWidth;
    float _middleImageHeight;
    
    float _leftUpWidth;
    float _leftUpHeight;
    
    BOOL _isFirstLoad;
    float _gap;
    
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
@property (nonatomic,strong)NSMutableArray *middlePointArray;

@end

@implementation ZBTemplate5_3_View

@synthesize imagesArray = _imagesArray;
@synthesize leftUpPointArray;
@synthesize leftDownPointArray;
@synthesize rightUpPointArray;
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
        self.leftDownPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.rightUpPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.rightDownPointArray = [[NSMutableArray alloc] initWithCapacity:2];
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
    _leftUpWidth = (_currentWidth-2*_gap)*0.25;
    _leftUpHeight = (_currentHeight-2*_gap)*0.25;
    
    _middleImageWidth = _currentWidth-2*_leftUpWidth-_gap*2;
    _middleImageHeight = _currentHeight - 2*_leftUpHeight - _gap*2;
}

- (void)loadImages
{
    _leftUpImage = [self.imagesArray objectAtIndex:0];
    _leftDownImage = [self.imagesArray objectAtIndex:1];
    _rightUpImage = [self.imagesArray objectAtIndex:2];
    _rightDownImage = [self.imagesArray objectAtIndex:3];
    _middleImage = [self.imagesArray objectAtIndex:4];
    
    _leftUpImage = [ImageUtil getScaleImage:_leftUpImage withWidth:_leftUpWidth andHeight:_leftUpHeight];
    _leftDownImage = [ImageUtil getScaleImage:_leftDownImage withWidth:_currentWidth-_leftUpWidth-_gap andHeight:_currentHeight-_leftUpHeight-_gap];
    _rightUpImage = [ImageUtil getScaleImage:_rightUpImage withWidth:_currentWidth-_leftUpWidth-_gap andHeight:_currentHeight-_leftUpHeight-_gap];
    _rightDownImage = [ImageUtil getScaleImage:_rightDownImage withWidth:_leftUpWidth andHeight:_leftUpHeight];
    _middleImage = [ImageUtil getScaleImage:_middleImage withWidth:_middleImageWidth andHeight:_middleImageHeight];
}

- (void)createScrollView
{
    if (self.imagesArray.count == 5) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, _leftUpWidth, _leftUpHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag;
        _scrollView.originImage = [self.imagesArray objectAtIndex:0];
        
        CGPoint p = CGPointMake(0, _leftUpImage.size.height);;
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftUpImage.size.height-_scrollView.frame.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height-_scrollView.frame.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftUpImage withPoints:self.leftUpPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftUpImage.size.width, _leftUpImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftUpImage.size.width, _leftUpImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the second image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_leftUpHeight+_gap, _currentWidth-_leftUpWidth-_gap, _currentHeight-_leftUpHeight-_gap)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+1;
        _scrollView.originImage = [self.imagesArray objectAtIndex:1];
        
        p = CGPointMake(0, _leftDownImage.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftDownImage.size.height-_scrollView.frame.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-_scrollView.frame.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-(_scrollView.frame.size.height-_leftUpHeight));
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_leftUpWidth, _leftDownImage.size.height-(_scrollView.frame.size.height-_leftUpHeight));
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_leftUpWidth, _leftDownImage.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftDownImage withPoints:self.leftDownPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftDownImage.size.width, _leftDownImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftDownImage.size.width, _leftDownImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the third image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_leftUpWidth+_gap, _gap, _currentWidth-_leftUpWidth-_gap, _currentHeight-_leftUpHeight-_gap)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+2;
        _scrollView.originImage = [self.imagesArray objectAtIndex:2];
        
        p = CGPointMake(0, _rightUpImage.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightUpImage.size.height-_leftUpHeight);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_leftUpWidth, _rightUpImage.size.height-_leftUpHeight);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_leftUpWidth, _rightUpImage.size.height-_scrollView.frame.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height-_scrollView.frame.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightUpImage withPoints:self.rightUpPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightUpImage.size.width, _rightUpImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightUpImage.size.width, _rightUpImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the fourth image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_currentWidth-_leftUpWidth, _gap+_currentHeight-_leftUpHeight, _leftUpWidth, _leftUpHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+3;
        _scrollView.originImage = [self.imagesArray objectAtIndex:3];
        
        p = CGPointMake(0, _rightDownImage.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightDownImage.size.height - _scrollView.frame.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height - _scrollView.frame.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil getSpecialImage:_rightDownImage withPoints:self.rightDownPointArray];
        _scrollView.imageView.frame = CGRectMake(0, 0, _rightDownImage.size.width, _rightDownImage.size.height);
        _scrollView.contentSize = CGSizeMake(_rightDownImage.size.width, _rightDownImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the fifth image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_leftUpWidth+_gap, _gap+_leftUpHeight+_gap, _middleImageWidth, _middleImageHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+4;
        _scrollView.originImage = [self.imagesArray objectAtIndex:4];
        
        p = CGPointMake(0, _middleImage.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _middleImage.size.height - _scrollView.frame.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _middleImage.size.height - _scrollView.frame.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _middleImage.size.height);
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
    [self.leftUpPointArray removeAllObjects];
    [self.leftDownPointArray removeAllObjects];
    [self.rightUpPointArray removeAllObjects];
    [self.rightDownPointArray removeAllObjects];
    [self.middlePointArray removeAllObjects];
    
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset;
    
    if (self.imagesArray.count == 5) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag];
        _scrollView.frame = CGRectMake(_gap, _gap, _leftUpWidth, _leftUpHeight);
        _scrollView.delegate = self;
        
        CGPoint p = CGPointMake(0, _leftUpImage.size.height);;
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftUpImage.size.height-_scrollView.frame.size.height);
        [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height-_scrollView.frame.size.height);
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
        
        /********* the second image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+1];
        _scrollView.frame = CGRectMake(_gap, _gap+_leftUpHeight+_gap, _currentWidth-_leftUpWidth-_gap, _currentHeight-_leftUpHeight-_gap);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _leftDownImage.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftDownImage.size.height-_scrollView.frame.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-_scrollView.frame.size.height);
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-(_scrollView.frame.size.height-_leftUpHeight));
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_leftUpWidth, _leftDownImage.size.height-(_scrollView.frame.size.height-_leftUpHeight));
        [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_leftUpWidth, _leftDownImage.size.height);
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
        
        /********* the third image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
        _scrollView.frame = CGRectMake(_gap+_leftUpWidth+_gap, _gap, _currentWidth-_leftUpWidth-_gap, _currentHeight-_leftUpHeight-_gap);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _rightUpImage.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightUpImage.size.height-_leftUpHeight);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_leftUpWidth, _rightUpImage.size.height-_leftUpHeight);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width-_leftUpWidth, _rightUpImage.size.height-_scrollView.frame.size.height);
        [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height-_scrollView.frame.size.height);
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
        
        /********* the fourth image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+3];
        _scrollView.frame = CGRectMake(_gap+_currentWidth-_leftUpWidth, _gap+_currentHeight-_leftUpHeight, _leftUpWidth, _leftUpHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _rightDownImage.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightDownImage.size.height - _scrollView.frame.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height - _scrollView.frame.size.height);
        [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height);
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
        
        /********* the fifth image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+4];
        _scrollView.frame = CGRectMake(_gap+_leftUpWidth+_gap, _gap+_leftUpHeight+_gap, _middleImageWidth, _middleImageHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _middleImage.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _middleImage.size.height - _scrollView.frame.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _middleImage.size.height - _scrollView.frame.size.height);
        [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _middleImage.size.height);
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
            _leftUpImage = [ImageUtil getScaleImage:image withWidth:_leftUpWidth andHeight:_leftUpHeight];
            [self.leftUpPointArray removeAllObjects];
            
            p = CGPointMake(0, _leftUpImage.size.height);;
            [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _leftUpImage.size.height-_scrollView.frame.size.height);
            [self.leftUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _leftUpImage.size.height-_scrollView.frame.size.height);
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
            _leftDownImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-_leftUpWidth-_gap andHeight:_currentHeight-_leftUpHeight-_gap];
            [self.leftDownPointArray removeAllObjects];
            
            p = CGPointMake(0, _leftDownImage.size.height);
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _leftDownImage.size.height-_scrollView.frame.size.height);
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-_scrollView.frame.size.height);
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _leftDownImage.size.height-(_scrollView.frame.size.height-_leftUpHeight));
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_leftUpWidth, _leftDownImage.size.height-(_scrollView.frame.size.height-_leftUpHeight));
            [self.leftDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_leftUpWidth, _leftDownImage.size.height);
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
            
            self.selectedIndex = 1;
        }
            break;
        case 2:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
            [self.imagesArray replaceObjectAtIndex:2 withObject:image];
            _scrollView.originImage = image;
            _rightUpImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-_leftUpWidth-_gap andHeight:_currentHeight-_leftUpHeight-_gap];
            [self.rightUpPointArray removeAllObjects];
            
            p = CGPointMake(0, _rightUpImage.size.height);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _rightUpImage.size.height-_leftUpHeight);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width-_leftUpWidth, _rightUpImage.size.height-_leftUpHeight);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width-_leftUpWidth, _rightUpImage.size.height-_scrollView.frame.size.height);
            [self.rightUpPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightUpImage.size.height-_scrollView.frame.size.height);
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
            
            self.selectedIndex = 2;
        }
            break;
        case 3:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+3];
            [self.imagesArray replaceObjectAtIndex:3 withObject:image];
            _scrollView.originImage = image;
            _rightDownImage = [ImageUtil getScaleImage:image withWidth:_leftUpWidth andHeight:_leftUpHeight];
            [self.rightDownPointArray removeAllObjects];
            
            p = CGPointMake(0, _rightDownImage.size.height);
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _rightDownImage.size.height - _scrollView.frame.size.height);
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height - _scrollView.frame.size.height);
            [self.rightDownPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _rightDownImage.size.height);
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
            
            p = CGPointMake(0, _middleImage.size.height);
            [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _middleImage.size.height - _scrollView.frame.size.height);
            [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _middleImage.size.height - _scrollView.frame.size.height);
            [self.middlePointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _middleImage.size.height);
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
        
        for (NSUInteger i=0; i<self.leftDownPointArray.count; i++) {
            NSValue *_value = [self.leftDownPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_leftDownImage withPoints:_pointArray];
        
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+2)
    {
        for (NSUInteger i=0; i<self.rightUpPointArray.count; i++) {
            NSValue *_value = [self.rightUpPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_rightUpImage withPoints:_pointArray];
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+3)
    {
        for (NSUInteger i=0; i<self.rightDownPointArray.count; i++) {
            NSValue *_value = [self.rightDownPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_rightDownImage withPoints:_pointArray];
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
