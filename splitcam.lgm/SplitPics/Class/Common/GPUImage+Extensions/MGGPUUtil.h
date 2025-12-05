//
//  MGGPUUtil.h
//  newFace
//
//  Created by tangtaoyu on 15-2-11.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "MGGPUAdjustFilter.h"

@interface MGGPUUtil : NSObject


+ (UIImage*)gaussianBlurFilter:(UIImage*)image WithRadius:(CGFloat)radius;
+ (UIImage*)boxBlurFilter:(UIImage*)image WithRadius:(CGFloat)radius;
+ (UIImage*)normalBlendFilter:(UIImage*)image1 With:(UIImage*)image2;
+ (UIImage *)brightnessFilter:(UIImage*)image With:(float)brightness;
+ (UIImage*)saturationFilter:(UIImage*)image With:(float)saturation;
+ (UIImage*)contrastFilter:(UIImage*)image With:(float)contrast;
+ (UIImage*)exposureFilter:(UIImage*)image With:(float)exposure;
+ (UIImage*)inverseAlphaFilter:(UIImage*)image;
+ (UIImage*)inverseRGBFilter:(UIImage*)image;
+ (UIImage*)customBorderFilter:(UIImage*)image;


+ (void)boxBlurFilter:(UIImage*)image WithRadius:(CGFloat)radius completion:(void(^)(UIImage *))completion ;

@end
