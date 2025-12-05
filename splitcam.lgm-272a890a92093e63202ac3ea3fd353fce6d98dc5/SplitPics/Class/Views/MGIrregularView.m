//
//  MGIrregularView.m
//  SplitPics
//
//  Created by tangtaoyu on 15-3-10.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGIrregularView.h"
#import "MGGPUUtil.h"
#import "MGImageUtil.h"
#import "UIImage+Rotating.h"
#import "UIImage+Rotation.h"
#import "MGDefine.h"

#define MRScreenWidth      CGRectGetWidth([UIScreen mainScreen].applicationFrame)
#define MRScreenHeight     CGRectGetHeight([UIScreen mainScreen].applicationFrame)

@interface MGIrregularView()
@property (strong, nonatomic) UIImageView *maskBorder;
@property (nonatomic, assign) CGPoint previousOriginal;
@property (nonatomic, assign) dispatch_once_t onceToken;
@property (nonatomic, assign) NSUInteger maskHash;
@end

@implementation MGIrregularView {
    NSInteger maskCount;
    BOOL isTakeOVer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        maskCount = 0;
        isTakeOVer = NO;
        [self initImageView];
    }
    return self;
}



- (void)initImageView
{
    self.backgroundColor = [UIColor grayColor];
    
    _mainView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_mainView];
    
    _contentView = [[TestScrollView alloc] initWithFrame:CGRectInset(self.bounds, 0, 0)];
    _contentView.delegate = self;
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.showsVerticalScrollIndicator = NO;
    [_mainView addSubview:_contentView];



    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.frame = CGRectMake(0, 0, MRScreenWidth * 2.5, MRScreenWidth * 2.5);
    _imageView.userInteractionEnabled = YES;
    [_contentView addSubview:_imageView];
    
    
    // Add gesture,double tap zoom imageView.
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:tapGes];
    
    float minimumScale = self.frame.size.width / _imageView.frame.size.width;
    [_contentView setMinimumZoomScale:minimumScale];
    [_contentView setZoomScale:minimumScale];
    
    //_maskBorder = [[UIImageView alloc] initWithFrame:self.bounds];
    //[self addSubview:_maskBorder];
    //_maskBorder.userInteractionEnabled = NO;
}


- (void)addShadow:(CALayer *)aLayer {
  aLayer.shadowColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
  aLayer.shadowOpacity = 1;
  aLayer.shadowRadius = 5;
  aLayer.shadowPath = [self bezierArea].CGPath;
}

- (void)setMaskLayer0
{
    _isInEdit = NO;
    
    switch (_shapeType) {
        case BezierShaper:{
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = self.bezierArea.CGPath;
            shapeLayer.fillColor = [[UIColor clearColor] CGColor];
            self.layer.mask = shapeLayer;
            break;
        }
        case ImageShaper:{
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = self.bezierArea.CGPath;
            shapeLayer.fillColor = [[UIColor clearColor] CGColor];
            self.layer.mask = shapeLayer;
            break;
        }
        case RectShaper:{
            
            if([self isNoKindOfAskewLine]){
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathAddPath(path, nil, [self.bezierArea CGPath]);
                CGPathAddRect(path, nil, self.bounds);
                
                CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                shapeLayer.path = path;
                CGPathRelease(path);
                shapeLayer.fillColor = [[UIColor clearColor] CGColor];
                self.layer.mask = shapeLayer;
            }else{
                CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                shapeLayer.path = self.bezierArea.CGPath;
                shapeLayer.fillColor = [[UIColor clearColor] CGColor];
                self.layer.mask = shapeLayer;
            }

            break;
        }
        default:
            break;
    }
    
    [self setNeedsLayout];
}


- (BOOL)isNoKindOfAskewLine {
  return
  self.layoutIndex != LayoutPatternDiagonal &&
  self.layoutIndex != LayoutPatternLeftArrowx2 &&
  self.layoutIndex != LayoutPatternLeftArrowx1 &&
  self.layoutIndex != LayoutPatternDownArrowx1 &&
  self.layoutIndex != LayoutPatternDownArrowx2 &&
  self.layoutIndex != LayoutPatternShapeSx1 &&
  self.layoutIndex != LayoutPatternShapeSx2;
}


