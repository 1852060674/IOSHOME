//
//  BHPresentTemplateView.m
//  PicFrame
//
//  Created by shen Lv on 13-6-3.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHPresentTemplateView.h"
#import "ZBAppDelegate.h"
#import "MRZoomScrollView.h"
#import "BHButton.h"
#import "BHDragView.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageUtil.h"
#import "ZBCommonMethod.h"

#import "ZBIrregularView.h"
#import "ZBTemplate2_1_View.h"
#import "ZBTemplate2_2_View.h"
#import "ZBTemplate3_1_View.h"
#import "ZBTemplate3_2_View.h"
#import "ZBTemplate3_3_View.h"
#import "ZBTemplate3_4_View.h"
#import "ZBTemplate3_5_View.h"
#import "ZBTemplate4_1_View.h"
#import "ZBTemplate4_2_View.h"
#import "ZBTemplate4_3_View.h"
#import "ZBTemplate5_1_View.h"
#import "ZBTemplate5_2_View.h"
#import "ZBTemplate5_3_View.h"
#import "ZBTemplate5_4_View.h"
#import "ZBTemplate5_5_View.h"
#import "ZBTemplate5_6_View.h"
#import "ZBTemplate5_7_View.h"
#import "ZBTemplate7_1_View.h"

@interface BHPresentTemplateView()<UIActionSheetDelegate,BHScrollViewDelegate, UIGestureRecognizerDelegate>
{
    PicImageTemplateType _picImageTemplateType;
    float _currentTemplateEdgeWidth;
    float _currentTemplateEdgeheigth;
    float _currentTemplateGap;
    
    CGFloat lastScale ;
    CGFloat _currentScale;
    BOOL _isInTheGap;
    CGPoint _firstPoint;
    BOOL _isHorizontal;
    ZBIrregularView *_irregularView;
    BOOL _isRegularTemplate;
}

@property (nonatomic, assign) NSInteger imagesInTemplate; //模板里面有多少张图片
@property (nonatomic, strong) NSMutableArray *rectArray; //保存图片位置的数组
@property (nonatomic, assign) NSInteger currentSelectedButtonTag;
@property (nonatomic, strong) UIImage *currentEditImage;
@property (nonatomic, strong) NSMutableArray *selectedImagesArray;
@property (nonatomic, strong) NSMutableArray *leftOrUpButtonArray;
@property (nonatomic, strong) NSMutableArray *rightOrDownButtonArray;
@property (nonatomic, strong) MRZoomScrollView *activeScrollView;
//@property (nonatomic, strong) BHDragView *activeDragView;

//根据模板类型，判断可以放入多少张图片，并且确定每张图片的位置
- (void)determineTheTypeOfTemplate;

- (void)hiddeRegularTemplate;

- (void)showRegularTemplate;

@end

@implementation BHPresentTemplateView

@synthesize imagesInTemplate = _imagesInTemplate;
@synthesize rectArray = _rectArray;
@synthesize delegate;
@synthesize selectedImage = _selectedImage;
@synthesize currentSelectedButtonTag = _currentSelectedButtonTag;
@synthesize currentEditImage = _currentEditImage;
@synthesize photoFrame = _photoFrame;
@synthesize selectedImagesDic = _selectedImagesDic;
@synthesize selectedImagesArray = _selectedImagesArray;
@synthesize leftOrUpButtonArray = _leftOrUpButtonArray;
@synthesize rightOrDownButtonArray = _rightOrDownButtonArray;
@synthesize activeScrollView;
//@synthesize dragViewArray = _dragViewArray;
//@synthesize activeDragView = _activeDragView;

- (void)dealloc
{
    [self.rectArray removeAllObjects];
    [self.selectedImagesArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangeBackGroundImage object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSelectedAnImage object:nil];
}

- (id)initWithFrame:(CGRect)frame withSelectedImages:(NSArray*)imagesArray
{
    self = [super initWithFrame:frame];
    if (self) {
//        _picImageTemplateType = type;
        _currentTemplateEdgeWidth = kTemplateEdge;
        _currentTemplateEdgeheigth = kTemplateEdge;
        _currentTemplateGap = kTemplateGap;
        if (IS_IPAD)
        {
            _currentTemplateGap = 10;
            _currentTemplateEdgeWidth = (kScreenWidth-2*_currentTemplateGap);
            _currentTemplateEdgeheigth = _currentTemplateEdgeWidth;
        }
        _currentScale = 1.0;
        _isInTheGap = NO;
        _isRegularTemplate = YES;

        self.backgroundColor = [UIColor whiteColor];
        
        _rectArray = [[NSMutableArray alloc] initWithCapacity:3];
        self.selectedImagesDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        self.selectedImagesArray = [[NSMutableArray alloc] initWithCapacity:1];
        [self.selectedImagesArray addObjectsFromArray:imagesArray];
        self.leftOrUpButtonArray = [[NSMutableArray alloc] initWithCapacity:1];
        self.rightOrDownButtonArray = [[NSMutableArray alloc] initWithCapacity:1];
        
        [self selectAnTemplate];
        
        [self presentTemplate];
        [self presentSelectedImages];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.photoFrame = imageView;
        [self addSubview:self.photoFrame];
//        [self sendSubviewToBack:self.photoFrame];
        
//        if (![ZBCommonMethod isShowRegularTemplateInFont] && (imagesArray.count!=1 && imagesArray.count!=2 && imagesArray.count != 6))
//        {
//            [self showIrregularTemplate:[ZBCommonMethod getTemplateIndex:MIN(imagesArray.count, 7)]+[ZBCommonMethod getRegularTemplateCountWithImagesCount:MIN(imagesArray.count, 7)]];
//        }
        
        //监听背景变化信息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBackgroundImage:) name:kChangeBackGroundImage object:nil];
    }
    return self;
}

