//
//  UIImage+mat.m
//  imageCut
//
//  Created by shen on 14-6-19.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "UIImage+Mat.h"
#import <opencv2/imgproc.hpp>

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
            *pdata++ = (*ptr)[0] * ((*ptr)[3]*1.0/255);
            *pdata++ = (*ptr)[1] * ((*ptr)[3]*1.0/255);
            *pdata++ = (*ptr)[2] * ((*ptr)[3]*1.0/255);
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

+(UIImage *)imageWith8UC1Mat:(cv::Mat)aMat
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    unsigned char* data = new unsigned char[aMat.cols * aMat.rows];
    for (int y = 0; y < aMat.rows; ++y)
    {
        uchar *ptr = aMat.ptr<uchar>(y);
        unsigned char *pdata = data + y*aMat.cols;
        
        for (int x = 0; x < aMat.cols; ++x, ++ptr)
        {
            *pdata++ = (*ptr);
//            *pdata++ = (*ptr)[1];
//            *pdata++ = (*ptr)[2];
//            *pdata++ = 255;
        }
    }
    
    // Bitmap context
    CGContextRef context = CGBitmapContextCreate(data, aMat.cols, aMat.rows, 8, aMat.cols, colorSpace, kCGImageAlphaNone);
    
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    
    UIImage *ret = [UIImage imageWithCGImage:cgimage scale:1.0 orientation:UIImageOrientationUp];
    
    CGImageRelease(cgimage);
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    delete []data;
    
    return ret;
}

+(UIImage *)alphaImageWith8UC1Mat:(cv::Mat)aMat
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    unsigned char* data = new unsigned char[aMat.cols * aMat.rows*4];
    for (int y = 0; y < aMat.rows; ++y)
    {
        uchar *ptr = aMat.ptr<uchar>(y);
        unsigned char *pdata = data + y*aMat.cols*4;
        
        for (int x = 0; x < aMat.cols; ++x, ++ptr)
        {
            *pdata++ = (*ptr);
            *pdata++ = (*ptr);
            *pdata++ = (*ptr);
            *pdata++ = (*ptr);
        }
    }
    
    // Bitmap context
    CGContextRef context = CGBitmapContextCreate(data, aMat.cols, aMat.rows, 8, aMat.cols*4, colorSpace, kCGImageAlphaPremultipliedLast);
    
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
            if (*(pdata+3) != 0) {
                (*ptr)[0] = *pdata*255/(*(pdata+3));
                (*ptr)[1] = *(pdata+1)*255/(*(pdata+3));
                (*ptr)[2] = *(pdata+2)*255/(*(pdata+3));
            }

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

+(UIImage *)alphaChannelImageWithImage:(UIImage *)image
{
    cv::Mat mat = [self mat8UC4WithImage:image];
    
    cv::Mat channels[4];
    
    cv::split(mat, channels);
    
    image = [self alphaImageWith8UC1Mat:channels[3]];
    
    return image;
}

+(CGPoint)opaqueCenter:(UIImage *)image
{
    cv::Mat mat = [self mat8UC4WithImage:image];
    
    int width = mat.cols;
    int height = mat.rows;
    cv::Vec4b *ptr;
    
    int leftest = width, rightest = 0;
    int highest = height, lowest = 0;
    
    for (int y=0; y<height; ++y) {
        
        ptr = mat.ptr<cv::Vec4b>(y);
        for (int x=0; x<width; ++x) {
            
            if ((*ptr)[3]>0)
            {
                if (x>rightest) {
                    rightest = x;
                }
                
                if (x<leftest)
                {
                    leftest = x;
                }
                
                if (y>lowest) {
                    lowest = y;
                }
                
                if (y<highest)
                {
                    highest = y;
                }
            }
            ++ptr;
        }
    }
    
    return CGPointMake((leftest+rightest)/2.0, (lowest+highest)/2.0);
}

