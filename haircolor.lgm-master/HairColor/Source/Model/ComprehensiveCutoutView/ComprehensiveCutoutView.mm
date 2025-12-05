//
//  ComprehensiveCutoutView.m
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/24.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "ComprehensiveCutoutView.h"
#import "ComprehensiveCutoutDrawView.h"
#import "ComprehensiveCutoutMaskView.h"
#import "ComprehensiveCutoutShapeMaskView.h"

#import <opencv2/ximgproc.hpp>
#import <opencv2/opencv.hpp>

#import "UIImage+Mat.h"
#import "UIImage+Rotation.h"
#import "UIImage+Blend.h"
#import "Masonry.h"
#import "MASViewConstraint.h"
#import "MASConstraint.h"
#import "CGRectCGPointUtility.h"

#import "GCGrabcut.h"
#import "SharedMatting.h"
#import "MagnifierView.h"
#import "ZoomView.h"
#import "ZBCommonMethod.h"

@interface ComprehensiveCutoutView ()<ComprehensiveCutoutDrawViewDelegate, UIGestureRecognizerDelegate>
{
    UIView *_shellView;
    UIView *_containerView;
    ComprehensiveCutoutDrawView *_drawView;
    
    ComprehensiveCutoutMaskView *_selectionMaskView;

    CGFloat _viewScale;
    CGFloat _smallImageScale;

    BOOL _currentTouchEverDraw;
    BOOL _currentTouchEverDraw_1;
    BOOL _currentTouchEverScale;
    BOOL _currentTouchEverChangeShape;
    
    BOOL _hasLeftEye, _hasRightEye, _hasMouth;
    cv::Rect _leftEyeRect, _rightEyeRect, _mouthRect;
    
    UIPanGestureRecognizer *_panGesture;
    UIPinchGestureRecognizer *_pinchGesture;
    UIRotationGestureRecognizer *_rotateGesture;

    UIImage *_originalImage;
    
    CGRect _wrapFGImageFrame;
    
    BOOL _supportZoomCanvas;
}

@property (readwrite, nonatomic) CGRect magnifierRectLeft;
@property (readwrite, nonatomic) CGRect magnifierRectRight;

@property (strong, nonatomic) UIView *magnifierShellView;
@property (strong, nonatomic) MagnifierView *magnifierView;
@property (strong, nonatomic) ZoomView *zoomView;

@property (strong, nonatomic) UIImageView *shapeView;
@end

@implementation ComprehensiveCutoutView

-(ComprehensiveCutoutView *)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.autoresizesSubviews = NO;
        self.autoresizingMask = UIViewAutoresizingNone;
        
        _supportZoomCanvas = [ZBCommonMethod systemVersion]>=8.0;
        _shellView = [[UIView alloc] init];
        [self addSubview:_shellView];
        [_shellView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(_shellView.mas_height).multipliedBy(image.size.width/image.size.height);
            
            make.width.height.lessThanOrEqualTo(self);
            make.width.height.equalTo(self).with.priorityLow();
            
            make.center.equalTo(self);
        }];
        _shellView.autoresizesSubviews = NO;
        ;
        _containerView = [[UIView alloc] init];
        _containerView.clipsToBounds = YES;
        [_shellView addSubview:_containerView];
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(_shellView);
        }];

        _imageView = [[UIImageView alloc] initWithFrame:_containerView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.image = image;
        [_containerView addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(_containerView);
        }];

        _baseSelectedcolorView = [[UIImageView alloc] init];
        _baseSelectedcolorView.contentMode = UIViewContentModeScaleAspectFill;
        [_containerView addSubview:_baseSelectedcolorView];
        [_baseSelectedcolorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(_containerView);
        }];
        _baseSelectedcolorView.hidden = YES;
        
        _selectedColorView = [[UIImageView alloc] init];
        _selectedColorView.contentMode = UIViewContentModeScaleAspectFill;
        [_containerView addSubview:_selectedColorView];
        [_selectedColorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(_containerView);
        }];
//        _selectedColorView.hidden = YES;
        
        _selectionColorView = [[UIImageView alloc] init];
        _selectionColorView.contentMode = UIViewContentModeScaleAspectFill;
        [_containerView addSubview:_selectionColorView];
        [_selectionColorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(_containerView);
        }];
        
        _selectionMaskView = [[ComprehensiveCutoutMaskView alloc] initWithFrame:_containerView.bounds andImageWidth:image.size.width andImageHeight:image.size.height];
        _selectionColorView.layer.mask = _selectionMaskView.layer;
        
        _drawView = [[ComprehensiveCutoutDrawView alloc] initWithFrame:_containerView.bounds andImageWidth:image.size.width andImageHeight:image.size.height];
        _drawView.userInteractionEnabled = NO;
        _drawView.delegate = self;
        [_containerView addSubview:_drawView];
        [_drawView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(_containerView);
        }];
        
        // shape move & scale & rotate
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
        pinchGesture.delegate = self;
        [self addGestureRecognizer:pinchGesture];
        _pinchGesture = pinchGesture;
        
        UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onRotate:)];
        rotateGesture.delegate = self;
        [self addGestureRecognizer:rotateGesture];
        _rotateGesture = rotateGesture;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
        _panGesture = panGesture;
        
        [self updateForSizeChange];
        _viewScale = 1.0;
        _smallImageScale = [UIScreen mainScreen].bounds.size.height>480?1.0/3.0:1.0/4.0;
        _originalImage = image;
        
        self.brushSmooth = 0.0;
        self.refineBrushRadius = 25.0;
        
        NSLog(@"%s", __FUNCTION__);
    }
    
    return self;
}

-(UIImageView *)shapeView
{
    if (!_shapeView) {
        _shapeView = [[UIImageView alloc] init];
        [_containerView addSubview:_shapeView];
        _shapeView.alpha = 0.5;
    }
    return _shapeView;
}

-(void)configShapeView
{
    self.shapeView.center = [self.shapeView.superview convertPoint:_selectionMaskView.shapeMaskView.shapeMaskImageView.center fromView:_selectionMaskView.shapeMaskView.shapeMaskImageView.superview];
    self.shapeView.bounds = _selectionMaskView.shapeMaskView.shapeMaskImageView.bounds;
    self.shapeView.transform = _selectionMaskView.shapeMaskView.shapeMaskImageView.transform;
    self.shapeView.image = _selectionMaskView.shapeMaskView.shapeMaskImageView.image;
    self.shapeView.contentMode = _selectionMaskView.shapeMaskView.shapeMaskImageView.contentMode;
}

-(CGRect)magnifierRectLeft
{
    if (CGRectIsEmpty(_magnifierRectLeft)) {
        CGRect frame = [UIScreen mainScreen].bounds;
        CGFloat mirrorScale = UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad?0.15:0.3;
        CGFloat mirrorWidth = frame.size.width*mirrorScale;
        CGFloat mirrorHeight = frame.size.height*mirrorScale;
        mirrorHeight = mirrorWidth;
        _magnifierRectLeft = CGRectMake(0, 0, mirrorWidth, mirrorHeight);
    }
    return _magnifierRectLeft;
}
-(CGRect)magnifierRectRight
{
    if (CGRectIsEmpty(_magnifierRectRight)) {
        CGRect frame = [UIScreen mainScreen].bounds;
        CGFloat mirrorScale = UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad?0.15:0.3;
        CGFloat mirrorWidth = frame.size.width*mirrorScale;
        CGFloat mirrorHeight = frame.size.height*mirrorScale;
        mirrorHeight = mirrorWidth;
        _magnifierRectRight = CGRectMake(frame.size.width-mirrorWidth, 0, mirrorWidth, mirrorHeight);
    }
    return _magnifierRectRight;
    
}
-(UIView *)magnifierShellView
{
    if (!_magnifierShellView) {
        _magnifierShellView = [[UIView alloc] initWithFrame:self.magnifierRectLeft];
        _magnifierShellView.layer.borderColor = [UIColor whiteColor].CGColor;
        _magnifierShellView.layer.borderWidth = 2.0;
        _magnifierShellView.layer.cornerRadius = 2.0;
        _magnifierShellView.clipsToBounds = YES;
        
        [self.magnifierShellView addSubview:self.magnifierView];
        
        [self.magnifierShellView addSubview:self.zoomView];
    }
    return _magnifierShellView;
}

-(MagnifierView *)magnifierView
{
    if (!_magnifierView) {
        _magnifierView = [[MagnifierView alloc] initWithFrame:self.magnifierShellView.bounds];
        _magnifierView.zoomScale = 1.0;
        [self.magnifierShellView addSubview:_magnifierView];
    }
    return _magnifierView;
}

-(ZoomView *)zoomView
{
    if (!_zoomView) {
        _zoomView = [[ZoomView alloc] initWithFrame:self.magnifierShellView.bounds andCircleRadius:5.0];
        _zoomView.center = self.magnifierView.center;
        _zoomView.hasCross = NO;
        _zoomView.circleLineWidth = 0.0;
    }
    return _zoomView;
}

