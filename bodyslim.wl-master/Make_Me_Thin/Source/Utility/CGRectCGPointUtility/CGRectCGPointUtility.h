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
+(CGPoint)centerPointOfRect:(CGRect)rect;
+(CGRect)rectWithCenterPoint:(CGPoint)center andSize:(CGSize)size;
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

@end
