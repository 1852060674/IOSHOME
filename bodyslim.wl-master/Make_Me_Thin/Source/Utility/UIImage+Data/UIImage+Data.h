//
//  UIImage+mat.h
//  imageCut
//
//  Created by shen on 14-6-19.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Data)
+(unsigned char *)data8UC4WithImage:(UIImage *)image;
+(void)releaseData:(unsigned char*)data;
+(UIImage *)imageWith8UC4Data:(unsigned char *)data andWidth:(NSInteger)width andHeight:(NSInteger)height;


+(UIImage *)smoothCircleWithDiameter:(NSInteger)circelDiameter;
+(UIImage *)smoothRectangleWithWidth:(NSInteger)width andHeight:(NSInteger)height;
+(UIImage *)smoothEllipseInRectangleWithWidth:(NSInteger)width andHeight:(NSInteger)height andSmoothFactor:(CGFloat)smoothFactor;

+(UIImage *)smoothSolidCircleWithDiameter:(NSInteger)circelDiameter;

+(UIImage *)generateImageWithSize:(CGSize)size andColor:(UIColor*)color;

+(UIImage *)generateImageWithSize:(CGSize)size withImage:(UIImage *)image andDrawArea:(CGRect)drawArea;
@end
