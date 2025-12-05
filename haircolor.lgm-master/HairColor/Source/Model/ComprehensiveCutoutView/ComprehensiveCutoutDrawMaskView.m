//
//  ComprehensiveCutoutMaskView.m
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/24.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "ComprehensiveCutoutDrawMaskView.h"
#import "UIImage+vImage.h"
#import "UIImage+Rotation.h"
#import "Masonry.h"

@interface ComprehensiveCutoutDrawMaskView ()
{
    BOOL _isDrawing;
    
    CGPoint _lastPoint, _currentPoint;
    
    UIImage *_brushImage;
    UIImage *_fixMaskImage, *_fixMaskBeginImage;
    
    CGContextRef _context;
}
@end

@implementation ComprehensiveCutoutDrawMaskView

-(ComprehensiveCutoutDrawMaskView *)initWithFrame:(CGRect)frame andImageWidth:(NSInteger)imageWidth andImageHeight:(NSInteger)imageHeight
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _imageWidth = imageWidth;
        _imageHeight = imageHeight;
        
        [self updateContextSize];
    }
    
    return self;
}

#pragma mark - touches
-(void)privateTouchesBeganAtPoint:(CGPoint)point
{
    _isDrawing = YES;
//    CGContextClearRect(_context, self.bounds);
//    CGContextDrawImage(_context, self.bounds, _fixMaskImage.CGImage);
    _fixMaskBeginImage = _fixMaskImage;
    
    _currentPoint = point;
    _currentPoint.y = self.bounds.size.height - _currentPoint.y;
    
    NSInteger brushRadius = _brushRadius*(1.0+_brushSmooth*0.5);
    
    UIGraphicsBeginImageContext(CGSizeMake(brushRadius*2+1, brushRadius*2+1));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat components[4] = {1.0, self.brushAlpha, 1.0, self.brushAlpha};
    CGContextSetFillColor(ctx, components);
    
    NSInteger solidRadius = (NSInteger)(_brushRadius)*(1.0-_brushSmooth*0.5);
    NSInteger difference = brushRadius-solidRadius;

    CGContextFillEllipseInRect(ctx, CGRectMake(difference, difference, solidRadius*2+1, solidRadius*2+1));
    _brushImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    difference = difference*2+1;
    const NSInteger maxBlur = 15;
    while (difference>=maxBlur) {
        _brushImage = [_brushImage boxBlurWithSize_2:maxBlur];
        difference -= maxBlur;
    }
    
    if (difference%2==0) {
        difference -= 1;
    }
    if (difference>0 && difference<maxBlur) {
        _brushImage = [_brushImage boxBlurWithSize_2:difference];
    }
    
    NSLog(@"%s", __FUNCTION__);
}
-(void)privateTouchesMovedToPoint:(CGPoint)point
{
    if (!_isDrawing) {
        _fixMaskBeginImage = _fixMaskImage;
        _isDrawing = YES;
    }
    
    _lastPoint = _currentPoint;
    _currentPoint = point;
    _currentPoint.y = self.bounds.size.height - _currentPoint.y;
    
    UIImage *maskImage = [self getDrawImage];

    _fixMaskImage = maskImage;
    self.layer.contents = (id)maskImage.CGImage;
    
    NSLog(@"%s", __FUNCTION__);

}

-(void)privateTouchesEndedAtPoint:(CGPoint)point
{
    _brushImage = nil;
    _fixMaskBeginImage = nil;
    _isDrawing = NO;
    
    NSLog(@"%s", __FUNCTION__);
}

-(void)privateTouchesCancelled
{
    if (_isDrawing) {
        _fixMaskImage = _fixMaskBeginImage;
        self.layer.contents = (id)_fixMaskImage.CGImage;
    }
    
    _brushImage = nil;
    _fixMaskBeginImage = nil;
    _isDrawing = NO;
    
    NSLog(@"%s", __FUNCTION__);

}

-(UIImage *)getDrawImage
{
    // Drawing code
    CGPoint fromPoint = _lastPoint;
    CGPoint toPoint = _currentPoint;
    
    CGFloat dx = toPoint.x - fromPoint.x;
    CGFloat dy = toPoint.y - fromPoint.y;
    CGFloat len = sqrtf((dx*dx)+(dy*dy));
    
    CGFloat ix = dx/len*_brushImage.size.width*0.1;
    CGFloat iy = dy/len*_brushImage.size.height*0.1;
    
    CGPoint point = fromPoint;

//    if (_fixMaskImage) {
//        CGRect rect = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
//        CGContextDrawImage(_context, rect, _fixMaskImage.CGImage);
//    }
    
    if (_eraseMode) {
        CGContextSetBlendMode(_context, kCGBlendModeDestinationOut);
    }
    else
    {
        CGContextSetBlendMode(_context, kCGBlendModeNormal);
    }
    
    CGFloat dlen = sqrtf((ix*ix)+(iy*iy));
    for (CGFloat i = 0; i <= len; i+=dlen)
    {
        CGRect rect = CGRectMake(point.x - ((_brushImage.size.width-1) / 2.0f),
                                 point.y - ((_brushImage.size.height-1) / 2.0f),
                                 _brushImage.size.width, _brushImage.size.height);
        CGContextDrawImage(_context, rect, _brushImage.CGImage);
        point.x += ix;
        point.y += iy;
    }
    
    CGContextFlush(_context);

    CGImageRef imageRef = CGBitmapContextCreateImage(_context);
    UIImage *drawImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return drawImage;
}

-(UIImage *)getMaskImage
{
    UIImage *maskImage = [self getFixMaskImage];
    
    return [maskImage resizeImageToSize:CGSizeMake(_imageWidth, _imageHeight)];
}

-(UIImage *)getFixMaskImage
{
    return _fixMaskImage;
}

-(void)setFixMaskImage:(UIImage *)image
{
    _fixMaskImage = image;
    
    if (_context) {
//        NSLog(@"%s", __FUNCTION__);
        CGContextSaveGState(_context);
        CGContextSetBlendMode(_context, kCGBlendModeNormal);
        CGContextClearRect(_context, self.bounds);
        CGContextDrawImage(_context, self.bounds, _fixMaskImage.CGImage);
        CGContextRestoreGState(_context);
        NSLog(@"%s", __FUNCTION__);
    }

    self.layer.contents = (id)_fixMaskImage.CGImage;
}

-(void)updateContextSize
{
    if (_context) {
        CGContextRelease(_context);
        _context = NULL;
    }
    
    NSInteger width = self.bounds.size.width*[UIScreen mainScreen].scale;
    NSInteger height = self.bounds.size.height*[UIScreen mainScreen].scale;
    
    if (width>0 && height>0) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        _context = CGBitmapContextCreate(NULL, width, height, 8, width*4, colorSpace, kCGImageAlphaPremultipliedLast);
        CGContextConcatCTM(_context, CGAffineTransformMakeScale([UIScreen mainScreen].scale, [UIScreen mainScreen].scale));
        CGColorSpaceRelease(colorSpace);
        
        [self setFixMaskImage:_fixMaskImage];
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