-(void)updateMagifierViewToPoint:(CGPoint)point end:(BOOL)end begin:(BOOL)begin
{
    if (end || _cutoutMode == kCutoutModeShape || _cutoutMode == kCutoutModeNone) {
        [self.magnifierShellView removeFromSuperview];
        return;
    }
    
    CGPoint touchPoint = [self.magnifierParentView convertPoint:point fromView:self];
    CGPoint magifyPoint = [_containerView convertPoint:point fromView:self];
    
    CGPoint finalMagifyPoint = magifyPoint;
    
    finalMagifyPoint.x = MIN(MAX(CGRectGetWidth(self.magnifierShellView.bounds)/2.0/_viewScale, magifyPoint.x), CGRectGetWidth(_containerView.bounds)-CGRectGetWidth(self.magnifierShellView.bounds)/2.0/_viewScale);
    finalMagifyPoint.y = MIN(MAX(CGRectGetHeight(self.magnifierShellView.bounds)/2.0/_viewScale, magifyPoint.y), CGRectGetHeight(_containerView.bounds)-CGRectGetHeight(self.magnifierShellView.bounds)/2.0/_viewScale);
    
    if (CGRectContainsPoint(self.magnifierShellView.frame, touchPoint)) {
        if (CGRectContainsPoint(self.magnifierRectLeft, touchPoint)) {
            self.magnifierShellView.frame = self.magnifierRectRight;
        }
        else
        {
            self.magnifierShellView.frame = self.magnifierRectLeft;
        }
    }
    
    if (begin) {
        [self.magnifierView setViewToMagnify:_containerView];
        self.magnifierView.zoomScale = _viewScale;
        
        switch (_cutoutMode) {
            case kCutoutModeNormalBrush:
                self.zoomView.innerColor = [self.maskColor colorWithAlphaComponent:0.5];;
                self.zoomView.circleRadius = (_selectionMaskView.brushRadius*(1.0+_selectionMaskView.brushSmooth*0.5) + 1)*_viewScale;
                break;
            case kCutoutModeSmartScissors:
                self.zoomView.innerColor = [self.maskColor colorWithAlphaComponent:0.5];;
                self.zoomView.circleRadius = _drawView.lineWidth*0.5*_viewScale;
                break;
            case kCutoutModeNormalEraser:
                self.zoomView.innerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
                self.zoomView.circleRadius = (_selectionMaskView.brushRadius*(1.0+_selectionMaskView.brushSmooth*0.5) + 1)*_viewScale;
                break;
            default:
                self.zoomView.innerColor = [UIColor clearColor];
                break;
        }
        
        [self.magnifierParentView addSubview:self.magnifierShellView];
        self.magnifierShellView.backgroundColor = [UIColor redColor];
    }
    
    [self.magnifierView setMagnifyPoint:finalMagifyPoint];
    [self.magnifierView setNeedsDisplay];
    self.zoomView.center = CGPointMake(CGRectGetMidX(self.magnifierShellView.bounds)+(magifyPoint.x-finalMagifyPoint.x)*_viewScale, CGRectGetMidY(self.magnifierShellView.bounds)+(magifyPoint.y-finalMagifyPoint.y)*_viewScale);
}

-(void)onPinch:(UIPinchGestureRecognizer *)pinchGesture
{
    switch (_cutoutMode) {
        case kCutoutModeShape:
            _currentTouchEverChangeShape = YES;
            [_selectionMaskView zoomByScale:pinchGesture.scale];
            break;
        case kCutoutModeNormalBrush:
        case kCutoutModeNormalEraser:
        case kCutoutModeSmartScissors:
        {
            _currentTouchEverScale = YES;
            [self zoomByScale:pinchGesture.scale atAnchorPoint:[pinchGesture locationInView:_containerView.superview]];
            break;
        }
        default:
            break;
    }
    
    switch (pinchGesture.state) {
        case UIGestureRecognizerStateBegan:
            [self beginGestureType:1];
            break;
        case UIGestureRecognizerStateChanged:
            [self changeGestureType:1];
            break;
        case UIGestureRecognizerStateEnded:
            if (_currentTouchEverChangeShape) {
                if ([self.delegate respondsToSelector:@selector(comprehensiveCutoutViewDidChange:)]) {
                    [self.delegate comprehensiveCutoutViewDidChange:self];
                }
                [_selectionMaskView makeAndPushHistoryFrame:2];
            }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self endGestureType:1];
            _currentTouchEverScale = NO;
            _currentTouchEverChangeShape = NO;
            break;
        default:
            break;
    }

    [pinchGesture setScale:1.0];
}

// 0 - move; 1 - pinch; 2 - rotate
-(void)beginGestureType:(NSInteger)type
{
    switch (_cutoutMode) {
        case kCutoutModeShape:
            [self configShapeView];
            self.shapeView.hidden = NO;
            break;
            
        default:
            break;
    }
}

-(void)changeGestureType:(NSInteger)type
{
    switch (_cutoutMode) {
        case kCutoutModeShape:
            [self configShapeView];

            break;
            
        default:
            break;
    }
}

-(void)endGestureType:(NSInteger)type
{
    switch (_cutoutMode) {
        case kCutoutModeShape:
            [self configShapeView];
            self.shapeView.hidden = YES;
            break;
            
        default:
            break;
    }
}

-(void)onRotate:(UIRotationGestureRecognizer *)rotateGesture
{
    switch (_cutoutMode) {
        case kCutoutModeShape:
            _currentTouchEverChangeShape = YES;
            [_selectionMaskView rotateByAngle:rotateGesture.rotation];
            break;
        case kCutoutModeNormalBrush:
        case kCutoutModeNormalEraser:
        case kCutoutModeSmartScissors:
        {
            _currentTouchEverScale = YES;
//            [self rotateByAngle:rotateGesture.rotation];
            break;
        }
        default:
            break;
    }
    
    switch (rotateGesture.state) {
        case UIGestureRecognizerStateBegan:
            [self beginGestureType:2];
            break;
        case UIGestureRecognizerStateChanged:
            [self changeGestureType:2];
            break;
        case UIGestureRecognizerStateEnded:
            if (_currentTouchEverChangeShape) {
                if ([self.delegate respondsToSelector:@selector(comprehensiveCutoutViewDidChange:)]) {
                    [self.delegate comprehensiveCutoutViewDidChange:self];
                }
                [_selectionMaskView makeAndPushHistoryFrame:2];

            }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self endGestureType:2];
            _currentTouchEverScale = NO;
            _currentTouchEverChangeShape = NO;
            break;
        default:
            break;
    }
    
    [rotateGesture setRotation:0.0];
}