- (void)selectAnTemplate
{
    NSUInteger _showImagesCount = MIN(7, self.selectedImagesArray.count);
    switch (_showImagesCount)
    {
        case 1:
        {
            _picImageTemplateType = PicImageTemplateType1;
        }
            break;
        case 2:
        {
            _picImageTemplateType = PicImageTemplateType2_1;
        }
            break;
        case 3:
        {
            _picImageTemplateType = PicImageTemplateType3_1;
        }
            break;
        case 4:
        {
            _picImageTemplateType = PicImageTemplateType4_1;
        }
            break;
        case 5:
        {
            _picImageTemplateType = PicImageTemplateType5_1;
        }
            break;
        case 6:
        {
            _picImageTemplateType = PicImageTemplateType6_1;
        }
            break;
        case 7:
        {
            _picImageTemplateType = PicImageTemplateType7_1;
        }
            break;
        default:
            break;
    }
    
    [self determineTheTypeOfTemplate];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (void)setBackgroundImage:(NSString*)imageName
{
    UIImage *_backgroundImage = [ImageUtil loadResourceImage:imageName];
    self.backgroundColor = [UIColor colorWithPatternImage:_backgroundImage];
}

//把历史选择的图片在新选择的模板里面重新展现
- (void)presentSelectedImages
{
    NSInteger _selectedImagesCount = 0;
    
    if (self.selectedImagesDic.count>0 && self.selectedImagesDic.count == self.rectArray.count)
    {
        [self.selectedImagesArray removeAllObjects];
        for (NSInteger i=0; i<10; i++)
        {
            UIImage *_image = [self.selectedImagesDic objectForKey:[NSNumber numberWithInt:(kStartButtonTag+i)]];
            if (nil != _image) {
                [self.selectedImagesArray addObject:_image];
            }
        }
        _selectedImagesCount = MIN(7, self.selectedImagesDic.count);
    }
    else
        _selectedImagesCount = MIN(7, self.selectedImagesArray.count);
    
    for (NSInteger i=0; i<_selectedImagesCount; i++)
    {
        UIButton *_selectedButton = (UIButton*)[self viewWithTag:(kStartButtonTag+i)];
        UIImage *selectedImage = [self.selectedImagesArray objectAtIndex:i];
        
        MRZoomScrollView *_zoomScrollView = (MRZoomScrollView*)[_selectedButton viewWithTag:(_selectedButton.tag-kStartButtonTag+kStartScrollViewTag)];
        if (nil == _zoomScrollView) {
            
            _zoomScrollView = [[MRZoomScrollView alloc]init];
            
            _zoomScrollView.tag = _selectedButton.tag-kStartButtonTag+kStartScrollViewTag;
            [_selectedButton addSubview:_zoomScrollView];
            _zoomScrollView.myDelegate = self;
            _zoomScrollView.imageView.tag = _selectedButton.tag-kStartButtonTag+kStartImageViewTag;
            
            //添加或更改图片到dic
            [self.selectedImagesDic setObject:selectedImage forKey:[NSNumber numberWithInteger:_selectedButton.tag]];
            
            //            UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]
            //
            //                                                         initWithTarget:self action:@selector(scale:)];
            //            [pinchRecognizer setDelegate:self];
            //            [_zoomScrollView.imageView addGestureRecognizer:pinchRecognizer];
        }
        else
        {
            _zoomScrollView.imageView.image = selectedImage;
        }
        _zoomScrollView.frame = CGRectMake(0, 0, _selectedButton.frame.size.width, _selectedButton.frame.size.height);
        [_zoomScrollView setImageViewImage:selectedImage];
        [_zoomScrollView setContentOffset:CGPointMake((_zoomScrollView.contentSize.width-_selectedButton.frame.size.width)/2, (_zoomScrollView.contentSize.height-_selectedButton.frame.size.height)/2)];
        
        UITapGestureRecognizer *_doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleThisPic:)];
        [_zoomScrollView.imageView addGestureRecognizer:_doubleTapRecognizer];
        // 双击的 Recognizer
        _doubleTapRecognizer.numberOfTapsRequired = 2; // 
    }
}

//根据每张图片的位置，展现模板
- (void)presentTemplate
{
    if (self.imagesInTemplate<1 || self.rectArray.count<1) {
        return;
    }
    
    for (NSInteger i=0; i<self.rectArray.count; i++)
    {
        BHButton *_button = (BHButton*)[self viewWithTag:kStartButtonTag+i];
        if (nil == _button) {
            _button = [BHButton buttonWithType:UIButtonTypeCustom];
            _button.tag = kStartButtonTag+i;
            _button.backgroundColor = [UIColor clearColor];
            [self addSubview:_button];
            [_button addTarget:self action:@selector(selectAnImage:) forControlEvents:UIControlEventTouchUpInside];
        }
        CGRect rect;
        [[self.rectArray objectAtIndex:i] getValue:&rect];
        _button.frame = rect;
        _button.cententPoint = CGPointMake(rect.size.width/2, rect.size.height/2);
    }
}

