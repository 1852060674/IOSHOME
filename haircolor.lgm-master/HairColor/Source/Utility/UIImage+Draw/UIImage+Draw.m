//
//  UIImage+Draw.m
//  cutout
//
//  Created by ZB_Mac on 16/4/28.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "UIImage+Draw.h"

@implementation UIImage (Draw)
+(UIImage *)drawRadiantImageWithSize:(CGSize)size andCenter:(CGPoint)center andBGColor:(UIColor *)bgColor andFGColor:(UIColor *)fgColor andNumber:(NSInteger)number
{
    if (size.width<=0 || size.height<=0 || center.x<=0 || center.y<=0 || size.width<center.x || size.height<center.y) {
        return nil;
    }
    
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [bgColor setFill];
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    
    CGFloat minDistance = MIN(MIN(MIN(center.x, center.y), size.width-center.x), size.height-center.y);
    
    CGFloat angleUnit = M_PI*2/number;
    CGFloat endRadius = tan(angleUnit/4)*minDistance;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = {0.0, 1.0};
    CGFloat colors[8] = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0};
    [fgColor getRed:colors+0 green:colors+1 blue:colors+2 alpha:colors+3];
    [fgColor getRed:colors+4 green:colors+5 blue:colors+6 alpha:colors+7];
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, colors, locations, num_locations);
    
    for (int idx=0; idx<number; ++idx) {
        CGPoint endPoint = center;
        endPoint.x += cos(angleUnit*idx)*minDistance;
        endPoint.y += sin(angleUnit*idx)*minDistance;
        CGContextDrawRadialGradient(ctx, gradient, center, 0.0f, endPoint, endRadius, kCGGradientDrawsAfterEndLocation);
    }

    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    CFRelease(gradient);
    CFRelease(colorspace);
    
    return resultImage;
}

+(UIImage *)drawLightImageWithSize:(CGSize)size andCenter:(CGPoint)center andBGColor:(UIColor *)bgColor andFGColor:(UIColor *)fgColor andLineWidth:(CGFloat)lineWidth andLineLength:(CGFloat)lineLength andOffset:(CGFloat)offset andNumber:(NSInteger)number
{
    if (size.width<=0 || size.height<=0 || center.x<=0 || center.y<=0 || size.width<center.x || size.height<center.y) {
        return nil;
    }
    
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [bgColor setFill];
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    
    CGFloat angleUnit = M_PI*2/number;
    
    CGContextSetStrokeColorWithColor(ctx, fgColor.CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    
    for (int idx=0; idx<number; ++idx) {
        CGPoint startPoint = center;
        startPoint.x += cos(angleUnit*idx)*(offset);
        startPoint.y += sin(angleUnit*idx)*(offset);
        
        CGPoint endPoint = center;
        endPoint.x += cos(angleUnit*idx)*(lineLength+offset);
        endPoint.y += sin(angleUnit*idx)*(lineLength+offset);
        
        CGContextMoveToPoint(ctx, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y);
    }
    
    CGContextStrokePath(ctx);
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return resultImage;
}

+(UIImage *)drawImageWithColor:(UIColor *)color size:(CGSize)size scale:(CGFloat)scale;
{
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}

+(UIImage *)drawTransparentImageWithSize:(CGSize)size scale:(CGFloat)scale;
{
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0] setFill];
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}
@end