-(void)onPan:(UIPanGestureRecognizer *)panGesture
{
    switch (_cutoutMode) {
        case kCutoutModeShape:
            _currentTouchEverChangeShape = YES;
            [_selectionMaskView translateByOffset:[panGesture translationInView:self]];
            break;
        case kCutoutModeSmartScissors:
        {
            if ([panGesture numberOfTouches] == 1) {
                switch (panGesture.state) {
                    case UIGestureRecognizerStateBegan:
                        _currentTouchEverDraw_1 = YES;
                        [_drawView privateTouchesBeganAtPoint:[panGesture locationInView:_drawView]];
                        break;
                    case UIGestureRecognizerStateChanged:
                        if (_currentTouchEverDraw_1) {
                            [_drawView privateTouchesMovedToPoint:[panGesture locationInView:_drawView]];
                        }
                        break;
                    default:
                        break;
                }
            }
            else
            {
                switch (panGesture.state) {
                    case UIGestureRecognizerStateChanged:
                        [self translateByOffset:[panGesture translationInView:self]];
                        break;
                    default:
                        break;
                }
            }
            
            switch (panGesture.state) {
                case UIGestureRecognizerStateEnded:
                {
                    if (_currentTouchEverDraw_1)
                    {
                        [_drawView privateTouchesEndedAtPoint:[panGesture locationInView:_drawView]];
                    }
                    break;
                }
                case UIGestureRecognizerStateCancelled:
                case UIGestureRecognizerStateFailed:
                {
                    if (_currentTouchEverDraw_1) {
                        [_drawView privateTouchesCancelled];
                    }
                }
                default:
                    break;
            }
            break;
        }
        case kCutoutModeNormalBrush:
        case kCutoutModeNormalEraser:
        {
            if ([panGesture numberOfTouches] == 1) {
                switch (panGesture.state) {
                    case UIGestureRecognizerStateBegan:
                        _currentTouchEverDraw = YES;
                        [_selectionMaskView privateTouchesBeganAtPoint:[panGesture locationInView:_selectionColorView]];
                        break;
                    case UIGestureRecognizerStateChanged:
                        if (_currentTouchEverDraw) {
                            [_selectionMaskView privateTouchesMovedToPoint:[panGesture locationInView:_drawView]];
                        }
                        break;
                    default:
                        break;
                }
            }
            else
            {
                switch (panGesture.state) {
                    case UIGestureRecognizerStateChanged:
                        [self translateByOffset:[panGesture translationInView:self]];
                        break;
                    default:
                        break;
                }
            }
            
            switch (panGesture.state) {
                case UIGestureRecognizerStateEnded:
                {
                    if (_currentTouchEverDraw)
                    {
                        [_selectionMaskView privateTouchesEndedAtPoint:[panGesture locationInView:_selectionColorView]];
                    }
                    break;
                }
                case UIGestureRecognizerStateCancelled:
                case UIGestureRecognizerStateFailed:
                {
                    if (_currentTouchEverDraw) {
                        [_selectionMaskView privateTouchesCancelled];
                    }
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    CGPoint point = [panGesture locationInView:self];
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            [self updateMagifierViewToPoint:point end:NO begin:YES];
            if ([self.delegate respondsToSelector:@selector(comprehensiveCutoutViewWillBeginDraw:)]) {
                [self.delegate comprehensiveCutoutViewWillBeginDraw:self];
            }
            [self beginGestureType:0];
            break;
        case UIGestureRecognizerStateChanged:
            [self updateMagifierViewToPoint:point end:NO begin:NO];
            [self changeGestureType:0];
            break;
        case UIGestureRecognizerStateEnded:
            if (_currentTouchEverChangeShape || _currentTouchEverDraw) {
                if ([self.delegate respondsToSelector:@selector(comprehensiveCutoutViewDidChange:)]) {
                    [self.delegate comprehensiveCutoutViewDidChange:self];
                }
                if (_currentTouchEverChangeShape) {
                    [_selectionMaskView makeAndPushHistoryFrame:2];
                }
            }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self updateMagifierViewToPoint:point end:YES begin:NO];
            [self endGestureType:0];
            _currentTouchEverScale = NO;
            _currentTouchEverChangeShape = NO;
            _currentTouchEverDraw = NO;
            _currentTouchEverDraw_1 = NO;

            if ([self.delegate respondsToSelector:@selector(comprehensiveCutoutViewDidEndDraw:)]) {
                [self.delegate comprehensiveCutoutViewDidEndDraw:self];
            }
            
            break;
        default:
            break;
    }

    [panGesture setTranslation:CGPointZero inView:self];
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    return YES;
//}

#pragma mark -
-(void)updateForSizeChange
{
//    _selectionColorView.layer.mask = nil;
    [_drawView updateContextSize];
    
    _selectionMaskView.frame = _selectionColorView.bounds;
    [_selectionMaskView updateContextSize];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        _selectionColorView.layer.mask = _selectionMaskView.layer;
//    });
    _containerView.transform = CGAffineTransformIdentity;
    _viewScale = 1.0;
}

-(void)resetContainer;
{
    _containerView.transform = CGAffineTransformIdentity;
    _containerView.center = CGPointMake(CGRectGetMidX(_containerView.superview.bounds), CGRectGetMidY(_containerView.superview.bounds));
}

-(void)setCutoutMode:(CutoutMode)cutoutMode
{
    switch (cutoutMode) {
        case kCutoutModeNormalBrush:
            _selectionMaskView.eraseMode = NO;
            break;
        case kCutoutModeNormalEraser:
            _selectionMaskView.eraseMode = YES;
            break;
        case kCutoutModeShape:
            break;
        case kCutoutModeSmartScissors:
            _drawView.forClosedArea = YES;
            _drawView.forClosedAreaWithContour = YES;
            [_drawView setFillColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
            [_drawView setLineColor:[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5]];
            [_drawView setLineWidth:16.0];
            break;
        default:
            break;
    }
    
    _cutoutMode = cutoutMode;
}

-(void)setMaskColor:(UIColor *)color
{
    _maskColor = color;
    _selectionColorView.backgroundColor = color;
}

-(CGFloat)brushSmooth
{
    return [_selectionMaskView brushSmooth];
}

-(void)setBrushSmooth:(CGFloat)smoothness
{
    [_selectionMaskView setBrushSmooth:smoothness];
}

-(void)setBrushRadius:(NSInteger)radius
{
    _brushRadius = radius;
//    _selectionMaskView.brushRadius = _brushRadius/MAX(log(_viewScale+1), 1.0);
    if (_viewScale > 1.0)
    {
        _selectionMaskView.brushRadius = _brushRadius/(1.0+log(_viewScale)*5.0);
    }
    else
    {
        _selectionMaskView.brushRadius = _brushRadius;
    }
}

-(CGFloat)brushAlpha
{
    return [_selectionMaskView brushAlpha];
}
-(void)setBrushAlpha:(CGFloat)alpha
{
    [_selectionMaskView setBrushAlpha:alpha];
}
-(void)setRefineBrushRadius:(NSInteger)refineBrushRadius
{
    _refineBrushRadius = refineBrushRadius;
}

-(void)setDrawLineColor:(UIColor *)color
{
    [_drawView setLineColor:color];
}
-(void)setDrawLineWidth:(CGFloat)lineWidth
{
    [_drawView setLineWidth:lineWidth];
}
-(CGFloat)drawLineWidth
{
    return [_drawView lineWidth];
}

// shape mode
-(void)resetShapeView;
{
    [_selectionMaskView resetShapeView];
}
-(void)setShapeImage:(UIImage *)image;
{
    [_selectionMaskView setShapeMaskImage:image];
}
-(void)conformShape;
{
    UIImage *maskImage = [_selectionMaskView getMaskImage];
//    [_selectionMaskView setFixMaskImage:maskImage];
//    [_selectionMaskView setShapeMaskImage:nil];
    
    [_selectionMaskView setFixMaskImage:maskImage andShapeMaskImage:nil record:NO];
}

-(void)undo;
{
    [_selectionMaskView undo];
}
-(void)redo;
{
    [_selectionMaskView redo];
}
-(BOOL)canUndo;
{
    return [_selectionMaskView canUndo];
}
-(BOOL)canRedo;
{
    return [_selectionMaskView canRedo];
}

-(void)jumpToLast;
{
    [_selectionMaskView jumpToLast];
}
-(void)jumpToFirst;
{
    [_selectionMaskView jumpToFirst];
}

-(void)useHistoryIndex:(NSInteger)idx
{
    [_selectionMaskView useHistoryIndex:idx];
}

-(void)clearHistoryIndex:(NSInteger)idx
{
    [_selectionMaskView clearHistoryIndex:idx];
}

#pragma mark -

-(void)setDefaultParaments
{
    [self setMaskColor:[[UIColor cyanColor] colorWithAlphaComponent:0.5]];
    [self setBrushRadius:15];
    [self setBrushSmooth:1.0];
    [self setBrushAlpha:0.5];
    [self setDrawLineColor:[UIColor whiteColor]];
    [self setDrawLineWidth:3];

    [self setCutoutMode:kCutoutModeSmartScissors];
}

#pragma mark - touches

-(void)zoomByScale:(CGFloat)scale atAnchorPoint:(CGPoint)anchorPoint
{
    [self updateMagifierViewToPoint:anchorPoint end:YES begin:NO];
    
    if (_viewScale * scale < 0.1) {
        scale = 0.1/_viewScale;
    }
    else if (_viewScale * scale > 20.0)
    {
        scale = 20.0/_viewScale;
    }
    _viewScale *= scale;
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformMakeTranslation(anchorPoint.x-_containerView.center.x, anchorPoint.y-_containerView.center.y);
    t = CGAffineTransformScale(t, scale, scale);
    t = CGAffineTransformTranslate(t, -(anchorPoint.x-_containerView.center.x), -(anchorPoint.y-_containerView.center.y));
    _containerView.transform = CGAffineTransformConcat(_containerView.transform, t);
    
    if (_viewScale > 1)
    {
        _selectionMaskView.brushRadius = _brushRadius/(1.0+log(_viewScale)*5.0);
    }
    else
    {
        _selectionMaskView.brushRadius = _brushRadius;
    }
}
-(void)rotateByAngle:(CGFloat)angle
{
    _containerView.transform = CGAffineTransformRotate(_containerView.transform, angle);
}
-(void)translateByOffset:(CGPoint)offset;
{
    if (!_supportZoomCanvas) {
        return;
    }
    CGPoint center = _containerView.center;
    center.x += offset.x;
    center.y += offset.y;
    
    _containerView.center = center;
}

#pragma mark -
#pragma mark - cut
/*
-(void) cutBigImage:(UIImage *)bigImage withMask:(cv::Mat)maskMat inRect:(cv::Rect)targetMaskRect toResultMat:(cv::Mat &) resultMat
{
    cv::Mat bigSizeImageMat;// UIImageToMat(bigImage, bigSizeImageMat);
    bigSizeImageMat = [UIImage mat8UC3WithImage:bigImage];
    
    cv::Mat targetMaskMat;
    maskMat(targetMaskRect).copyTo(targetMaskMat);
#ifdef DEBUG
    NSTimeInterval begin = [NSDate timeIntervalSinceReferenceDate], end;
#endif
    
    // randomly select as many pr background points as foreground points in the target mat.
    NSInteger targetSelectedCount = 0, targetNotSelectedCount = 0;
    
    std::vector<cv::Point> targetNotSelectedPoints;
    uchar *ptrTargetMask;
    cv::Point point;
    for (point.y=0; point.y<targetMaskMat.rows; ++point.y) {
        ptrTargetMask = targetMaskMat.ptr<uchar>(point.y);
        for (point.x=0; point.x<targetMaskMat.cols; ++point.x) {
            if (ptrTargetMask[point.x] == cv::GC_FGD) {
                ++targetSelectedCount;
            }
            else
            {
                targetNotSelectedPoints.push_back(point);
            }
        }
    }
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"select pr bgd point use %d ms", (int)((end-begin)*1000)); begin=end;
#endif
    
    std::random_shuffle(targetNotSelectedPoints.begin(), targetNotSelectedPoints.end());
    targetNotSelectedCount = targetNotSelectedPoints.size();
#ifdef DEBUG
    
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"select pr bgd point use %d ms", (int)((end-begin)*1000)); begin=end;
#endif
    
    for (int i=0; i<targetSelectedCount && i<targetNotSelectedCount; ++i) {
        cv::Point &point = targetNotSelectedPoints[i];
        targetMaskMat.at<uchar>(point) = cv::GC_PR_BGD;
    }
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"select pr bgd point use %d ms", (int)((end-begin)*1000));
    NSLog(@"target selected point: %ld, target not selected point: %ld", (long)targetSelectedCount, (long)targetNotSelectedCount); begin=end;
#endif
    
    // set rect borders to background
    if (targetMaskRect.x > 0)
        targetMaskMat.col(0).setTo(cv::GC_BGD);
    if (targetMaskRect.x+targetMaskRect.width < bigSizeImageMat.cols-1)
        targetMaskMat.col(targetMaskMat.cols-1).setTo(cv::GC_BGD);
    if (targetMaskRect.y > 0)
        targetMaskMat.row(0).setTo(cv::GC_BGD);
    if (targetMaskRect.y+targetMaskRect.height < bigSizeImageMat.rows-1)
        targetMaskMat.row(targetMaskMat.rows-1).setTo(cv::GC_BGD);
    
    if (_faceDetectEnable && _hasLeftEye) {
        cv::Rect featureRect = _leftEyeRect;
        featureRect = featureRect&targetMaskRect;
        featureRect.x -= targetMaskRect.x;
        featureRect.y -= targetMaskRect.y;
        featureRect = featureRect & cv::Rect(0, 0, targetMaskMat.cols, targetMaskMat.rows);
        
        targetMaskMat(featureRect).setTo(cv::GC_FGD);
    }
    
    if (_faceDetectEnable && _hasRightEye) {
        cv::Rect featureRect = _rightEyeRect;
        featureRect = featureRect&targetMaskRect;
        featureRect.x -= targetMaskRect.x;
        featureRect.y -= targetMaskRect.y;
        featureRect = featureRect & cv::Rect(0, 0, targetMaskMat.cols, targetMaskMat.rows);

        targetMaskMat(featureRect).setTo(cv::GC_FGD);
    }
    
    if (_faceDetectEnable && _hasMouth) {
        cv::Rect featureRect = _mouthRect;
        featureRect = featureRect&targetMaskRect;
        featureRect.x -= targetMaskRect.x;
        featureRect.y -= targetMaskRect.y;
        featureRect = featureRect & cv::Rect(0, 0, targetMaskMat.cols, targetMaskMat.rows);

        targetMaskMat(featureRect).setTo(cv::GC_FGD);
    }
    
    // cut the target image
    cv::Mat targetImageMat = bigSizeImageMat(targetMaskRect);
    //    cv::cvtColor(bigSizeImageMat(targetMaskRect), targetImageMat, CV_RGBA2RGB);
    
    cv::Mat bgdModel, fgdModel;
    GCGrabCut cutter;
    cutter.cutImage(targetImageMat, targetMaskMat, targetMaskRect, bgdModel, fgdModel, 1, cv::GC_INIT_WITH_MASK);
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"first cut use %d ms", (int)((end-begin)*1000)); begin=end;
#endif
    
    // merge the target area to result and update mask image
    
    resultMat.create(maskMat.size(), CV_8UC4);
    resultMat.setTo(cv::Scalar(0, 0, 0, 0));
    cv::Mat targetTemp = resultMat(targetMaskRect);
    
    int width = targetMaskMat.cols;
    int height = targetMaskMat.rows;
    
    uchar *maskPtr;
    cv::Vec4b *tempPtr;
    
    cv::Vec4b fgColor = cv::Vec4b(255, 255, 255, 255);
    cv::Vec4b bgColor = cv::Vec4b(0, 0, 0, 0);
    
    for (int y=0; y<height; ++y) {
        maskPtr = targetMaskMat.ptr<uchar>(y);
        tempPtr = targetTemp.ptr<cv::Vec4b>(y);
        
        for (int x=0; x<width; ++x) {
            
            (*tempPtr) = (*maskPtr==cv::GC_FGD || *maskPtr==cv::GC_PR_FGD)?fgColor:bgColor;
            ++maskPtr;
            ++tempPtr;
        }
    }
}

-(void) cutScaledImage:(UIImage *)bigImage withMask:(cv::Mat)maskMat andImageScale:(CGFloat)smallImageScale inRect:(cv::Rect)targetMaskRect toResultMat:(cv::Mat &) resultMat
{
    UIImage *scaledImage = [bigImage rotateAndScale:smallImageScale];
    cv::Mat imageMat; //UIImageToMat(scaledImage, imageMat);
    imageMat = [UIImage mat8UC3WithImage:scaledImage];
    scaledImage = nil;
    
    cv::Mat bigSizeImageMat;// UIImageToMat(bigImage, bigSizeImageMat);
    bigSizeImageMat = [UIImage mat8UC3WithImage:bigImage];
    
    // 1. update maskMat & get the selected points containing rect.
    cv::Rect bigSizeTargetRect = targetMaskRect;
    
    targetMaskRect.x = (bigSizeTargetRect.x+(1.0/smallImageScale-1))*smallImageScale;
    targetMaskRect.y = (bigSizeTargetRect.y+(1.0/smallImageScale-1))*smallImageScale;
    targetMaskRect.width = (bigSizeTargetRect.width+(1.0/smallImageScale-1))*smallImageScale;
    targetMaskRect.height = (bigSizeTargetRect.height+(1.0/smallImageScale-1))*smallImageScale;
    
    if (targetMaskRect.x>=imageMat.cols) targetMaskRect.x=imageMat.cols-1;
    if (targetMaskRect.y>=imageMat.rows) targetMaskRect.y=imageMat.rows-1;
    if (targetMaskRect.x+targetMaskRect.width>imageMat.cols) targetMaskRect.width=imageMat.cols-targetMaskRect.x;
    if (targetMaskRect.y+targetMaskRect.height>imageMat.rows) targetMaskRect.height=imageMat.rows-targetMaskRect.y;
    
    int fgdCnt=0;
    cv::Mat targetMaskMat; targetMaskMat.create(targetMaskRect.height, targetMaskRect.width, CV_8UC1);
    for (int i=0; i<targetMaskMat.rows; ++i) {
        for (int j=0; j<targetMaskMat.cols; ++j) {
            cv::Point point;
            point.x = (targetMaskRect.x+j)/smallImageScale;
            point.y = (targetMaskRect.y+i)/smallImageScale;
            
            if (point.x >= maskMat.cols) {
                point.x = maskMat.cols-1;
            }
            if (point.y >= maskMat.rows) {
                point.y = maskMat.rows-1;
            }
            targetMaskMat.at<uchar>(i, j) = maskMat.at<uchar>(point);
            if (targetMaskMat.at<uchar>(i,j) == cv::GC_FGD || targetMaskMat.at<uchar>(i,j) == cv::GC_PR_FGD) {
                ++fgdCnt;
            }
        }
    }
    if (fgdCnt == 0) {
        return;
    }
#ifdef DEBUG
    NSTimeInterval begin = [NSDate timeIntervalSinceReferenceDate], end;
#endif
    
    // randomly select as many pr background points as foreground points in the target mat.
    NSInteger targetSelectedCount = 0, targetNotSelectedCount = 0;
    
    std::vector<cv::Point> targetNotSelectedPoints;
    uchar *ptrTargetMask;
    cv::Point point;
    for (point.y=0; point.y<targetMaskMat.rows; ++point.y) {
        ptrTargetMask = targetMaskMat.ptr<uchar>(point.y);
        for (point.x=0; point.x<targetMaskMat.cols; ++point.x) {
            if (ptrTargetMask[point.x] == cv::GC_FGD) {
                ++targetSelectedCount;
            }
            else
            {
                targetNotSelectedPoints.push_back(point);
            }
        }
    }
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"select pr bgd point use %d ms", (int)((end-begin)*1000)); begin=end;
#endif
    
    std::random_shuffle(targetNotSelectedPoints.begin(), targetNotSelectedPoints.end());
    targetNotSelectedCount = targetNotSelectedPoints.size();
#ifdef DEBUG
    
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"select pr bgd point use %d ms", (int)((end-begin)*1000)); begin=end;
#endif
    
    for (int i=0; i<targetNotSelectedCount && i<targetNotSelectedCount; ++i) {
        cv::Point &point = targetNotSelectedPoints[i];
        targetMaskMat.at<uchar>(point) = cv::GC_PR_BGD;
    }
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"select pr bgd point use %d ms", (int)((end-begin)*1000));
    NSLog(@"target selected point: %ld, target not selected point: %ld", (long)targetSelectedCount, (long)targetNotSelectedCount); begin=end;
#endif
    
    // set rect borders to background
    if (targetMaskRect.x > 0)
        targetMaskMat.col(0).setTo(cv::GC_BGD);
    if (targetMaskRect.x+targetMaskRect.width< imageMat.cols-1)
        targetMaskMat.col(targetMaskMat.cols-1).setTo(cv::GC_BGD);
    if (targetMaskRect.y > 0)
        targetMaskMat.row(0).setTo(cv::GC_BGD);
    if (targetMaskRect.y+targetMaskRect.height < imageMat.rows-1)
        targetMaskMat.row(targetMaskMat.rows-1).setTo(cv::GC_BGD);
    
    if (_faceDetectEnable && _hasLeftEye) {
        
        cv::Rect smallFeatureRect;
        cv::Rect featureRect = _leftEyeRect;
        smallFeatureRect.x = (featureRect.x+(1.0/smallImageScale-1))*smallImageScale;
        smallFeatureRect.y = (featureRect.y+(1.0/smallImageScale-1))*smallImageScale;
        smallFeatureRect.width = (featureRect.width+(1.0/smallImageScale-1))*smallImageScale;
        smallFeatureRect.height = (featureRect.height+(1.0/smallImageScale-1))*smallImageScale;
        
        smallFeatureRect.x -= targetMaskRect.x;
        smallFeatureRect.y -= targetMaskRect.y;

        cv::Rect targetRect = targetMaskRect;
        targetRect.x = 0; targetRect.y = 0;
        smallFeatureRect = smallFeatureRect&targetRect;

        targetMaskMat(smallFeatureRect).setTo(cv::GC_FGD);
    }

    if (_faceDetectEnable && _hasRightEye) {
        cv::Rect smallFeatureRect;
        cv::Rect featureRect = _rightEyeRect;
        smallFeatureRect.x = (featureRect.x+(1.0/smallImageScale-1))*smallImageScale;
        smallFeatureRect.y = (featureRect.y+(1.0/smallImageScale-1))*smallImageScale;
        smallFeatureRect.width = (featureRect.width+(1.0/smallImageScale-1))*smallImageScale;
        smallFeatureRect.height = (featureRect.height+(1.0/smallImageScale-1))*smallImageScale;
        
        smallFeatureRect.x -= targetMaskRect.x;
        smallFeatureRect.y -= targetMaskRect.y;
        
        cv::Rect targetRect = targetMaskRect;
        targetRect.x = 0; targetRect.y = 0;
        smallFeatureRect = smallFeatureRect&targetRect;
        
        targetMaskMat(smallFeatureRect).setTo(cv::GC_FGD);
    }
    
    if (_faceDetectEnable && _hasMouth) {
        cv::Rect smallFeatureRect;
        cv::Rect featureRect = _mouthRect;
        smallFeatureRect.x = (featureRect.x+(1.0/smallImageScale-1))*smallImageScale;
        smallFeatureRect.y = (featureRect.y+(1.0/smallImageScale-1))*smallImageScale;
        smallFeatureRect.width = (featureRect.width+(1.0/smallImageScale-1))*smallImageScale;
        smallFeatureRect.height = (featureRect.height+(1.0/smallImageScale-1))*smallImageScale;
        
        smallFeatureRect.x -= targetMaskRect.x;
        smallFeatureRect.y -= targetMaskRect.y;
        
        cv::Rect targetRect = targetMaskRect;
        targetRect.x = 0; targetRect.y = 0;
        smallFeatureRect = smallFeatureRect&targetRect;
        
        targetMaskMat(smallFeatureRect).setTo(cv::GC_FGD);
    }
    
    // cut the scaled target image
    cv::Mat targetImageMat = imageMat(targetMaskRect);
    //    cv::cvtColor(imageMat(targetMaskRect), targetImageMat, CV_RGBA2RGB);
    
    cv::Mat bgdModel, fgdModel;
    GCGrabCut cutter;
    cutter.cutImage(targetImageMat, targetMaskMat, targetMaskRect, bgdModel, fgdModel, 1, cv::GC_INIT_WITH_MASK);
    
    // get the ribbon area
    cv::Mat bigSizeTargetMaskMat;
    cv::Mat bigSizeTargetImageMat = bigSizeImageMat(bigSizeTargetRect);
    // cv::cvtColor(bigSizeImageMat(bigSizeTargetRect), bigSizeTargetImageMat, CV_RGBA2RGB);
    
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"first cut use %d ms", (int)((end-begin)*1000)); begin=end;
#endif
    
    int nBGDCount=0, nFGDCount=0;
    bigSizeTargetMaskMat.create(bigSizeTargetImageMat.size(), CV_8UC1);
    cutter.labelRibbon(targetMaskMat, bigSizeTargetMaskMat, smallImageScale, nBGDCount, nFGDCount);
    
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"ribbon label use %d ms", (int)((end-begin)*1000)); begin=end;
    NSLog(@"background: %d, foreground: %d", nBGDCount, nFGDCount);
#endif
    
    // cut the ribbon area
    if (nBGDCount>0 && nFGDCount>0) {
        cutter.cutImage(bigSizeTargetImageMat, bigSizeTargetMaskMat, 1);
    }
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"second cut use %d ms", (int)((end-begin)*1000)); begin=end;
#endif
    
    // merge the target area to result and update mask image
    
    resultMat.create(maskMat.size(), CV_8UC4);
    resultMat.setTo(cv::Scalar(0, 0, 0, 0));
    cv::Mat targetTemp = resultMat(bigSizeTargetRect);
    
    int width = bigSizeTargetMaskMat.cols;
    int height = bigSizeTargetMaskMat.rows;
    
    uchar *maskPtr;
    cv::Vec4b *tempPtr;
    cv::Vec4b fgColor = cv::Vec4b(255, 255, 255, 255);
    
    for (int y=0; y<height; ++y) {
        maskPtr = bigSizeTargetMaskMat.ptr<uchar>(y);
        tempPtr = targetTemp.ptr<cv::Vec4b>(y);
        
        for (int x=0; x<width; ++x) {
            
            if (x*smallImageScale < targetImageMat.cols && y*smallImageScale < targetImageMat.rows)
            {
                uchar val = targetMaskMat.at<uchar>((int)floor(y*smallImageScale),(int)floor(x*smallImageScale));
                
                if (val == cv::GC_FGD || (val == cv::GC_PR_FGD && *maskPtr != cv::GC_PR_BGD))
                {
                    (*tempPtr) = fgColor;
                }
            }
            
            if(*maskPtr == cv::GC_PR_FGD)
            {
                (*tempPtr) = fgColor;
            }
            
            ++maskPtr;
            ++tempPtr;
        }
    }
}

*/

-(void) cutScaledImage_2:(UIImage *)bigImage withPreprocessedMask:(cv::Mat)maskMat andImageScale:(CGFloat)smallImageScale inRect:(cv::Rect)targetMaskRect toResultMat:(cv::Mat &) resultMat
{
    UIImage *scaledImage = [bigImage rotateAndScale:smallImageScale];
    cv::Mat imageMat;// UIImageToMat(scaledImage, imageMat);
    imageMat = [UIImage mat8UC4WithImage:scaledImage];
    cv::Mat bigSizeImageMat;// UIImageToMat(bigImage, bigSizeImageMat);
    bigSizeImageMat = [UIImage mat8UC4WithImage:bigImage];
    
    // 1. update maskMat & get the selected points containing rect.
    cv::Rect bigSizeTargetRect = targetMaskRect;
    
    targetMaskRect.x = (bigSizeTargetRect.x+(1.0/smallImageScale-1))*smallImageScale;
    targetMaskRect.y = (bigSizeTargetRect.y+(1.0/smallImageScale-1))*smallImageScale;
    targetMaskRect.width = (bigSizeTargetRect.width+(1.0/smallImageScale-1))*smallImageScale;
    targetMaskRect.height = (bigSizeTargetRect.height+(1.0/smallImageScale-1))*smallImageScale;
    
    if (targetMaskRect.x>=imageMat.cols) targetMaskRect.x=imageMat.cols-1;
    if (targetMaskRect.y>=imageMat.rows) targetMaskRect.y=imageMat.rows-1;
    if (targetMaskRect.x+targetMaskRect.width>imageMat.cols) targetMaskRect.width=imageMat.cols-targetMaskRect.x;
    if (targetMaskRect.y+targetMaskRect.height>imageMat.rows) targetMaskRect.height=imageMat.rows-targetMaskRect.y;
    
    int fgdCnt=0;
    int bgdCnt=0;
    cv::Mat targetMaskMat; targetMaskMat.create(targetMaskRect.height, targetMaskRect.width, CV_8UC1);
    for (int i=0; i<targetMaskMat.rows; ++i) {
        for (int j=0; j<targetMaskMat.cols; ++j) {
            cv::Point point;
            point.x = (targetMaskRect.x+j)/smallImageScale; point.y = (targetMaskRect.y+i)/smallImageScale;
            
            if (point.x >= maskMat.cols) {
                point.x = maskMat.cols-1;
            }
            if (point.y >= maskMat.rows) {
                point.y = maskMat.rows-1;
            }
            targetMaskMat.at<uchar>(i, j) = maskMat.at<uchar>(point);
            if (targetMaskMat.at<uchar>(i,j) == cv::GC_FGD || targetMaskMat.at<uchar>(i,j) == cv::GC_PR_FGD) {
                ++fgdCnt;
            }
            else if (targetMaskMat.at<uchar>(i,j) == cv::GC_BGD || targetMaskMat.at<uchar>(i,j) == cv::GC_PR_BGD) {
                ++bgdCnt;
            }
        }
    }
    
    if (fgdCnt == 0 || bgdCnt == 0) {
        return;
    }
#ifdef DEBUG
    NSTimeInterval begin = [NSDate timeIntervalSinceReferenceDate], end;
#endif
    
    // set rect borders to background
    if (targetMaskRect.x > 0)
        targetMaskMat.col(0).setTo(cv::GC_BGD);
    if (targetMaskRect.x+targetMaskRect.width < imageMat.cols-1)
        targetMaskMat.col(targetMaskMat.cols-1).setTo(cv::GC_BGD);
    if (targetMaskRect.y > 0)
        targetMaskMat.row(0).setTo(cv::GC_BGD);
    if (targetMaskRect.y+targetMaskRect.height < imageMat.rows-1)
        targetMaskMat.row(targetMaskMat.rows-1).setTo(cv::GC_BGD);
    
    // gen model
    cv::Mat targetImageMat;
    cv::cvtColor(imageMat(targetMaskRect), targetImageMat, CV_RGBA2RGB);
    
    cv::Mat bgdModel, fgdModel;
    GCGrabCut cutter;
    cutter.genModel(targetImageMat, targetMaskMat, targetMaskRect, bgdModel, fgdModel, 1);

    cv::Mat bigSizeTargetMaskMat;
    cv::Mat bigSizeTargetImageMat; cv::cvtColor(bigSizeImageMat(bigSizeTargetRect), bigSizeTargetImageMat, CV_RGBA2RGB);
    
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"first cut use %d ms", (int)((end-begin)*1000)); begin=end;
#endif
    
    int nBGDCount=0, nFGDCount=0;
    bigSizeTargetMaskMat.create(bigSizeTargetImageMat.size(), CV_8UC1);
    cutter.labelRibbon(targetMaskMat, bigSizeTargetMaskMat, smallImageScale, nBGDCount, nFGDCount);
    
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"ribbon label use %d ms", (int)((end-begin)*1000)); begin=end;
    NSLog(@"background: %d, foreground: %d", nBGDCount, nFGDCount);
#endif
    
    // cut the ribbon area
    if (nBGDCount>0 && nFGDCount>0) {
        cutter.cutImage(bigSizeTargetImageMat, bigSizeTargetMaskMat, 1);
    }
    
    NSLog(@"(%d, %d), (%d, %d)", bigSizeTargetRect.x, bigSizeTargetRect.y, bigSizeTargetRect.width, bigSizeTargetRect.height);
    
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"second cut use %d ms", (int)((end-begin)*1000)); begin=end;
#endif
    
    // merge the target area to result and update mask image
    
    resultMat.create(maskMat.size(), CV_8UC1);
    resultMat.setTo(cv::Scalar(0));
    cv::Mat targetTemp = resultMat(bigSizeTargetRect);
    
    int width = bigSizeTargetMaskMat.cols;
    int height = bigSizeTargetMaskMat.rows;
    
    uchar *maskPtr;
    uchar *tempPtr;
    uchar fgColor = 255;
    
    for (int y=0; y<height; ++y) {
        maskPtr = bigSizeTargetMaskMat.ptr<uchar>(y);
        tempPtr = targetTemp.ptr<uchar>(y);
        
        for (int x=0; x<width; ++x) {
            
            if (x*smallImageScale < targetImageMat.cols && y*smallImageScale < targetImageMat.rows)
            {
                uchar val = targetMaskMat.at<uchar>((int)floor(y*smallImageScale),(int)floor(x*smallImageScale));
                
                if (val == cv::GC_FGD || (val == cv::GC_PR_FGD && *maskPtr != cv::GC_PR_BGD))
                {
                    (*tempPtr) = fgColor;
                }
            }
            
            if(*maskPtr == cv::GC_PR_FGD)
            {
                (*tempPtr) = fgColor;
            }
            
            ++maskPtr;
            ++tempPtr;
        }
    }
    
    cutter.estimate2(bigSizeTargetImageMat, resultMat(bigSizeTargetRect));
}

-(UIImage *)smartScissorsWithDrawImage_2:(UIImage *)drawImage andMaskImage:(UIImage *)maskImage withGuidedRadius:(float)guidedRadius andGuidedEps:(float)guidedEps
{
    if (!drawImage)
    {
        return nil;
    }
    
    UIImage *guidedMaskImage;
    
    drawImage = [drawImage rotateAndScale:_smallImageScale];
    UIImage *scaledImage = [_originalImage rotateAndScale:_smallImageScale];
    cv::Mat scaledMat = [UIImage mat8UC3WithImage:scaledImage];
    
    cv::Mat tempMat = [UIImage mat8UC4WithImage:drawImage];
    cv::Mat mats[4];
    cv::split(tempMat, mats);
    
    cv::Mat maskMat;
    mats[3].copyTo(maskMat);
    
    tempMat.release();
    mats[0].release();
    mats[1].release();
    mats[2].release();
    mats[3].release();
    
    int nCols = maskMat.cols;
    int nRows = maskMat.rows;
    int selectedCount = 0;
    int leftest = nCols;
    int rightest = 0;
    int lowest = 0;
    int highest = nRows;
    
    uchar *grayPtr;
    for (int i=0; i<nRows; ++i)
    {
        grayPtr = maskMat.ptr<uchar>(i);
        for (int j=0; j<nCols; ++j)
        {
            if (grayPtr[j]>0) {
                ++selectedCount;
                
                leftest = leftest>j?j:leftest;
                rightest = rightest<j?j:rightest;
                
                lowest = lowest<i?i:lowest;
                highest = highest>i?i:highest;
            }
        }
    }
    
    if (selectedCount==0) {
        return nil;
    }
    // 1.0 cut
    cv::Mat cutMaskMat(maskMat.size(), CV_8UC1, cv::Scalar(GC_UNKNOWN));
    
    if (!maskImage) {
        leftest = MAX(leftest-40, 0);
        rightest = MIN(rightest+40, nCols-1);
        lowest = MIN(lowest+40, nRows-1);
        highest = MAX(highest-40, 0);
        
        uchar *cutMaskPtr;
        
        int unknowCnt = 0;
        
        for (int y=0; y<nRows; ++y) {
            grayPtr = maskMat.ptr<uchar>(y);
            cutMaskPtr = cutMaskMat.ptr<uchar>(y);
            
            for (int x=0; x<nCols; ++x) {
                
                *cutMaskPtr = *grayPtr>192?cv::GC_FGD:(*grayPtr>64?GC_UNKNOWN:cv::GC_BGD);
                
                if (*cutMaskPtr == GC_UNKNOWN)
                {
                    ++unknowCnt;
                }
                
                ++grayPtr;
                ++cutMaskPtr;
            }
        }
        
        cv::Mat bgdModel, fgdModel;
        GCGrabCut cutter;
        cutter.genModel(scaledMat, cutMaskMat, cv::Rect(0, 0, nCols, nRows), bgdModel, fgdModel, 1);
        cutter.estimate3(scaledMat, cutMaskMat);
        
        for (int y=0; y<nRows; ++y) {
            grayPtr = maskMat.ptr<uchar>(y);
            cutMaskPtr = cutMaskMat.ptr<uchar>(y);
        
            for (int x=0; x<nCols; ++x) {
                
                if (*cutMaskPtr == GC_UNKNOWN)
                {
                    *grayPtr = 128;
                }
                
                ++grayPtr;
                ++cutMaskPtr;
            }
        }
        
        UIImage *mattedMaskImage = [SharedMatting sharedMattingMat:scaledMat withMaskImage:maskMat];
        
        guidedMaskImage = [mattedMaskImage resizeImageToSize:_originalImage.size];
//        guidedMaskImage = mattedMaskImage;
    }
    else
    {
        tempMat = [UIImage mat8UC4WithImage:maskImage];
        cv::split(tempMat, mats);
        mats[3].copyTo(cutMaskMat);
        tempMat.release();
        mats[0].release();
        mats[1].release();
        mats[2].release();
        mats[3].release();
        
        // 2.0 guided filter
        
        cv::Mat rgbMat = [UIImage mat8UC3WithImage:_originalImage];
        cv::Mat guidedGrayMat;
        
        cv::ximgproc::guidedFilter(rgbMat, cutMaskMat, guidedGrayMat, guidedRadius, guidedEps);
        
        cv::Mat channels[4] = {guidedGrayMat, guidedGrayMat, guidedGrayMat, guidedGrayMat};
        cv::merge(channels, 4, tempMat);
        guidedGrayMat.release();
        
        guidedMaskImage = [UIImage imageWith8UC4Mat:tempMat];
        rgbMat.release();
        tempMat.release();
    }
    
    return guidedMaskImage;
}

-(void) cutScaledImage:(UIImage *)bigImage withPreprocessedMask:(cv::Mat)maskMat andImageScale:(CGFloat)smallImageScale inRect:(cv::Rect)targetMaskRect toResultMat:(cv::Mat &) resultMat
{
    UIImage *scaledImage = [bigImage rotateAndScale:smallImageScale];
    cv::Mat imageMat;// UIImageToMat(scaledImage, imageMat);
    imageMat = [UIImage mat8UC4WithImage:scaledImage];
    cv::Mat bigSizeImageMat;// UIImageToMat(bigImage, bigSizeImageMat);
    bigSizeImageMat = [UIImage mat8UC4WithImage:bigImage];
    
    // 1. update maskMat & get the selected points containing rect.
    cv::Rect bigSizeTargetRect = targetMaskRect;
    
    targetMaskRect.x = (bigSizeTargetRect.x+(1.0/smallImageScale-1))*smallImageScale;
    targetMaskRect.y = (bigSizeTargetRect.y+(1.0/smallImageScale-1))*smallImageScale;
    targetMaskRect.width = (bigSizeTargetRect.width+(1.0/smallImageScale-1))*smallImageScale;
    targetMaskRect.height = (bigSizeTargetRect.height+(1.0/smallImageScale-1))*smallImageScale;
    
    if (targetMaskRect.x>=imageMat.cols) targetMaskRect.x=imageMat.cols-1;
    if (targetMaskRect.y>=imageMat.rows) targetMaskRect.y=imageMat.rows-1;
    if (targetMaskRect.x+targetMaskRect.width>imageMat.cols) targetMaskRect.width=imageMat.cols-targetMaskRect.x;
    if (targetMaskRect.y+targetMaskRect.height>imageMat.rows) targetMaskRect.height=imageMat.rows-targetMaskRect.y;
    
    int fgdCnt=0;
    int bgdCnt=0;
    cv::Mat targetMaskMat; targetMaskMat.create(targetMaskRect.height, targetMaskRect.width, CV_8UC1);
    for (int i=0; i<targetMaskMat.rows; ++i) {
        for (int j=0; j<targetMaskMat.cols; ++j) {
            cv::Point point;
            point.x = (targetMaskRect.x+j)/smallImageScale; point.y = (targetMaskRect.y+i)/smallImageScale;
            
            if (point.x >= maskMat.cols) {
                point.x = maskMat.cols-1;
            }
            if (point.y >= maskMat.rows) {
                point.y = maskMat.rows-1;
            }
            targetMaskMat.at<uchar>(i, j) = maskMat.at<uchar>(point);
            if (targetMaskMat.at<uchar>(i,j) == cv::GC_FGD || targetMaskMat.at<uchar>(i,j) == cv::GC_PR_FGD) {
                ++fgdCnt;
            }
            else if (targetMaskMat.at<uchar>(i,j) == cv::GC_BGD || targetMaskMat.at<uchar>(i,j) == cv::GC_PR_BGD) {
                ++bgdCnt;
            }
        }
    }
    
    if (fgdCnt == 0 || bgdCnt == 0) {
        return;
    }
#ifdef DEBUG
    NSTimeInterval begin = [NSDate timeIntervalSinceReferenceDate], end;
#endif
    
    // set rect borders to background
    if (targetMaskRect.x > 0)
        targetMaskMat.col(0).setTo(cv::GC_BGD);
    if (targetMaskRect.x+targetMaskRect.width < imageMat.cols-1)
        targetMaskMat.col(targetMaskMat.cols-1).setTo(cv::GC_BGD);
    if (targetMaskRect.y > 0)
        targetMaskMat.row(0).setTo(cv::GC_BGD);
    if (targetMaskRect.y+targetMaskRect.height < imageMat.rows-1)
        targetMaskMat.row(targetMaskMat.rows-1).setTo(cv::GC_BGD);
    
    // cut the scaled target image
    cv::Mat targetImageMat;
    cv::cvtColor(imageMat(targetMaskRect), targetImageMat, CV_RGBA2RGB);
    
    cv::Mat bgdModel, fgdModel;
    GCGrabCut cutter;
    cutter.cutImage(targetImageMat, targetMaskMat, targetMaskRect, bgdModel, fgdModel, 1, cv::GC_INIT_WITH_MASK);
    
    // get the ribbon area
    cv::Mat bigSizeTargetMaskMat;
    cv::Mat bigSizeTargetImageMat; cv::cvtColor(bigSizeImageMat(bigSizeTargetRect), bigSizeTargetImageMat, CV_RGBA2RGB);
    
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"first cut use %d ms", (int)((end-begin)*1000)); begin=end;
#endif
    
    int nBGDCount=0, nFGDCount=0;
    bigSizeTargetMaskMat.create(bigSizeTargetImageMat.size(), CV_8UC1);
    cutter.labelRibbon(targetMaskMat, bigSizeTargetMaskMat, smallImageScale, nBGDCount, nFGDCount);
    
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"ribbon label use %d ms", (int)((end-begin)*1000)); begin=end;
    NSLog(@"background: %d, foreground: %d", nBGDCount, nFGDCount);
