//
//  ImageUtil.h
//  ImageProcessing
//
//  Created by Evangel on 10-11-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>

@interface ImageUtil : NSObject

//安全获取图片，防止图片内存泄漏
+ (UIImage *)loadResourceImage:(NSString*)imageName;

+ (CGSize) fitSize: (CGSize)thisSize inSize: (CGSize) aSize;

+ (UIImage *) image: (UIImage *) image fitInSize: (CGSize) viewsize;

+(UIImage *)imageFromText:(NSString *)text width:(float)width height:(float)height;

+(UIImage *)screenshot;

+(UIImage*)captureView:(CGRect)rect;

// 对空白部分要做裁剪
+ (UIImage*)captureViewWithCrop:(CGRect)rect;

// 裁剪掉图片边缘多余的空白部分 
+ (UIImage *) cutImageEdge: (UIImage *) inImage edgeMargin:(float)margin;

+ (UIImage*)changeImageColor:(UIImage*)inImage r1:(int)r1 g1:(int)g1 b1:(int)b1 r2:(int)r2 g2:(int)g2 b2:(int)b2;

//等比率缩放
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

// 合并2个图像
+ (UIImage*) mergeImage:(UIImage*)bg front:(UIImage*) front size:(CGSize)size;

// 合并2个图像
+ (UIImage*) mergeImage:(UIImage*)bg front:(UIImage*) front size:(CGSize)size alpha:(float)alpha;

// 缩放并旋转图像
+ (UIImage *)scaleAndRotateImage:(UIImage *)image kMaxResolution:(int)kMaxResolution; 

// 获得图片的宽度
+(int) getImageWidth:(UIImage*)inImage;

// 获得图片的高度
+(int) getImageHeight:(UIImage*)inImage;

+(int) getMinHeight:(UIImage*)inImage;
+(int) getMinWidth:(UIImage*)inImage;
+(CGContextRef) CreateRGBABitmapContext: (CGImageRef)inImage;
+(unsigned char *)RequestImagePixelData:(UIImage *)inImage;

// 判断颜色是否够深
+(int) getDarkLevel:(int)r g:(int)g b:(int)b;
+(BOOL) isDarkBlack:(int)r g:(int)g b:(int)b;
+(BOOL) isMiddleBlack:(int)r g:(int)g b:(int)b;
+(BOOL) isLightBlack:(int)r g:(int)g b:(int)b;

// 计算颜色的相似度
+(int) colorDiff:(int)r1 g1:(int)g1 b1:(int)b1 r2:(int)r2 g2:(int)g2 b2:(int)b2;

//+(void) changeColor:(int&)r g:(int&)g b:(int&)b mode:(int)m;
+ (UIImage*)getSpecialImage:(UIImage*)image withPoints:(NSArray*)pointArray;

+ (UIImage*)draw3_2_Image:(UIImage*)image withPoints:(NSArray*)pointArray withCenter:(CGPoint)centerPoint radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clock;
+ (UIImage*)drawCircle:(UIImage*)image withCenter:(CGPoint)centerPoint radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clock;

+ (UIImage*)draw5_1_Image:(UIImage*)image withPoints:(NSArray*)pointArray withCenter:(CGPoint)centerPoint radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clock;

+ (UIImage*)getScaleImage:(UIImage*)image withWidth:(float)width andHeight:(float)height;

@end
