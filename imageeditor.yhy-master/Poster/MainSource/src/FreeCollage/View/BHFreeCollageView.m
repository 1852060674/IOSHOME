//
//  BHFreeCollageView.m
//  PicFrame
//
//  Created by shen on 13-6-24.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHFreeCollageView.h"
#import "ImageUtil.h"
#import <QuartzCore/QuartzCore.h>


BOOL _isFirstTimeLoad;

@interface BHFreeCollageView()<UIGestureRecognizerDelegate,UIActionSheetDelegate>
{
    float _currentWidth;
    float _currentHeight;
    NSUInteger _currentTemplateTypeIndex;
}

@property (nonatomic, strong)NSMutableArray *rectImageViewArray;
@property (nonatomic, strong)NSMutableArray *centerImageViewArray;
@property (nonatomic, strong)NSMutableArray *transformArray;
@property (nonatomic, strong)NSArray *selectedImagesArray;
@property (nonatomic, strong)UIImageView *bgImageView;
@property (nonatomic, strong) UIImage *currentEditImage;
@property (nonatomic, assign) NSUInteger currentSelectedImageViewTag;

- (CGSize)getImageThumbnailSize:(CGSize)imageSize withScale:(float)scale;

@end

@implementation BHFreeCollageView

@synthesize selectedImagesDic = _selectedImagesDic;
@synthesize rectImageViewArray = _rectImageViewArray;
@synthesize centerImageViewArray = _centerImageViewArray;
@synthesize transformArray = _transformArray;
@synthesize bgImageView = _bgImageView;
@synthesize currentEditImage = _currentEditImage;
@synthesize currentSelectedImageViewTag;
@synthesize delegate;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangeBackGroundImage object:nil];
}

- (id)initWithFrame:(CGRect)frame withSelectedImages:(NSArray *)imagesArray
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundImage:@"free_back_7"];
        _currentTemplateTypeIndex = 0;
        self.selectedImagesArray = imagesArray;
        _isFirstTimeLoad = NO;
        
        _currentWidth = self.frame.size.width;
        _currentHeight = self.frame.size.height;
        self.backgroundColor = [UIColor whiteColor];
        self.selectedImagesDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        self.rectImageViewArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.centerImageViewArray = [[NSMutableArray alloc] initWithCapacity:2];
        self.transformArray = [[NSMutableArray alloc] initWithCapacity:2];
        
        UIButton *_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [UIColor clearColor];
        _backButton.frame = CGRectMake(0, 0, _currentWidth, _currentHeight);
        [_backButton addTarget:self action:@selector(selectAnImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        //监听背景变化信息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBackgroundImage:) name:kChangeBackGroundImage object:nil];
        
        [self createCanvas:self.selectedImagesArray];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _currentWidth = self.frame.size.width;
    _currentHeight = self.frame.size.height;
    self.bgImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.rectImageViewArray removeAllObjects];
    [self.transformArray removeAllObjects];
    [self.centerImageViewArray removeAllObjects];
    
    if (!_isFirstTimeLoad) {
        _isFirstTimeLoad = YES;
        [self decideImageViewRect];
    }
    [self presentFreeCollage];
}

- (void)setBackgroundColorOrImage:(UIColor *)backgroundColor
{
    self.bgImageView.image = nil;
    self.backgroundColor = backgroundColor;
}

- (void)changeBackgroundImage:(NSNotification*)notification
{
    NSDictionary *_infoDic = [notification object];//获取到传递的对象
    
    CollageType _type = [[_infoDic valueForKey:@"CollageType"] integerValue];
    if (_type != CollageTypeFree) {
        return;
    }
    
    NSString *_imageName = [_infoDic valueForKey:@"imageIndex"];
    _imageName = [NSString stringWithFormat:@"bg%@.png",_imageName];
    
    UIImage *_backgroundImage = [ImageUtil loadResourceImage:_imageName];
    self.bgImageView.image = nil;
    self.backgroundColor = [UIColor colorWithPatternImage:_backgroundImage];
}

