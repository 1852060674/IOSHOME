//
//  UIImage+mat.m
//  imageCut
//
//  Created by shen on 14-6-19.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "UIImage+Data.h"
#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVFoundation.h>
#import "CGRectCGPointUtility.h"

@implementation UIImage (Data)

+(unsigned char *)data8UC4WithImage:(UIImage *)image
{
    int width = image.size.width;
    int height = image.size.height;
    
    unsigned char* data = malloc(4*width*height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    
    unsigned char* imageBuffer = malloc(4*width*height);
    
    for (int y = 0; y<height; ++y)
    {
        unsigned char *ppdata = imageBuffer + 4*y*width;
        unsigned char *pdata = data + 4*y*width;
        
        for (int x = 0; x < width; ++x)
        {
//            *(ppdata+0) = *(pdata+0)*255/(*(pdata+3));
//            *(ppdata+1) = *(pdata+1)*255/(*(pdata+3));
//            *(ppdata+2) = *(pdata+2)*255/(*(pdata+3));
//            *(ppdata+3) = 255;
            *(ppdata+0) = *(pdata+0);
            *(ppdata+1) = *(pdata+1);
            *(ppdata+2) = *(pdata+2);
            *(ppdata+3) = *(pdata+3);
            
            pdata+=4;
            ppdata+=4;
        }
    }
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(data);
    
    return imageBuffer;
}

+(void)releaseData:(unsigned char*)data;
{
    free(data);
}

+(UIImage *)imageWith8UC4Data:(unsigned char *)data andWidth:(NSInteger)width andHeight:(NSInteger)height
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Bitmap context
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    
    UIImage *ret = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:UIImageOrientationUp];
    
    CGImageRelease(cgimage);
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}

+(UIImage *)smoothCircleWithDiameter:(NSInteger)circelDiameter;
{
    int width = (int)circelDiameter;
    int height = (int)circelDiameter;
    int imageHeight = height + (int)(height*0.25)*2;
    int imageWidth = width + (int)(width*0.25)*2;
    
    const size_t n = sizeof(UInt8) * imageWidth * imageHeight * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    unsigned char *data = (unsigned char *)calloc(1, n);
    memset(data, 255, n);
    CGContextRef context = CGBitmapContextCreate(data, imageWidth, imageHeight, 8, 4*imageWidth, colorSpace, kCGImageAlphaPremultipliedLast);
    
    const CGFloat fillColor[4] = {1.0, 0.0, 1.0, 1.0};
    CGContextSetFillColor(context, fillColor);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextFillEllipseInRect(context, CGRectMake((imageWidth-width)/2, (imageHeight-height)/2, width, height));
    
//    CGImageRef cgimage_1 = CGBitmapContextCreateImage(context);
//    UIImage *ret_1 = [UIImage imageWithCGImage:cgimage_1 scale:1.0 orientation:UIImageOrientationUp];
//    CGImageRelease(cgimage_1);

    CGContextRelease(context);
    
    void* outData = malloc(n);
    context = CGBitmapContextCreate(outData, imageWidth, imageHeight, 8, 4*imageWidth, colorSpace,kCGImageAlphaPremultipliedLast);
    
    vImage_Buffer src = {data, (vImagePixelCount)imageHeight, (vImagePixelCount)imageWidth, (size_t)imageWidth*4};
    vImage_Buffer dest = {outData, (vImagePixelCount)imageHeight, (vImagePixelCount)imageWidth, (size_t)imageWidth*4};
    
    uint32_t radius = (uint32_t)(imageHeight-height)|0x01;
    Pixel_8888 outerBGColor = {255, 255, 255, 255};
    vImageBoxConvolve_ARGB8888(&src, &dest, NULL, 0, 0, radius, radius, outerBGColor, kvImageEdgeExtend);
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    UIImage *ret = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:UIImageOrientationUp];
    
    CGImageRelease(cgimage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(data);
    free(outData);
    
    return ret;
}

