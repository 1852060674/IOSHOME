//
//  CGRectCGPointUtility.m
//  closedCurveImageCut
//
//  Created by shen on 14-6-27.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "CGRectCGPointUtility.h"
#import <UIKit/UIKit.h>

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

+(CGPoint)vectorFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    return CGPointMake(toPoint.x-fromPoint.x, toPoint.y-fromPoint.y);
}

+(CGPoint)vectorFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint byRatio:(CGFloat)ratio
{
    return [self vectorFromPoint:fromPoint toPoint:[self pointFromPoint:fromPoint toPoint:toPoint byRatio:ratio]];
}

+(CGFloat)angleBetweenVector:(CGPoint)vector1 andVector:(CGPoint)vector2
{
    CGFloat mod1 = sqrt((vector1.x*vector1.x)+(vector1.y*vector1.y));
    if (mod1 == 0) {
        return 0;
    }
    
    CGFloat mod2 = sqrt((vector2.x*vector2.x)+(vector2.y*vector2.y));
    if (mod2 == 0) {
        return 0;
    }
    
    CGFloat innerProduct = vector1.x*vector2.x + vector1.y*vector2.y;
    
    CGFloat cosinA = MIN(MAX(innerProduct/(mod1*mod2), -1), 1);
    CGFloat A = acos(cosinA);
    
    return A;
}
+(CGFloat)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2
{
    CGPoint vector = [self vectorFromPoint:point1 toPoint:point2];
    
    CGFloat mod = sqrt((vector.x*vector.x)+(vector.y*vector.y));
    
    return mod;
}

+(CGFloat)distanceSquareBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2
{
    CGPoint vector = [self vectorFromPoint:point1 toPoint:point2];
    
    CGFloat mod = ((vector.x*vector.x)+(vector.y*vector.y));
    
    return mod;
}

+(CGPoint)pointFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint byRatio:(CGFloat)ratio
{
    CGPoint vector = [self vectorFromPoint:fromPoint toPoint:toPoint];
    
    return [self pointFromPoint:fromPoint translateByVector:CGPointMake(vector.x*ratio, vector.y*ratio)];
}

+(CGPoint)pointFromPoint:(CGPoint)fromPoint translateByVector:(CGPoint)vector
{
    return CGPointMake(fromPoint.x+vector.x, fromPoint.y+vector.y);
}

+(CGFloat)rotateAngelFromVector:(CGPoint)vector1 toVector:(CGPoint)vector2
{
    CGFloat betweenAngel = [self angleBetweenVector:vector1 andVector:vector2];
    
    CGFloat crossProduct = vector1.x*vector2.y-vector1.y*vector2.x;
    
    BOOL clockWise = crossProduct>0.0;
    
    return clockWise?betweenAngel:-betweenAngel;
}

+(CGPoint)rotateVector:(CGPoint)vector byRotationAngle:(CGFloat)angle
{
    CGPoint rotatedVector;
    rotatedVector.x = vector.x*cos(angle)+vector.y*sin(angle);
    rotatedVector.y = -vector.x*sin(angle)+vector.y*cos(angle);
    
    return rotatedVector;
}

+(CGPoint)scaleVector:(CGPoint)vector toLength:(CGFloat)length
{
    CGFloat originalLength = [self distanceBetweenPoint:CGPointZero andPoint:vector];
    
    if (originalLength <= 0) {
        return CGPointZero;
    }
    
    CGPoint scaledVector = CGPointMake(vector.x*length/originalLength, vector.y*length/originalLength);
    
    return scaledVector;
}

+(CGPoint)scalePoint:(CGPoint)point byRatio:(CGFloat)ratio
{
    return [self pointFromPoint:CGPointZero toPoint:point byRatio:ratio];
}

+(CGPoint)rotatePoint:(CGPoint)point byRotationAngle:(CGFloat)angle aroundPoint:(CGPoint)center
{
    CGPoint vector = [self vectorFromPoint:center toPoint:point];
    vector = [self rotateVector:vector byRotationAngle:angle];
    return [self pointFromPoint:center translateByVector:vector];
}

+(CGPoint)clipPoint:(CGPoint)point inFrame:(CGRect)frame
{
    if (point.x < CGRectGetMinX(frame)) point.x = CGRectGetMinX(frame);
    else if (point.x > CGRectGetMaxX(frame)) point.x = CGRectGetMaxX(frame);
    if (point.y < CGRectGetMinX(frame)) point.y = CGRectGetMinX(frame);
    else if (point.y > CGRectGetMaxX(frame)) point.y = CGRectGetMaxX(frame);
    
    return point;
}

+(CGPoint)normalizedPoint:(CGPoint)point inSize:(CGSize)size
{
    return CGPointMake(point.x/size.width, point.y/size.height);
}

