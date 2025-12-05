//
//  CGRectCGPointUtility.m
//  closedCurveImageCut
//
//  Created by shen on 14-6-27.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "CGRectCGPointUtility.h"

@implementation CGRectCGPointUtility
#pragma mark - My Methods -
+ (CGRect)scaleRespectAspectFromRect1:(CGRect)rect1 toRect2:(CGRect)rect2
{
    CGSize scaledSize = rect2.size;
    
    float scaleFactor = 1.0;
    
    CGFloat widthFactor  = rect2.size.width / rect1.size.width;
    CGFloat heightFactor = rect2.size.height / rect1.size.height;
    
    if (widthFactor < heightFactor)
        scaleFactor = widthFactor;
    else
        scaleFactor = heightFactor;
    
    scaledSize.height = rect1.size.height *scaleFactor;
    scaledSize.width  = rect1.size.width  *scaleFactor;
    
    float y = (rect2.size.height - scaledSize.height)/2;
    float x = (rect2.size.width - scaledSize.width)/2;
    
    return CGRectMake(x, y, scaledSize.width, scaledSize.height);
}

+(CGRect)scaleRespectAspectSize:(CGSize)size inRect:(CGRect)rect
{
    float scaleFactor = 1.0;
    
    CGFloat widthFactor  = rect.size.width / size.width;
    CGFloat heightFactor = rect.size.height / size.height;
    
    if (widthFactor < heightFactor)
        scaleFactor = widthFactor;
    else
        scaleFactor = heightFactor;
    
    CGSize scaledSize = CGSizeMake(size.width*scaleFactor, size.height*scaleFactor);
    
    float y = (rect.size.height - scaledSize.height)/2.0;
    float x = (rect.size.width - scaledSize.width)/2.0;
    
    return CGRectMake(x, y, scaledSize.width, scaledSize.height);
}

+ (CGRect)scaleRespectAspectSize:(CGSize)outerSize toContainSize:(CGSize)innerSize
{
    float scaleFactor = 1.0;
    
    CGFloat widthFactor  = outerSize.width/innerSize.width;
    CGFloat heightFactor = outerSize.height/innerSize.height;
    
    if (widthFactor < heightFactor)
        scaleFactor = widthFactor;
    else
        scaleFactor = heightFactor;
    
    CGSize scaledSize;
    scaledSize.height = outerSize.height/scaleFactor;
    scaledSize.width  = outerSize.width/scaleFactor;
    
    float x = (scaledSize.width-innerSize.width)/2.0;
    float y = (scaledSize.height-innerSize.height)/2.0;
    
    return CGRectMake(x, y, scaledSize.width, scaledSize.height);
}

+(CGRect) rectThatCenterSize:(CGSize)innerSize inSize:(CGSize)outerSize
{
    CGFloat widthFactor = innerSize.width/outerSize.width;
    CGFloat heightFactor = innerSize.height/outerSize.height;
    
    CGFloat factor = MAX(widthFactor, heightFactor);
    
    CGSize size;
    if (factor < 1.0) {
        size = innerSize;
    }
    else
    {
        size = CGSizeMake(innerSize.width/factor, innerSize.height/factor);
    }
    return CGRectMake((outerSize.width-size.width)/2.0, (outerSize.height-size.height)/2.0, size.width, size.height);
}

+ (CGPoint)convertCGPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2
{
    point1.y = rect1.height - point1.y;
    CGPoint result = CGPointMake((point1.x*rect2.width)/rect1.width, (point1.y*rect2.height)/rect1.height);
    return result;
}

+ (CGPoint)convertPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2
{
    CGPoint result = CGPointMake((point1.x*rect2.width)/rect1.width, (point1.y*rect2.height)/rect1.height);
    return result;
}

