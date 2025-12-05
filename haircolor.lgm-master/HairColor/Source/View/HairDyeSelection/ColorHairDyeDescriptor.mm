//
//  ColorHairDyeDescriptor.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/12.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "ColorHairDyeDescriptor.h"
#import "UIImage+Mat.h"
#import "UIImage+Blend.h"

#import <opencv2/core/mat.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
#import <opencv2/imgproc/types_c.h>

@implementation ColorHairDyeDescriptor
-(UIImage *)hairDyeImage:(UIImage *)image withMaskImage:(UIImage *)maskImage
{
    const CGFloat* colors = CGColorGetComponents(_color.CGColor);
    
    cv::Mat srcMat; //UIImageToMat(self, srcMat);
    srcMat = [UIImage mat8UC3WithImage:image];
    int rows = srcMat.rows;
    int cols = srcMat.cols;
    
    NSArray *ctlPoints = @[
                           [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                           [NSValue valueWithCGPoint:CGPointMake(0.5, (0.5+colors[0])*0.5)],
                           [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                           ];
    NSArray *mapPoints = [self getPreparedSplineCurve:ctlPoints];
    CGFloat RCurveMap[256];
    for (int i=0; i<256; ++i) {
        CGFloat value = [mapPoints[i] floatValue];
        RCurveMap[i] = (value+i)/255.0;
    }
    
    ctlPoints = @[
                  [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                  [NSValue valueWithCGPoint:CGPointMake(0.5, (0.5+colors[1])*0.5)],
                  [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                  ];
    mapPoints = [self getPreparedSplineCurve:ctlPoints];
    CGFloat GCurveMap[256];
    for (int i=0; i<256; ++i) {
        CGFloat value = [mapPoints[i] floatValue];
        GCurveMap[i] = (value+i)/255.0;
    }
    
    ctlPoints = @[
                  [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                  [NSValue valueWithCGPoint:CGPointMake(0.5, (0.5+colors[2])*0.5)],
                  [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                  ];
    mapPoints = [self getPreparedSplineCurve:ctlPoints];
    CGFloat BCurveMap[256];
    for (int i=0; i<256; ++i) {
        CGFloat value = [mapPoints[i] floatValue];
        BCurveMap[i] = (value+i)/255.0;
    }
    
    cv::Mat grayMat;
    cv::cvtColor(srcMat, grayMat, CV_RGB2GRAY);
    cv::Vec3b *srcPtr;
    uchar *grayPtr;
    
    CGFloat highlight = self.highlight*2-1;

    ctlPoints = @[
                  [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                  [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5+0.35*highlight)],
                  [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                  ];
    mapPoints = [self getPreparedSplineCurve:ctlPoints];
    CGFloat RGBCurveMap[256];
    for (int i=0; i<256; ++i) {
        CGFloat value = [mapPoints[i] floatValue];
        RGBCurveMap[i] = (value+i)/255.0;
    }
    
    for (int y=0; y<rows; ++y) {
        srcPtr = srcMat.ptr<cv::Vec3b>(y);
        grayPtr = grayMat.ptr<uchar>(y);
        
        for (int x=0; x<cols; ++x) {
            
            (*grayPtr) = RGBCurveMap[(*grayPtr)]*255;
            
            (*srcPtr)[0] = RCurveMap[(*grayPtr)]*255;
            (*srcPtr)[1] = GCurveMap[(*grayPtr)]*255;
            (*srcPtr)[2] = BCurveMap[(*grayPtr)]*255;
            
            ++grayPtr;
            ++srcPtr;
        }
    }
    
    image = MatToUIImage(srcMat);
    
//    if (maskImage) {
//        return [image imageMaskedWithImage:maskImage];
//    }
//    else
    {
        return image;
    }
}
@end