- (void)presentFreeCollage
{
    if (self.rectImageViewArray.count<1 && self.rectImageViewArray.count != self.transformArray.count) {
        return;
    }
    
    for (NSUInteger i=0; i<self.rectImageViewArray.count; i++)
    {
        UIImageView *_imageView = (UIImageView*)[self viewWithTag:kFreeCollageImageViewStartTag+i];
        if (nil == _imageView)
        {
            CGRect _rect = CGRectFromString([self.rectImageViewArray objectAtIndex:i]);
            _imageView = [[UIImageView alloc] initWithFrame:_rect];
            _imageView.tag = kFreeCollageImageViewStartTag+i;
            [_imageView setUserInteractionEnabled:YES];
            [self addSubview:_imageView];
            
            //添加或更改图片到dic
            [self.selectedImagesDic setObject:[self.selectedImagesArray objectAtIndex:i] forKey:[NSNumber numberWithInteger:_imageView.tag]];
            
            //            [_imageView.layer setShouldRasterize:YES];
            
            // 单击的 Recognizer
            UITapGestureRecognizer* _singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            _singleRecognizer.numberOfTapsRequired = 1; // 单击
            [_imageView addGestureRecognizer:_singleRecognizer];
            
            // 双击的 Recognizer
            UITapGestureRecognizer* _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
            _doubleTapRecognizer.numberOfTapsRequired = 2; // 双击
            [_imageView addGestureRecognizer:_doubleTapRecognizer];
            
            [_singleRecognizer requireGestureRecognizerToFail:_doubleTapRecognizer];
            
            //移动
            UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            [_imageView addGestureRecognizer:panRecognizer];
            
            // 旋转的 Recognizer
            UIRotationGestureRecognizer *rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
            [_imageView addGestureRecognizer:rotateRecognizer];
            
            // 捏合的 Recognizer
            UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
            [_imageView addGestureRecognizer:pinchGestureRecognizer];
        }
        
        [_imageView setTransform:CGAffineTransformMakeRotation(0)];
        CGRect _rect = CGRectFromString([self.rectImageViewArray objectAtIndex:i]);
        _imageView.frame = CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, _rect.size.width, _rect.size.height);
        
        [UIView animateWithDuration:0.6 animations:^
         {
             if (self.transformArray.count>1) {
                 CGAffineTransform transform;
                 [[self.transformArray objectAtIndex:i] getValue:&transform];
                 [_imageView setTransform:transform];
             }
             
             CGPoint _centerPoint = [[self.centerImageViewArray objectAtIndex:i] CGPointValue];
             _imageView.center = _centerPoint;
             NSLog(@"center %f,%f",_centerPoint.x,_centerPoint.y);
             //下面判断图片是否出界，出界就进行调整
             if (_imageView.frame.origin.x<0) {
                 _imageView.center = CGPointMake(_imageView.center.x-_imageView.frame.origin.x, _imageView.center.y);
             }
             if (_imageView.frame.origin.x+_imageView.frame.size.width>self.frame.size.width) {
                 _imageView.center = CGPointMake(_imageView.center.x-(_imageView.frame.origin.x+_imageView.frame.size.width-self.frame.size.width), _imageView.center.y);
             }
             
             if (_imageView.frame.origin.y<0) {
                 _imageView.center = CGPointMake(_imageView.center.x, _imageView.center.y-_imageView.frame.origin.y);
             }
             if (_imageView.frame.origin.y+_imageView.frame.size.height>self.frame.size.height) {
                 _imageView.center = CGPointMake(_imageView.center.x, _imageView.center.y-(_imageView.frame.origin.y+_imageView.frame.size.height-self.frame.size.height));
//                 NSLog(@"%f,%f,%f,%f,%f",_imageView.center.y,_imageView.frame.origin.y,_imageView.frame.size.height,self.frame.size.height,_imageView.center.y-(_imageView.frame.origin.y+_imageView.frame.size.height-self.frame.size.height));
             }
             
             
         } completion:^(BOOL finished)
         {
         }];
        
//        
//        _imageView.layer.shadowOffset = CGSizeMake(0, 2);//0,2
//        _imageView.layer.shadowRadius = 2.0;
//        _imageView.layer.shadowColor = [UIColor clearColor].CGColor;
//        _imageView.layer.shadowOpacity = 0.8;
//        _imageView.layer.borderColor = [UIColor clearColor].CGColor;
//        _imageView.layer.borderWidth = 2.0;//2.0
//        //            _imageView.layer.cornerRadius = 1.0;//3.0
//        _imageView.layer.masksToBounds=YES;
        
        UIImage *image = [self.selectedImagesDic objectForKey:[NSNumber numberWithInt:_imageView.tag]];
//        CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
//        UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0);
//        [image drawInRect:CGRectMake(1,1,image.size.width-2,image.size.height-2)];
//        image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        _imageView.image = image;

    }
}

