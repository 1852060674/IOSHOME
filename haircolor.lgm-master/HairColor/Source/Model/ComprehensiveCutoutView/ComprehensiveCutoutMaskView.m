//
//  ComprehensiveCutoutMaskView.m
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/27.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "ComprehensiveCutoutMaskView.h"
#import "ComprehensiveCutoutShapeMaskView.h"
#import "ComprehensiveCutoutDrawMaskView.h"
#import "UIImage+Blend.h"
#import "UIImage+Rotation.h"
#import "Masonry.h"
#import "CGRectCGPointUtility.h"
#import <AVFoundation/AVFoundation.h>
#import "PhotoCache.h"
#import "ObjectStack.h"
#import "UIImage+Draw.h"
@interface ComprehensiveCutoutMaskViewHistoryFrame : NSObject
@property (nonatomic, strong) NSString *fixMaskPath;
@property (nonatomic, strong) NSString *shapeMaskPath;
@property (nonatomic, readwrite) CGPoint shapeCenter;
@property (nonatomic, readwrite) CGAffineTransform shapeTransform;
@end

@implementation ComprehensiveCutoutMaskViewHistoryFrame
@end

@interface ComprehensiveCutoutMaskView ()
{
    ComprehensiveCutoutDrawMaskView *_drawMaskView;
    
    int _historyIndex;
}
@property (nonatomic, strong) ObjectStack *objectStack_0;
@property (nonatomic, strong) ObjectStack *objectStack_1;
@property (nonatomic, weak) ObjectStack *objectStack;
@property (nonatomic, strong) PhotoCache *photoCache;
@end

@implementation ComprehensiveCutoutMaskView

-(ObjectStack *)objectStack_0
{
    if (!_objectStack_0) {
        _objectStack_0 = [[ObjectStack alloc] initWithMaxSize:100 andSupportRedo:YES];
    }
    return _objectStack_0;
}

-(ObjectStack *)objectStack_1
{
    if (!_objectStack_1) {
        _objectStack_1 = [[ObjectStack alloc] initWithMaxSize:100 andSupportRedo:YES];
    }
    return _objectStack_1;
}

-(PhotoCache *)photoCache
{
    if (!_photoCache) {
        _photoCache = [[PhotoCache alloc] initWithIdentifier:@"cutoutmask"];
    }
    return _photoCache;
}

-(ComprehensiveCutoutMaskView *)initWithFrame:(CGRect)frame andImageWidth:(NSInteger)imageWidth andImageHeight:(NSInteger)imageHeight
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _imageWidth = imageWidth;
        _imageHeight = imageHeight;
        
        _drawMaskView = [[ComprehensiveCutoutDrawMaskView alloc] initWithFrame:CGRectZero andImageWidth:_imageWidth andImageHeight:_imageHeight];
        [self addSubview:_drawMaskView];
//        [_drawMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.bottom.top.equalTo(self);
//        }];
        
        _shapeMaskView = [[ComprehensiveCutoutShapeMaskView alloc] initWithFrame:CGRectZero andImageWidth:_imageWidth andImageHeight:_imageHeight];
        [self addSubview:_shapeMaskView];
//        [_shapeMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.bottom.top.equalTo(self);
//        }];
        
        self.objectStack = self.objectStack_0;
    }

    return self;
}

-(NSInteger)brushRadius
{
    return _drawMaskView.brushRadius;
}

-(void)setBrushRadius:(NSInteger)brushRadius
{
    [_drawMaskView setBrushRadius:brushRadius];
}

-(CGFloat)brushSmooth
{
    return _drawMaskView.brushSmooth;
}

-(void)setBrushSmooth:(CGFloat)brushSmooth
{
    [_drawMaskView setBrushSmooth:brushSmooth];
}

-(CGFloat)brushAlpha
{
    return _drawMaskView.brushAlpha;
}

-(void)setBrushAlpha:(CGFloat)brushAlpha;
{
    [_drawMaskView setBrushAlpha:brushAlpha];
}
-(void)setEraseMode:(BOOL)eraseMode;
{
    [_drawMaskView setEraseMode:eraseMode];
}

-(void)privateTouchesBeganAtPoint:(CGPoint)point
{
    [_drawMaskView privateTouchesBeganAtPoint:point];
}
-(void)privateTouchesMovedToPoint:(CGPoint)point
{
    [_drawMaskView privateTouchesMovedToPoint:point];
}
-(void)privateTouchesEndedAtPoint:(CGPoint)point
{
    [_drawMaskView privateTouchesEndedAtPoint:point];
    
    [self makeAndPushHistoryFrame:0];
}
-(void)privateTouchesCancelled
{
    [_drawMaskView privateTouchesCancelled];
}

