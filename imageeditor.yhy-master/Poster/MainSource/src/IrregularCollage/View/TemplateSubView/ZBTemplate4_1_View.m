//
//  ZBTemplate4_1_View.m
//  Collage
//
//  Created by shen on 13-7-5.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBTemplate4_1_View.h"
#import "ZBIrregularCollageScrollView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBTemplate4_1_View()<UIScrollViewDelegate>
{
    float _currentWidth;
    float _currentHeight;
    
    float _minusHeight;
    float _minusWidth;
    float _middleMinusWidth;
    float _middleMinusHeight;
    
    float _gap;
    
    UIImage *_upImage;
    UIImage *_leftImage;
    UIImage *_rightImage;
    UIImage *_downImage;
    
    BOOL _isFirstLoad;
}

@property (nonatomic,strong)NSMutableArray *imagesArray;
@property (nonatomic,strong)NSMutableArray *upPointArray;
@property (nonatomic,strong)NSMutableArray *leftPointArray;
@property (nonatomic,strong)NSMutableArray *rightPointArray;
@property (nonatomic,strong)NSMutableArray *donwPointArray;

@end

@implementation ZBTemplate4_1_View
@synthesize imagesArray = _imagesArray;
@synthesize upPointArray;
@synthesize leftPointArray;
@synthesize rightPointArray;
@synthesize donwPointArray;

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
        self.donwPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        
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
    
    float l = sqrt(_currentWidth*_currentWidth+_currentHeight*_currentHeight);
    _minusHeight = _gap*0.5*l/_currentWidth;
    _minusWidth = _gap*0.5*l/_currentHeight;
    _middleMinusWidth = _gap*0.5*sqrt(2);
    _middleMinusHeight = _gap*0.5*sqrt(2);
}

- (void)loadImages
{
    _upImage = [self.imagesArray objectAtIndex:0];
    _leftImage = [self.imagesArray objectAtIndex:1];
    _rightImage = [self.imagesArray objectAtIndex:2];
    _downImage = [self.imagesArray objectAtIndex:3];
    
    _upImage = [ImageUtil getScaleImage:_upImage withWidth:_currentWidth-_minusWidth*2 andHeight:_currentHeight*0.5-_middleMinusHeight];
    _leftImage = [ImageUtil getScaleImage:_leftImage withWidth:_currentWidth*0.5-_middleMinusWidth andHeight:_currentHeight-2*_minusHeight];
    _rightImage = [ImageUtil getScaleImage:_rightImage withWidth:_currentWidth*0.5-_middleMinusWidth andHeight:_currentHeight-2*_minusHeight];
    _downImage = [ImageUtil getScaleImage:_downImage withWidth:_currentWidth-_minusWidth*2 andHeight:_currentHeight*0.5-_middleMinusHeight];
}