+(CGRect)opaqueRect:(UIImage *)image
{
    cv::Mat mat = [self mat8UC4WithImage:image];
    
    int width = mat.cols;
    int height = mat.rows;
    cv::Vec4b *ptr;
    
    int leftest = width, rightest = 0;
    int highest = height, lowest = 0;
    
    for (int y=0; y<height; ++y) {
        
        ptr = mat.ptr<cv::Vec4b>(y);
        for (int x=0; x<width; ++x) {
            
            if ((*ptr)[3]>0)
            {
                if (x>rightest) {
                    rightest = x;
                }
                
                if (x<leftest)
                {
                    leftest = x;
                }
                
                if (y>lowest) {
                    lowest = y;
                }
                
                if (y<highest)
                {
                    highest = y;
                }
            }
            ++ptr;
        }
    }
    
    return CGRectMake(leftest, highest, rightest-leftest+1, lowest-highest+1);
}

+(UIImage *)allWhiteImageWithSize:(CGSize)size
{
    cv::Mat aMat((int)size.height, (int)size.width, CV_8UC4, cv::Scalar(255, 255, 255, 255));// aMat.create((int)size.height, (int)size.width, CV_8UC4);

    return [self imageWith8UC4Mat:aMat];
}

+(UIImage *)allBlackImageWithSize:(CGSize)size
{
    cv::Mat aMat((int)size.height, (int)size.width, CV_8UC4, cv::Scalar(0, 0, 0, 0));
    
    return [self imageWith8UC4Mat:aMat];
}

+(UIImage *)reverseImage:(UIImage *)image;
{
    if (!image) {
        return nil;
    }
    cv::Mat aMat = [self mat8UC4WithImage:image];
    
    for (int y = 0; y < aMat.rows; ++y)
    {
        cv::Vec4b *ptr = aMat.ptr<cv::Vec4b>(y);
        
        for (int x = 0; x < aMat.cols; ++x, ++ptr)
        {
            (*ptr)[0] = 255 - (*ptr)[0];
            (*ptr)[1] = 255 - (*ptr)[1];
            (*ptr)[2] = 255 - (*ptr)[2];
            (*ptr)[3] = 255 - (*ptr)[3];
        }
    }
    
    return [self imageWith8UC4Mat:aMat];
}
+(UIImage *)featherImage:(UIImage *)image featherRadius:(int)radius
{
    cv::Mat aMat = [self mat8UC4WithImage:image];
    
    cv::Mat bMat;

    cv::blur(aMat, bMat, cv::Size(radius*2+1, radius*2+1));
//    cv::GaussianBlur(aMat, bMat, cv::Size(radius*2+1, radius*2+1), 0);
    
    return [self imageWith8UC4Mat:bMat];
}

+(UIImage *)expandImage:(UIImage *)image radius:(int)radius feather:(BOOL)featherOn
{
    cv::Mat aMat = [self mat8UC4WithImage:image];

    cv::Mat bMat;

    UIImage *maskImage = image;
    int realRadius = abs(radius);
    if (radius < 0) {
        cv::Scalar all0(0, 0, 0, 0);
        cv::erode(aMat, bMat, cv::Mat(realRadius, realRadius, CV_8UC1, cv::Scalar(1)),cv::Point(-1, -1), 1, cv::BORDER_CONSTANT, all0);
    }
    else if (radius > 0)
    {
        cv::dilate(aMat, bMat, cv::Mat(realRadius, realRadius, CV_8UC1, cv::Scalar(1)));
    }
    
    if (radius != 0) {
        if (featherOn) {
//            cv::GaussianBlur(bMat, aMat, cv::Size(realRadius*2+1, realRadius*2+1), 0);
            cv::blur(bMat, aMat, cv::Size(realRadius*2+1, realRadius*2+1));
            maskImage = [self imageWith8UC4Mat:aMat];;
        }
        else
        {
            maskImage = [self imageWith8UC4Mat:bMat];;
        }
    }
    
    return maskImage;
}



@end
