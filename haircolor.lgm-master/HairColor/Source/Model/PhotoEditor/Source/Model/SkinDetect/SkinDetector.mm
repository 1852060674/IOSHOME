//
//  SkinDetector.m
//  PlasticDoctor
//
//  Created by ZB_Mac on 16/1/29.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "SkinDetector.h"
#import "SkinDetect.h"
//#import <sketchLib2.0_iOS/SkinDetect.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
#import "UIImage+mat.h"
@implementation SkinDetector
+(UIImage *)getSkinMaskImageWithSrcImage:(UIImage *)srcImage
{
    cv::Mat tempMat;
    cv::Mat srcMat, maskMat;
    
    srcMat = [UIImage mat8UC3WithImage:srcImage];
    cv::Mat hsvMat, YCrCbMat;
    
    cv::cvtColor(srcMat, hsvMat, CV_RGB2HSV);
    cv::cvtColor(srcMat, YCrCbMat, CV_RGB2YCrCb);
    
    int width = srcMat.cols;
    int height = srcMat.rows;
    
    maskMat.create(height, width, CV_8UC1);
    
    uchar *maskPtr = NULL;
    cv::Vec3b *rgbPtr = NULL;
    cv::Vec3b *hsvPtr = NULL;
    cv::Vec3b *yCrCbPtr = NULL;
    
    int count = 0;
    for (int y=0; y<height; ++y) {
        maskPtr = maskMat.ptr<uchar>(y);
        rgbPtr = srcMat.ptr<cv::Vec3b>(y);
        hsvPtr = hsvMat.ptr<cv::Vec3b>(y);
        yCrCbPtr = YCrCbMat.ptr<cv::Vec3b>(y);
        
        for (int x=0; x<width; ++x) {
            
            count = 0;
            
            if ((isSkinRGB((*rgbPtr)[0], (*rgbPtr)[1], (*rgbPtr)[2])))
            {
                ++count;
            }
            if (isSkinRG((*rgbPtr)[0], (*rgbPtr)[1], (*rgbPtr)[2])) {
                ++count;
            }
            if (isSkinHSV((*hsvPtr)[0])) {
                ++count;
            }
            if (isSkinYCrCb((*yCrCbPtr)[1], (*yCrCbPtr)[2])) {
                ++count;
            }
            
            if (count>2) {
                (*maskPtr) = 255;
                
            }
            else
            {
                (*maskPtr) = 0;
            }
            
            ++rgbPtr;
            ++yCrCbPtr;
            ++hsvPtr;
            ++maskPtr;
        }
    }
    
    UIImage *result = MatToUIImage(maskMat);
    
    return result;
}
@end