- (void)setMaskLayer
{
    _isInEdit = YES;
    
    switch (_shapeType) {
        case BezierShaper:{
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = self.bezierArea.CGPath;
            shapeLayer.fillRule = kCAFillRuleEvenOdd;
            self.layer.mask = shapeLayer;
            
            break;
        }
        case ImageShaper:{
    
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = self.bezierArea.CGPath;
            shapeLayer.fillRule = kCAFillRuleEvenOdd;
            self.layer.mask = shapeLayer;
            
            break;
        }
        case RectShaper:{
            if([self.dataSource isTakeOverAtMGIrregularView:self]){
                CAShapeLayer *layer = [CAShapeLayer layer];
                layer.path = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
                layer.fillColor = [[UIColor whiteColor] CGColor];
                self.layer.mask = layer;
            }else{
                
                if([self isNoKindOfAskewLine]){
                    CGMutablePathRef path = CGPathCreateMutable();
                    CGPathAddPath(path, nil, [self.bezierArea CGPath]);
                    CGPathAddRect(path, nil, self.bounds);
                    
                    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                    shapeLayer.path = path;
                    CGPathRelease(path);
                    shapeLayer.fillRule = kCAFillRuleEvenOdd;
                    self.layer.mask = shapeLayer;
                }else{
                    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                    shapeLayer.path = self.bezierArea.CGPath;
                    shapeLayer.fillRule = kCAFillRuleEvenOdd;
                    self.layer.mask = shapeLayer;
                }
                
            }
            
            break;
        }
        default:
            break;
    }
    
    [self setNeedsLayout];
}

- (void)setRectShapeTypeLayer
{
    //完成拍摄后的动作
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
    layer.fillColor = [[UIColor whiteColor] CGColor];
    self.layer.mask = layer;
    
    isTakeOVer = YES;
    [self setNeedsDisplay];
}

- (void)setIrregularTypeLayer
{
    //完成拍摄后的动作
    if(_sublayoutIndex == 0){
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
        layer.fillColor = [[UIColor whiteColor] CGColor];
        self.layer.mask = layer;
    }
    
    self.hidden = NO;
    [self setNeedsDisplay];
}

- (void)setBorderWithAutoHide:(BOOL)isHide
{
    /*
    if(_borderLayer != nil){
        [_borderLayer removeFromSuperlayer];
        _borderLayer = nil;
    }
    
    switch (_shapeType) {
        case BezierShaper:{
            
            if(_frameIdx != 9){
                _maskBorder.frame = _viewRect;
                _maskBorder.layer.borderWidth = self.borderWidth;
                _maskBorder.layer.borderColor = [UIColor whiteColor].CGColor;
            }else{
                _maskBorder.image = [MGImageUtil bezierPath:self.bezierArea inRect:self.frame WithWidth:self.borderWidth];
            }
            break;
        }
        case ImageShaper:{            
            _maskBorder.image = [MGGPUUtil customBorderFilter:_mask];
            break;
        }
        case RectShaper:{
            _maskBorder.frame = self.bounds;
            _maskBorder.layer.borderWidth = self.borderWidth;
            _maskBorder.layer.borderColor = [UIColor whiteColor].CGColor;

            break;
        }
        default:
            break;
    }

    
    if(isHide)
        [self hiddenBorder];
    [self setNeedsLayout];*/
}

- (void)changeEdgeBlurWidth:(CGFloat)blurRadius
{
    if (_shapeType == BezierShaper) {

        CALayer *maskLayer = [self blurLayerWithRadius:blurRadius];
        self.layer.mask = maskLayer;
        [self setResfreshWithBlur:blurRadius];
    } else if (_shapeType == ImageShaper) {
        CALayer *maskLayer = [self blurLayerWhileImageShapeWithRadius:blurRadius];
        self.layer.mask = maskLayer;
        [self setResfreshWithBlur:blurRadius];


//      __weak typeof(self) weakSelf = self;
//      [self blurLayerWhileImageShapeWithRadius:blurRadius completion:^(CALayer * maskLayer) {
//        weakSelf.layer.mask = maskLayer;
//        [weakSelf setResfreshWithBlur:blurRadius];
//      }];



    }else{
        
        if([self.dataSource isTakeOverAtMGIrregularView:self]){
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.path = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
            layer.fillColor = [[UIColor whiteColor] CGColor];
            self.layer.mask = layer;
        }else{
            
            if([self isNoKindOfAskewLine]){
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathAddPath(path, nil, [self.bezierArea CGPath]);
                CGPathAddRect(path, nil, self.bounds);
                
                CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                shapeLayer.path = path;
                CGPathRelease(path);
                shapeLayer.fillRule = kCAFillRuleEvenOdd;
                self.layer.mask = shapeLayer;
            } else {
                CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                shapeLayer.path = self.bezierArea.CGPath;
                shapeLayer.fillRule = kCAFillRuleEvenOdd;
                self.layer.mask = shapeLayer;
            }
        }

        [self setResfresh];
    }
    [self setNeedsDisplay];
}