#endif
    
    // cut the ribbon area
    if (nBGDCount>0 && nFGDCount>0) {
        cutter.cutImage(bigSizeTargetImageMat, bigSizeTargetMaskMat, 1);
    }
    
    NSLog(@"(%d, %d), (%d, %d)", bigSizeTargetRect.x, bigSizeTargetRect.y, bigSizeTargetRect.width, bigSizeTargetRect.height);
    
#ifdef DEBUG
    end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"second cut use %d ms", (int)((end-begin)*1000)); begin=end;
#endif
    
    // merge the target area to result and update mask image
    
    resultMat.create(maskMat.size(), CV_8UC1);
    resultMat.setTo(cv::Scalar(0));
    cv::Mat targetTemp = resultMat(bigSizeTargetRect);
    
    int width = bigSizeTargetMaskMat.cols;
    int height = bigSizeTargetMaskMat.rows;
    
    uchar *maskPtr;
    uchar *tempPtr;
    uchar fgColor = 255;
    
    for (int y=0; y<height; ++y) {
        maskPtr = bigSizeTargetMaskMat.ptr<uchar>(y);
        tempPtr = targetTemp.ptr<uchar>(y);
        
        for (int x=0; x<width; ++x) {
            
            if (x*smallImageScale < targetImageMat.cols && y*smallImageScale < targetImageMat.rows)
            {
                uchar val = targetMaskMat.at<uchar>((int)floor(y*smallImageScale),(int)floor(x*smallImageScale));
                
                if (val == cv::GC_FGD || (val == cv::GC_PR_FGD && *maskPtr != cv::GC_PR_BGD))
                {
                    (*tempPtr) = fgColor;
                }
            }
            
            if(*maskPtr == cv::GC_PR_FGD)
            {
                (*tempPtr) = fgColor;
            }
            
            ++maskPtr;
            ++tempPtr;
        }
    }
    
    cutter.estimate2(bigSizeTargetImageMat, resultMat(bigSizeTargetRect));
}

