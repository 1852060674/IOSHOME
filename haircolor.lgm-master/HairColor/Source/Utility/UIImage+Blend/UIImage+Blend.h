//
//  UIImage+Blend.h
//  Kuchibiru
//
//  Created by  on 11/08/26.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blend)

- (UIImage *)imageMaskedWithImage:(UIImage *)maskImage;
- (UIImage *)imageMaskedWithImage:(UIImage *)maskImage alpha:(CGFloat)alpha;
- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;
- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage maskImage:(UIImage *)maskImage;
- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage maskImage:(UIImage *)maskImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage atOrigin:(CGPoint)origin maskImage:(UIImage *)maskImage;
- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage atOrigin:(CGPoint)origin maskImage:(UIImage *)maskImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

- (UIImage *)imageFillBlendedWithImage:(UIImage *)overlayImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;
- (UIImage *)imageBlendedWithAspectFillImage:(UIImage *)overlayImage blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

- (UIImage *)imageBlendedWithImage:(UIImage *)overlayImage inFrame:(CGRect)frame blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;
-(UIImage *)imageBlendedWithImage:(UIImage *)overlayImage inOverlayRect:(CGRect)overlayRect withTransform:(CGAffineTransform)t alpha:(CGFloat)alpha;

@end
