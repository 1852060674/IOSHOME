//
//  ComprehensiveCutoutDrawView.m
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/24.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "ComprehensiveCutoutDrawView.h"
#import "UIImage+Rotation.h"
#import "CGRectCGPointUtility.h"

@interface ComprehensiveCutoutDrawView ()
{
    BOOL _isDrawing;
    
    CGPoint _startPoint;
    CGPoint _previousPos1, _previousPos2, _currentPos;
    CGPoint _curveStartPoint, _curveControlPoint, _curveEndPoint;
    
    CGFloat _imageScale;
    
    UIImage *_drawImage;
    UIBezierPath *_fillPath;
    UIBezierPath *_drawPath;

    CGContextRef _context;
}
@end

@implementation ComprehensiveCutoutDrawView

-(ComprehensiveCutoutDrawView *)initWithFrame:(CGRect)frame andImageWidth:(NSInteger)imageWidth andImageHeight:(NSInteger)imageHeight
{
    self = [super initWithFrame:frame];
    
    if (self) {

        _imageWidth = imageWidth;
        _imageHeight = imageHeight;
        
        [self updateContextSize];
    }
    
    return self;
}

-(void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    if (_context) {
        CGContextSetLineWidth(_context, _lineWidth);
    }
}

-(void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    
    if (_context) {
        CGContextSetStrokeColorWithColor(_context, _lineColor.CGColor);
    }
}

-(void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    
    if (_context) {
        CGContextSetStrokeColorWithColor(_context, _fillColor.CGColor);
    }
}