- (void)decideImageViewRect
{
    switch (self.selectedImagesArray.count) {
        case 1:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth/4, _currentHeight/4);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:0]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
        }
            break;
        case 2:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.3);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth/8, _currentHeight/8);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:0]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.5, _currentHeight*0.4);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:1]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(-0.1);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);//定义一个transform 旋转（3.14/6）;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 3:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.35, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:0]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.7, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.6, _currentHeight*0.5);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:1]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.4, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:2]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0.1);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 4:
        {
            CGRect _rect;
            CGPoint _centerPoint;

            _centerPoint = CGPointMake(_currentWidth*0.3, _currentHeight*0.3);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:0]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.6, _currentHeight*0.5);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:1]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:2]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];

            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:3]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(-0.1);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];

        }
            break;
        case 5:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:0]).size withScale:0.35];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.2, _currentHeight*0.65);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:1]).size withScale:0.35];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:2]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:3]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:4]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(-0.05);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 6:
        {
//            CGRect _rect;
//            CGPoint _centerPoint;
//            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
//            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
//            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
//            
//            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
//            
//            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
//            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
//            
//            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
//            
//            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.2);
//            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
//            
//            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
//            
//            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.45);
//            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
//            
//            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
//            
//            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.65);
//            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
//            
//            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
//            
//            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.8);
//            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
//            
//            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
//            
//            
//            CGAffineTransform transform =CGAffineTransformMakeRotation(-0.05);//定义一个transform 旋转（0）;
//            NSValue *value = nil;
//            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
//            [self.transformArray addObject:value];
//            
//            transform =CGAffineTransformMakeRotation(-0.08);
//            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
//            [self.transformArray addObject:value];
//            
//            transform =CGAffineTransformMakeRotation(0.08);
//            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
//            [self.transformArray addObject:value];
//            
//            transform =CGAffineTransformMakeRotation(0.05);
//            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
//            [self.transformArray addObject:value];
//            
//            transform =CGAffineTransformMakeRotation(0.08);
//            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
//            [self.transformArray addObject:value];
//            
//            transform =CGAffineTransformMakeRotation(-0.05);
//            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
//            [self.transformArray addObject:value];
            
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:0]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:1]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:2]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:3]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:4]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:5]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];

        }
            break;
        case 7:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:0]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.2, _currentHeight*0.2);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:1]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.2);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:2]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.2);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:3]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.2, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:4]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:5]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:6]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        default:
        {
            [self handle8Images];
        }
            break;
    }
}

- (void)createCanvas:(NSArray*)imagesArray
{
    [self decideImageViewRect];
    [self presentFreeCollage];
}

- (CGSize)getImageThumbnailSize:(CGSize)imageSize withScale:(float)scale
{
    float _scale = 0;
    CGSize size;
    size.width = kScreenWidth*scale;
    size.height = kScreenHeight*scale;
    
    NSLog(@"%f,%f,%f",kScreenHeight,scale,kScreenHeight*scale);
    
    _scale = size.width/imageSize.width;
    if (_scale<size.height/imageSize.height) {
        size.height = size.width*imageSize.height/imageSize.width;
    }
    else
    {
        _scale = size.height/imageSize.height;
        size.width = size.height*imageSize.width/imageSize.height;
    }

//    float _scale = maxEdge/imageSize.height;
//    if (_scale>1) {
//        _scale = maxEdge/imageSize.width;
//    }
//    float _newWidht = _scale*imageSize.width;
//    if (imageSize.width<=imageSize.height) {
//        size.height = maxEdge;
//        size.width = maxEdge/imageSize.height * imageSize.width;
//    }
//    else
//    {
//        size.width = maxEdge;
//        size.height = maxEdge/imageSize.width * imageSize.height;
//    }
    return size;
}

