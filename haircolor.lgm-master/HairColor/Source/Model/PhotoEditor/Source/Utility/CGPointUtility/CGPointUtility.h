//
//  CGPointUtility.h
//  FaceSimilality
//
//  Created by ZB_Mac on 15/6/3.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CGPointUtility : NSObject
+(CGPoint)vectorFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

+(CGPoint)vectorFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint byRatio:(CGFloat)ratio;

// [0, PI]
+(CGFloat)angleBetweenVector:(CGPoint)vector1 andVector:(CGPoint)vector2;

+(CGFloat)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2;

+(CGFloat)distanceSquareBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2;

+(CGPoint)pointFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint byRatio:(CGFloat)ratio;

+(CGPoint)pointFromPoint:(CGPoint)fromPoint translateByVector:(CGPoint)vector;

+(CGPoint)pointFromPoint:(CGPoint)fromPoint translateByVector:(CGPoint)vector withRatio:(CGFloat)ratio;

+(CGPoint)pointFromPoint:(CGPoint)fromPoint translateByMinusVector:(CGPoint)vector;

+(CGFloat)rotateAngelFromVector:(CGPoint)vector1 toVector:(CGPoint)vector2;

+(CGPoint)rotateVector:(CGPoint)vector byRotationAngle:(CGFloat)angle;

+(CGPoint)scaleVector:(CGPoint)vector toLength:(CGFloat)length;

+(CGPoint)scalePoint:(CGPoint)point byRatio:(CGFloat)ratio;

+(CGPoint)rotatePoint:(CGPoint)point byRotationAngle:(CGFloat)angle aroundPoint:(CGPoint)point;

+(CGPoint)rotatePoint:(CGPoint)point byRotationAngle:(CGFloat)angle aroundPoint:(CGPoint)center enlongByRatio:(CGFloat)enlongRatio;

+(CGPoint)clipPoint:(CGPoint)point inFrame:(CGRect)frame;

+(CGPoint)crossPointFromPoint:(CGPoint)srcPoint toLineDescribedByStart:(CGPoint)startPoint andEnd:(CGPoint)endPoint;

+(CGPoint)pointFromPoint:(CGPoint)srcPoint toLineDescribedByStart:(CGPoint)startPoint andEnd:(CGPoint)endPoint byRatio:(CGFloat)ratio;

+(CGPoint)pointFromPoint:(CGPoint)srcPoint toPoint:(CGPoint)dstPoint alongLineDescribedByStart:(CGPoint)startPoint andEnd:(CGPoint)endPoint byRatio:(CGFloat)ratio;

+(CGPoint)normalizedPoint:(CGPoint)point inSize:(CGSize)size;

+(CGFloat)lengthOfVector:(CGPoint)vector inDirection:(CGPoint)directionVector;

+(NSValue *)crossPointOfLine1StartPoint:(CGPoint)start1 toEndPoint:(CGPoint)end1 andLine2StartPoint:(CGPoint)start2 toEndPoint:(CGPoint)end2;

@end