-(UIImage *)smartScissorsWithDrawImage:(UIImage *)drawImage andMaskImage:(UIImage *)maskImage withGuidedRadius:(float)guidedRadius andGuidedEps:(float)guidedEps
{
//    if ([self.delegate respondsToSelector:@selector(cutoutContainerViewWillBeginHairMatting:)]) {
//        [self.delegate cutoutContainerViewWillBeginHairMatting:self];
//    }
    
    if (!drawImage) {

        return nil;
    }
    
    cv::Mat tempMat = [UIImage mat8UC4WithImage:drawImage];
    cv::Mat mats[4];
    cv::split(tempMat, mats);
    
    cv::Mat maskMat;
    mats[3].copyTo(maskMat);
    
    tempMat.release();
    mats[0].release();
    mats[1].release();
    mats[2].release();
    mats[3].release();
    
    int nCols = maskMat.cols;
    int nRows = maskMat.rows;
    int selectedCount = 0;
    int leftest = nCols;
    int rightest = 0;
    int lowest = 0;
    int highest = nRows;
    
    uchar *grayPtr;
    for (int i=0; i<nRows; ++i)
    {
        grayPtr = maskMat.ptr<uchar>(i);
        for (int j=0; j<nCols; ++j)
        {
            if (grayPtr[j]>0) {
                ++selectedCount;
                
                leftest = leftest>j?j:leftest;
                rightest = rightest<j?j:rightest;
                
                lowest = lowest<i?i:lowest;
                highest = highest>i?i:highest;
            }
        }
    }
    
    if (selectedCount==0) {
        return nil;
    }
    // 1.0 cut
    cv::Mat cutMaskMat(maskMat.size(), CV_8UC1, cv::Scalar(GC_UNKNOWN));
    int fgdCnt = 0;
    int bgdCnt = 0;
    if (!maskImage) {
        leftest = MAX(leftest-40, 0);
        rightest = MIN(rightest+40, nCols-1);
        lowest = MIN(lowest+40, nRows-1);
        highest = MAX(highest-40, 0);
        
        uchar *cutMaskPtr;
        
        int unknowCnt = 0;
        
        for (int y=0; y<nRows; ++y) {
            grayPtr = maskMat.ptr<uchar>(y);
            cutMaskPtr = cutMaskMat.ptr<uchar>(y);
            
            for (int x=0; x<nCols; ++x) {
                
                *cutMaskPtr = *grayPtr>192?cv::GC_FGD:(*grayPtr>64?cv::GC_PR_BGD:cv::GC_BGD);
                
                if (*cutMaskPtr == cv::GC_FGD) {
                    ++fgdCnt;
                }
                else
                {
                    ++bgdCnt;
                }
                
                if (*cutMaskPtr == cv::GC_PR_BGD)
                {
                    ++unknowCnt;
                }
                
                ++grayPtr;
                ++cutMaskPtr;
            }
        }
        
        if (fgdCnt < 10 || bgdCnt < 10)
        {
            return nil;
        }
        [self cutScaledImage:_originalImage withPreprocessedMask:cutMaskMat andImageScale:_smallImageScale inRect:cv::Rect(leftest, highest, rightest-leftest, lowest-highest) toResultMat:cutMaskMat];
    }
    else
    {
        tempMat = [UIImage mat8UC4WithImage:maskImage];
        cv::split(tempMat, mats);
        mats[3].copyTo(cutMaskMat);
        tempMat.release();
        mats[0].release();
        mats[1].release();
        mats[2].release();
        mats[3].release();
    }
    
//    cv::Mat channels[4] = {cutMaskMat, cutMaskMat, cutMaskMat, cutMaskMat};
//    cv::merge(channels, 4, tempMat);
//    UIImage *guidedMaskImage = [UIImage imageWith8UC4Mat:tempMat];
//    return guidedMaskImage;
//    UIImage *cutImage = [UIImage imageWith8UC1Mat:cutMaskMat];
//    cutImage = cutImage;
    
    // 2.0 guided filter
    
    cv::Mat rgbMat = [UIImage mat8UC3WithImage:_originalImage];
    cv::Mat guidedGrayMat;
    
    cv::ximgproc::guidedFilter(rgbMat, cutMaskMat, guidedGrayMat, guidedRadius, guidedEps);
    
    cv::Mat channels[4] = {guidedGrayMat, guidedGrayMat, guidedGrayMat, guidedGrayMat};
    cv::merge(channels, 4, tempMat);
    guidedGrayMat.release();

    UIImage *guidedMaskImage = [UIImage imageWith8UC4Mat:tempMat];
    rgbMat.release();
    tempMat.release();
    
    return guidedMaskImage;
}