+(UIImage *)smoothRectangleWithWidth:(NSInteger)width andHeight:(NSInteger)height;
{
    int imageHeight = height*1.5;
    int imageWidth = (int)width;
    
    const size_t n = sizeof(UInt8) * imageWidth * imageHeight * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    unsigned char *data = (unsigned char *)calloc(1, n);
    memset(data, 255, n);
    CGContextRef context = CGBitmapContextCreate(data, imageWidth, imageHeight, 8, 4*imageWidth, colorSpace, kCGImageAlphaPremultipliedLast);
    
    const CGFloat fillColor[4] = {1.0, 0.0, 1.0, 1.0};
    CGContextSetFillColor(context, fillColor);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextFillRect(context, CGRectMake((imageWidth-width)/2, (imageHeight-height)/2, width, height));
    CGContextRelease(context);
    
    void* outData = malloc(n);
    context = CGBitmapContextCreate(outData, imageWidth, imageHeight, 8, 4*imageWidth, colorSpace,kCGImageAlphaPremultipliedLast);

    vImage_Buffer src = {data, (vImagePixelCount)imageHeight, (vImagePixelCount)imageWidth, (size_t)imageWidth*4};
    vImage_Buffer dest = {outData, (vImagePixelCount)imageHeight, (vImagePixelCount)imageWidth, (size_t)imageWidth*4};
    
    uint32_t radius = (uint32_t)(imageHeight-height)|0x01;
    Pixel_8888 outerBGColor = {255, 255, 255, 255};
    vImageBoxConvolve_ARGB8888(&src, &dest, NULL, 0, 0, radius, radius, outerBGColor, kvImageEdgeExtend);
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    UIImage *ret = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:UIImageOrientationUp];
    
    CGImageRelease(cgimage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(data);
    free(outData);
    
    return ret;
}

+(UIImage *)smoothEllipseInRectangleWithWidth:(NSInteger)width andHeight:(NSInteger)height andSmoothFactor:(CGFloat)smoothFactor;
{
//    width = width*(1+smoothFactor*0.5);
//    height = height*(1+smoothFactor*0.5);
    
    int imageHeight = (int)height*(1.0+smoothFactor*0.5);
    int imageWidth = (int)width*(1.0+smoothFactor*0.5);
    
    const size_t n = sizeof(UInt8) * imageWidth * imageHeight * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    unsigned char *data = (unsigned char *)calloc(1, n);
    memset(data, 255, n);
    CGContextRef context = CGBitmapContextCreate(data, imageWidth, imageHeight, 8, 4*imageWidth, colorSpace, kCGImageAlphaPremultipliedLast);
    
    const CGFloat fillColor[4] = {1.0, 0.0, 1.0, 1.0};
    CGContextSetFillColor(context, fillColor);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextFillEllipseInRect(context, CGRectMake((imageWidth-width)/2, (imageHeight-height)/2, width, height));
    
    CGContextRelease(context);
    
    void* outData = malloc(n);
    context = CGBitmapContextCreate(outData, imageWidth, imageHeight, 8, 4*imageWidth, colorSpace,kCGImageAlphaPremultipliedLast);
    
    vImage_Buffer src = {data, (vImagePixelCount)imageHeight, (vImagePixelCount)imageWidth, (size_t)imageWidth*4};
    vImage_Buffer dest = {outData, (vImagePixelCount)imageHeight, (vImagePixelCount)imageWidth, (size_t)imageWidth*4};
    
    int radius = (int)(imageHeight-height)*0.8;
    radius = radius+radius%2-1;
    radius = MAX(1, radius);
    Pixel_8888 outerBGColor = {255, 255, 255, 255};
    vImageBoxConvolve_ARGB8888(&src, &dest, NULL, 0, 0, radius, radius, outerBGColor, kvImageEdgeExtend);
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    UIImage *ret = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:UIImageOrientationUp];
    
    CGImageRelease(cgimage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(data);
    free(outData);
    
    return ret;
}

