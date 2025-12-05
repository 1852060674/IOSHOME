//
//  SharedMatting.m
//  ShareMatting
//
//  Created by ZB_Mac on 16/9/27.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "SharedMatting.h"
#import "InternalSharedMatting.hpp"
#import "UIImage+Mat.h"
#import "UIImage+Blend.h"
#import <opencv2/imgcodecs/ios.h>

@implementation SharedMatting

+(UIImage *)sharedMattingMat:(cv::Mat)imageMat withMaskImage:(cv::Mat)maskMat;
{
    InternalSharedMatting sm;
    
    sm.loadImage(imageMat);
    sm.loadTrimap(maskMat);
    
    sm.solveAlpha();
    
    cv::Mat alphaMat;
    sm.getMat(alphaMat);
    cv::Mat channels[4] = {alphaMat, alphaMat, alphaMat, alphaMat};
    cv::Mat tempMat;
    cv::merge(channels, 4, tempMat);
    
    UIImage *resultImage = [UIImage imageWith8UC4Mat:tempMat];
    
    return resultImage;
}

+(UIImage *)sharedMattingImage:(UIImage *)image withMaskImage:(UIImage *)maskImage;
{
    cv::Mat imageMat = [UIImage mat8UC4WithImage:image];
    cv::Mat grayMask = [UIImage mat8UC4WithImage:maskImage];
    
    return [self sharedMattingMat:imageMat withMaskImage:grayMask];
}
@end
