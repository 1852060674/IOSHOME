//
//  UIImage+Draw.h
//  cutout
//
//  Created by ZB_Mac on 16/4/28.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Draw)
+(UIImage *)drawRadiantImageWithSize:(CGSize)size andCenter:(CGPoint)center andBGColor:(UIColor *)bgColor andFGColor:(UIColor *)fgColor andNumber:(NSInteger)number;
+(UIImage *)drawLightImageWithSize:(CGSize)size andCenter:(CGPoint)center andBGColor:(UIColor *)bgColor andFGColor:(UIColor *)fgColor andLineWidth:(CGFloat)lineWidth andLineLength:(CGFloat)lineLength andOffset:(CGFloat)offset andNumber:(NSInteger)number;
+(UIImage *)drawImageWithColor:(UIColor *)color size:(CGSize)size scale:(CGFloat)scale;
+(UIImage *)drawTransparentImageWithSize:(CGSize)size scale:(CGFloat)scale;
@end