#pragma mark - ComprehensiveCutoutDrawViewDelegate
-(void)comprehensiveCutoutDrawView:(ComprehensiveCutoutDrawView *)drawView didFinishDrawWithImage:(UIImage *)image
{
    if ([self.delegate respondsToSelector:@selector(comprehensiveCutoutViewWillBeginTimeConsumingOperation:)]) {
        [self.delegate comprehensiveCutoutViewWillBeginTimeConsumingOperation:self];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        {
            UIImage *newMaskImage;
            switch (_cutoutMode) {
                case kCutoutModeSmartScissors:
                    newMaskImage = [self smartScissorsWithDrawImage:image andMaskImage:nil withGuidedRadius:8 andGuidedEps:2];
                    break;
                default:
                    break;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *maskImage = [_selectionMaskView getMaskImage];
                
                if (maskImage) {
                    maskImage = [maskImage imageBlendedWithImage:newMaskImage blendMode:kCGBlendModeNormal alpha:1.0];
                }
                else
                {
                    maskImage = newMaskImage;
                }
                [_selectionMaskView setFixMaskImage:maskImage];
                
                if ([self.delegate respondsToSelector:@selector(comprehensiveCutoutViewDidFinishTimeConsumingOperation:)]) {
                    [self.delegate comprehensiveCutoutViewDidFinishTimeConsumingOperation:self];
                }
                
                if ([self.delegate respondsToSelector:@selector(comprehensiveCutoutViewDidChange:)])
                {
                    [self.delegate comprehensiveCutoutViewDidChange:self];
                }
            });
        }
    });
}