- (void)showIrregularTemplate:(NSUInteger)templateIndex
{
    _isRegularTemplate = NO;
    if (nil != _irregularView) {
        [_irregularView removeFromSuperview];
    }
    [self hiddeRegularTemplate];
    if (templateIndex==7) {
        _irregularView = [[ZBTemplate2_1_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if (templateIndex==8) {
        _irregularView = [[ZBTemplate2_2_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if (templateIndex==25) {
        _irregularView = [[ZBTemplate3_1_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex == 26)
    {
        _irregularView = [[ZBTemplate3_2_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex == 27)
    {
        _irregularView = [[ZBTemplate3_3_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex == 28)
    {
        _irregularView = [[ZBTemplate3_4_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex == 29)
    {
        _irregularView = [[ZBTemplate3_5_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex==55)
    {
        _irregularView = [[ZBTemplate4_1_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex==56)
    {
        _irregularView = [[ZBTemplate4_2_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }

    else if(templateIndex==57)
    {
        _irregularView = [[ZBTemplate4_3_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }

    else if(templateIndex==89)
    {
        _irregularView = [[ZBTemplate5_1_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex==90)
    {
        _irregularView = [[ZBTemplate5_2_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex==91)
    {
        _irregularView = [[ZBTemplate5_3_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex==92)
    {
        _irregularView = [[ZBTemplate5_4_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex==93)
    {
        _irregularView = [[ZBTemplate5_5_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex==94)
    {
        _irregularView = [[ZBTemplate5_6_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex==95)
    {
        _irregularView = [[ZBTemplate5_7_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    else if(templateIndex==104)
    {
        _irregularView = [[ZBTemplate7_1_View alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withImagesArray:self.selectedImagesArray];
        [self addSubview:_irregularView];
    }
    
    _irregularView.backgroundColor = self.backgroundColor;
    
    if (self.photoFrame != nil) {
        [self bringSubviewToFront:self.photoFrame];
    }
}

- (void)hiddeRegularTemplate
{
    for (UIView *aView in self.subviews) {
        if ([aView isKindOfClass:[BHButton class]]) {
            aView.hidden = YES;
        }
    }
}

- (void)showRegularTemplate
{
    if (nil != _irregularView) {
        [_irregularView removeFromSuperview];
    }
    _isRegularTemplate = YES;
    for (UIView *aView in self.subviews) {
        if ([aView isKindOfClass:[BHButton class]]) {
            aView.hidden = NO;
        }
    }
}

//根据选择的ascpect，调整模板里面的布局
- (void)adjustFrameSize:(float)width withHeight:(float)height
{
    _currentTemplateEdgeWidth = width;
    _currentTemplateEdgeheigth = height;
    self.photoFrame.frame = CGRectMake(0, 0, width, height);
    [self.rectArray removeAllObjects];
    [self determineTheTypeOfTemplate];
    
    if (!_isRegularTemplate) {
        _irregularView.frame = CGRectMake(0, 0, _currentTemplateEdgeWidth, _currentTemplateEdgeheigth);
        [_irregularView setNeedsDisplay];
    }
    
    if (self.imagesInTemplate<1 || self.rectArray.count<1) {
        return;
    }
    
    for (NSInteger i=0; i<self.rectArray.count; i++) {
        UIButton *_button = (UIButton*)[self viewWithTag:(kStartButtonTag+i)];
        MRZoomScrollView *_scrollView = (MRZoomScrollView*)[_button viewWithTag:(kStartScrollViewTag+i)];
        CGRect rect;
        [[self.rectArray objectAtIndex:i] getValue:&rect];
        _button.frame = rect;
        _scrollView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        [_scrollView setImageViewImage:_scrollView.imageView.image];
        [_scrollView setContentOffset:CGPointMake((_scrollView.contentSize.width-_button.frame.size.width)/2, (_scrollView.contentSize.height-_button.frame.size.height)/2)];
        
    }
    
    float _scaleX = width/self.frame.size.width;
    float _scaleY = height/self.frame.size.height;
    for (UIView *_aView in [self subviews]) {
        if ([_aView isKindOfClass:[BHDragView class]]) {
            _aView.frame = CGRectMake(_aView.frame.origin.x*_scaleX, _aView.frame.origin.y*_scaleY, _aView.frame.size.width, _aView.frame.size.height);
        }
    }
}

- (void)changedBorderOrCornerValue:(float)value withChangedType:(SliderChangeType)type
{
    if (type == SliderChangeTypeCorner)
    {
        for (NSUInteger i=0; i<self.rectArray.count; i++)
        {
            UIButton *_button = (UIButton*)[self viewWithTag:(kStartButtonTag+i)];
            _button.layer.cornerRadius = value;
            _button.layer.masksToBounds = YES;
        }
        [self setNeedsDisplay];
    }
    else
    {
        _currentTemplateGap = value;
        [self determineTheTypeOfTemplate];
        [self presentTemplate];
        [self presentSelectedImages];
    }
}

- (void)changeBackgroundImage:(NSNotification*)notification
{
    NSDictionary *_infoDic = [notification object];//获取到传递的对象
    
    CollageType _type = [[_infoDic valueForKey:@"CollageType"] integerValue];
    if (_type != CollageTypeGrid) {
        return;
    }
    
    NSString *_imageName = [_infoDic valueForKey:@"imageIndex"];
    NSInteger index = [_imageName intValue];
    
    _imageName = [NSString stringWithFormat:@"bg%@.png",_imageName];
    
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(canChangeBackground:)]
        && ![self.delegate canChangeBackground:index]) {
        return;
    }
    
    UIImage *_backgroundImage = [ImageUtil loadResourceImage:_imageName];
    self.backgroundColor = [UIColor colorWithPatternImage:_backgroundImage];
}

//用户重新选择模板后，调整图片显示
- (void)adjustTemplate:(NSUInteger)templateIndex
{
    [self showRegularTemplate];
    _picImageTemplateType = templateIndex;
    [self determineTheTypeOfTemplate];
    [self presentTemplate];
    [self presentSelectedImages];
}

//根据模板类型，判断可以放入多少张图片，并且确定每张图片的位置
- (void)determineTheTypeOfTemplate
{
    [_rectArray removeAllObjects];
    CGRect rect;
    switch (_picImageTemplateType) {
        case PicImageTemplateType1:
        {
            self.imagesInTemplate =1;
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = _currentTemplateEdgeWidth-2*_currentTemplateGap;
            rect.size.height = _currentTemplateEdgeheigth - 2*_currentTemplateGap;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType2_1:
        {
            self.imagesInTemplate =2;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = _currentTemplateEdgeheigth-2*_currentTemplateGap;

            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2 + 2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = _currentTemplateEdgeheigth-2*_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType2_2:
        {
            self.imagesInTemplate =2;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = _currentTemplateEdgeWidth-2*_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2 + 2*_currentTemplateGap;
            rect.size.width = _currentTemplateEdgeWidth-2*_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType2_3:
        {
            self.imagesInTemplate =2;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-4*_currentTemplateGap)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-4*_currentTemplateGap)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-4*_currentTemplateGap)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType2_4:
        {
            self.imagesInTemplate =2;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-4*_currentTemplateGap)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-4*_currentTemplateGap)/3*2+3*_currentTemplateGap;;
            rect.size.width = (_currentTemplateEdgeWidth-4*_currentTemplateGap)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType2_5:
        {
            self.imagesInTemplate =2;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = _currentTemplateEdgeWidth-2*_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3 + 2*_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType2_6:
        {
            self.imagesInTemplate =2;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = _currentTemplateEdgeWidth-2*_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2 + 3*_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType3_1:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType3_2:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
        }
            break;
        case PicImageTemplateType3_3:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType3_4:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType3_5:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-2*_currentTemplateGap);
            rect.size.height = (_currentTemplateEdgeheigth-4*_currentTemplateGap)/3*2+_currentTemplateGap;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-4*_currentTemplateGap)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-3*_currentTemplateGap)/2;
            rect.size.height = (_currentTemplateEdgeheigth-4*_currentTemplateGap)/3;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-3*_currentTemplateGap)/2+2*_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType3_6:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = _currentTemplateEdgeWidth-_currentTemplateGap*2;
            rect.size.height = (_currentTemplateEdgeheigth-4*_currentTemplateGap)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-4*_currentTemplateGap)/3 + 2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-3*_currentTemplateGap)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-3*_currentTemplateGap)/2 + 2*_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType3_7:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-4*_currentTemplateGap)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-4*_currentTemplateGap)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-4*_currentTemplateGap)/3*2+_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType3_8:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-3*_currentTemplateGap)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-3*_currentTemplateGap)/2 + 2*_currentTemplateGap;            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = _currentTemplateEdgeWidth-_currentTemplateGap*2;
            rect.size.height = (_currentTemplateEdgeheigth-4*_currentTemplateGap)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType3_9:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = _currentTemplateEdgeWidth-_currentTemplateGap*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType3_10:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
                    break;
        case PicImageTemplateType3_11:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-4*_currentTemplateGap)/3*2+_currentTemplateGap;
            rect.size.height = _currentTemplateEdgeheigth-_currentTemplateGap*2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-4*_currentTemplateGap)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-4*_currentTemplateGap)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2 + 2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType3_12:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-3*_currentTemplateGap)/3;
            rect.size.height = _currentTemplateEdgeheigth-_currentTemplateGap*2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap*2+(_currentTemplateEdgeWidth-3*_currentTemplateGap)/3;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-3*_currentTemplateGap)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap*2+(_currentTemplateEdgeWidth-3*_currentTemplateGap)/3;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2 + 2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-3*_currentTemplateGap)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType3_13:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-4*_currentTemplateGap)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2 + 2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-4*_currentTemplateGap)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-4*_currentTemplateGap)/3*2+_currentTemplateGap;
            rect.size.height = _currentTemplateEdgeheigth-_currentTemplateGap*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType3_14:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-3*_currentTemplateGap)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2 + 2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-3*_currentTemplateGap)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap*2+(_currentTemplateEdgeWidth-3*_currentTemplateGap)/3*2;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-3*_currentTemplateGap)/3;
            rect.size.height = _currentTemplateEdgeheigth-_currentTemplateGap*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType3_15:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3 + 2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth - ((_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap))/2;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2 + 3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType3_16:
        {
            self.imagesInTemplate =3;
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth - ((_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap))/2;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3 + 2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType4_1:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            break;
        }
        case PicImageTemplateType4_2:
        {            
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType4_3:
        {            
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_4:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_5:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType4_6:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType4_7:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType4_8:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType4_9:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType4_10:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_11:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_12:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_13:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_14:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_15:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_16:
        {
            
            
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType4_17:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_18:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_19:
        {            
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_20:
        {
            self.imagesInTemplate =4;
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_21:
        {
            
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType4_22:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType4_23:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType4_24:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4*3+4*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType4_25:
        {
            self.imagesInTemplate =4;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4*3+4*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        
        case PicImageTemplateType5_1:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_2:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x =_currentTemplateGap;
            rect.origin.y =  (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_3:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_4:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_5:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_6:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        
        case PicImageTemplateType5_7:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_8:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_9:
        {
            self.imagesInTemplate =5;
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_10:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_11:
        {
            
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_12:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_13:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_14:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_15:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_16:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_17:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_18:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];


        }
            break;
        case PicImageTemplateType5_19:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_20:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_21:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_22:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_23:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_24:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_25:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
            
        case PicImageTemplateType5_26:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4*3+4*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_27:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4*3+4*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_28:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4*3+4*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*5)/4;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/3*2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_29:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4*3+4*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*5)/4;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3*2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType5_30:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType5_31:
        {
            self.imagesInTemplate =5;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;;
            rect.origin.y = _currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType6_1:
        {
            self.imagesInTemplate =6;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*3)/2;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType6_2:
        {
            self.imagesInTemplate =6;
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*3)/2;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        
        case PicImageTemplateType6_3:
        {
            self.imagesInTemplate =6;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType6_4:
        {
            self.imagesInTemplate =6;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType6_5:
        {
            self.imagesInTemplate =6;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
//            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+2*_currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
//            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
//            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType6_6:
        {
            self.imagesInTemplate =6;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+_currentTemplateGap;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        case PicImageTemplateType7_1:
        {
            self.imagesInTemplate =7;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*2);
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];

        }
            break;
        case PicImageTemplateType7_2:
        {
            self.imagesInTemplate =7;
            
            rect.origin.x = _currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.width = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*2);
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.x = (_currentTemplateEdgeWidth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            rect.origin.y = _currentTemplateGap;
            rect.size.height = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3+2*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
            
            rect.origin.y = (_currentTemplateEdgeheigth-_currentTemplateGap*4)/3*2+3*_currentTemplateGap;
            value = nil;
            value = [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
            [_rectArray addObject:value];
        }
            break;
        default:
            break;
    }
}

- (void)setTemplateBackgroundColor:(UIColor*)color
{
    self.backgroundColor = color;
    _irregularView.backgroundColor = color;
}

#pragma mark -- 手势，图片缩放
-(void)scale:(UIPinchGestureRecognizer*)sender {
    
    UIView *_selectedView = [sender view];
    
    //当手指离开屏幕时,将lastscale设置为1.0
    if([sender state] == UIGestureRecognizerStateEnded) {
        lastScale = 1.0;
        return;
    }
    CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    if (_currentScale<1.0) {
        scale = 1.0;
//        return;
    }
    CGAffineTransform currentTransform = _selectedView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    [_selectedView setTransform:newTransform];
    lastScale = [sender scale];
}

#pragma mark -- button method
- (void)selectAnImage:(id)sender
{
    self.currentSelectedButtonTag = ((UIButton*)sender).tag;
    UIButton *_selectedButton = (UIButton*)[self viewWithTag:self.currentSelectedButtonTag];
    if (self.delegate && [self.delegate respondsToSelector:@selector(openAlbum: withRect:)]) {
        [self.delegate openAlbum:UIImagePickerControllerSourceTypeSavedPhotosAlbum  withRect:_selectedButton.frame];
    }
//    UIActionSheet *aActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"Albums" otherButtonTitles:@"Camera", nil];
//    [aActionSheet showInView:self];
}

- (void)setSelectedImage:(UIImage *)selectedImage
{
    if (_isRegularTemplate) {
        UIButton *_selectedButton = (UIButton*)[self viewWithTag:self.currentSelectedButtonTag];
        
        MRZoomScrollView *_zoomScrollView = (MRZoomScrollView*)[_selectedButton viewWithTag:(self.currentSelectedButtonTag-kStartButtonTag+kStartScrollViewTag)];
        if (nil == _zoomScrollView) {
            
            _zoomScrollView = [[MRZoomScrollView alloc]init];
            _zoomScrollView.frame = CGRectMake(0, 0, _selectedButton.frame.size.width, _selectedButton.frame.size.height);
            _zoomScrollView.tag = self.currentSelectedButtonTag-kStartButtonTag+kStartScrollViewTag;
            _zoomScrollView.myDelegate = self;
            [_selectedButton addSubview:_zoomScrollView];
            
            _zoomScrollView.imageView.tag = self.currentSelectedButtonTag-kStartButtonTag+kStartImageViewTag;
            _zoomScrollView.imageView.image = selectedImage;
        }
        else
        {
            _zoomScrollView.imageView.image = selectedImage;
            
        }
        [_zoomScrollView setImageViewImage:selectedImage];
        [_zoomScrollView setContentOffset:CGPointMake((_zoomScrollView.contentSize.width-_selectedButton.frame.size.width)/2, (_zoomScrollView.contentSize.height-_selectedButton.frame.size.height)/2)];
        
        //添加或更改图片到dic
        [self.selectedImagesDic setObject:selectedImage forKey:[NSNumber numberWithInteger:_selectedButton.tag]];
        [self.selectedImagesArray replaceObjectAtIndex:(_selectedButton.tag-kStartButtonTag) withObject:selectedImage];
        
        UITapGestureRecognizer *_doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleThisPic:)];
        [_zoomScrollView.imageView addGestureRecognizer:_doubleTapRecognizer];
        // 双击的 Recognizer
        _doubleTapRecognizer.numberOfTapsRequired = 2; //

    }
        
    else  {
        [_irregularView setSelectedImage:selectedImage];
        [self.selectedImagesDic setObject:selectedImage forKey:[NSNumber numberWithInteger:_irregularView.selectedIndex+kStartButtonTag]];
        [self.selectedImagesArray replaceObjectAtIndex:_irregularView.selectedIndex withObject:selectedImage];
    }
}


- (void)handleThisPic:(UIGestureRecognizer *)gestureRecognizer
{
    UIImageView *view = (UIImageView*)[gestureRecognizer view];
    self.currentEditImage = view.image;
    int _tagValue = view.tag;
    self.currentSelectedButtonTag = _tagValue-kStartImageViewTag+kStartButtonTag;
//    UIButton *_button = (UIButton*)[self viewWithTag:(_tagValue-kStartImageViewTag+kStartButtonTag)];
//    [self selectAnImage:_button];
    
    UIActionSheet *aActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reselect photo" otherButtonTitles:@"Edit current photo", nil];
    [aActionSheet showInView:self];
}

#pragma mark -- UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIButton *_selectedButton = (UIButton*)[self viewWithTag:self.currentSelectedButtonTag];

    if (buttonIndex == 0)
    {
        //打开相册
       
        if (self.delegate && [self.delegate respondsToSelector:@selector(openAlbum: withRect:)]) {
            [self.delegate openAlbum:UIImagePickerControllerSourceTypeSavedPhotosAlbum  withRect:_selectedButton.frame];
        }
        
    }else if (buttonIndex == 1) {
        //编辑当前选择的图片
        if (self.delegate && [self.delegate respondsToSelector:@selector(editCurrentSelectedImage:)]) {
            [self.delegate editCurrentSelectedImage:self.currentEditImage];
        }
    }
}

#pragma mark -- UILongPressGestureRecognizer
-(void)handleLongPress:(UILongPressGestureRecognizer*)recognizer
{
    //处理长按操作
    NSLog(@"长按, %f", recognizer.minimumPressDuration);

    MRZoomScrollView *_selectedScrollView = (MRZoomScrollView*)[recognizer view];
    if ([_selectedScrollView.superview isKindOfClass:[BHButton class]]) {
        UIView *_scrollSuperView = _selectedScrollView.superview ;
        [_selectedScrollView removeFromSuperview];
        [_scrollSuperView.superview addSubview:_selectedScrollView];
        self.activeScrollView = _selectedScrollView;
        
        [UIView beginAnimations: @"drag" context: nil];
        self.activeScrollView.frame = CGRectMake(_scrollSuperView.frame.origin.x, _scrollSuperView.frame.origin.y, 200, 200);
        self.activeScrollView.alpha = 0.5;
        [UIView commitAnimations];
        
        // 拖移的 Recognizer
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self                                               action:@selector(handlePan:)];
        [_selectedScrollView addGestureRecognizer:panGestureRecognizer];
    }
    else
    {


    }
    
}

- (void)handlePan:(UIPanGestureRecognizer*) recognizer
{
    MRZoomScrollView *_seclectScrollView = (MRZoomScrollView*)recognizer.view;
    if (_seclectScrollView.superview == self) {
//        NSLog(@"拖移，慢速移动");
        CGPoint translation = [recognizer translationInView:self];
        CGPoint _newCenter = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
        for (UIView *_aView in [self subviews]) {
            
        }
        recognizer.view.center = CGPointMake(_newCenter.x, _newCenter.y);
        [recognizer setTranslation:CGPointZero inView:self];
    }
    
}

#pragma mark -- BHScrollViewDelegate
- (void)emergeImageView
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark-- touches

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    _isHorizontal = NO;//NO表示是vertical
	CGPoint locationPoint = [[touches anyObject] locationInView:self];

    CGRect _checkRect1 = CGRectMake(locationPoint.x, 0, 1, self.frame.size.height);//竖线
    CGRect _checkRect2 = CGRectMake(0, locationPoint.y, self.frame.size.width, 1);//横线
    for (UIView *point in self.subviews)
    {
        CGPoint viewPoint = [point convertPoint:locationPoint fromView:self];
        
        if ([point isKindOfClass:[UIImageView class]]) {
            continue;
        }
        
//        if ([point isKindOfClass:[MRZoomScrollView class]]) {
//            
//        }
        
        if ([point pointInside:viewPoint withEvent:event])
        {
            _isInTheGap = NO;
            return;
        }
        
        
        
    }
    
    //边框，则返回不做任何处理
    if (locationPoint.x-_currentTemplateGap<=0 || locationPoint.x+_currentTemplateGap>=self.frame.size.width || locationPoint.y-_currentTemplateGap<=0||locationPoint.y+_currentTemplateGap>=self.frame.size.height)
    {
        return;
    }
    
    //判断当前点左右两边是imageView，还是上下是imageView
    CGPoint _checkPoint = CGPointMake(locationPoint.x+_currentTemplateGap, locationPoint.y);
    for (UIView *point in self.subviews)
    {
        CGPoint viewPoint = [point convertPoint:_checkPoint fromView:self];  //把_checkPoint转换为point上的坐标
        
        if ([point isKindOfClass:[BHButton class]]) {
            if ([point pointInside:viewPoint withEvent:event])
            {
                _isHorizontal = YES;
                break;
            }
        }
    }
    
    if (_isHorizontal) {
        //水平移动
        //先判断右边的矩形
        CGRect rect = CGRectMake(locationPoint.x, 0, 1+_currentTemplateGap, self.frame.size.height);
        for (UIView *_aView in self.subviews) {
            if ([_aView isKindOfClass:[BHButton class]])
            {
                if([_aView isKindOfClass:[BHButton class]])
                {
                    if(CGRectIntersectsRect(_aView.frame,_checkRect1))
                    {
                        _isInTheGap = NO;
                        return;
                    }
                }
                if (CGRectIntersectsRect(rect, _aView.frame))
                {
                    [self.rightOrDownButtonArray addObject:_aView];
                }
            }
        }
        
        rect = CGRectMake(locationPoint.x-_currentTemplateGap, 0, 1+_currentTemplateGap, self.frame.size.height);
        for (UIView *_aView in self.subviews) {
            if ([_aView isKindOfClass:[BHButton class]])
            {
                

                if (CGRectIntersectsRect(rect, _aView.frame))
                {
                    [self.leftOrUpButtonArray addObject:_aView];
                }
            }
        }
    }
    else
    {
        //垂直移动
        //先判断右边的矩形
        CGRect rect = CGRectMake(0, locationPoint.y-_currentTemplateGap, self.frame.size.width, 1+_currentTemplateGap);
        for (UIView *_aView in self.subviews) {
            if ([_aView isKindOfClass:[BHButton class]])
            {
                if(CGRectIntersectsRect(_aView.frame,_checkRect2) )
                {
                    _isInTheGap = NO;
                    return;
                }
                if (CGRectIntersectsRect(rect, _aView.frame))
                {
                    [self.leftOrUpButtonArray addObject:_aView];
                }
            }
        }
        
        rect = CGRectMake(0, locationPoint.y+_currentTemplateGap, self.frame.size.width, 1+_currentTemplateGap);
        for (UIView *_aView in self.subviews) {
            if ([_aView isKindOfClass:[BHButton class]])
            {
                if (CGRectIntersectsRect(rect, _aView.frame))
                {
                    [self.rightOrDownButtonArray addObject:_aView];
                }
            }
        }
    }
    

    _isInTheGap = YES;
    _firstPoint = locationPoint;
}
//
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    for (UIView *_aView in self.subviews)
    {
        if ([_aView isKindOfClass:[MRZoomScrollView class]])
        {
            [UIView beginAnimations: @"drag" context: nil];
            self.activeScrollView.center = [[touches anyObject] locationInView: self.superview];
            [UIView commitAnimations];
        }
    }
    if (!_isInTheGap) {
        return;
    }
	
	NSArray * touchesArr=[[event allTouches] allObjects];
    
    if ([touchesArr count] == 1) {
        CGPoint pt = [[touches anyObject] locationInView:self];
        float dx = pt.x - _firstPoint.x;
        float dy = pt.y - _firstPoint.y;
        
        if (_isHorizontal) {

            for (NSInteger i=0; i<self.rightOrDownButtonArray.count; i++)
            {
                UIView *_aView = [self.rightOrDownButtonArray objectAtIndex:i];
                float w = _aView.frame.size.width -dx;
                if (w<50) {
                    return;
                }
                _aView.frame = CGRectMake(_aView.frame.origin.x+dx, _aView.frame.origin.y, _aView.frame.size.width-dx, _aView.frame.size.height);
                MRZoomScrollView *_scrollView = (MRZoomScrollView*)[_aView viewWithTag:_aView.tag-kStartButtonTag+kStartScrollViewTag];
                _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width-dx, _scrollView.frame.size.height);
                [_scrollView setImageViewImage:_scrollView.imageView.image];

            }
            
            for (NSInteger i=0; i<self.leftOrUpButtonArray.count; i++) {
                UIView *_aView = [self.leftOrUpButtonArray objectAtIndex:i];
                _aView.frame = CGRectMake(_aView.frame.origin.x, _aView.frame.origin.y, _aView.frame.size.width+dx, _aView.frame.size.height);
                MRZoomScrollView *_scrollView = (MRZoomScrollView*)[_aView viewWithTag:_aView.tag-kStartButtonTag+kStartScrollViewTag];
                _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width+dx, _scrollView.frame.size.height);
                [_scrollView setImageViewImage:_scrollView.imageView.image];
            }
        }
        else
        {
            for (NSInteger i=0; i<self.leftOrUpButtonArray.count; i++) {
                UIView *_aView = [self.leftOrUpButtonArray objectAtIndex:i];
                _aView.frame = CGRectMake(_aView.frame.origin.x, _aView.frame.origin.y, _aView.frame.size.width, _aView.frame.size.height+dy);
                MRZoomScrollView *_scrollView = (MRZoomScrollView*)[_aView viewWithTag:_aView.tag-kStartButtonTag+kStartScrollViewTag];
                _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height+dy);
                [_scrollView setImageViewImage:_scrollView.imageView.image];
            }
            
            for (NSInteger i=0; i<self.rightOrDownButtonArray.count; i++)
            {
                UIView *_aView = [self.rightOrDownButtonArray objectAtIndex:i];
                _aView.frame = CGRectMake(_aView.frame.origin.x, _aView.frame.origin.y+dy, _aView.frame.size.width, _aView.frame.size.height-dy);
                MRZoomScrollView *_scrollView = (MRZoomScrollView*)[_aView viewWithTag:_aView.tag-kStartButtonTag+kStartScrollViewTag];
                _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height-dy);
                [_scrollView setImageViewImage:_scrollView.imageView.image];
            }
        }

//        for (UIView *point in self.subviews)
//        {
//            CGPoint viewPoint = [point convertPoint:pt fromView:self];
//            
//            switch (_picImageTemplateType) {
//                case PicImageTemplateType2_1:
//                {
//                    if ([point isKindOfClass:[BHButton class]]) {
//                        if ([point pointInside:viewPoint withEvent:event])
//                        {
//                            if (point.tag == kStartButtonTag+1) {
//                                point.frame = CGRectMake(point.frame.origin.x+dx, point.frame.origin.y, point.frame.size.width-dx, point.frame.size.height);
//                                MRZoomScrollView *_scrollView = (MRZoomScrollView*)[point viewWithTag:point.tag-kStartButtonTag+kStartScrollViewTag];
//                                _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width-dx, _scrollView.frame.size.height);
//                                [_scrollView setImageViewImage:_scrollView.imageView.image];
//
//                                BHButton *_button = (BHButton*)[self viewWithTag:kStartButtonTag];
//                                _button.frame = CGRectMake(_button.frame.origin.x, _button.frame.origin.y, _button.frame.size.width+dx, _button.frame.size.height);
//                                MRZoomScrollView *_scrollView2 = (MRZoomScrollView*)[_button viewWithTag:_button.tag-kStartButtonTag+kStartScrollViewTag];
//                                _scrollView2.frame = CGRectMake(_scrollView2.frame.origin.x, _scrollView2.frame.origin.y, _scrollView2.frame.size.width+dx, _scrollView2.frame.size.height);
//                                [_scrollView2 setImageViewImage:_scrollView2.imageView.image];
//                            }
//                            else
//                            {
//                                point.frame = CGRectMake(point.frame.origin.x, point.frame.origin.y, point.frame.size.width+dx, point.frame.size.height);
//                                MRZoomScrollView *_scrollView = (MRZoomScrollView*)[point viewWithTag:point.tag-kStartButtonTag+kStartScrollViewTag];
//                                _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width+dx, _scrollView.frame.size.height);
//                                [_scrollView setImageViewImage:_scrollView.imageView.image];
//                                
//                                BHButton *_button = (BHButton*)[self viewWithTag:kStartButtonTag+1];
//                                _button.frame = CGRectMake(_button.frame.origin.x+dx, _button.frame.origin.y, _button.frame.size.width-dx, _button.frame.size.height);
//                                MRZoomScrollView *_scrollView2 = (MRZoomScrollView*)[_button viewWithTag:_button.tag-kStartButtonTag+kStartScrollViewTag];
//                                _scrollView2.frame = CGRectMake(_scrollView2.frame.origin.x, _scrollView2.frame.origin.y, _scrollView2.frame.size.width-dx, _scrollView2.frame.size.height);
//                                [_scrollView2 setImageViewImage:_scrollView2.imageView.image];
//                            }
//                            
//                        }
//                    }
//                }
//                    break;
//                case PicImageTemplateType2_2:
//                {
//                    if ([point isKindOfClass:[BHButton class]]) {
//                        if ([point pointInside:viewPoint withEvent:event])
//                        {
//                            if (point.tag == kStartButtonTag+1) {
//                                point.frame = CGRectMake(point.frame.origin.x, point.frame.origin.y+dy, point.frame.size.width, point.frame.size.height-dy);
//                                MRZoomScrollView *_scrollView = (MRZoomScrollView*)[point viewWithTag:point.tag-kStartButtonTag+kStartScrollViewTag];
//                                _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height-dy);
//                                [_scrollView setImageViewImage:_scrollView.imageView.image];
//                                
//                                BHButton *_button = (BHButton*)[self viewWithTag:kStartButtonTag];
//                                _button.frame = CGRectMake(_button.frame.origin.x, _button.frame.origin.y, _button.frame.size.width, _button.frame.size.height+dy);
//                                MRZoomScrollView *_scrollView2 = (MRZoomScrollView*)[_button viewWithTag:_button.tag-kStartButtonTag+kStartScrollViewTag];
//                                _scrollView2.frame = CGRectMake(_scrollView2.frame.origin.x, _scrollView2.frame.origin.y, _scrollView2.frame.size.width, _scrollView2.frame.size.height+dy);
//                                [_scrollView2 setImageViewImage:_scrollView2.imageView.image];
//                            }
//                            else
//                            {
//                                point.frame = CGRectMake(point.frame.origin.x, point.frame.origin.y, point.frame.size.width, point.frame.size.height+dy);
//                                MRZoomScrollView *_scrollView = (MRZoomScrollView*)[point viewWithTag:point.tag-kStartButtonTag+kStartScrollViewTag];
//                                _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height+dy);
//                                [_scrollView setImageViewImage:_scrollView.imageView.image];
//                                
//                                BHButton *_button = (BHButton*)[self viewWithTag:kStartButtonTag+1];
//                                _button.frame = CGRectMake(_button.frame.origin.x, _button.frame.origin.y+dy, _button.frame.size.width, _button.frame.size.height-dy);
//                                MRZoomScrollView *_scrollView2 = (MRZoomScrollView*)[_button viewWithTag:_button.tag-kStartButtonTag+kStartScrollViewTag];
//                                _scrollView2.frame = CGRectMake(_scrollView2.frame.origin.x, _scrollView2.frame.origin.y, _scrollView2.frame.size.width, _scrollView2.frame.size.height-dy);
//                                [_scrollView2 setImageViewImage:_scrollView2.imageView.image];
//                            }
//                            
//                        }
//                    }
//                }
//                    break;
//                default:
//                    break;
//            }
//        }
         _firstPoint = pt;
    }
   
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//	lastDistance=0;
//    //    [self performSelector:@selector(delayShowDeleteButtonIcon) withObject:nil afterDelay:3];
//    //    _scaleView.backgroundColor = [UIColor blueColor];
//    self.activeDragView = nil;
    [self.leftOrUpButtonArray removeAllObjects];
    [self.rightOrDownButtonArray removeAllObjects];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    _scaleView.backgroundColor = [UIColor blueColor];
//    self.activeDragView = nil;
    [self.leftOrUpButtonArray removeAllObjects];
    [self.rightOrDownButtonArray removeAllObjects];
}


@end