#pragma mark -
-(void)setFixMaskImage:(UIImage *)fixImage andShapeMaskImage:(UIImage *)shapeImage record:(BOOL)record
{
    CGImageRef imageRef = CGImageCreateCopy(fixImage.CGImage);
    UIImage* fixImage_ = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    [_drawMaskView setFixMaskImage:fixImage_];
    [_shapeMaskView setShapeMaskImage:shapeImage];
    
    if (record) {
        [self makeAndPushHistoryFrame:3];
    }
}

-(UIImage *)getFixMaskImage
{
    return [_drawMaskView getFixMaskImage];
}
-(void)setFixMaskImage:(UIImage *)image
{
    [_drawMaskView setFixMaskImage:[UIImage imageWithCGImage:image.CGImage]];

    [self makeAndPushHistoryFrame:0];
}

// for shape

-(UIImage *)getShapeMaskImage
{
    return [_shapeMaskView getShapeMaskImage];
}

-(void)setShapeMaskImage:(UIImage *)image;
{
    [_shapeMaskView setShapeMaskImage:image];
    [self makeAndPushHistoryFrame:1];
}

-(void)resetShapeView
{
    [_shapeMaskView resetShapeView];
}

-(void)zoomByScale:(CGFloat)scale
{
    [_shapeMaskView zoomByScale:scale];
}
-(void)rotateByAngle:(CGFloat)angle;
{
    [_shapeMaskView rotateByAngle:angle];
}
-(void)translateByOffset:(CGPoint)offset;
{
    [_shapeMaskView translateByOffset:offset];
}
//
-(void)updateContextSize
{
    _drawMaskView.frame = self.bounds;
    [_drawMaskView updateContextSize];

    _shapeMaskView.frame = self.bounds;
//    [_shapeMaskView setNeedsLayout];
    [_shapeMaskView updateContextSize];
}

-(UIImage *)getMaskImage
{
    UIImage *drawMaskImage = [self getFixMaskImage];
    UIImage *shapeMaskImage= [self getShapeMaskImage];
    
    if (shapeMaskImage) {
        if (!drawMaskImage) {
            drawMaskImage = [UIImage drawTransparentImageWithSize:_drawMaskView.bounds.size scale:[UIScreen mainScreen].scale];
        }
        UIView *overlayImageView = _shapeMaskView.shapeMaskImageView;
        CGPoint center = overlayImageView.center;
        center = [_drawMaskView convertPoint:center fromView:overlayImageView.superview];
        CGRect overlayFrame = overlayImageView.bounds;
        overlayFrame = AVMakeRectWithAspectRatioInsideRect(shapeMaskImage.size, overlayFrame);
        
        overlayFrame.origin = CGPointMake(center.x-overlayFrame.size.width/2.0, center.y-overlayFrame.size.height/2.0);

        overlayFrame = [CGRectCGPointUtility imageViewConvertRect:overlayFrame fromViewRect:_shapeMaskView.bounds toImageRect:CGRectMake(0, 0, drawMaskImage.size.width, drawMaskImage.size.height)];
        
        CGAffineTransform transform = overlayImageView.transform;
        transform = CGAffineTransformMake(transform.a, -transform.b, -transform.c, transform.d, transform.tx, transform.ty);
        
        drawMaskImage = [drawMaskImage imageBlendedWithImage:shapeMaskImage inOverlayRect:overlayFrame withTransform:transform alpha:1.0];
    }
    
    if (drawMaskImage) {
        return [drawMaskImage resizeImageToSize:CGSizeMake(_imageWidth, _imageHeight)];
    }
    return [shapeMaskImage resizeImageToSize:CGSizeMake(1, 1)];

}

