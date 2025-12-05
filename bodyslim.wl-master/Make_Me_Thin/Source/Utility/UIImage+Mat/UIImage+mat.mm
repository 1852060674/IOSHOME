//
//  UIImage+mat.m
//  imageCut
//
//  Created by shen on 14-6-19.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "UIImage+mat.h"
//#import "ImageHelper.h"

@implementation UIImage (mat)

+(UIImage *)imageWith8UC4Mat:(cv::Mat)aMat
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    unsigned char* data = new unsigned char[4*aMat.cols * aMat.rows];
    for (int y = 0; y < aMat.rows; ++y)
    {
        cv::Vec4b *ptr = aMat.ptr<cv::Vec4b>(y);
        unsigned char *pdata = data + 4*y*aMat.cols;
        
        for (int x = 0; x < aMat.cols; ++x, ++ptr)
        {
            *pdata++ = (*ptr)[0];
            *pdata++ = (*ptr)[1];
            *pdata++ = (*ptr)[2];
            *pdata++ = (*ptr)[3];
        }
    }
    
    // Bitmap context
    CGContextRef context = CGBitmapContextCreate(data, aMat.cols, aMat.rows, 8, 4*aMat.cols, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    
    UIImage *ret = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:UIImageOrientationUp];
    
    CGImageRelease(cgimage);
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    delete []data;
    
    return ret;
}

+(UIImage *)imageWith8UC3Mat:(cv::Mat)aMat
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    unsigned char* data = new unsigned char[4*aMat.cols * aMat.rows];
    for (int y = 0; y < aMat.rows; ++y)
    {
        cv::Vec3b *ptr = aMat.ptr<cv::Vec3b>(y);
        unsigned char *pdata = data + 4*y*aMat.cols;
        
        for (int x = 0; x < aMat.cols; ++x, ++ptr)
        {
            *pdata++ = (*ptr)[0];
            *pdata++ = (*ptr)[1];
            *pdata++ = (*ptr)[2];
            *pdata++ = 255;
        }
    }
    
    // Bitmap context
    CGContextRef context = CGBitmapContextCreate(data, aMat.cols, aMat.rows, 8, 4*aMat.cols, colorSpace, kCGImageAlphaNoneSkipLast);
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    
    UIImage *ret = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:UIImageOrientationUp];
    
    CGImageRelease(cgimage);
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    delete []data;
    
    return ret;
}

+(cv::Mat)mat8UC4WithImage:(UIImage *)image
{
    cv::Mat aMat; aMat.create((int)image.size.height, (int)image.size.width, CV_8UC4);
    unsigned char* data = new unsigned char[4*aMat.cols * aMat.rows];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, aMat.cols, aMat.rows, 8, 4*aMat.cols, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    
    for (int y = 0; y < aMat.rows; ++y)
    {
        cv::Vec4b *ptr = aMat.ptr<cv::Vec4b>(y);
        unsigned char *pdata = data + 4*y*aMat.cols;
        
        for (int x = 0; x < aMat.cols; ++x, ++ptr)
        {
            (*ptr)[0] = *pdata++;
            (*ptr)[1] = *pdata++;
            (*ptr)[2] = *pdata++;
            (*ptr)[3] = *pdata++;
        }
    }
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    delete [] data;
    
    return aMat;
}

+(cv::Mat)mat8UC3WithImage:(UIImage *)image
{
    cv::Mat aMat; aMat.create((int)image.size.height, (int)image.size.width, CV_8UC3);
    unsigned char* data = new unsigned char[4*aMat.cols * aMat.rows];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, aMat.cols, aMat.rows, 8, 4*aMat.cols, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    
    for (int y = 0; y < aMat.rows; ++y)
    {
        cv::Vec3b *ptr = aMat.ptr<cv::Vec3b>(y);
        unsigned char *pdata = data + 4*y*aMat.cols;
        
        for (int x = 0; x < aMat.cols; ++x, ++ptr)
        {
            (*ptr)[0] = *pdata*255/(*(pdata+3));
            (*ptr)[1] = *(pdata+1)*255/(*(pdata+3));
            (*ptr)[2] = *(pdata+2)*255/(*(pdata+3));

//            (*ptr)[0] = 128;
//            (*ptr)[1] = 255;
//            (*ptr)[2] = 0;
            pdata+=4;
        }
    }
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    delete [] data;
    
    return aMat;
}

+(unsigned char *)data8UC4WithImage:(UIImage *)image
{
    int width = image.size.width;
    int height = image.size.height;
    
    unsigned char* data = new unsigned char[4*width*height];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    
    unsigned char* imageBuffer = new unsigned char[4*width*height];
    
    for (int y = 0; y<height; ++y)
    {
        unsigned char *ppdata = imageBuffer + 4*y*width;
        unsigned char *pdata = data + 4*y*width;
        
        for (int x = 0; x < width; ++x)
        {
            *(ppdata+0) = *(pdata+0)*255/(*(pdata+3));
            *(ppdata+1) = *(pdata+1)*255/(*(pdata+3));
            *(ppdata+2) = *(pdata+2)*255/(*(pdata+3));
            *(ppdata+3) = 255;
            //            (*ptr)[0] = 128;
            //            (*ptr)[1] = 255;
            //            (*ptr)[2] = 0;
            pdata+=4;
            ppdata+=4;
        }
    }
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    delete [] data;
    
    return imageBuffer;
}

+(UIImage *)imageWithMatAlpha:(cv::Mat)image
{
    NSData *data = [NSData dataWithBytes:image.data length:image.
                    elemSize()*image.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(image.cols,   //width
                                        image.rows,   //height
                                        8,            //bits per
                                        8*image.elemSize(),//bits per pixel
                                        image.step.p[0],   // bytesPerRow
                                        colorSpace,   //colorspace
                                        kCGImageAlphaLast|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,     // CGDataProviderRef
                                        NULL,         //decode
                                        false,        //should interpolate
                                        kCGRenderingIntentDefault //intent
                                        );
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
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
@end
