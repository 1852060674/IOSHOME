//
//  ZBTemplate3_3_View.m
//  Collage
//
//  Created by shen on 13-7-15.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBTemplate3_3_View.h"
#import "ZBIrregularCollageScrollView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBTemplate3_3_View()<UIScrollViewDelegate>
{
    float _currentWidth;
    float _currentHeight;
    
    float _radius;
    float _middleHeight;
    
    float _gap;
    BOOL _isFirstLoad;
    
    UIImage *_leftImage;
    UIImage *_middleImage;
    UIImage *_rightImage;
    
    BOOL _isReplace;
}

@property (nonatomic,strong)NSMutableArray *imagesArray;
@property (nonatomic,strong)NSMutableArray *leftPointArray;
@property (nonatomic,strong)NSMutableArray *rightPointArray;

@end


@implementation ZBTemplate3_3_View

@synthesize imagesArray = _imagesArray;
@synthesize leftPointArray;
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
        self.leftPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.rightPointArray = [[NSMutableArray alloc] initWithCapacity:2];
        
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
    if (_currentWidth<_currentHeight) {
        _radius = _currentWidth*0.25;
    }
    else
        _radius = _currentHeight*0.25;
    _middleHeight = (_currentHeight - 2*_radius - 2*_gap)*0.5;
}

- (void)loadImages
{
    _leftImage = [self.imagesArray objectAtIndex:0];
    _middleImage = [self.imagesArray objectAtIndex:1];
    _rightImage = [self.imagesArray objectAtIndex:2];
    
    _leftImage = [ImageUtil getScaleImage:_leftImage withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight];
    _middleImage = [ImageUtil getScaleImage:_middleImage withWidth:2*_radius andHeight:2*_radius];
    _rightImage = [ImageUtil getScaleImage:_rightImage withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight];
}