#pragma mark -- custom method
- (void)setBackgroundImage:(NSString*)imageName
{
    if (nil == imageName || [imageName isEqualToString:@""]) {
        return;
    }
    if (nil == self.bgImageView) {
        self.bgImageView = [[UIImageView alloc] initWithImage:[ImageUtil loadResourceImage:imageName]];
        self.bgImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.bgImageView];
        [self sendSubviewToBack:self.bgImageView];
    }
    self.bgImageView.image = [ImageUtil loadResourceImage:imageName];
}

- (void)changedCornerValue:(float)value
{
    for (NSUInteger i=0; i<self.rectImageViewArray.count; i++)
    {
        UIImageView *_imageView = (UIImageView*)[self viewWithTag:kFreeCollageImageViewStartTag+i];
        if (nil != _imageView) {
            _imageView.layer.cornerRadius = value;
            _imageView.layer.masksToBounds = YES;
        }
    }
    [self setNeedsDisplay];
}

- (void)selectAnImage
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedAnImage object:nil];
}

//- (void)addAnNewImage:(UIImage*)image
//{
//    CGRect _rect = CGRectMake(_currentWidth/2, _currentHeight/2, 200, 200);
//    UIButton *_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [_button setImage:image forState:UIControlStateNormal];
//    _button.frame = _rect;
//    //        _imageView.image = [self.selectedImagesDic objectForKey:[NSNumber numberWithInt:(kStartButtonTag+i)]];
//    //        [_imageView setUserInteractionEnabled:YES];
//    [self addSubview:_button];
//    
//    //        // 单击的 Recognizer
//    //        UITapGestureRecognizer* _singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//    //        _singleRecognizer.numberOfTapsRequired = 1; // 单击
//    //        [_button addGestureRecognizer:_singleRecognizer];
//    
//    //移动
//    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    [_button addGestureRecognizer:panRecognizer];//关键语句，给self.view添加一个手势监测；
//    
//    // 旋转的 Recognizer
//    UIRotationGestureRecognizer *rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
//    [_button addGestureRecognizer:rotateRecognizer];
//    
//    // 捏合的 Recognizer
//    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
//    [_button addGestureRecognizer:pinchGestureRecognizer];
//}

- (void)setCurrentSelectedImage:(UIImage*)image
{
    UIImageView *_selectedImageView = (UIImageView*)[self viewWithTag:self.currentSelectedImageViewTag];
    CGSize _imageSize;
    _imageSize = [self getImageThumbnailSize:image.size withScale:MAX(_selectedImageView.frame.size.height/kScreenHeight,_selectedImageView.frame.size.width/kScreenWidth)];
    _selectedImageView.image = image;
    _selectedImageView.frame = CGRectMake(_selectedImageView.frame.origin.x, _selectedImageView.frame.origin.y, _imageSize.width, _imageSize.height);
    
    //添加或更改图片到dic
    [self.selectedImagesDic setObject:image forKey:[NSNumber numberWithInteger:self.currentSelectedImageViewTag]];
    
    [UIView animateWithDuration:0.6 animations:^
     {
         
         //下面判断图片是否出界，出界就进行调整
         if (_selectedImageView.frame.origin.x<0) {
             _selectedImageView.center = CGPointMake(_selectedImageView.center.x-_selectedImageView.frame.origin.x, _selectedImageView.center.y);
         }
         if (_selectedImageView.frame.origin.x+_selectedImageView.frame.size.width>self.frame.size.width) {
             _selectedImageView.center = CGPointMake(_selectedImageView.center.x-(_selectedImageView.frame.origin.x+_selectedImageView.frame.size.width-self.frame.size.width), _selectedImageView.center.y);
         }
         
         if (_selectedImageView.frame.origin.y<0) {
             _selectedImageView.center = CGPointMake(_selectedImageView.center.x, _selectedImageView.center.y-_selectedImageView.frame.origin.y);
         }
         if (_selectedImageView.frame.origin.y+_selectedImageView.frame.size.height>self.frame.size.height) {
             _selectedImageView.center = CGPointMake(_selectedImageView.center.x, _selectedImageView.center.y-(_selectedImageView.frame.origin.y+_selectedImageView.frame.size.height-self.frame.size.height));
         }
         
         
     } completion:^(BOOL finished)
     {
     }];

}

