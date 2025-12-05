//
//  MGImageUtil.h
//  newFace
//
//  Created by tangtaoyu on 15-2-10.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface MGImageUtil : NSObject

+ (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)scaleSize;
+ (UIImage*)cutImage:(UIImage*)image WithRect:(CGRect)rect;
+ (UIImage *)getImageFromView:(UIView*)view;
+ (UIImage *)getImageFromView:(UIView *)view WithSize:(CGSize)size;

+ (UIImage*)drawImage:(UIImage*)image WithRect:(CGRect)rect InRect:(CGRect)aRect;
+ (UIImage*)bezierPath:(UIBezierPath*)path inRect:(CGRect)rect WithWidth:(float)width;
+ (UIImage*)bezierPath:(UIBezierPath*)path inRect:(CGRect)rect;

+ (NSArray*)getHSV:(UIImage*)image;
@end
