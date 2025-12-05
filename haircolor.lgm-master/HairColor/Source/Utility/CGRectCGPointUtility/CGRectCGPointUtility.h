//
//  CGRectCGPointUtility.h
//  closedCurveImageCut
//
//  Created by shen on 14-6-27.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
@interface CGRectCGPointUtility : NSObject
+ (CGRect)scaleRespectAspectFromRect1:(CGRect)rect1 toRect2:(CGRect)rect2;
+ (CGRect)scaleRespectAspectSize:(CGSize)size inRect:(CGRect)rect;
+ (CGRect)scaleRespectAspectSize:(CGSize)outerSize toContainSize:(CGSize)innerSize;
+(CGRect) rectThatCenterSize:(CGSize)innerSize inSize:(CGSize)outerSize;

+ (CGPoint)convertCGPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2;
+ (CGPoint)convertPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2;

+(CGRect) imageViewConvertRect:(CGRect) rect fromImageRect:(CGRect) fromRect toViewRect:(CGRect)toRect;
+(CGRect) imageViewConvertRect:(CGRect)rect fromViewRect:(CGRect)fromRect toImageRect:(CGRect)toRect;
+(CGPoint) imageViewConvertPoint:(CGPoint) point fromImageRect:(CGRect) fromRect toViewRect:(CGRect) toRect;
+(CGPoint) imageViewConvertPoint:(CGPoint) point fromViewRect:(CGRect) fromRect toImageRect:(CGRect) toRect;
+(CGFloat) imageViewConvertLength:(CGFloat) len fromImageRect:(CGRect) fromRect toViewRect:(CGRect) toRect;
+(CGFloat) imageViewConvertLength:(CGFloat) len fromViewRect:(CGRect) fromRect toImageRect:(CGRect) toRect;

+(CGPoint)vectorFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

+(CGPoint)vectorFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint byRatio:(CGFloat)ratio;

// [0, PI]
+(CGFloat)angleBetweenVector:(CGPoint)vector1 andVector:(CGPoint)vector2;

+(CGFloat)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2;

+(CGFloat)distanceSquareBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2;

+(CGFloat)lengthFrom:(CGFloat)fromLen toLength:(CGFloat)toLen byRatio:(CGFloat)ratio;

+(CGPoint)pointFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint byRatio:(CGFloat)ratio;

+(CGPoint)pointFromPoint:(CGPoint)fromPoint translateByVector:(CGPoint)vector;

+(CGFloat)rotateAngelFromVector:(CGPoint)vector1 toVector:(CGPoint)vector2;

+(CGPoint)rotateVector:(CGPoint)vector byRotationAngle:(CGFloat)angle;

+(CGPoint)scaleVector:(CGPoint)vector toLength:(CGFloat)length;

+(CGPoint)scalePoint:(CGPoint)point byRatio:(CGFloat)ratio;

+(CGPoint)rotatePoint:(CGPoint)point byRotationAngle:(CGFloat)angle aroundPoint:(CGPoint)point;

+(CGPoint)clipPoint:(CGPoint)point inFrame:(CGRect)frame;

+(CGPoint)normalizedPoint:(CGPoint)point inSize:(CGSize)size;

+(CGPoint)pointFromPoint:(CGPoint)fromPoint translateByVector:(CGPoint)vector withRatio:(CGFloat)ratio;

+(CGPoint)pointFromPoint:(CGPoint)srcPoint toLineDescribedByStart:(CGPoint)startPoint andEnd:(CGPoint)endPoint byRatio:(CGFloat)ratio;

+(CGFloat)lengthOfVector:(CGPoint)vector inDirection:(CGPoint)directionVector;

+(CGPoint)vectorOfVector:(CGPoint)vector inDirection:(CGPoint)directionVector;

+(NSArray *)pointsIntersectByLineFromPoint:(CGPoint)srcPoint inDirection:(CGPoint)directionVector andFrame:(CGRect)frame;
@end