- (void)createScrollView
{
    if (self.imagesArray.count == 3) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap, _gap, (_currentWidth-_gap)*0.5, _currentHeight)];
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1;
        _scrollView.tag = kIrregularScrollViewStartTag;
        _scrollView.originImage = [self.imagesArray objectAtIndex:0];
        
        CGPoint p = CGPointMake(0, _leftImage.size.height);;
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftImage.size.height-_scrollView.frame.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height-_scrollView.frame.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height - (_scrollView.frame.size.height - _middleHeight));
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height - _middleHeight);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil draw3_2_Image:_leftImage withPoints:self.leftPointArray withCenter:CGPointMake(_scrollView.frame.size.width+0.5*_gap, _leftImage.size.height-_scrollView.frame.size.height*0.5) radius:(_radius+_gap) startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:NO];
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftImage.size.width, _leftImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftImage.size.width, _leftImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the second image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_currentWidth*0.5-_radius, _gap+_middleHeight+_gap, 2*_radius, 2*_radius)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+1;
        _scrollView.originImage = [self.imagesArray objectAtIndex:1];
        
        _scrollView.imageView.image = [ImageUtil drawCircle:_middleImage withCenter:CGPointMake(_scrollView.frame.size.width*0.5, (_middleImage.size.height-_scrollView.frame.size.height*0.5)) radius:_radius startAngle:-M_PI endAngle:M_PI clockwise:YES];
        _scrollView.imageView.frame = CGRectMake(0, 0, _middleImage.size.width, _middleImage.size.height);
        _scrollView.contentSize = CGSizeMake(_middleImage.size.width, _middleImage.size.height);
        [self addSubview:_scrollView];
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the third image ***************/
        _scrollView = [[ZBIrregularCollageScrollView alloc] initWithFrame:CGRectMake(_gap+_currentWidth*0.5+_gap*0.5, _gap, (_currentWidth-_gap)*0.5, _currentHeight)];
        _scrollView.delegate = self;
        _scrollView.tag = kIrregularScrollViewStartTag+2;
        _scrollView.originImage = [self.imagesArray objectAtIndex:2];
        
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height-_scrollView.frame.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height-_scrollView.frame.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height - (_scrollView.frame.size.height - _middleHeight));
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height - _middleHeight);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        _scrollView.imageView.image = [ImageUtil draw3_2_Image:_rightImage withPoints:self.rightPointArray withCenter:CGPointMake(-_gap*0.5, _rightImage.size.height-_scrollView.frame.size.height*0.5) radius:(_radius+_gap) startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES];
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
    [self.leftPointArray removeAllObjects];
    [self.rightPointArray removeAllObjects];
    
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    CGPoint _currentOffset;
    
    if (self.imagesArray.count == 3) {
        /********* the firt image ***************/
        ZBIrregularCollageScrollView *_scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag];
        _scrollView.frame = CGRectMake(_gap, _gap, (_currentWidth-_gap)*0.5, _currentHeight);
        _scrollView.delegate = self;
        
        CGPoint p = CGPointMake(0, _leftImage.size.height);;
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _leftImage.size.height-_scrollView.frame.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height-_scrollView.frame.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height - (_scrollView.frame.size.height - _middleHeight));
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height - _middleHeight);
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
        _scrollView.imageView.image = [ImageUtil draw3_2_Image:_leftImage withPoints:_pointArray withCenter:CGPointMake(_scrollView.frame.size.width+0.5*_gap +_currentOffset.x, _leftImage.size.height-_scrollView.frame.size.height*0.5-_currentOffset.y) radius:(_radius+_gap) startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:NO];
        
        _scrollView.imageView.frame = CGRectMake(0, 0, _leftImage.size.width, _leftImage.size.height);
        _scrollView.contentSize = CGSizeMake(_leftImage.size.width, _leftImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the second image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+1];
        _scrollView.frame = CGRectMake(_gap+_currentWidth*0.5-_radius, _gap+_middleHeight+_gap, 2*_radius, 2*_radius);
        _scrollView.delegate = self;
        
        _currentOffset = _scrollView.contentOffset;
        _scrollView.imageView.image = [ImageUtil drawCircle:_middleImage withCenter:CGPointMake(_scrollView.frame.size.width*0.5+_currentOffset.x, _middleImage.size.height-_scrollView.frame.size.height*0.5-_currentOffset.y) radius:_radius startAngle:-M_PI endAngle:M_PI clockwise:YES];
        
        _scrollView.imageView.frame = CGRectMake(0, 0, _middleImage.size.width, _middleImage.size.height);
        _scrollView.contentSize = CGSizeMake(_middleImage.size.width, _middleImage.size.height);
        
        //set image to the middle
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_scrollView.frame.size.width)/2, (_scrollView.contentSize.height-_scrollView.frame.size.height)/2)];
        
        /********* the third image ***************/
        _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
        _scrollView.frame = CGRectMake(_gap+_currentWidth*0.5+_gap*0.5, _gap, (_currentWidth-_gap)*0.5, _currentHeight);
        _scrollView.delegate = self;
        
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height-_scrollView.frame.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height-_scrollView.frame.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height - (_scrollView.frame.size.height - _middleHeight));
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height - _middleHeight);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(0, _rightImage.size.height);
        [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
        
        [_pointArray removeAllObjects];
        _currentOffset = _scrollView.contentOffset;
        for (NSUInteger i=0; i<self.rightPointArray.count; i++) {
            NSValue *_value = [self.rightPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        _scrollView.imageView.image = [ImageUtil draw3_2_Image:_rightImage withPoints:_pointArray withCenter:CGPointMake(-_gap*0.5+_currentOffset.x, _rightImage.size.height-_scrollView.frame.size.height*0.5-_currentOffset.y) radius:(_radius+_gap) startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES];
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
    
    if (_scrollView.isSelected)
    {
        if (_isReplace) {
            [self.imagesArray replaceObjectAtIndex:0 withObject:image];
            _leftImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight];
        }
        else
        {
            
            if (image.size.width<_scrollView.frame.size.width || image.size.height<_scrollView.frame.size.height) {
                _leftImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight];
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
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height-_scrollView.frame.size.height);
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height - (_scrollView.frame.size.height - _middleHeight));
        [self.leftPointArray addObject:[NSValue valueWithCGPoint:p]];
        p = CGPointMake(_scrollView.frame.size.width, _leftImage.size.height - _middleHeight);
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
        _scrollView.imageView.image = [ImageUtil draw3_2_Image:_leftImage withPoints:_pointArray withCenter:CGPointMake(_scrollView.frame.size.width+0.5*_gap +_currentOffset.x, _leftImage.size.height-_scrollView.frame.size.height*0.5-_currentOffset.y) radius:(_radius+_gap) startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:NO];
        
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
                _middleImage = [ImageUtil getScaleImage:image withWidth:2*_radius andHeight:2*_radius];
            }
            else
            {
                
                if (image.size.width<_scrollView.frame.size.width || image.size.height<_scrollView.frame.size.height) {
                    _middleImage = [ImageUtil getScaleImage:image withWidth:2*_radius andHeight:2*_radius];
                }
                else
                    _middleImage = image;
            }
            
            _scrollView.originImage = image;
            
            
            _currentOffset = _scrollView.contentOffset;
            _scrollView.imageView.image = [ImageUtil drawCircle:_middleImage withCenter:CGPointMake(_scrollView.frame.size.width*0.5+_currentOffset.x, _middleImage.size.height-_scrollView.frame.size.height*0.5-_currentOffset.y) radius:_radius startAngle:-M_PI endAngle:M_PI clockwise:YES];
            
            _scrollView.imageView.frame = CGRectMake(0, 0, _middleImage.size.width, _middleImage.size.height);
            _scrollView.contentSize = CGSizeMake(_middleImage.size.width, _middleImage.size.height);
            
            _scrollView.isSelected = NO;
            self.selectedIndex = 1;
        }
        else
        {
            _scrollView = (ZBIrregularCollageScrollView*)[self viewWithTag:kIrregularScrollViewStartTag+2];
            if (_scrollView.isSelected) {
                if (_isReplace) {
                    [self.imagesArray replaceObjectAtIndex:2 withObject:image];
                    _rightImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight];
                }
                else
                {
                    
                    if (image.size.width<_scrollView.frame.size.width || image.size.height<_scrollView.frame.size.height) {
                        _rightImage = [ImageUtil getScaleImage:image withWidth:(_currentWidth-_gap)*0.5 andHeight:_currentHeight];
                    }
                    else
                        _rightImage = image;
                }
                
                _scrollView.originImage = image;
                [self.rightPointArray removeAllObjects];
                
                
                p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height);
                [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
                p = CGPointMake(_scrollView.frame.size.width, _rightImage.size.height-_scrollView.frame.size.height);
                [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
                p = CGPointMake(0, _rightImage.size.height-_scrollView.frame.size.height);
                [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
                p = CGPointMake(0, _rightImage.size.height - (_scrollView.frame.size.height - _middleHeight));
                [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
                p = CGPointMake(0, _rightImage.size.height - _middleHeight);
                [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
                p = CGPointMake(0, _rightImage.size.height);
                [self.rightPointArray addObject:[NSValue valueWithCGPoint:p]];
                
                [_pointArray removeAllObjects];
                _currentOffset = _scrollView.contentOffset;
                for (NSUInteger i=0; i<self.rightPointArray.count; i++) {
                    NSValue *_value = [self.rightPointArray objectAtIndex:i];
                    CGPoint _point = [_value CGPointValue];
                    _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
                    [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
                }
                
                _scrollView.imageView.image = [ImageUtil draw3_2_Image:_rightImage withPoints:_pointArray withCenter:CGPointMake(-_gap*0.5+_currentOffset.x, _rightImage.size.height-_scrollView.frame.size.height*0.5-_currentOffset.y) radius:(_radius+_gap) startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES];
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
        
        for (NSUInteger i=0; i<self.leftPointArray.count; i++) {
            NSValue *_value = [self.leftPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil draw3_2_Image:_leftImage withPoints:_pointArray withCenter:CGPointMake(scrollView.frame.size.width+0.5*_gap +_currentOffset.x, _leftImage.size.height-scrollView.frame.size.height*0.5-_currentOffset.y) radius:(_radius+_gap) startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:NO];
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+1)
    {
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil drawCircle:_middleImage withCenter:CGPointMake(scrollView.frame.size.width*0.5+_currentOffset.x, _middleImage.size.height-scrollView.frame.size.height*0.5-_currentOffset.y) radius:_radius startAngle:-M_PI endAngle:M_PI clockwise:YES];
        
    }
    else if(scrollView.tag == kIrregularScrollViewStartTag+2)
    {
        for (NSUInteger i=0; i<self.rightPointArray.count; i++) {
            NSValue *_value = [self.rightPointArray objectAtIndex:i];
            CGPoint _point = [_value CGPointValue];
            _point = CGPointMake(_point.x+_currentOffset.x, _point.y-_currentOffset.y);
            [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
        }
        
        ((ZBIrregularCollageScrollView*)scrollView).imageView.image = [ImageUtil draw3_2_Image:_rightImage withPoints:_pointArray withCenter:CGPointMake(-_gap*0.5+_currentOffset.x, _rightImage.size.height-scrollView.frame.size.height*0.5-_currentOffset.y) radius:(_radius+_gap) startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES];
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
//    //缩放操作中被调用
//    scrollView.contentOffset = CGPointZero;
//}
//
//
////用户进行缩放时会得到通知，缩放比例表示为一个浮点数，作为参数传递
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//    //    NSLog(@"scale %f",scale);
//    [scrollView setZoomScale:scale animated:YES];
//    
//    //缩放操作中被调用
//    _isReplace = NO;
//    if (scrollView.tag == kIrregularScrollViewStartTag) {
//        
//        _leftImage = [ImageUtil scaleImage:[self.imagesArray objectAtIndex:0] toScale:scale];
//        ((ZBIrregularCollageScrollView*)scrollView).isSelected = YES;
//        [self setSelectedImage:_leftImage];
//        
//    }
//    else if(scrollView.tag == kIrregularScrollViewStartTag+1)
//    {
//        
//        _middleImage = [ImageUtil scaleImage:[self.imagesArray objectAtIndex:1] toScale:scale];
//        ((ZBIrregularCollageScrollView*)scrollView).isSelected = YES;
//        [self setSelectedImage:_middleImage];
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

@end