-(BOOL)canAdjustTemplateType:(NSUInteger)imageCount  withFreeCollageChangeType:(FreeCollageChangeType)type
{
    BOOL canAdjust = YES;
    switch (imageCount) {
        case 2:
        {
            if (type == FreeCollageChangeTypeLast && _currentTemplateTypeIndex == 0) {
                canAdjust = NO;
            }
            if (type == FreeCollageChangeTypeNext && _currentTemplateTypeIndex == 3) {
                canAdjust = NO;
            }
        }
            break;
        case 3:
        {
//            [self handle3ImagesWithChangeType:type];
            if (type == FreeCollageChangeTypeLast && _currentTemplateTypeIndex == 0) {
                canAdjust = NO;
            }
            if (type == FreeCollageChangeTypeNext && _currentTemplateTypeIndex == 3) {
                canAdjust = NO;
            }
        }
            break;
        case 4:
        {
            if (type == FreeCollageChangeTypeLast && _currentTemplateTypeIndex == 0) {
                canAdjust = NO;
            }
            if (type == FreeCollageChangeTypeNext && _currentTemplateTypeIndex == 4) {
                canAdjust = NO;
            }
        }
            break;
        case 5:
        {
            if (type == FreeCollageChangeTypeLast && _currentTemplateTypeIndex == 0) {
                canAdjust = NO;
            }
            if (type == FreeCollageChangeTypeNext && _currentTemplateTypeIndex == 4) {
                canAdjust = NO;
            }
        }
            break;
        case 6:
        {
            if (type == FreeCollageChangeTypeLast && _currentTemplateTypeIndex == 0) {
                canAdjust = NO;
            }
            if (type == FreeCollageChangeTypeNext && _currentTemplateTypeIndex == 4) {
                canAdjust = NO;
            }
        }
            break;
        case 7:
        {
            if (type == FreeCollageChangeTypeLast && _currentTemplateTypeIndex == 0) {
                canAdjust = NO;
            }
            if (type == FreeCollageChangeTypeNext && _currentTemplateTypeIndex == 4) {
                canAdjust = NO;
            }
        }
            break;
        default:
        {
            canAdjust = NO;
        }
            break;
    }
    return canAdjust;
}

- (void)adjustTemplateType:(NSUInteger)imageCount  withFreeCollageChangeType:(FreeCollageChangeType)type
{
    switch (imageCount) {
        case 2:
        {
            [self handle2ImagesTypeWithChangeType:type];
        }
            break;
        case 3:
        {
            [self handle3ImagesWithChangeType:type];
        }
            break;
        case 4:
        {
            [self handle4ImagesWithChangeType:type];
        }
            break;
        case 5:
        {
            [self handle5ImagesWithChangeType:type];
        }
            break;
        case 6:
        {
            [self handle6ImagesWithChangeType:type];
        }
            break;
        case 7:
        {
            [self handle7ImagesWithChangeType:type];
        }
            break;
//        case 8:
//        {
//            [self handle8Images];
//        }
//            break;
//        case 9:
//        {
//            
//        }
//            break;
        default:
        {
            [self handle8Images];
        }
            break;
    }
}

#pragma mark -- UIGestureRecognizer 手势
- (void)handleSingleTap:(UIGestureRecognizer*)recognizer
{
    UIImageView *_imageView = (UIImageView*)[recognizer view];
    [self bringSubviewToFront:_imageView];
}

- (void)handleDoubleTap:(UIGestureRecognizer*)recognizer
{
    UIImageView *_imageView = (UIImageView*)[recognizer view];
    [self bringSubviewToFront:_imageView];
    
    self.currentEditImage = _imageView.image;
    self.currentSelectedImageViewTag = _imageView.tag;
    
    UIActionSheet *aActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reselect photo" otherButtonTitles:@"Edit current photo", nil];
    [aActionSheet showInView:self];
}