- (void)showBorder
{
    _maskBorder.hidden = NO;

    [self setNeedsLayout];
}

- (void)hiddenBorder
{
     _maskBorder.hidden = YES;
    
    [self setNeedsLayout];
}

- (void)setImageViewData:(UIImage*)image
{
    _contentView.frame = _viewRect;
    
    _imageView.image = image;
    if(image == nil)
        return;
    
    CGRect rect  = CGRectZero;
    CGFloat w = 0.0f;
    CGFloat h = 0.0f;
    
    if(self.frame.size.width > self.frame.size.height)
    {
        w = self.frame.size.width;
        h = w*image.size.height/image.size.width;
        if(h < self.frame.size.height){
            h = self.frame.size.height;
            w = h*image.size.width/image.size.height;
        }
        
    }else{
        
        h = self.frame.size.height;
        w = h*image.size.width/image.size.height;
        if(w < self.frame.size.width){
            w = self.frame.size.width;
            h = w*image.size.height/image.size.width;
        }
    }
    
    rect.size = CGSizeMake(w, h);

    _imageView.frame = rect;
    [_contentView setZoomScale:0.2 animated:YES];
    
    _contentView.contentOffset = CGPointMake(_viewRect.origin.x, _viewRect.origin.y);

    [self setNeedsLayout];
}