+(CGPoint)pointFromPoint:(CGPoint)fromPoint translateByVector:(CGPoint)vector withRatio:(CGFloat)ratio
{
    vector = [self scalePoint:vector byRatio:ratio];
    return CGPointMake(fromPoint.x+vector.x, fromPoint.y+vector.y);
}

//可能为负数
+(CGFloat)lengthOfVector:(CGPoint)vector inDirection:(CGPoint)directionVector
{
    directionVector = [self scaleVector:directionVector toLength:1.0];
    
    return vector.x*directionVector.x+vector.y*directionVector.y;
}

+(CGPoint)vectorOfVector:(CGPoint)vector inDirection:(CGPoint)directionVector
{
    CGFloat lengthInDirection = [self lengthOfVector:vector inDirection:directionVector];
    return [self scaleVector:directionVector toLength:lengthInDirection];
}

+(CGPoint)crossPointFromPoint:(CGPoint)srcPoint toLineDescribedByStart:(CGPoint)startPoint andEnd:(CGPoint)endPoint
{
    CGPoint vectorInDirection = [self vectorOfVector:[self vectorFromPoint:startPoint toPoint:srcPoint] inDirection:[self vectorFromPoint:startPoint toPoint:endPoint]];
    
    return [self pointFromPoint:startPoint translateByVector:vectorInDirection];
}

+(CGPoint)pointFromPoint:(CGPoint)srcPoint toLineDescribedByStart:(CGPoint)startPoint andEnd:(CGPoint)endPoint byRatio:(CGFloat)ratio
{
    return [self pointFromPoint:srcPoint toPoint:[self crossPointFromPoint:srcPoint toLineDescribedByStart:startPoint andEnd:endPoint] byRatio:ratio];
}

+(CGFloat)lengthFrom:(CGFloat)fromLen toLength:(CGFloat)toLen byRatio:(CGFloat)ratio
{
    return fromLen*(1.0-ratio)+toLen*ratio;
}

+(NSValue *)pointsIntersectByLineFromPoint:(CGPoint)srcPoint_1 inDirection:(CGPoint)directionVector_1 andLineFromPoint:(CGPoint)srcPoint_2 inDirection:(CGPoint)directionVector_2
{
    CGFloat A1, B1, C1, A2, B2, C2;
    
    A1 = directionVector_1.y;
    B1 = -directionVector_1.x;
    C1 = directionVector_1.x*srcPoint_1.y-directionVector_1.y*srcPoint_1.x;
    
    A2 = directionVector_2.y;
    B2 = -directionVector_2.x;
    C2 = directionVector_2.x*srcPoint_2.y-directionVector_2.y*srcPoint_2.x;
    
    CGFloat K = A2*B1-A1*B2;
    if (K<0.000000001 && K>-0.000000001) {
        return nil;
    }
    else
    {
        CGPoint point;
        point.y = (A1*C2-A2*C1)/K;
        point.x = (B2*C1-B1*C2)/K;
        
        return [NSValue valueWithCGPoint:point];
    }
}

+(NSArray *)pointsIntersectByLineFromPoint:(CGPoint)srcPoint inDirection:(CGPoint)directionVector andFrame:(CGRect)frame;
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSValue *left = [self pointsIntersectByLineFromPoint:srcPoint inDirection:directionVector andLineFromPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame)) inDirection:CGPointMake(0.0, 1.0)];
    NSValue *top = [self pointsIntersectByLineFromPoint:srcPoint inDirection:directionVector andLineFromPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame)) inDirection:CGPointMake(1.0, 0.0)];
    NSValue *right = [self pointsIntersectByLineFromPoint:srcPoint inDirection:directionVector andLineFromPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame)) inDirection:CGPointMake(0.0, 1.0)];
    NSValue *bottom = [self pointsIntersectByLineFromPoint:srcPoint inDirection:directionVector andLineFromPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame)) inDirection:CGPointMake(1.0, 0.0)];

    if (left) {
        CGPoint point = [left CGPointValue];
        if (point.y >= CGRectGetMinY(frame) && point.y < CGRectGetMaxY(frame)) {
            [array addObject:left];
        }
    }
    
    if (top) {
        CGPoint point = [top CGPointValue];
        if (point.x > CGRectGetMinX(frame) && point.x <= CGRectGetMaxX(frame)) {
            [array addObject:top];
        }
    }
    
    if (right) {
        CGPoint point = [right CGPointValue];
        
        if (point.y > CGRectGetMinY(frame) && point.y <= CGRectGetMaxY(frame)) {
            [array addObject:right];
        }
    }
    
    if (bottom) {
        CGPoint point = [bottom CGPointValue];
        if (point.x >= CGRectGetMinX(frame) && point.x < CGRectGetMaxX(frame)) {
            [array addObject:bottom];
        }
    }
    
    return array;
}

@end