- (void)handlePan:(UIPanGestureRecognizer*)recognizer
{
//    CGPoint curPoint = [recognizer locationInView:self];
//    [[recognizer view] setCenter:curPoint];
    [self bringSubviewToFront:[recognizer view]];
    CGPoint translation = [recognizer translationInView:self];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:self];
}

- (void) handleRotate:(UIRotationGestureRecognizer*) recognizer
{
    [self bringSubviewToFront:[recognizer view]];
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
}

- (void) handlePinch:(UIPinchGestureRecognizer*) recognizer
{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

#pragma mark -- UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImageView *_selectedImageView = (UIImageView*)[self viewWithTag:self.currentSelectedImageViewTag];
    
    if (buttonIndex == 0)
    {
        //打开相册
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(openAlbum: withRect:)]) {
            [self.delegate openAlbum:UIImagePickerControllerSourceTypeSavedPhotosAlbum  withRect:_selectedImageView.frame];
        }
        
    }else if (buttonIndex == 1) {
        //编辑当前选择的图片
        if (self.delegate && [self.delegate respondsToSelector:@selector(editCurrentSelectedImage:)]) {
            [self.delegate editCurrentSelectedImage:self.currentEditImage];
        }
    }
}

#pragma mark -- template type

- (void)handle2ImagesTypeWithChangeType:(FreeCollageChangeType)type
{
    if (type == FreeCollageChangeTypeLast && _currentTemplateTypeIndex == 0) {
        return;
    }
    if (type == FreeCollageChangeTypeNext && _currentTemplateTypeIndex == 3) {
        return;
    }
    if (type == FreeCollageChangeTypeLast) {
        _currentTemplateTypeIndex--;
    }
    else if(type == FreeCollageChangeTypeNext)
        _currentTemplateTypeIndex++;
//    _currentTemplateTypeIndex = _currentTemplateTypeIndex%3;
//    NSLog(@"2 %d",_currentTemplateTypeIndex);
    [self.rectImageViewArray removeAllObjects];
    [self.transformArray removeAllObjects];
    [self.centerImageViewArray removeAllObjects];
    switch (_currentTemplateTypeIndex) {
        case 0:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.3);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth/8, _currentHeight/8);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(-0.1);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);//定义一个transform 旋转（3.14/6）;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 1:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.8, _currentHeight*0.3);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth/8, _currentHeight/8);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.45, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.6];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(-0.2);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);//定义一个transform 旋转（3.14/6）;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 2:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth/8, _currentHeight/8);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.3, _currentHeight*0.8);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.6];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(-0.1);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);//定义一个transform 旋转（3.14/6）;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        default:
            break;
    }
    
    [self presentFreeCollage];
}

- (void)handle3ImagesWithChangeType:(FreeCollageChangeType)type
{
    if (type == FreeCollageChangeTypeLast && _currentTemplateTypeIndex == 0) {
        return;
    }
    if (type == FreeCollageChangeTypeNext && _currentTemplateTypeIndex == 3) {
        return;
    }
    if (type == FreeCollageChangeTypeLast) {
        _currentTemplateTypeIndex--;
    }
    else if(type == FreeCollageChangeTypeNext)
        _currentTemplateTypeIndex++;

//    NSLog(@"3 %d",_currentTemplateTypeIndex);
    [self.rectImageViewArray removeAllObjects];
    [self.transformArray removeAllObjects];
    [self.centerImageViewArray removeAllObjects];
    switch (_currentTemplateTypeIndex) {
        case 0:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.35, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.7, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.6, _currentHeight*0.5);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.4, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0.1);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 1:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.4);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.02);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.7];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.05, _currentHeight*0.6);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.33];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.6, _currentHeight*0.6);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.33];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0.01);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);//定义一个transform 旋转（3.14/6）;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);//定义一个transform 旋转（3.14/6）;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 2:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.3, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.08, _currentHeight*0.3);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.7, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth/2, _currentHeight*0.1);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.33];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.7, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth/2, _currentHeight*0.6);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.33];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0.01);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);//定义一个transform 旋转（3.14/6）;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);//定义一个transform 旋转（3.14/6）;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 3:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.3);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.55];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.05, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.6, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0.01);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);//定义一个transform 旋转（3.14/6）;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);//定义一个transform 旋转（3.14/6）;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        default:
            break;
    }
    [self presentFreeCollage];
}

