//
//  UIImage+mat.h
//  imageCut
//
//  Created by shen on 14-6-19.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "opencv2/highgui/highgui.hpp"

@interface UIImage (mat)
+(unsigned char *)data8UC4WithImage:(UIImage *)image;

+(cv::Mat)mat8UC4WithImage:(UIImage *)image;
+(cv::Mat)mat8UC3WithImage:(UIImage *)image;

+(UIImage *)imageWith8UC4Data:(unsigned char *)data andWidth:(NSInteger)width andHeight:(NSInteger)height;

+(UIImage *)imageWith8UC3Mat:(cv::Mat)aMat;
+(UIImage *)imageWith8UC4Mat:(cv::Mat)aMat;
+(UIImage *)imageWithMatAlpha:(cv::Mat)image;
@end
