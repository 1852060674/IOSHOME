//
//  ImageWhitenService.m
//  Meitu
//
//  Created by ZB_Mac on 15-1-23.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "ImageWhitenService.h"
#import "Whiten.h"
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
#import "UIImage+mat.h"
#include <opencv2/opencv.hpp>

@implementation ImageWhitenService
+(instancetype) defaultProcessor
{
    static dispatch_once_t once;
    static id warper = nil;
    dispatch_once(&once, ^{
        warper = [[self alloc] init];
    });
    return warper;
}
-(UIImage *)whitenImage:(UIImage *)image byStrenght:(CGFloat)strenght
{
    cv::Mat srcMat, dstMat;
    srcMat = [UIImage mat8UC3WithImage:image];
    
    TTPTWhiten(srcMat, dstMat, strenght);
    
    image = MatToUIImage(dstMat);
    
    return image;
}

//-(UIImage *)whitenImage:(UIImage *)image byStrenght:(CGFloat)strenght
//{
//    cv::Mat srcMat, dstMat;
//    UIImageToMat(image, srcMat);
//    
//    TTPTWhiten(srcMat, dstMat, strenght);
//    
//    image = MatToUIImage(dstMat);
//    
//    return image;
//}
@end
