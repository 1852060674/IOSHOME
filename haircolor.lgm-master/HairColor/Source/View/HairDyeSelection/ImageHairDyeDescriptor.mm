//
//  ImageHairDyeDescriptor.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/12.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "ImageHairDyeDescriptor.h"
#import "UIImage+Mat.h"
#import "UIImage+Blend.h"

#import <opencv2/core/mat.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
#import <opencv2/imgproc/types_c.h>

@implementation ImageHairDyeDescriptor
-(UIImage *)hairDyeImage:(UIImage *)image withMaskImage:(UIImage *)maskImage
{
    cv::Mat rgbMat = [UIImage mat8UC3WithImage:image];
    cv::Mat grayMat;
    cv::cvtColor(rgbMat, grayMat, CV_RGB2GRAY);
    UIImage *grayImage = [UIImage imageWith8UC1Mat:grayMat];
    
    CGBlendMode blendMode = kCGBlendModeOverlay;
    switch (self.mode) {
        case 4:
            blendMode = kCGBlendModeOverlay;
            break;
        case 5:
            blendMode = kCGBlendModeSoftLight;
            break;
        default:
            break;
    }
    
    CGRect frame = CGRectMake(0, 0, rgbMat.cols, rgbMat.rows);
    if (maskImage) {
        frame = [UIImage opaqueRect:maskImage];
    }
    
    frame.origin.y = image.size.height-frame.size.height-frame.origin.y;
    UIImage *coloredImage = [grayImage imageBlendedWithImage:self.dyeImage inFrame:frame blendMode:blendMode alpha:1.0];
    
    CGFloat highlight = self.highlight*2-1;
    
//    if (highlight > 0.0 || highlight < 0)
    
    {
        NSArray *ctlPoints = @[
                               [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                               [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5+0.25*highlight)],
                               [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                               ];
        NSArray *mapPoints = [self getPreparedSplineCurve:ctlPoints];
        CGFloat RGBCurveMap[256];
        for (int i=0; i<256; ++i) {
            CGFloat value = [mapPoints[i] floatValue];
            RGBCurveMap[i] = (value+i)/255.0;
        }
        
        cv::Mat rgbMat = [UIImage mat8UC3WithImage:coloredImage];
        
        int rows = rgbMat.rows;
        int cols = rgbMat.cols;
        cv::Vec3b *srcPtr;
        
        for (int y=0; y<rows; ++y) {
            srcPtr = rgbMat.ptr<cv::Vec3b>(y);
            
            for (int x=0; x<cols; ++x) {
                
                (*srcPtr)[0] = RGBCurveMap[(*srcPtr)[0]]*255;
                (*srcPtr)[1] = RGBCurveMap[(*srcPtr)[1]]*255;
                (*srcPtr)[2] = RGBCurveMap[(*srcPtr)[2]]*255;
                
                ++srcPtr;
            }
        }
        
        coloredImage = [UIImage imageWith8UC3Mat:rgbMat];
    }
    
//    if (maskImage) {
//        return [coloredImage imageMaskedWithImage:maskImage];
//    }
//    else
    {
        return coloredImage;
    }
}
@end