+(UIImage *)smoothSolidCircleWithDiameter:(NSInteger)circelDiameter;
{
    int width = (int)circelDiameter;
    int height = (int)circelDiameter;
    int imageHeight = height + (int)(height*0.25)*2;
    int imageWidth = width + (int)(width*0.25)*2;
    
    const size_t n = sizeof(UInt8) * imageWidth * imageHeight * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    unsigned char *data = (unsigned char *)calloc(1, n);
    memset(data, 255, n);
    CGContextRef context = CGBitmapContextCreate(data, imageWidth, imageHeight, 8, 4*imageWidth, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextSetBlendMode(context, kCGBlendModeCopy);

    CGFloat fillColor[4] = {1.0, 0.0, 1.0, 0.0};
    CGContextSetFillColor(context, fillColor);
    CGContextFillRect(context, CGRectMake(0, 0, imageWidth, imageHeight));
    
    fillColor[1] = 1.0;
    CGContextSetFillColor(context, fillColor);
    CGContextFillEllipseInRect(context, CGRectMake((imageWidth-width)/2, (imageHeight-height)/2, width, height));
    
//    CGImageRef cgimage_1 = CGBitmapContextCreateImage(context);
//    UIImage *ret_1 = [UIImage imageWithCGImage:cgimage_1 scale:1.0 orientation:UIImageOrientationUp];
//    CGImageRelease(cgimage_1);
    
    CGContextRelease(context);
    
    void* outData = malloc(n);
    context = CGBitmapContextCreate(outData, imageWidth, imageHeight, 8, 4*imageWidth, colorSpace,kCGImageAlphaPremultipliedLast);
    
    vImage_Buffer src = {data, (vImagePixelCount)imageHeight, (vImagePixelCount)imageWidth, (size_t)imageWidth*4};
    vImage_Buffer dest = {outData, (vImagePixelCount)imageHeight, (vImagePixelCount)imageWidth, (size_t)imageWidth*4};
    
    uint32_t radius = (uint32_t)(imageHeight-height)|0x01;
    Pixel_8888 outerBGColor = {255, 255, 255, 255};
    vImageBoxConvolve_ARGB8888(&src, &dest, NULL, 0, 0, radius, radius, outerBGColor, kvImageEdgeExtend);
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    UIImage *ret = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:UIImageOrientationUp];
    
    CGImageRelease(cgimage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(data);
    free(outData);
    
    return ret;
}

+(UIImage *)generateImageWithSize:(CGSize)size andColor:(UIColor*)color;
{
    int width = size.width;
    int height = size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Bitmap context
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    
    UIImage *ret = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:UIImageOrientationUp];
    
    CGImageRelease(cgimage);
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}

+(UIImage *)generateImageWithSize:(CGSize)size withImage:(UIImage *)image andDrawArea:(CGRect)drawArea;
{
    int width = size.width;
    int height = size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Bitmap context
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    
    CGContextDrawImage(context, drawArea, image.CGImage);
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    
    UIImage *ret = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:UIImageOrientationUp];
    
    CGImageRelease(cgimage);
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}

+(UIImage *)generateImageWithSize:(CGSize)size withCenterImage:(UIImage *)image andRatio:(CGFloat)ratio;
{
    int width = size.width;
    int height = size.height;

    CGRect fitArea = AVMakeRectWithAspectRatioInsideRect(image.size, CGRectMake(0, 0, width, height));
    CGPoint center = [CGRectCGPointUtility centerPointOfRect:fitArea];
    CGRect drawArea = [CGRectCGPointUtility rectWithCenterPoint:center andSize:CGSizeMake(fitArea.size.width*ratio, fitArea.size.height*ratio)];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Bitmap context
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    
    CGContextDrawImage(context, drawArea, image.CGImage);
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    
    UIImage *ret = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:UIImageOrientationUp];
    
    CGImageRelease(cgimage);
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}

@end
