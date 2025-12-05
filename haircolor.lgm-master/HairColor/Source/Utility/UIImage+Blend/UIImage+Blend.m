//
//  UIImage+Blend.m
//  Kuchibiru
//
//  Created by  on 11/08/26.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Blend.h"
#import "UIImage+Extensions.h"

@implementation UIImage (Blend)

- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:rect];
    
//    [overlayImage drawAtPoint:CGPointMake(0, 0) blendMode:blendMode alpha:alpha];
    
    [overlayImage drawInRect:rect blendMode:blendMode alpha:alpha];
    
    UIImage *blendedImage = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();
    
    return blendedImage;
}

- (UIImage *)imageMaskedWithImage:(UIImage *)maskImage
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextRef context = CGBitmapContextCreate(NULL, CGRectGetWidth(rect), CGRectGetHeight(rect), 8, CGRectGetWidth(rect)*4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    CGContextClipToMask(context, rect, maskImage.CGImage);
    CGContextDrawImage(context, rect, self.CGImage);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *maskedImage = [UIImage imageWithCGImage:imageRef];

    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(imageRef);
    
    return maskedImage;
}

- (UIImage *)imageMaskedWithImage:(UIImage *)maskImage alpha:(CGFloat)alpha
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextRef context = CGBitmapContextCreate(NULL, CGRectGetWidth(rect), CGRectGetHeight(rect), 8, CGRectGetWidth(rect)*4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    CGContextClipToMask(context, rect, maskImage.CGImage);
    
    CGContextSetAlpha(context, alpha);
    
    CGContextDrawImage(context, rect, self.CGImage);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *maskedImage = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(imageRef);
    
    return maskedImage;
}

- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage maskImage:(UIImage *)maskImage
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextRef context = CGBitmapContextCreate(NULL, CGRectGetWidth(rect), CGRectGetHeight(rect), 8, CGRectGetWidth(rect)*4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(context, rect, self.CGImage);
    CGContextClipToMask(context, rect, maskImage.CGImage);
    CGContextDrawImage(context, CGRectMake(0, 0, overlayImage.size.width, overlayImage.size.height), overlayImage.CGImage);

    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *maskedImage = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(imageRef);
    
    return maskedImage;
}

- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage atOrigin:(CGPoint)origin maskImage:(UIImage *)maskImage
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextRef context = CGBitmapContextCreate(NULL, CGRectGetWidth(rect), CGRectGetHeight(rect), 8, CGRectGetWidth(rect)*4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(context, rect, self.CGImage);
    CGContextClipToMask(context, CGRectMake(origin.x, origin.y, overlayImage.size.width, overlayImage.size.height), maskImage.CGImage);
    CGContextDrawImage(context, CGRectMake(origin.x, origin.y, overlayImage.size.width, overlayImage.size.height), overlayImage.CGImage);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *maskedImage = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(imageRef);
    
    return maskedImage;
}

- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage maskImage:(UIImage *)maskImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(NULL, CGRectGetWidth(rect), CGRectGetHeight(rect), 8, CGRectGetWidth(rect)*4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
//    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, rect, self.CGImage);
    CGContextClipToMask(context, rect, maskImage.CGImage);
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetBlendMode(context, blendMode);
    CGContextSetAlpha(context, alpha);
    CGContextDrawImage(context, rect, overlayImage.CGImage);
    
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    maskedImage = [maskedImage imageFlipVertical];
    
//    CGImageRef imageRef = CGBitmapContextCreateImage(context);
//    UIImage *maskedImage = [UIImage imageWithCGImage:imageRef];
//    CGColorSpaceRelease(colorSpace);
//    CGContextRelease(context);
//    CGImageRelease(imageRef);
    
    UIGraphicsEndImageContext();
    return maskedImage;
}

- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage atOrigin:(CGPoint)origin maskImage:(UIImage *)maskImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextRef context = CGBitmapContextCreate(NULL, CGRectGetWidth(rect), CGRectGetHeight(rect), 8, CGRectGetWidth(rect)*4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(context, rect, self.CGImage);
    CGContextClipToMask(context, CGRectMake(origin.x, origin.y, overlayImage.size.width, overlayImage.size.height), maskImage.CGImage);
    
    CGContextSetBlendMode(context, blendMode);
    CGContextSetAlpha(context, alpha);
    CGContextDrawImage(context, CGRectMake(origin.x, origin.y, overlayImage.size.width, overlayImage.size.height), overlayImage.CGImage);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *maskedImage = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(imageRef);
    
    return maskedImage;
}