- (void)setResfresh
{
    if(_shapeType == ImageShaper){
        _contentView.frame = _viewRect;
    }else if(_shapeType == BezierShaper){
        _contentView.frame = _viewRect;
        
        if(self.layoutIndex == LayoutPatternDiagonal){
          if (_sublayoutIndex == 1) {
            float offsetX = _blurWidth*sqrtf(kW(self)*kW(self)+kH(self)*kH(self))/kH(self)/2;
            float offsetY = offsetX*kH(self)/kW(self);
            float originX = (_viewRect.origin.x-offsetX > 0)?_viewRect.origin.x-offsetX:0;
            float originY = (_viewRect.origin.y-offsetY > 0)?_viewRect.origin.y-offsetY:0;
            _contentView.frame = CGRectMake(originX, originY, _viewRect.size.width+offsetX, _viewRect.size.height+offsetY);

            _contentView.contentOffset = CGPointMake(originX, originY);
          } else if(_sublayoutIndex == 0){
            _contentView.frame = self.frame;
          }

        }
        else if(self.layoutIndex == LayoutPatternShapeSx1) {
          if (self.sublayoutIndex == 0) {
            _contentView.frame = self.frame;
          } else if (self.sublayoutIndex == 1) {
            float offsetX = _blurWidth/2;
            float offsetY = 0*offsetX*kH(self)/kW(self);
            float originX = (_viewRect.origin.x-offsetX > 0)?_viewRect.origin.x-offsetX:0;
            float originY = (_viewRect.origin.y-offsetY > 0)?_viewRect.origin.y-offsetY:0;
            float width = (_viewRect.size.width+offsetX) > kW(self) ? kW(self)-originX : (_viewRect.size.width+offsetX);
            float height = (_viewRect.size.height+offsetY) > kH(self) ? kH(self)-originY : (_viewRect.size.height+offsetY);
            _contentView.frame = CGRectMake(originX, originY, width, height);

            _contentView.contentOffset = CGPointMake(originX, originY);
          }
        }else if(self.layoutIndex == LayoutPatternShapeSx2) {
          if (self.sublayoutIndex == 0) {
            _contentView.frame = self.frame;
          } else if (self.sublayoutIndex == 1) {
            //2*offsex/blurWidth = diag / h_diag;
            float offsetX = _blurWidth/2;
            float offsetY = 0*offsetX*kH(self)/kW(self);
            float originX = (_viewRect.origin.x-offsetX > 0)?_viewRect.origin.x-offsetX:0;
            float originY = (_viewRect.origin.y-offsetY > 0)?_viewRect.origin.y-offsetY:0;
            _contentView.frame = CGRectMake(originX, originY, _viewRect.size.width+offsetX, _viewRect.size.height+offsetY);

            _contentView.contentOffset = CGPointMake(originX, originY);
          } else if (self.sublayoutIndex == 2) {
            float offsetX = _blurWidth/2;
            float offsetY = 0*offsetX*kH(self)/kW(self);
            float originX = (_viewRect.origin.x-offsetX > 0)?_viewRect.origin.x-offsetX:0;
            float originY = (_viewRect.origin.y-offsetY > 0)?_viewRect.origin.y-offsetY:0;
            float width = (_viewRect.size.width+offsetX) > kW(self) ? kW(self)-originX : (_viewRect.size.width+offsetX);
            float height = (_viewRect.size.height+offsetY) > kH(self) ? kH(self)-originY : (_viewRect.size.height+offsetY);
            _contentView.frame = CGRectMake(originX, originY, width, height);

            _contentView.contentOffset = CGPointMake(originX, originY);
          }
        }

        else if(self.layoutIndex == LayoutPatternDownArrowx1) {
          if (self.sublayoutIndex == 0) {
            _contentView.frame = self.frame;
          } else if (self.sublayoutIndex == 1) {
            float offsetY = _blurWidth*sqrtf(kH(self)*(0.4-0.6)*kH(self)*(0.4-0.6)+kW(self)*0.5*kW(self)*0.5)/(kW(self)*0.5)/2;
            float offsetX = 0*offsetY*kH(self)/kW(self);
            float originX = (_viewRect.origin.x-offsetX > 0)?_viewRect.origin.x-offsetX:0;
            float originY = (_viewRect.origin.y-offsetY > 0)?_viewRect.origin.y-offsetY:0;
            float width = (_viewRect.size.width+offsetX) > kW(self) ? kW(self)-originX : (_viewRect.size.width+offsetX);
            float height = (_viewRect.size.height+offsetY) > kH(self) ? kH(self)-originY : (_viewRect.size.height+offsetY);
            _contentView.frame = CGRectMake(originX, originY, width, height);
            _contentView.contentOffset = CGPointMake(originX, originY);
          }
        }else if(self.layoutIndex == LayoutPatternDownArrowx2) {
          if (self.sublayoutIndex == 0) {
            _contentView.frame = self.frame;
          } else if (self.sublayoutIndex == 1) {
            //2*offsex/blurWidth = diag / h_diag;
            float offsetY = _blurWidth*sqrtf(kH(self)*(0.4-0.6)*kH(self)*(0.4-0.6)+kW(self)*0.5*kW(self)*0.5)/(kW(self)*0.5)/2;
            float offsetX = 0*offsetY*kH(self)/kW(self);
            float originX = (_viewRect.origin.x-offsetX > 0)?_viewRect.origin.x-offsetX:0;
            float originY = (_viewRect.origin.y-offsetY > 0)?_viewRect.origin.y-offsetY:0;
            _contentView.frame = CGRectMake(originX, originY, _viewRect.size.width+offsetX, _viewRect.size.height+offsetY);

            _contentView.contentOffset = CGPointMake(originX, originY);
          } else if (self.sublayoutIndex == 2) {
            float offsetY = _blurWidth*sqrtf(kH(self)*(0.4-0.6)*kH(self)*(0.4-0.6)+kW(self)*0.5*kW(self)*0.5)/(kW(self)*0.5)/2;
            float offsetX = 0*offsetY*kH(self)/kW(self);
            float originX = (_viewRect.origin.x-offsetX > 0)?_viewRect.origin.x-offsetX:0;
            float originY = (_viewRect.origin.y-offsetY > 0)?_viewRect.origin.y-offsetY:0;
            float width = (_viewRect.size.width+offsetX) > kW(self) ? kW(self)-originX : (_viewRect.size.width+offsetX);
            float height = (_viewRect.size.height+offsetY) > kH(self) ? kH(self)-originY : (_viewRect.size.height+offsetY);
            _contentView.frame = CGRectMake(originX, originY, width, height);

            _contentView.contentOffset = CGPointMake(originX, originY);
          }
        }
        else if(self.layoutIndex == LayoutPatternLeftArrowx1) {
          if (self.sublayoutIndex == 0) {
            _contentView.frame = self.frame;
          } else if (self.sublayoutIndex == 1) {
            float offsetX = _blurWidth*sqrtf(kW(self)*(0.4-0.6)*kW(self)*(0.4-0.6)+kH(self)*0.5*kH(self)*0.5)/(kH(self)*0.5)/2;
            float offsetY = 0*offsetX*kH(self)/kW(self);
            float originX = (_viewRect.origin.x-offsetX > 0)?_viewRect.origin.x-offsetX:0;
            float originY = (_viewRect.origin.y-offsetY > 0)?_viewRect.origin.y-offsetY:0;
            float width = (_viewRect.size.width+offsetX) > kW(self) ? kW(self)-originX : (_viewRect.size.width+offsetX);
            float height = (_viewRect.size.height+offsetY) > kH(self) ? kH(self)-originY : (_viewRect.size.height+offsetY);
            _contentView.frame = CGRectMake(originX, originY, width, height);

            _contentView.contentOffset = CGPointMake(originX, originY);
          }
        }else if(self.layoutIndex == LayoutPatternLeftArrowx2) {
          if (self.sublayoutIndex == 0) {
            _contentView.frame = self.frame;
          } else if (self.sublayoutIndex == 1) {
            //2*offsex/blurWidth = diag / h_diag;
            float offsetX = _blurWidth*sqrtf(kW(self)*(0.4-0.3)*kW(self)*(0.4-0.3)+kH(self)*0.5*kH(self)*0.5)/(kH(self)*0.5)/2;
            float offsetY = 0*offsetX*kH(self)/kW(self);
            float originX = (_viewRect.origin.x-offsetX > 0)?_viewRect.origin.x-offsetX:0;
            float originY = (_viewRect.origin.y-offsetY > 0)?_viewRect.origin.y-offsetY:0;
            _contentView.frame = CGRectMake(originX, originY, _viewRect.size.width+offsetX, _viewRect.size.height+offsetY);

            _contentView.contentOffset = CGPointMake(originX, originY);
          } else if (self.sublayoutIndex == 2) {
            float offsetX = _blurWidth*sqrtf(kW(self)*(0.4-0.3)*kW(self)*(0.4-0.3)+kH(self)*0.5*kH(self)*0.5)/(kH(self)*0.5)/2;
            float offsetY = 0*offsetX*kH(self)/kW(self);
            float originX = (_viewRect.origin.x-offsetX > 0)?_viewRect.origin.x-offsetX:0;
            float originY = (_viewRect.origin.y-offsetY > 0)?_viewRect.origin.y-offsetY:0;
            float width = (_viewRect.size.width+offsetX) > kW(self) ? kW(self)-originX : (_viewRect.size.width+offsetX);
            float height = (_viewRect.size.height+offsetY) > kH(self) ? kH(self)-originY : (_viewRect.size.height+offsetY);
            _contentView.frame = CGRectMake(originX, originY, width, height);

            _contentView.contentOffset = CGPointMake(originX, originY);
          }
        }
    }else{
        _contentView.frame = self.frame;
    }
    
    CGRect rect  = CGRectZero;
    CGFloat w = 0.0f;
    CGFloat h = 0.0f;
    
    if(self.frame.size.width > self.frame.size.height)
    {
        w = self.frame.size.width;
        h = w*self.imageView.image.size.height/self.imageView.image.size.width;
        if(h < self.frame.size.height){
            h = self.frame.size.height;
            w = h*self.imageView.image.size.width/self.imageView.image.size.height;
        }
        
    }else{
        
        h = self.frame.size.height;
        w = h*self.imageView.image.size.width/self.imageView.image.size.height;
        if(w < self.frame.size.width){
            w = self.frame.size.width;
            h = w*self.imageView.image.size.height/self.imageView.image.size.width;
        }
    }
    
    rect.size = CGSizeMake(w, h);
    
    _imageView.frame = rect;
    
    [self setNeedsLayout];
}