+(CGRect) imageViewConvertRect:(CGRect) rect fromImageRect:(CGRect) fromRect toViewRect:(CGRect) toRect
{
    CGRect result;

    result.origin = [self imageViewConvertPoint:rect.origin fromImageRect:fromRect toViewRect:toRect];
    result.size.width = [self imageViewConvertLength:rect.size.width fromImageRect:fromRect toViewRect:toRect];
    result.size.height = [self imageViewConvertLength:rect.size.height fromImageRect:fromRect toViewRect:toRect];
    return result;
}
+ (CGRect)imageViewConvertRect:(CGRect)rect fromViewRect:(CGRect)fromRect toImageRect:(CGRect)toRect
{
    CGRect result;
    
    result.origin = [self imageViewConvertPoint:rect.origin fromViewRect:fromRect toImageRect:toRect];
    result.size.width = [self imageViewConvertLength:rect.size.width fromViewRect:fromRect toImageRect:toRect];
    result.size.height = [self imageViewConvertLength:rect.size.height fromViewRect:fromRect toImageRect:toRect];
    return result;
}
+(CGPoint) imageViewConvertPoint:(CGPoint) point fromImageRect:(CGRect) fromRect toViewRect:(CGRect) toRect
{
    CGSize imageSize = fromRect.size;
    CGSize viewSize = toRect.size;
    
    CGFloat scaleFactor = 1.0;
    
    CGFloat widthFactor  = viewSize.width / imageSize.width;
    CGFloat heightFactor = viewSize.height / imageSize.height;
    
    if (widthFactor < heightFactor)
        scaleFactor = widthFactor;
    else
        scaleFactor = heightFactor;
    
    CGSize scaledSize;
    
    scaledSize.height = imageSize.height *scaleFactor;
    scaledSize.width  = imageSize.width  *scaleFactor;
    
    CGFloat y = (viewSize.height - scaledSize.height)/2;
    CGFloat x = (viewSize.width - scaledSize.width)/2;
    
    point.x *= scaleFactor;
    point.y *= scaleFactor;
    
    point.x += x;
    point.y += y;
    
    return point;
}
+(CGPoint) imageViewConvertPoint:(CGPoint) point fromViewRect:(CGRect) fromRect toImageRect:(CGRect) toRect
{
    CGSize imageSize = toRect.size;
    CGSize viewSize = fromRect.size;
    
    CGFloat scaleFactor = 1.0;
    
    CGFloat widthFactor  = viewSize.width / imageSize.width;
    CGFloat heightFactor = viewSize.height / imageSize.height;
    
    if (widthFactor < heightFactor)
        scaleFactor = widthFactor;
    else
        scaleFactor = heightFactor;
    
    CGSize scaledSize;
    
    scaledSize.height = imageSize.height *scaleFactor;
    scaledSize.width  = imageSize.width  *scaleFactor;
    
    CGFloat y = (viewSize.height - scaledSize.height)/2;
    CGFloat x = (viewSize.width - scaledSize.width)/2;
    
    point.x -= x;
    point.y -= y;
    
    point.x /= scaleFactor;
    point.y /= scaleFactor;
    
    return point;
}
+(CGFloat) imageViewConvertLength:(CGFloat) len fromImageRect:(CGRect) fromRect toViewRect:(CGRect) toRect
{
    CGSize imageSize = fromRect.size;
    CGSize viewSize = toRect.size;
    
    CGFloat scaleFactor = 1.0;
    
    CGFloat widthFactor  = viewSize.width / imageSize.width;
    CGFloat heightFactor = viewSize.height / imageSize.height;
    
    if (widthFactor < heightFactor)
        scaleFactor = widthFactor;
    else
        scaleFactor = heightFactor;
    
    len *= scaleFactor;
    
    return len;
}
+(CGFloat) imageViewConvertLength:(CGFloat) len fromViewRect:(CGRect) fromRect toImageRect:(CGRect) toRect
{
    CGSize imageSize = toRect.size;
    CGSize viewSize = fromRect.size;
    
    CGFloat scaleFactor = 1.0;
    
    CGFloat widthFactor  = viewSize.width / imageSize.width;
    CGFloat heightFactor = viewSize.height / imageSize.height;
    
    if (widthFactor < heightFactor)
        scaleFactor = widthFactor;
    else
        scaleFactor = heightFactor;
    
    len /= scaleFactor;
    
    return len;
}

@end
