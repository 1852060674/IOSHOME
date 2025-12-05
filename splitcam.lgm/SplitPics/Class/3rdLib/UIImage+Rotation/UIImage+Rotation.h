//
//  UIImage+Rotation.h
//  HelloGPUImage
//
//  Created by shen on 14-5-16.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Rotation)
- (UIImage *)rotateImage;
- (UIImage *)rotateAndScale:(CGFloat)scale;
- (UIImage *)rotateAndScale:(CGFloat)scale introplate:(CGInterpolationQuality) quality;
- (UIImage *)imageRotatedByOrientation:(UIImageOrientation)orient;
- (UIImage *) grayscaleImage;
- (UIImage *)rotateAndScaleWithMaxSize:(NSInteger)resolution;
- (UIImage*)rotateAndScaleWithMaxPixels:(float)maxPixels WithMinPixels:(float)minPixels;

- (UIImage *)FlippedImageOrientationHorizontal:(BOOL)horizontal vertical:(BOOL)vertical;

- (UIImage *)FlippedImageRedrawHorizontal:(BOOL)horizontal vertical:(BOOL)vertical;

- (UIImage *)FlippedImageRedrawNewHorizontal:(BOOL)horizontal vertical:(BOOL)vertical;
@end