-(CGSize)sizeContainingSize:(CGSize)smallSize withRatio:(CGFloat)ratio
{
    CGSize size = smallSize;
    if (smallSize.height<smallSize.width*ratio) {
        size.height = smallSize.width*ratio;
    }
    else if (smallSize.height>smallSize.width*ratio)
    {
        size.width = size.height/ratio;
    }
    return size;
}

- (UIImage *)imageBlendedWithAspectFillImage:(UIImage *)overlayImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    
    UIGraphicsBeginImageContext(self.size);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:rect];
    
    rect.size = [self sizeContainingSize:self.size withRatio:overlayImage.size.height/overlayImage.size.width];
    rect.origin = CGPointMake((self.size.width-rect.size.width)/2.0, (self.size.height-rect.size.height)/2.0);
    
    [overlayImage drawInRect:rect blendMode:blendMode alpha:alpha];
    
    UIImage *blendedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return blendedImage;
}

- (UIImage *)imageFillBlendedWithImage:(UIImage *)overlayImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    
    UIGraphicsBeginImageContext(self.size);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:rect];
    
    [overlayImage drawInRect:rect blendMode:blendMode alpha:alpha];
    
    UIImage *blendedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return blendedImage;
}

-(UIImage *)imageBlendedWithImage:(UIImage *)overlayImage inFrame:(CGRect)frame blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextRef context = CGBitmapContextCreate(NULL, CGRectGetWidth(rect), CGRectGetHeight(rect), 8, CGRectGetWidth(rect)*4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(context, rect, self.CGImage);
    
    CGContextSetBlendMode(context, blendMode);
    CGContextSetAlpha(context, alpha);
    CGContextDrawImage(context, frame, overlayImage.CGImage);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *maskedImage = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(imageRef);
    
    return maskedImage;
}
//
//-(UIImage *)imageBlendedWithImage:(UIImage *)overlayImage inOverlayRect:(CGRect)overlayRect withTransform:(CGAffineTransform)t alpha:(CGFloat)alpha
//{
//    UIImage *baseImage = self;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGRect rect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
//    CGContextRef context = CGBitmapContextCreate(NULL, CGRectGetWidth(rect), CGRectGetHeight(rect), 8, CGRectGetWidth(rect)*4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
//    
//    CGContextDrawImage(context, rect, baseImage.CGImage);
//    
//    CGContextSetBlendMode(context, kCGBlendModeNormal);
//    CGContextSetAlpha(context, alpha);
//    
//    overlayRect.origin.y = rect.size.height-overlayRect.origin.y-overlayRect.size.height;
//    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(CGRectGetMidX(overlayRect), CGRectGetMidY(overlayRect)));
//    CGContextConcatCTM(context, t);
//    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-CGRectGetMidX(overlayRect), -CGRectGetMidY(overlayRect)));
//    CGContextDrawImage(context, overlayRect, overlayImage.CGImage);
//    
//    CGImageRef imageRef = CGBitmapContextCreateImage(context);
//    UIImage *maskedImage = [UIImage imageWithCGImage:imageRef];
//    
//    CGColorSpaceRelease(colorSpace);
//    CGContextRelease(context);
//    CGImageRelease(imageRef);
//    
//    return maskedImage;
//}


-(UIImage *)imageBlendedWithImage:(UIImage *)overlayImage inOverlayRect:(CGRect)overlayRect withTransform:(CGAffineTransform)t alpha:(CGFloat)alpha
{
    UIImage *baseImage = self;
    CGRect rect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    
    UIGraphicsBeginImageContextWithOptions(baseImage.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextDrawImage(context, rect, baseImage.CGImage);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetAlpha(context, alpha);
    
    overlayRect.origin.y = rect.size.height-overlayRect.origin.y-overlayRect.size.height;
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(CGRectGetMidX(overlayRect), CGRectGetMidY(overlayRect)));
    CGContextConcatCTM(context, t);
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-CGRectGetMidX(overlayRect), -CGRectGetMidY(overlayRect)));
    CGContextDrawImage(context, overlayRect, overlayImage.CGImage);
    
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    maskedImage = [maskedImage imageFlipVertical];
    
    return maskedImage;
}

@end