//0 - fix mask change; 1 - shape mask change; 2 - shape geo change; 3 - both mask change
-(void)makeAndPushHistoryFrame:(NSInteger)type
{
    ComprehensiveCutoutMaskViewHistoryFrame *historyFrame = [ComprehensiveCutoutMaskViewHistoryFrame new];

    historyFrame.shapeTransform = _shapeMaskView.shapeMaskImageView.transform;
    historyFrame.shapeCenter = _shapeMaskView.shapeMaskImageView.center;
    
    ComprehensiveCutoutMaskViewHistoryFrame *lastHistoryFrame = (ComprehensiveCutoutMaskViewHistoryFrame *)[self.objectStack getTopObject];

    switch (type) {
        case 0:
        {
            if (lastHistoryFrame) {
                historyFrame.shapeMaskPath = lastHistoryFrame.shapeMaskPath;
            }
            else
            {
                historyFrame.shapeMaskPath = [NSString stringWithFormat:@"shapemask_%d", _historyIndex];
                [self.photoCache addCacheImage:[self getShapeMaskImage] withKey:historyFrame.shapeMaskPath];
            }
            historyFrame.fixMaskPath = [NSString stringWithFormat:@"fixmask_%d", _historyIndex];
            [self.photoCache addCacheImage:[self getFixMaskImage] withKey:historyFrame.fixMaskPath];
            break;
        }
        case 1:
        {
            if (lastHistoryFrame) {
                historyFrame.fixMaskPath = lastHistoryFrame.fixMaskPath;
            }
            else
            {
                historyFrame.fixMaskPath = [NSString stringWithFormat:@"fixmask_%d", _historyIndex];
                [self.photoCache addCacheImage:[self getFixMaskImage] withKey:historyFrame.fixMaskPath];
            }
            historyFrame.shapeMaskPath = [NSString stringWithFormat:@"shapemask_%d", _historyIndex];
            [self.photoCache addCacheImage:[self getShapeMaskImage] withKey:historyFrame.shapeMaskPath];
            break;
        }
        case 2:
        {
            if (lastHistoryFrame) {
                historyFrame.shapeMaskPath = lastHistoryFrame.shapeMaskPath;
            }
            else
            {
                historyFrame.shapeMaskPath = [NSString stringWithFormat:@"shapemask_%d", _historyIndex];
                [self.photoCache addCacheImage:[self getShapeMaskImage] withKey:historyFrame.shapeMaskPath];
            }
            
            if (lastHistoryFrame) {
                historyFrame.fixMaskPath = lastHistoryFrame.fixMaskPath;
            }
            else
            {
                historyFrame.fixMaskPath = [NSString stringWithFormat:@"fixmask_%d", _historyIndex];
                [self.photoCache addCacheImage:[self getFixMaskImage] withKey:historyFrame.fixMaskPath];
            }
        }
        case 3:
        {
            historyFrame.fixMaskPath = [NSString stringWithFormat:@"fixmask_%d", _historyIndex];
            [self.photoCache addCacheImage:[self getFixMaskImage] withKey:historyFrame.fixMaskPath];
            historyFrame.shapeMaskPath = [NSString stringWithFormat:@"shapemask_%d", _historyIndex];
            [self.photoCache addCacheImage:[self getShapeMaskImage] withKey:historyFrame.shapeMaskPath];
        }
        default:
            break;
    }
    
    [self.objectStack pushObject:historyFrame];
    ++_historyIndex;
}

-(void)useHistoryFrame:(ComprehensiveCutoutMaskViewHistoryFrame *)historyFrame
{
    if (historyFrame) {
        UIImage *fixMask = [self.photoCache cachedImageWithKey:historyFrame.fixMaskPath];
        UIImage *shapeMask = [self.photoCache cachedImageWithKey:historyFrame.shapeMaskPath];
        
        [_drawMaskView setFixMaskImage:fixMask];
        [_shapeMaskView setShapeMaskImage:shapeMask];
        _shapeMaskView.shapeMaskImageView.center = historyFrame.shapeCenter;
        _shapeMaskView.shapeMaskImageView.transform = historyFrame.shapeTransform;
    }
    else
    {
        [_drawMaskView setFixMaskImage:nil];
        [_shapeMaskView setShapeMaskImage:nil];
        _shapeMaskView.shapeMaskImageView.center = _drawMaskView.center;
        _shapeMaskView.shapeMaskImageView.transform = CGAffineTransformIdentity;
    }
}

-(void)undo;
{
    ComprehensiveCutoutMaskViewHistoryFrame *historyFrame = (ComprehensiveCutoutMaskViewHistoryFrame *)[self.objectStack getUndoObject];
    [self useHistoryFrame:historyFrame];
}
-(void)redo;
{
    ComprehensiveCutoutMaskViewHistoryFrame *historyFrame = (ComprehensiveCutoutMaskViewHistoryFrame *)[self.objectStack getRedoObject];
    [self useHistoryFrame:historyFrame];
}

-(BOOL)canUndo;
{
    return [self.objectStack canUndo];
}
-(BOOL)canRedo;
{
    return [self.objectStack canRedo];
}

-(void)jumpToLast;
{
    [self.objectStack jumpToLast];
    ComprehensiveCutoutMaskViewHistoryFrame *historyFrame = (ComprehensiveCutoutMaskViewHistoryFrame *)[self.objectStack getTopObject];
    [self useHistoryFrame:historyFrame];
}
-(void)jumpToFirst;
{
    [self.objectStack jumpToFirst];
    ComprehensiveCutoutMaskViewHistoryFrame *historyFrame = (ComprehensiveCutoutMaskViewHistoryFrame *)[self.objectStack getUndoObject];
    [self useHistoryFrame:historyFrame];
}

-(void)useHistoryIndex:(NSInteger)idx
{
    switch (idx) {
        case 0:
            self.objectStack = self.objectStack_0;
            break;
        case 1:
            self.objectStack = self.objectStack_1;
            break;
        default:
            break;
    }
}

-(void)clearHistoryIndex:(NSInteger)idx
{
    switch (idx) {
        case 0:
            [self.objectStack_0 reset];
            break;
        case 1:
            [self.objectStack_1 reset];
            break;
        default:
            break;
    }
}
-(void)reset
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