/**
 setResfreshFrame

 @param blurRadius blurRadius
 */
- (void)setResfreshWithBlur:(CGFloat)blurRadius
{
    if(_shapeType == ImageShaper){
        CGRect tmp_rect;
        if([self isNoKindOfAskewLine]){
            tmp_rect = CGRectInset(_viewRect, -blurRadius/2, -blurRadius/2);
        }else{
            float offsetX = _blurWidth*sqrtf(kW(self)*kW(self)+kH(self)*kH(self))/kH(self)/2;
            float offsetY = offsetX*kH(self)/kW(self);
            float originX = (_viewRect.origin.x-offsetX > 0)?_viewRect.origin.x-offsetX:0;
            float originY = (_viewRect.origin.y-offsetY > 0)?_viewRect.origin.y-offsetY:0;
            
            tmp_rect = CGRectMake(originX, originY, kRW(_viewRect)+offsetX, kRH(_viewRect)+offsetY);
        }

      CGPoint point1 = tmp_rect.origin;
      CGPoint point2 = _contentView.frame.origin;
      CGPoint contentOffset = _contentView.contentOffset;
      CGPoint newContentOffset = CGPointMake(contentOffset.x+(point1.x-point2.x), contentOffset.y+(point1.y-point2.y));
      _contentView.contentOffset = newContentOffset;
      _contentView.frame = tmp_rect;

    }else{

      CGPoint point1 = _viewRect.origin;
      CGPoint point2 = _contentView.frame.origin;
      CGPoint contentOffset = _contentView.contentOffset;
      CGPoint newContentOffset = CGPointMake(contentOffset.x+(point1.x-point2.x), contentOffset.y+(point1.y-point2.y));
      _contentView.contentOffset = newContentOffset;
      _contentView.frame = _viewRect;

    }
    [self setNeedsLayout];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isContained;
    
    switch(_shapeType){
        case BezierShaper:{
            isContained = [_bezierArea containsPoint:point];
            break;
        }
        case ImageShaper:{
            isContained = [_bezierArea containsPoint:point];
            break;
        }
        case RectShaper:{
            if([self isNoKindOfAskewLine])
                isContained = ![_bezierArea containsPoint:point];
            else
                isContained = [_bezierArea containsPoint:point];;
            break;
        }
        default:{
            break;
        }
    }
    
    if(isContained)
        [_delegate tapViewAtIndex:_sublayoutIndex];
    
    return isContained;
}