- (void)handle4ImagesWithChangeType:(FreeCollageChangeType)type
{
    if (type == FreeCollageChangeTypeLast && _currentTemplateTypeIndex == 0) {
        return;
    }
    if (type == FreeCollageChangeTypeNext && _currentTemplateTypeIndex == 4) {
        return;
    }
    if (type == FreeCollageChangeTypeLast) {
        _currentTemplateTypeIndex--;
    }
    else if(type == FreeCollageChangeTypeNext)
        _currentTemplateTypeIndex++;
//    NSLog(@"4 %d",_currentTemplateTypeIndex);
    [self.rectImageViewArray removeAllObjects];
    [self.transformArray removeAllObjects];
    [self.centerImageViewArray removeAllObjects];
    switch (_currentTemplateTypeIndex)
    {
        case 0:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.3, _currentHeight*0.3);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.6, _currentHeight*0.5);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(-0.1);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 1:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.4);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.6];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 2:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.6];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.6, _currentHeight*0.5);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 3:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.35);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.6, _currentHeight*0.5);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(-0.1);//定义一个transform 旋转（3.14/6）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];

        }
            break;
        case 4:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.6, _currentHeight*0.5);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        default:
            break;
    }
    [self presentFreeCollage];
}

- (void)handle5ImagesWithChangeType:(FreeCollageChangeType)type
{
    if (type == FreeCollageChangeTypeLast && _currentTemplateTypeIndex == 0) {
        return;
    }
    if (type == FreeCollageChangeTypeNext && _currentTemplateTypeIndex == 4) {
        return;
    }
    if (type == FreeCollageChangeTypeLast) {
        _currentTemplateTypeIndex--;
    }
    else if(type == FreeCollageChangeTypeNext)
        _currentTemplateTypeIndex++;
//    NSLog(@"5 %d",_currentTemplateTypeIndex);
    [self.rectImageViewArray removeAllObjects];
    [self.transformArray removeAllObjects];
    [self.centerImageViewArray removeAllObjects];
    switch (_currentTemplateTypeIndex)
    {
        case 0:
        {            
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.35];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.2, _currentHeight*0.65);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.35];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(-0.05);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 1:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.35];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.65);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.35];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0.05);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 2:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(-0.05);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];

        }
            break;
        case 3:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.35);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.2, _currentHeight*0.6);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.3, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.6);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.7, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 4:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.3);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        default:
            break;
    }
    [self presentFreeCollage];
}

- (void)handle6ImagesWithChangeType:(FreeCollageChangeType)type
{
    if (type == FreeCollageChangeTypeLast && _currentTemplateTypeIndex == 0) {
        return;
    }
    if (type == FreeCollageChangeTypeNext && _currentTemplateTypeIndex == 4) {
        return;
    }
    if (type == FreeCollageChangeTypeLast) {
        _currentTemplateTypeIndex--;
    }
    else if(type == FreeCollageChangeTypeNext)
        _currentTemplateTypeIndex++;
//    NSLog(@"6 %d",_currentTemplateTypeIndex);
    [self.rectImageViewArray removeAllObjects];
    [self.transformArray removeAllObjects];
    [self.centerImageViewArray removeAllObjects];
    switch (_currentTemplateTypeIndex)
    {
        case 0:
        {            
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+5]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 1:
        {            
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.4);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.2);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.2);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.2);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+5]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 2:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.2);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.45);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.65);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+5]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(-0.05);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];

        }
            break;
        case 3:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.2);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.45);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.65);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+5]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];

        }
            break;
        case 4:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.6, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.6, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.6, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.15);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.3);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.6);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+5]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];        }
            break;
        default:
            break;
    }
    [self presentFreeCollage];
}