#pragma mark - touches
-(void)privateTouchesBeganAtPoint:(CGPoint)point
{
//    NSUInteger count = [[touches allObjects] count];
//    if (count == 1)
    {
        CGContextClearRect(_context, self.bounds);
        _isDrawing = YES;

//        UITouch *touch = [touches anyObject];
        
        _previousPos1 = point;
        _previousPos1.y = self.frame.size.height - _previousPos1.y;

        _previousPos2 = point;
        _previousPos2.y = self.frame.size.height - _previousPos2.y;
        
        _currentPos = point;
        _currentPos.y = self.frame.size.height - _currentPos.y;
        
        _curveStartPoint = [CGRectCGPointUtility pointFromPoint:_previousPos1 toPoint:_previousPos2 byRatio:0.5];
        _curveEndPoint = [CGRectCGPointUtility pointFromPoint:_previousPos1 toPoint:_currentPos byRatio:0.5];
        _curveControlPoint = _previousPos1;
        
        _startPoint = _curveStartPoint;
        
        CGContextMoveToPoint(_context, _curveStartPoint.x, _curveStartPoint.y);

    }
    
}
-(void)privateTouchesMovedToPoint:(CGPoint)point
{
//    NSUInteger count = [touches count];
//    if (count == 1 && _isDrawing == YES)
    if (_isDrawing == YES)
    {
        _previousPos2 = _previousPos1;
        
        _previousPos1 = _currentPos;
        
        _currentPos = point;
        _currentPos.y = self.frame.size.height - _currentPos.y;
        
        _curveStartPoint = [CGRectCGPointUtility pointFromPoint:_previousPos1 toPoint:_previousPos2 byRatio:0.5];
        _curveEndPoint = [CGRectCGPointUtility pointFromPoint:_previousPos1 toPoint:_currentPos byRatio:0.5];
        _curveControlPoint = _previousPos1;
        
        [self draw];
        self.layer.contents = (id)_drawImage.CGImage;
    }
}
-(void)privateTouchesEndedAtPoint:(CGPoint)point
{
//    NSUInteger count = [[touches allObjects] count];
//    if (count == 1 && _isDrawing == YES)
    if (_isDrawing == YES)
    {
        if (_forClosedArea) {
            [_fillPath closePath];

            CGContextClearRect(_context, self.bounds);
            CGContextAddPath(_context, _fillPath.CGPath);
            CGContextSetFillColorWithColor(_context, _fillColor.CGColor);
            CGContextFillPath(_context);
            
            if (_forClosedAreaWithContour)
            {
                CGContextAddPath(_context, _drawPath.CGPath);
                CGContextStrokePath(_context);
            }
            
            CGImageRef imageRef = CGBitmapContextCreateImage(_context);
            _drawImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        
//        if (_forClosedArea) {
//            CGContextClearRect(_context, self.bounds);
//
////            [_fillPath closePath];
//            [_drawPath addLineToPoint:_startPoint];
//            CGContextAddPath(_context, _drawPath.CGPath);
//
//            CGContextSetFillColorWithColor(_context, _fillColor.CGColor);
//
//            CGContextDrawPath(_context, kCGPathFillStroke);
//            
//            CGImageRef imageRef = CGBitmapContextCreateImage(_context);
//            _drawImage = [UIImage imageWithCGImage:imageRef];
//            CGImageRelease(imageRef);
//
//        }
        
        if ([self.delegate respondsToSelector:@selector(comprehensiveCutoutDrawView:didFinishDrawWithImage:)]) {
            UIImage *image = [_drawImage resizeImageToSize:CGSizeMake(_imageWidth, _imageHeight)];
            
            [self.delegate comprehensiveCutoutDrawView:self didFinishDrawWithImage:image];
        }
    }
    _isDrawing = NO;
    _drawImage = nil;
    _drawPath = nil;
    _fillPath = nil;
    self.layer.contents = nil;
}
-(void)privateTouchesCancelled
{
    _isDrawing = NO;
    _drawImage = nil;
    _drawPath = nil;
    _fillPath = nil;
    self.layer.contents = nil;
}

-(void)draw
{
    if (!_drawPath) {
        _drawPath = [UIBezierPath bezierPath];
//        [_drawPath moveToPoint:_curveStartPoint];
    }
    [_drawPath moveToPoint:_curveStartPoint];
    [_drawPath addQuadCurveToPoint:_curveEndPoint controlPoint:_curveControlPoint];
    
    if (!_fillPath) {
        _fillPath = [UIBezierPath bezierPath];
        [_fillPath moveToPoint:_curveStartPoint];
    }
    [_fillPath addQuadCurveToPoint:_curveEndPoint controlPoint:_curveControlPoint];
    
    CGContextMoveToPoint(_context, _curveStartPoint.x, _curveStartPoint.y);
    CGContextAddQuadCurveToPoint(_context, _curveControlPoint.x, _curveControlPoint.y, _curveEndPoint.x, _curveEndPoint.y);
//    CGContextAddPath(_context, _drawPath.CGPath);
    CGContextStrokePath(_context);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(_context);
    _drawImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
}

-(void)updateContextSize
{
    if (_context) {
        CGContextRelease(_context);
        _context = NULL;
    }
    
    CGRect frame = self.bounds;
    NSInteger width = frame.size.width*[UIScreen mainScreen].scale;
    NSInteger height = frame.size.height*[UIScreen mainScreen].scale;
    
    if (width>0 && height>0) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        _context = CGBitmapContextCreate(NULL, width, height, 8, width*4, colorSpace, kCGImageAlphaPremultipliedLast);
        CGContextSetLineCap(_context, kCGLineCapRound);
        CGContextSetStrokeColorWithColor(_context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(_context, 10);
        CGContextConcatCTM(_context, CGAffineTransformMakeScale([UIScreen mainScreen].scale, [UIScreen mainScreen].scale));
        CGColorSpaceRelease(colorSpace);
        CGContextSetLineWidth(_context, _lineWidth);
        CGContextSetBlendMode(_context, kCGBlendModeCopy);
        CGContextSetStrokeColorWithColor(_context, _lineColor.CGColor);
    }
}

-(void)dealloc
{
    if (_context) {
        CGContextRelease(_context);
        _context = NULL;
    }
}
@end
