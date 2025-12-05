//
//  CGPointUtility.m
//  FaceSimilality
//
//  Created by ZB_Mac on 15/6/3.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "CGPointUtility.h"

@implementation CGPointUtility
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

+(CGPoint)pointFromPoint:(CGPoint)fromPoint translateByVector:(CGPoint)vector withRatio:(CGFloat)ratio
{
    vector = [self scalePoint:vector byRatio:ratio];
    return CGPointMake(fromPoint.x+vector.x, fromPoint.y+vector.y);
}

+(CGPoint)pointFromPoint:(CGPoint)fromPoint translateByMinusVector:(CGPoint)vector
{
    return CGPointMake(fromPoint.x-vector.x, fromPoint.y-vector.y);
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

+(CGPoint)rotatePoint:(CGPoint)point byRotationAngle:(CGFloat)angle aroundPoint:(CGPoint)center enlongByRatio:(CGFloat)enlongRatio
{
    CGPoint vector = [self vectorFromPoint:center toPoint:point];
    vector = [self scalePoint:[self rotateVector:vector byRotationAngle:angle] byRatio:(1.0+enlongRatio)];

    return [self pointFromPoint:center translateByVector:vector];
}

+(CGPoint)clipPoint:(CGPoint)point inFrame:(CGRect)frame
{
    if (point.x < CGRectGetMinX(frame)) point.x = CGRectGetMinX(frame);
    else if (point.x > CGRectGetMaxX(frame)) point.x = CGRectGetMaxX(frame);
    if (point.y < CGRectGetMinY(frame)) point.y = CGRectGetMinY(frame);
    else if (point.y > CGRectGetMaxY(frame)) point.y = CGRectGetMaxY(frame);
    
    return point;
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

+(CGPoint)pointFromPoint:(CGPoint)srcPoint toPoint:(CGPoint)dstPoint alongLineDescribedByStart:(CGPoint)startPoint andEnd:(CGPoint)endPoint byRatio:(CGFloat)ratio
{
    CGPoint crossPoint = [self crossPointFromPoint:dstPoint toLineDescribedByStart:srcPoint andEnd:[self pointFromPoint:srcPoint translateByVector:[self vectorFromPoint:startPoint toPoint:endPoint]]];
    
    return [self pointFromPoint:srcPoint toPoint:crossPoint byRatio:ratio];
}

+(CGPoint)normalizedPoint:(CGPoint)point inSize:(CGSize)size
{
    return CGPointMake(point.x/size.width, point.y/size.height);
}

+(NSValue *)crossPointOfLine1StartPoint:(CGPoint)start1 toEndPoint:(CGPoint)end1 andLine2StartPoint:(CGPoint)start2 toEndPoint:(CGPoint)end2
{
    if (start1.x == end1.x) {
        if (start2.x == end2.x) {
            return nil;
        }
        else
        {
            CGFloat a2 = (start2.y - end2.y) / (start2.x - end2.x);
            CGFloat b2 = start2.y - a2 * (start2.x);
            
            return [NSValue valueWithCGPoint:CGPointMake(start1.x, a2*start1.x+b2)];
        }
    }
    else
    {
        if (start2.x == end2.x) {
            CGFloat a1 = (start1.y - end1.y) / (start1.x - end1.x);
            CGFloat b1 = start1.y - a1 * (start1.x);
            
            return [NSValue valueWithCGPoint:CGPointMake(start2.x, a1*start2.x+b1)];
        }
    }
    CGFloat a1 = (start1.y - end1.y) / (start1.x - end1.x);
    CGFloat b1 = start1.y - a1 * (start1.x);
    
    CGFloat a2 = (start2.y - end2.y) / (start2.x - end2.x);
    CGFloat b2 = start2.y - a2 * (start2.x);
    
    if (a1>=a2 && a1<=a2) {
        return nil;
    }
    
    CGPoint crossPoint;
    crossPoint.x = (b1 - b2) / (a2 - a1);
    crossPoint.y = a1 * crossPoint.x + b1;
    return [NSValue valueWithCGPoint:crossPoint];
}
@end
