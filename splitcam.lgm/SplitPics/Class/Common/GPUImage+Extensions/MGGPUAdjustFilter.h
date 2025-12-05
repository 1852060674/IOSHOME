//
//  MGGPUAdjustFilter.h
//  SplitPics
//
//  Created by tangtaoyu on 15-3-15.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "GPUImage.h"
#import "LemonUtil.h"

@interface MGGPUAdjustFilter : GPUImageFilterGroup
{
    GPUImageBrightnessFilter *brightnessFilter;
    GPUImageContrastFilter *contrastFilter;
    GPUImageSaturationFilter *saturationFilter;
    GPUImageExposureFilter *exposureFilter;
    GPUImageGaussianBlurFilter *blurFilter;
}

// Brightness ranges from -1.0 to 1.0, with 0.0 as the normal level
@property(readwrite, nonatomic) CGFloat brightness;

/** Contrast ranges from 0.0 to 4.0 (max contrast), with 1.0 as the normal level
 */
@property(readwrite, nonatomic) CGFloat contrast;

/** Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 1.0 as the normal level
 */
@property(readwrite, nonatomic) CGFloat saturation;

// Exposure ranges from -10.0 to 10.0, with 0.0 as the normal level
@property(readwrite, nonatomic) CGFloat exposure;

/** A radius in pixels to use for the blur, with a default of 12.0. This adjusts the sigma variable in the Gaussian distribution function.
 */
@property (readwrite, nonatomic) CGFloat blurRadiusInPixels;

/** The degree to which to downsample, then upsample the incoming image to minimize computations within the Gaussian blur, default of 4.0
 */
@property (readwrite, nonatomic) CGFloat downsampling;


@end
