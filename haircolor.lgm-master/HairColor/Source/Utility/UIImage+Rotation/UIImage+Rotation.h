//
//  UIImage+Rotation.h
//  HelloGPUImage
//
//  Created by shen on 14-5-16.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Rotation)
-(UIImage *)rotateImage;
-(UIImage *)rotateAndScale:(CGFloat)scale;

-(UIImage *)rotateAndScaleWithMaxSize:(NSInteger)resolution;
-(UIImage *)rotateAndScaleWithMinSize:(NSInteger)resolution;
-(UIImage *)resizeImageToSize:(CGSize)size;

-(UIImage *)imageRotatedByTransform:(CGAffineTransform)transform;
-(UIImage *)imageRotatedByOrientation:(UIImageOrientation)orient;
@end