#pragma mark - public

-(void)setMaskImage:(UIImage *)maskImage
{
    [_selectionMaskView setFixMaskImage:maskImage andShapeMaskImage:nil record:YES];
}

-(void)setMaskImageWithoutSave:(UIImage *)maskImage
{
    [_selectionMaskView setFixMaskImage:maskImage andShapeMaskImage:nil record:NO];
}

-(void)setFixMaskImage:(UIImage *)fixImage andShapeMaskImage:(UIImage *)shapeImage save:(BOOL)save;
{
    [_selectionMaskView setFixMaskImage:fixImage andShapeMaskImage:shapeImage record:save];
}

-(UIImage *)getMaskImage
{
    return [_selectionMaskView getMaskImage];
}

-(UIImage *)getFixeMaskImage;
{
    return [_selectionMaskView getFixMaskImage];
}
-(UIImage *)getShapeMaskImage;
{
    return [_selectionMaskView getShapeMaskImage];
}

-(NSArray *)requireImages:(NSArray *)imageTypes withAccurateOn:(BOOL)on
{
    UIImage *maskImage = [_selectionMaskView getMaskImage];
    if (!maskImage) {
        return nil;
    }
//    {
//        cv::Mat tempMat = [UIImage mat8UC4WithImage:maskImage];
//        cv::Mat mats[4];
//        cv::split(tempMat, mats);
//        
//        cv::Mat &maskMat = mats[3];
//        tempMat.release();
//        mats[0].release();
//        mats[1].release();
//        mats[2].release();
//        
//        int nRows = maskMat.rows;
//        int nCols = maskMat.cols;
//        
//        uchar *grayPtr;
//        uchar *cutMaskPtr;
//        
//        cv::Mat cutMaskMat(maskMat.size(), CV_8UC1, cv::Scalar(GC_UNKNOWN));
//
//        for (int y=0; y<nRows; ++y) {
//            grayPtr = maskMat.ptr<uchar>(y);
//            cutMaskPtr = cutMaskMat.ptr<uchar>(y);
//            
//            for (int x=0; x<nCols; ++x) {
//                
//                *cutMaskPtr = *grayPtr>128?cv::GC_PR_FGD:cv::GC_PR_BGD;
//                
//                ++grayPtr;
//                ++cutMaskPtr;
//            }
//        }
//        
//        cv::Mat bgdModel, fgdModel;
//        GCGrabCut cutter;
//        cv::Mat bigSizeImageMat = [UIImage mat8UC3WithImage:self.originalImage];
//
//        cutter.estimate(bigSizeImageMat, cutMaskMat);
//        
//        return nil;
//    }
    cv::Mat tempMat = [UIImage mat8UC4WithImage:maskImage];
    cv::Mat mats[4];
    cv::split(tempMat, mats);
    
    cv::Mat &grayMat = mats[3];
    tempMat.release();
    mats[0].release();
    mats[1].release();
    mats[2].release();
    
    int nRows = grayMat.rows;
    int nCols = grayMat.cols;
    
    uchar *grayPtr;
    
    int selectedCount = 0;
    int visiableCnt = 0;
    int leftest = nCols, rightest = 0;
    int highest = nRows, lowest = 0;
    
    int leftestBG = nCols, rightestBG = 0;
    int highestBG = nRows, lowestBG = 0;
    
    for (int i=0; i<nRows; ++i) {
        grayPtr = grayMat.ptr<uchar>(i);
        for (int j=0; j<nCols; ++j) {
            
            if (grayPtr[j]>128)
            {
                ++visiableCnt;
            }
            
            if (grayPtr[j]>0)
            {
                if (j>rightest) {
                    rightest = j;
                }
                
                if (j<leftest)
                {
                    leftest = j;
                }
                
                if (i>lowest) {
                    lowest = i;
                }
                
                if (i<highest)
                {
                    highest = i;
                }
                
                ++selectedCount;
            }
            
            if (grayPtr[j]<255)
            {
                if (j>rightestBG) {
                    rightestBG = j;
                }
                
                if (j<leftestBG)
                {
                    leftestBG = j;
                }
                
                if (i>lowestBG) {
                    lowestBG = i;
                }
                
                if (i<highestBG)
                {
                    highestBG = i;
                }
            }
        }
    }
    
    if (selectedCount==0) {
        return nil;
    }

    if (visiableCnt<=1000) {
        return nil;
    }
    
    UIImage *maskImageBG = nil;
    
    const int realRadius = 3;

    if (on) {
        float guidedRadius = 40;
        float guidedEps = 10;
        
        cv::Mat rgbMat = [UIImage mat8UC3WithImage:_originalImage];
        cv::Mat guidedGrayMat;
        
        //        NSLog(@"%d, %d", rgbMat.channels(), rgbMat.depth());
        
        cv::ximgproc::guidedFilter(rgbMat, grayMat, guidedGrayMat, guidedRadius, guidedEps);
        
        cv::Mat erodedMat;
        cv::Scalar all0(0, 0, 0, 0);
        cv::erode(guidedGrayMat, erodedMat, cv::Mat(realRadius, realRadius, CV_8UC1, cv::Scalar(1)),cv::Point(-1, -1), 1, cv::BORDER_CONSTANT, all0);
        cv::blur(erodedMat, guidedGrayMat, cv::Size(realRadius*2+1, realRadius*2+1));
        erodedMat.release();
        
//        maskImage = MatToUIImage(guidedGrayMat);
        maskImage = [UIImage alphaImageWith8UC1Mat:guidedGrayMat];
        // invert
        guidedGrayMat = 255-guidedGrayMat;
//        maskImageBG = MatToUIImage(guidedGrayMat);
        maskImageBG = [UIImage alphaImageWith8UC1Mat:guidedGrayMat];

        guidedGrayMat.release();
        rgbMat.release();
        
        guidedRadius = 40;
        leftest = MAX(leftest-guidedRadius, 0);
        rightest = MIN(rightest+guidedRadius, nCols-1);
        highest = MAX(highest-guidedRadius, 0);
        lowest = MIN(lowest+guidedRadius, nRows-1);
        
        leftestBG = MAX(leftestBG-guidedRadius, 0);
        rightestBG = MIN(rightestBG+guidedRadius, nCols-1);
        highestBG = MAX(highestBG-guidedRadius, 0);
        lowestBG = MIN(lowestBG+guidedRadius, nRows-1);
    }
    else
    {
        cv::Mat erodedMat;
        cv::Scalar all0(0, 0, 0, 0);
        cv::erode(grayMat, erodedMat, cv::Mat(realRadius, realRadius, CV_8UC1, cv::Scalar(1)),cv::Point(-1, -1), 1, cv::BORDER_CONSTANT, all0);
        cv::blur(erodedMat, grayMat, cv::Size(realRadius*2+1, realRadius*2+1));
        erodedMat.release();
        
//        maskImage = MatToUIImage(grayMat);
        maskImage = [UIImage alphaImageWith8UC1Mat:grayMat];

        // invert
        grayMat = 255-grayMat;
//        maskImageBG = MatToUIImage(grayMat);
        maskImageBG = [UIImage alphaImageWith8UC1Mat:grayMat];
    }
    grayMat.release();
    
    NSMutableArray *images = [NSMutableArray array];
    UIImage *fgImage = nil;
    UIImage *bgImage = nil;
    
    for (NSInteger idx=0; idx<imageTypes.count; ++idx) {
        NSInteger type = [imageTypes[idx] integerValue];
        
        UIImage *image = nil;
        switch (type) {
            case kICImageTypeFGFullSize:
            {
                if (!fgImage) {
                    fgImage = [_originalImage imageMaskedWithImage:maskImage];
                }
                image = fgImage;
                break;
            }
            case kICImageTypeBGFullSize:
            {
                if (!bgImage) {
                    bgImage = [_originalImage imageMaskedWithImage:maskImageBG];
                }
                image = bgImage;
                break;
            }
            case kICImageTypeFGWrap:
            {
                if (!fgImage) {
                    fgImage = [_originalImage imageMaskedWithImage:maskImage];
                }
                _wrapFGImageFrame = CGRectMake(leftest, highest, rightest-leftest+1, lowest-highest+1);
                CGImageRef imageRef = CGImageCreateWithImageInRect(fgImage.CGImage, CGRectMake(leftest, highest, rightest-leftest+1, lowest-highest+1));
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                break;
            }
            case kICImageTypeBGWrap:
            {
                if (!bgImage) {
                    bgImage = [_originalImage imageMaskedWithImage:maskImageBG];
                }
                CGImageRef imageRef = CGImageCreateWithImageInRect(bgImage.CGImage, CGRectMake(leftestBG, highestBG, rightestBG-leftestBG+1, lowestBG-highestBG+1));
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                break;
            }
            case kICImageTypeMaskBGWrap:
            {
                CGImageRef imageRef = CGImageCreateWithImageInRect(maskImageBG.CGImage, CGRectMake(leftestBG, highestBG, rightestBG-leftestBG+1, lowestBG-highestBG+1));
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);

                break;
            }
            case kICImageTypeMaskBGFullSize:
            {
                image = maskImageBG;
                break;
            }
            case kICImageTypeMaskFGWrap:
            {
                CGImageRef imageRef = CGImageCreateWithImageInRect(maskImage.CGImage, CGRectMake(leftest, highest, rightest-leftest+1, lowest-highest+1));
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                break;
            }
            case kICImageTypeMaskFGFullSize:
            {
                image = maskImage;
                break;
            }
            default:
                break;
        }
        
        if (image) {
            [images addObject:image];
        }
        else
        {
            [images addObject:[NSNull null]];
        }
    }
    
    return images;
}