- (void)handle7ImagesWithChangeType:(FreeCollageChangeType)type
{
    if (type == FreeCollageChangeTypeLast && _currentTemplateTypeIndex == 0) {
        return;
    }
    if (type == FreeCollageChangeTypeNext && _currentTemplateTypeIndex == 4) {
        return;
    }
    if (type == FreeCollageChangeTypeLast) {
        _currentTemplateTypeIndex--;
    }
    else if(type == FreeCollageChangeTypeNext)
        _currentTemplateTypeIndex++;
//    NSLog(@"7 %d",_currentTemplateTypeIndex);
    [self.rectImageViewArray removeAllObjects];
    [self.transformArray removeAllObjects];
    [self.centerImageViewArray removeAllObjects];
    switch (_currentTemplateTypeIndex)
    {
        case 0:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.2, _currentHeight*0.2);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.2);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.2);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.2, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+5]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+6]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 1:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.2, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.35];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.2, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.7, _currentHeight*0.3);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.35];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+5]]).size withScale:0.35];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.7, _currentHeight*0.7);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+6]]).size withScale:0.35];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0.1);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 2:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.5, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.3];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.5];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.8, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+5]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.2, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+6]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.05);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 3:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.2, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.4);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.6);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+5]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+6]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0.08);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.08);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.02);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.15);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(-0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0.1);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        case 4:
        {
            CGRect _rect;
            CGPoint _centerPoint;
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.origin = CGPointMake(_currentWidth*0.1, _currentHeight*0.05);
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.5);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+1]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.25, _currentHeight*0.75);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+2]]).size withScale:0.4];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.25);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+3]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.4);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+4]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.6);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+5]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            _centerPoint = CGPointMake(_currentWidth*0.75, _currentHeight*0.8);
            [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
            _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesDic objectForKey:[NSNumber numberWithInt:kFreeCollageImageViewStartTag+6]]).size withScale:0.25];
            [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
            
            
            CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
            NSValue *value = nil;
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
            
            transform =CGAffineTransformMakeRotation(0);
            value = [NSValue valueWithBytes:&transform objCType:@encode(CGRect)];
            [self.transformArray addObject:value];
        }
            break;
        default:
            break;
    }
    [self presentFreeCollage];
}

- (void)handle8Images
{
    _currentTemplateTypeIndex++;
    _currentTemplateTypeIndex = _currentTemplateTypeIndex%5;
//    NSLog(@"7 %d",_currentTemplateTypeIndex);
    [self.rectImageViewArray removeAllObjects];
    [self.transformArray removeAllObjects];
    [self.centerImageViewArray removeAllObjects];
    
    NSUInteger _imagesInPerLine = sqrt(self.selectedImagesArray.count);
    NSUInteger _lineIndex = 0;
    NSUInteger _imageIndex = 0;
    NSUInteger _lines = ceilf(self.selectedImagesArray.count/_imagesInPerLine);
    CGRect _rect;
    CGPoint _centerPoint;
    
    for (NSUInteger i = 0; i<self.selectedImagesArray.count; i++)
    {
        _lineIndex = i/_imagesInPerLine;
        _imageIndex = i%_imagesInPerLine;
        _centerPoint = CGPointMake(_currentWidth/_imagesInPerLine*(_imageIndex+0.5), _currentHeight/_lines*(_lineIndex+0.5));
        [self.centerImageViewArray addObject:[NSValue valueWithCGPoint:_centerPoint]];
        _rect.origin = CGPointMake(_currentWidth/_imagesInPerLine*_imageIndex, _currentHeight/_lines*_lineIndex);
//        _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:i]).size withScale:_currentHeight/_lines];
        
        _rect.size = [self getImageThumbnailSize:((UIImage*)[self.selectedImagesArray objectAtIndex:i]).size withScale:MAX(_currentHeight/_lines/kScreenHeight,_currentWidth/_lines/kScreenWidth)];
        [self.rectImageViewArray addObject:NSStringFromCGRect(_rect)];
        
        CGAffineTransform transform =CGAffineTransformMakeRotation(0);//定义一个transform 旋转（0）;
        NSValue *value = nil;
        value = [NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)];
        [self.transformArray addObject:value];
    }
    
    [self presentFreeCollage];
}


@end