- (void)createScrollView
{
    /********* the firt image ***************/
    ZBIrregularCollageScrollView *_scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_minusWidth, _gap, _currentWidth-_minusWidth*2, _currentHeight*0.5-_middleMinusHeight)];
    _scrollView.delegate = self;
    _scrollView.tag = kIrregularScrollViewStartTag;
    _scrollView.originImage = [self.imagesArray objectAtIndex:0];
    
    CGPoint p = CGPointMake(0, _upImage.size.height);;
    [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(_scrollView.frame.size.width*0.5, _upImage.size.height-_scrollView.frame.size.height);
    [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(_scrollView.frame.size.width, _upImage.size.height);
    [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
    
    _scrollView.imageView.image = [ImageUtil getSpecialImage:_upImage withPoints:self.upPointArray];
    _scrollView.imageView.frame = CGRectMake(0, 0, _upImage.size.width, _upImage.size.height);
    _scrollView.contentSize = CGSizeMake(_upImage.size.width, _upImage.size.height);
    
    [self addSubview:_scrollView];
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the second image ***************/
    _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap+_minusHeight, _currentWidth*0.5-_middleMinusWidth, _currentHeight-2*_minusHeight)];
    _scrollView.delegate = self;
    _scrollView.tag = kIrregularScrollViewStartTag+1;
    _scrollView.originImage = [self.imagesArray objectAtIndex:1];
    
    p = CGPointMake(0, _leftImage.size.height);
    [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(0, _leftImage.size.height-_scrollView.frame.size.height);
    [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height-_scrollView.frame.size.height*0.5);
    [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
    
    _scrollView.imageView.image = [ImageUtil getSpecialImage:_leftImage withPoints:self.leftPointArray];
    _scrollView.imageView.frame = CGRectMake(0, 0, _leftImage.size.width, _leftImage.size.height);
    _scrollView.contentSize = CGSizeMake(_leftImage.size.width, _leftImage.size.height);

   
    [self addSubview:_scrollView];
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
    
    /********* the third image ***************/
    _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_currentWidth*0.5+_middleMinusWidth, _gap+_minusHeight, _currentWidth*0.5-_middleMinusHeight, _currentHeight-2*_minusHeight)];
    _scrollView.delegate = self;
    _scrollView.tag = kIrregularScrollViewStartTag+2;
    _scrollView.originImage = [self.imagesArray objectAtIndex:2];
    
    p = CGPointMake(0, _rightImage.size.height-_scrollView.frame.size.height*0.5);
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
    
    /********* the fourth image ***************/
    _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_minusWidth, _gap+_currentHeight*0.5+_middleMinusHeight, _currentWidth-_minusWidth*2, _currentHeight*0.5-_middleMinusHeight)];
    _scrollView.delegate = self;
    _scrollView.tag = kIrregularScrollViewStartTag+3;
    _scrollView.originImage = [self.imagesArray objectAtIndex:3];
    
    p = CGPointMake(0, _downImage.size.height - _scrollView.frame.size.height);
    [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(_scrollView.frame.size.width, _downImage.size.height - _scrollView.frame.size.height);
    [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
    p = CGPointMake(_scrollView.frame.size.width*0.5, _downImage.size.height);
    [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
    
    _scrollView.imageView.image = [ImageUtil getSpecialImage:_downImage withPoints:self.donwPointArray];
    _scrollView.imageView.frame = CGRectMake(0, 0, _downImage.size.width, _downImage.size.height);
    _scrollView.contentSize = CGSizeMake(_downImage.size.width, _downImage.size.height);
    
    [self addSubview:_scrollView];
    
    //set image to the middle
    [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
}

- (void)loadScrollViews
{
    for (NSUInteger i=0; i<4; i++) {
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+i];
        _scrollView.delegate = nil;
    }
    [self.upPointArray removeAllObjects];
    [self.leftPointArray removeAllObjects];
    [self.rightPointArray removeAllObjects];
    [self.donwPointArray removeAllObjects];
    
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset;

    if (self.imagesArray.count == 4) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag];
        _scrollView.frame = CGRectMake(_gap+_minusWidth, _gap, _currentWidth-_minusWidth*2, _currentHeight*0.5-_middleMinusHeight);
        _scrollView.delegate = self;
        
        //重新存储位置信息
        CGPoint p = CGPointMake(0, _upImage.size.height);;
        [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.5, _upImage.size.height-_scrollView.frame.size.height);
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
        _scrollView.frame = CGRectMake(_gap, _gap+_minusHeight, _currentWidth*0.5-_middleMinusWidth, _currentHeight-2*_minusHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _leftImage.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftImage.size.height-_scrollView.frame.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height-_scrollView.frame.size.height*0.5);
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
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the third image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
        _scrollView.frame = CGRectMake(_gap+_currentWidth*0.5+_middleMinusWidth, _gap+_minusHeight, _currentWidth*0.5-_middleMinusHeight, _currentHeight-2*_minusHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _rightImage.size.height-_scrollView.frame.size.height*0.5);
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
        
        /********* the fourth image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+3];
        _scrollView.frame = CGRectMake(_gap+_minusWidth, _gap+_currentHeight*0.5+_middleMinusHeight, _currentWidth-_minusWidth*2, _currentHeight*0.5-_middleMinusHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(0, _downImage.size.height - _scrollView.frame.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _downImage.size.height - _scrollView.frame.size.height);
        [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width*0.5, _downImage.size.height);
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
    NSUInteger _selectedIndex = 0;
    for (NSUInteger i=0; i<4; i++) {
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
            _upImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-_minusWidth*2 andHeight:_currentHeight*0.5-_middleMinusHeight];
            _scrollView.originImage = image;
            [self.upPointArray removeAllObjects];
            
            p = CGPointMake(0, _upImage.size.height);;
            [self.upPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width*0.5, _upImage.size.height-_scrollView.frame.size.height);
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
            _leftImage = [ImageUtil getScaleImage:image withWidth:_currentWidth*0.5-_middleMinusWidth andHeight:_currentHeight-2*_minusHeight];
            _scrollView.originImage = image;
            [self.leftPointArray removeAllObjects];
            
            p = CGPointMake(0, _leftImage.size.height);
            [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(0, _leftImage.size.height-_scrollView.frame.size.height);
            [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height-_scrollView.frame.size.height*0.5);
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
            _rightImage = [ImageUtil getScaleImage:image withWidth:_currentWidth*0.5-_middleMinusWidth andHeight:_currentHeight-2*_minusHeight];
            _scrollView.originImage = image;
            [self.rightPointArray removeAllObjects];
            
            p = CGPointMake(0, _rightImage.size.height-_scrollView.frame.size.height*0.5);
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
            
            self.selectedIndex = 2;
        }
            break;
        case 3:
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+3];
            [self.imagesArray replaceObjectAtIndex:3 withObject:image];
            _downImage = [ImageUtil getScaleImage:image withWidth:_currentWidth-_minusWidth*2 andHeight:_currentHeight*0.5-_middleMinusHeight];
            _scrollView.originImage = image;
            [self.donwPointArray removeAllObjects];
            
            p = CGPointMake(0, _downImage.size.height - _scrollView.frame.size.height);
            [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width, _downImage.size.height - _scrollView.frame.size.height);
            [self.donwPointArray addObject:[NSValue valueWithCGPoint:p]];
            p = CGPointMake(_scrollView.frame.size.width*0.5, _downImage.size.height);
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
            
            self.selectedIndex = 3;
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
        for (NSUInteger i=0; i<self.donwPointArray.count; i++) {
            NSValue *_value = [self.donwPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil getSpecialImage:_downImage withPoints:_pointArray];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    scrollView.decelerationRate = 0;
}

@end