-(CGRect)getWrapFGImageFrame
{
    return _wrapFGImageFrame;
}

-(CGRect)getWrapFGImageFrameInImageView
{
    return [CGRectCGPointUtility imageViewConvertRect:_wrapFGImageFrame fromImageRect:CGRectMake(0, 0, _originalImage.size.width, _originalImage.size.height) toViewRect:_imageView.bounds];
}

#pragma mark -

-(void)setLeftEyeRect:(CGRect)leftEyeRect
{
    _faceDetectEnable = YES;
    
    _hasLeftEye = !CGRectIsEmpty(leftEyeRect);
    _leftEyeRect = cv::Rect(leftEyeRect.origin.x, leftEyeRect.origin.y, leftEyeRect.size.width, leftEyeRect.size.height);
}

-(void)setRightEyeRect:(CGRect)rightEyeRect
{
    _faceDetectEnable = YES;
    
    _hasRightEye = !CGRectIsEmpty(rightEyeRect);
    _rightEyeRect = cv::Rect(rightEyeRect.origin.x, rightEyeRect.origin.y, rightEyeRect.size.width, rightEyeRect.size.height);
}

-(void)setMouthRect:(CGRect)mouthRect
{
    _faceDetectEnable = YES;
    
    _hasMouth = !CGRectIsEmpty(mouthRect);
    _mouthRect = cv::Rect(mouthRect.origin.x, mouthRect.origin.y, mouthRect.size.width, mouthRect.size.height);
}

#pragma mark -

-(void)layoutSubviews
{
    [super layoutSubviews];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateForSizeChange];
    });
}

-(void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

@end
