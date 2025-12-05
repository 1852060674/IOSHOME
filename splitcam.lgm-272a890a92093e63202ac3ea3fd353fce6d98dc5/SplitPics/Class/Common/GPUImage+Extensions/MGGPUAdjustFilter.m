//
//  MGGPUAdjustFilter.m
//  SplitPics
//
//  Created by tangtaoyu on 15-3-15.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGGPUAdjustFilter.h"

@implementation MGGPUAdjustFilter

@synthesize brightness;
@synthesize contrast;
@synthesize saturation;
@synthesize exposure;
@synthesize blurRadiusInPixels;
@synthesize downsampling = _downsampling;

- (id)init
{
    if(!(self = [super init])){
        return nil;
    }
    
    brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [self addFilter:brightnessFilter];
    
    contrastFilter = [[GPUImageContrastFilter alloc] init];
    [self addTarget:contrastFilter];
    
    saturationFilter = [[GPUImageSaturationFilter alloc] init];
    [self addTarget:saturationFilter];
    
    exposureFilter = [[GPUImageExposureFilter alloc] init];
    [self addTarget:exposureFilter];
    
    blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [self addTarget:blurFilter];
        
    [brightnessFilter addTarget:blurFilter];
    [blurFilter addTarget:contrastFilter];
    [contrastFilter addTarget:saturationFilter];
    [saturationFilter addTarget:exposureFilter];
    
    self.initialFilters = [NSArray arrayWithObject:brightnessFilter];
    self.terminalFilter = exposureFilter;
    
    
    self.brightness = 0.0;
    self.contrast = 1.0;
    self.saturation = 1.0;
    self.exposure = 0.0;
    self.blurRadiusInPixels = 0.0;
    self.downsampling = 1.0;
    
    return self;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    
    if (_downsampling > 1.0)
    {
        CGSize rotatedSize = [brightnessFilter rotatedSize:newSize forIndex:textureIndex];
        
        [brightnessFilter forceProcessingAtSize:CGSizeMake(rotatedSize.width / _downsampling, rotatedSize.height / _downsampling)];
        [exposureFilter forceProcessingAtSize:rotatedSize];
    }
    
    [super setInputSize:newSize atIndex:textureIndex];
}

- (void)setBrightness:(CGFloat)newValue
{
    brightnessFilter.brightness = newValue;
}

- (CGFloat)brightness
{
    return brightnessFilter.brightness;
}

- (void)setContrast:(CGFloat)newValue
{
    contrastFilter.contrast = newValue;
}

- (CGFloat)contrast
{
    return contrastFilter.contrast;
}

- (void)setSaturation:(CGFloat)newValue
{
    saturationFilter.saturation = newValue;
}

- (CGFloat)saturation
{
    return saturationFilter.saturation;
}

- (void)setExposure:(CGFloat)newValue
{
    exposureFilter.exposure = newValue;
}

- (CGFloat)exposure
{
    return exposureFilter.exposure;
}

- (void)setBlurRadiusInPixels:(CGFloat)newValue
{
    blurFilter.blurRadiusInPixels = newValue;
}

- (CGFloat)blurRadiusInPixels
{
    return blurFilter.blurRadiusInPixels;
}

- (void)setDownsampling:(CGFloat)newValue;
{
    _downsampling = newValue;
}

@end
