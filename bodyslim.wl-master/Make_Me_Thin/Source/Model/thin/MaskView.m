//
//  maskView.m
//  eyeColorPlus
//
//  Created by shen on 14-7-16.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "MaskView.h"
#import "UIBezierPath+Points.h"
#import "CGRectCGPointUtility.h"

@interface MaskView ()
{
    CGPoint previousPos1, previousPos2, currentPos;
}
@property(nonatomic, strong) UIBezierPath *imagePath;
@property(nonatomic, strong) UIBezierPath *path;

@property(nonatomic, strong) UIImage *maskImage;
@end

@implementation MaskView

-(UIBezierPath *)path
{
    if (_path == nil) {
        _path = [[UIBezierPath alloc] init];
    }
    return _path;
}

-(UIBezierPath *)imagePath
{
    if (_imagePath==nil) {
        _imagePath=[[UIBezierPath alloc] init];
    }
    return _imagePath;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andDataSource:(id<MaskViewDataSource>)dataSource
{
    self = [self initWithFrame:frame];
    if (self) {
        self.dataSource = dataSource;
    }
    return self;
}
#pragma mark Private Helper function

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

-(void)privateTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.path = nil;
    self.imagePath = nil;
    
    UITouch *mytouch  = [touches anyObject];

    previousPos1 = [mytouch previousLocationInView:self];
    previousPos2 = [mytouch previousLocationInView:self];
    
    currentPos = [mytouch locationInView:self];
}
-(void)privateTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *mytouch  = [touches anyObject];
    UIImageView *imageView = [self.dataSource underneathImageView];
    CGRect rect = CGRectZero;
    rect.size = [self.dataSource imageSizeForMaskView:self];
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return;
    }
    
    previousPos2 = previousPos1;
    previousPos1 = [mytouch previousLocationInView:self];
    currentPos = [mytouch locationInView:self];
    
    CGPoint mid1 = midPoint(previousPos1, previousPos2);
    CGPoint mid2 = midPoint(previousPos1, currentPos);
    
    [self.path moveToPoint:mid1];
    [self.path addQuadCurveToPoint:mid2 controlPoint:previousPos1];
    
    mid1 = [self convertPoint:mid1 toView:imageView];
    mid1 = [CGRectCGPointUtility imageViewConvertPoint:mid1 fromViewRect:imageView.frame toImageRect:rect];
    
    mid2 = [self convertPoint:mid2 toView:imageView];
    mid2 = [CGRectCGPointUtility imageViewConvertPoint:mid2 fromViewRect:imageView.frame toImageRect:rect];
    
    CGPoint imageControlPnt = [self convertPoint:previousPos1 toView:imageView];
    imageControlPnt = [CGRectCGPointUtility imageViewConvertPoint:imageControlPnt fromViewRect:imageView.frame toImageRect:rect];
    
    [self.imagePath moveToPoint:mid1];
    [self.imagePath addQuadCurveToPoint:mid2 controlPoint:imageControlPnt];
    
    [self setNeedsDisplay];
}
-(void)privateTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self prepareMaskImage];
    self.path = nil;
    self.imagePath = nil;
    [self setNeedsDisplay];
}
-(void)privateTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.maskImage = nil;
    self.path = nil;
    self.imagePath = nil;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIColor orangeColor] setStroke];
    CGFloat stokeSize = [self.dataSource stokeWidthForMaskView:self]*2.0;
    [self.path setLineWidth:stokeSize];
    [self.path setLineCapStyle:kCGLineCapRound];
    [self.path strokeWithBlendMode:kCGBlendModeCopy alpha:0.5f];
}
-(void) prepareMaskImage
{
    if ([[self.path points] count] == 0) {
        self.maskImage = nil;
        return;
    }
    CGRect rect = CGRectZero;
    rect.size = [self.dataSource imageSizeForMaskView:self];
    
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        self.maskImage = nil;
        return;
    }
    
    CGFloat viewScale = [self.dataSource viewScaleForMaskView:self];
    CGFloat stokeSize = [self.dataSource stokeWidthForMaskView:self]*2.0/viewScale;
    stokeSize = [CGRectCGPointUtility imageViewConvertLength:stokeSize fromViewRect:self.frame toImageRect:rect];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, [self.dataSource imageScaleForMaskView:self]);
    {
        [[UIColor blackColor] setFill];
        UIRectFill(rect);
        
        [self.imagePath setLineWidth:stokeSize];
        [self.imagePath setLineCapStyle:kCGLineCapRound];
        [[UIColor whiteColor] setStroke];
        
        [self.imagePath stroke];
    }
    
    self.maskImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}
-(UIImage *)getMaskImage
{
    UIImage *image = self.maskImage;
    self.maskImage = nil;
    return image;
}
-(UIImage *)getViewImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