#pragma mark - Zoom methods

- (void)singleTap:(UITapGestureRecognizer*)gestureRecognizer
{
    /*
    float newScale = _contentView.zoomScale * 1.2;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:_imageView]];
    [_contentView zoomToRect:zoomRect animated:YES];*/
    
    CGPoint point = [gestureRecognizer locationInView:self];
    
    [self.delegate tapFocusInPoint:point WithIndex:_sublayoutIndex];
    
    //_maskBorder.hidden = !_maskBorder.hidden;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    if (scale == 0) {
        scale = 1;
    }
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
    [scrollView setZoomScale:scale animated:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    return;
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    return;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    self.imageView.center = touch;
}

- (CALayer*)blurLayerWithRadius:(CGFloat)blurRadius
{
    CALayer* maskLayer = [CALayer layer];
    
    maskLayer.bounds = CGRectMake(0, 0, self.viewRect.size.width, self.viewRect.size.height);
    
    [maskLayer setPosition:CGPointMake(self.viewRect.origin.x+self.viewRect.size.width/2,
                                       self.viewRect.origin.y+self.viewRect.size.height/2)];
    
    if(_blurDirection == BlurDirectionTriangleBottomRight || _blurDirection == BlurDirectionTriangleTopLeft){
        maskLayer.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [maskLayer setPosition:CGPointMake(0+self.bounds.size.width/2,
                                           0+self.bounds.size.height/2)];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate (NULL, maskLayer.bounds.size.width, maskLayer.bounds.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGFloat colors[] = {
        0.0, 0.0, 0.0, 1.0, //BLACK
        0.5, 0.5, 0.5, 0.0, //BLACK
    };
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    CGColorSpaceRelease(colorSpace);
    
    NSUInteger gradientH = blurRadius;
//    NSUInteger gradientHPos = 0;
    float offset = 1.0;
    
    switch(_blurDirection){
        case BlurDirectionNone:{
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
            CGContextFillRect(context, CGRectMake(0, 0, _viewRect.size.width, _viewRect.size.height));
            CGGradientRelease(gradient);
            break;
        }
        case BlurDirectionUp:{
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
            CGContextFillRect(context, CGRectMake(0, 0, _viewRect.size.width, _viewRect.size.height-gradientH));
            
//            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.0].CGColor);
//            CGContextFillRect(context, CGRectMake(0, _viewRect.size.height-gradientH, _viewRect.size.width, gradientH));
            
            CGContextDrawLinearGradient(context, gradient, CGPointMake(_viewRect.size.width/2, _viewRect.size.height-gradientH-offset), CGPointMake(_viewRect.size.width/2, _viewRect.size.height), 0);
            CGGradientRelease(gradient);
            break;
        }
        case BlurDirectionRight:{
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
            CGContextFillRect(context, CGRectMake(0, 0, _viewRect.size.width-gradientH, _viewRect.size.height));
            
//            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.0].CGColor);
//            CGContextFillRect(context, CGRectMake(_viewRect.size.width-gradientH, 0, gradientH, _viewRect.size.height));
            
            CGContextDrawLinearGradient(context, gradient, CGPointMake(_viewRect.size.width-gradientH-offset, _viewRect.size.height/2), CGPointMake(_viewRect.size.width, _viewRect.size.height/2), 0);
            CGGradientRelease(gradient);
            break;
        }
        case BlurDirectionDown:{
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
            CGContextFillRect(context, CGRectMake(0, gradientH, _viewRect.size.width, _viewRect.size.height-gradientH));
            
//            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.0].CGColor);
//            CGContextFillRect(context, CGRectMake(0, 0, _viewRect.size.width, gradientH));
            
            CGContextDrawLinearGradient(context, gradient, CGPointMake(_viewRect.size.width/2, gradientH+offset), CGPointMake(_viewRect.size.width/2, 0), 0);
            CGGradientRelease(gradient);
            break;
        }
        case BlurDirectionLeft:{
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
            CGContextFillRect(context, CGRectMake(gradientH, 0, _viewRect.size.width-gradientH, _viewRect.size.height));
            
//            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.0].CGColor);
//            CGContextFillRect(context, CGRectMake(_viewRect.size.width-gradientH, 0, gradientH, _viewRect.size.height));
            
            CGContextDrawLinearGradient(context, gradient, CGPointMake(gradientH+offset, _viewRect.size.height/2), CGPointMake(0, _viewRect.size.height/2), 0);
            CGGradientRelease(gradient);
            break;
        }
        case BlurDirectionTriangleTopLeft:{
            CGContextSaveGState(context);
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
            CGContextAddPath(context, self.bezierArea.CGPath);
            CGContextFillPath(context);
            CGContextRestoreGState(context);
            CGGradientRelease(gradient);
            break;
        }
        case BlurDirectionTriangleBottomRight:{
            CGContextSaveGState(context);
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
            CGContextAddPath(context, self.bezierArea.CGPath);
            CGContextFillPath(context);
            CGContextRestoreGState(context);
            CGGradientRelease(gradient);
            break;
        }
        case BlurDirectionTopLeft:{
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
            CGContextFillRect(context, CGRectMake(gradientH, 0, _viewRect.size.width-gradientH, _viewRect.size.height-gradientH));
            
            float offsetG = 1.0;
            
            CGContextSaveGState(context);
            CGContextMoveToPoint(context, 0, 0);
            CGContextAddLineToPoint(context, 0, _viewRect.size.height);
            CGContextAddLineToPoint(context, gradientH+offset, _viewRect.size.height-gradientH+offsetG);
            CGContextAddLineToPoint(context, gradientH+offset, 0);
            CGContextClosePath(context);
            //CGContextClip(context);
            
            CGContextDrawLinearGradient(context, gradient, CGPointMake(gradientH+offset, _viewRect.size.height/2), CGPointMake(0, _viewRect.size.height/2), 0);
            CGContextRestoreGState(context);
            
            CGContextSaveGState(context);
            CGContextMoveToPoint(context, 0,  _viewRect.size.height);
            CGContextAddLineToPoint(context,  _viewRect.size.width, _viewRect.size.height);
            CGContextAddLineToPoint(context,  _viewRect.size.width, _viewRect.size.height-gradientH-offset);
            CGContextAddLineToPoint(context, gradientH+offsetG, _viewRect.size.height-gradientH-offset);
            CGContextClosePath(context);
            //CGContextClip(context);
            
            CGContextDrawLinearGradient(context, gradient, CGPointMake(_viewRect.size.width/2, _viewRect.size.height-gradientH-offset), CGPointMake(_viewRect.size.width/2, _viewRect.size.height), 0);
            CGContextRestoreGState(context);
          CGContextSaveGState(context);

          CGContextSetBlendMode(context, kCGBlendModeClear);
          CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
          CGContextFillRect(context, CGRectMake(0, _viewRect.size.height-gradientH, gradientH+offset, gradientH));
          CGContextRestoreGState(context);
          CGFloat radius = 1.414 * gradientH;
          CGContextDrawRadialGradient(context, gradient, CGPointMake(gradientH+offset, _viewRect.size.height-gradientH), 0, CGPointMake(gradientH+offset, _viewRect.size.height-gradientH), radius, 0);

            CGGradientRelease(gradient);
            break;
        }
        default:{
            break;
        }
    }
    
    CGImageRef contextImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *flipImage;
    
    if(_blurDirection == BlurDirectionTriangleTopLeft){
        flipImage = [UIImage imageWithCGImage:contextImage];
        flipImage = [flipImage verticalFlip];
        [maskLayer setContents:(__bridge id)flipImage.CGImage];
    }else if(_blurDirection == BlurDirectionTriangleBottomRight){
        flipImage = [UIImage imageWithCGImage:contextImage];
        flipImage = [flipImage verticalFlip];
        flipImage = [MGGPUUtil boxBlurFilter:flipImage WithRadius:blurRadius];
        [maskLayer setContents:(__bridge id)flipImage.CGImage];
    }else{
        [maskLayer setContents:(__bridge id)contextImage];
    }
    
    CGImageRelease (contextImage);
    
    return maskLayer;
}

- (CALayer*)blurLayerWhileImageShapeWithRadius:(CGFloat)blurRadius
{
    CALayer *maskLayer = [CALayer layer];
    maskLayer.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [maskLayer setPosition:CGPointMake(self.bounds.origin.x+self.bounds.size.width/2,
                                       self.bounds.origin.y+self.bounds.size.height/2)];

    UIImage *shapeImage = [MGImageUtil bezierPath:self.bezierArea inRect:self.bounds];
    UIImage *blurImage = [MGGPUUtil boxBlurFilter:shapeImage WithRadius:blurRadius];
    [maskLayer setContents:(__bridge id)blurImage.CGImage];

   
    
    return maskLayer;
}



- (void)blurLayerWhileImageShapeWithRadius:(CGFloat)blurRadius completion:(void(^)(CALayer *))completion {
  CALayer *maskLayer = [CALayer layer];
  maskLayer.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
  [maskLayer setPosition:CGPointMake(self.bounds.origin.x+self.bounds.size.width/2,
                                     self.bounds.origin.y+self.bounds.size.height/2)];

  UIImage *shapeImage = [MGImageUtil bezierPath:self.bezierArea inRect:self.bounds];


  [MGGPUUtil boxBlurFilter:shapeImage WithRadius:blurRadius completion:^(UIImage * blurImage) {
    [maskLayer setContents:(__bridge id)blurImage.CGImage];
    if (completion) {
      completion(maskLayer);
    }
  }];


}


- (void)Tap:(UITapGestureRecognizer*)gestureRecognizer
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-variable"
  UIView *view = gestureRecognizer.view;
  CGPoint point = [gestureRecognizer locationInView:view];
#pragma clang diagnostic pop
  
    
    /*
     for(int i=0; i<bezierPaths.count; i++){
     if([bezierPaths[i] containsPoint:point]){
     NSLog(@"click %i", i);
     }
     }*/
}

-(void)Pan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-variable"
    CGPoint newCenter = view.center;
#pragma clang diagnostic pop
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}

- (void)dealloc
{
    [self.layer.mask removeFromSuperlayer];
    self.layer.mask = nil;
    
    [self.borderLayer removeFromSuperlayer];
    self.borderLayer = nil;
}

@end
