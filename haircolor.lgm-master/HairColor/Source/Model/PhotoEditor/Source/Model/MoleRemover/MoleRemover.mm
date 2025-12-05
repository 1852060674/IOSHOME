//
//  MoleRemover.m
//  Meitu
//
//  Created by ZB_Mac on 15-1-23.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "MoleRemover.h"
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/types_c.h>
#import "UIImage+mat.h"
#import "InternalMoleRemover_New.hpp"

@implementation MoleRemover
+(instancetype) defaultProcessor
{
    static dispatch_once_t once;
    static id warper = nil;
    dispatch_once(&once, ^{
        warper = [[self alloc] init];
    });
    return warper;
}

-(UIImage *)removeMole:(UIImage *)image andCenter:(CGPoint)center andRadius:(CGFloat)radius
{
    cv::Mat srcMat;
    srcMat = [UIImage mat8UC3WithImage:image];
    
    removeMoleNew(srcMat, cv::Point(center.x, center.y), radius);
    image = MatToUIImage(srcMat);
    
    return image;
}

-(UIImage *)autoRemoveMole:(UIImage *)image inFaceRect:(CGRect)faceRect
{
    cv::Mat srcMat;
    srcMat = [UIImage mat8UC3WithImage:image];
    
    cv::Rect cvFaceRect;
    cvFaceRect.x = faceRect.origin.x;
    cvFaceRect.y = faceRect.origin.y;
    cvFaceRect.width = faceRect.size.width;
    cvFaceRect.height = faceRect.size.height;
    
    removeMoleNew(srcMat, cvFaceRect);
    image = MatToUIImage(srcMat);

    return image;
}

@end
