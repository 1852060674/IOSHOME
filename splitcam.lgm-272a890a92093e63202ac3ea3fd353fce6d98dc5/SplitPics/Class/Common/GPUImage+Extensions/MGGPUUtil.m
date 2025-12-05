//
//  MGGPUUtil.m
//  newFace
//
//  Created by tangtaoyu on 15-2-11.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGGPUUtil.h"

@implementation MGGPUUtil

+ (UIImage*)gaussianBlurFilter:(UIImage*)image WithRadius:(CGFloat)radius {
    GPUImagePicture *gpuImage = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageGaussianBlurFilter *filter = [[GPUImageGaussianBlurFilter alloc] init];
    filter.blurRadiusInPixels = radius;
    
    [gpuImage addTarget:filter];
    [filter useNextFrameForImageCapture];
    [gpuImage processImage];
    
    UIImage *output = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    
    if(output == nil){
        [gpuImage removeAllTargets];
        GPUImageBoxBlurFilter *filter2 = [[GPUImageBoxBlurFilter alloc] init];
        filter2.blurRadiusInPixels = radius;
        [gpuImage addTarget:filter2];
        [filter2 useNextFrameForImageCapture];
        [gpuImage processImage];
        
        output = [filter2 imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    }
    
    return output;
}

+ (UIImage*)boxBlurFilter:(UIImage*)image WithRadius:(CGFloat)radius {
  GPUImagePicture *gpuImage = [[GPUImagePicture alloc] initWithImage:image];
  GPUImageBoxBlurFilter *filter = [[GPUImageBoxBlurFilter alloc] init];
  filter.blurRadiusInPixels = radius;

  [gpuImage addTarget:filter];
  [filter useNextFrameForImageCapture];
  [gpuImage processImage];

  UIImage *output = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
  if (output == nil) {
    NSLog(@"%f",radius);
  }
  return output;
}

+ (void)boxBlurFilter:(UIImage*)image WithRadius:(CGFloat)radius completion:(void(^)(UIImage *))completion {
  GPUImagePicture *gpuImage = [[GPUImagePicture alloc] initWithImage:image];
  GPUImageBoxBlurFilter *filter = [[GPUImageBoxBlurFilter alloc] init];
  filter.blurRadiusInPixels = radius;

  [gpuImage addTarget:filter];
  [filter useNextFrameForImageCapture];

  [gpuImage processImageWithCompletionHandler:^{
    UIImage *output = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    if (output == nil) {
      NSLog(@"%f",radius);
    }
    if (completion) {
      completion(output);
    }
  }];
  
}



+ (UIImage*)normalBlendFilter:(UIImage*)image1 With:(UIImage*)image2 {
    GPUImagePicture *gpuImage1 = [[GPUImagePicture alloc] initWithImage:image1];
    GPUImagePicture *gpuImage2 = [[GPUImagePicture alloc] initWithImage:image2];
    GPUImageNormalBlendFilter *filter = [[GPUImageNormalBlendFilter alloc] init];
    
    [gpuImage1 addTarget:filter];
    [gpuImage2 addTarget:filter];
    [filter useNextFrameForImageCapture];
    [gpuImage1 processImage];
    [gpuImage2 processImage];
    
    UIImage *output = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    return output;
}

+ (UIImage *)brightnessFilter:(UIImage*)image With:(float)brightness {
    GPUImageBrightnessFilter * filter = [[GPUImageBrightnessFilter alloc] init];
    filter.brightness = brightness;
    
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:image];
    [inputGPUImage addTarget:filter];

    [filter useNextFrameForImageCapture];
    [inputGPUImage processImage];
    
    UIImage * output = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    return output;
}

+ (UIImage*)saturationFilter:(UIImage*)image With:(float)saturation
{
    GPUImageSaturationFilter *filter = [[GPUImageSaturationFilter alloc] init];
    filter.saturation = saturation;
    
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:image];
    [inputGPUImage addTarget:filter];
    
    [filter useNextFrameForImageCapture];
    [inputGPUImage processImage];
    
    UIImage * output = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    return output;
}

+ (UIImage*)contrastFilter:(UIImage*)image With:(float)contrast
{
    GPUImageContrastFilter *filter = [[GPUImageContrastFilter alloc] init];
    filter.contrast = contrast;
    
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:image];
    [inputGPUImage addTarget:filter];
    
    [filter useNextFrameForImageCapture];
    [inputGPUImage processImage];
    
    UIImage * output = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    return output;
}

+ (UIImage*)exposureFilter:(UIImage*)image With:(float)exposure
{
    GPUImageExposureFilter *filter = [[GPUImageExposureFilter alloc] init];
    filter.exposure = exposure;
    
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:image];
    [inputGPUImage addTarget:filter];
    
    [filter useNextFrameForImageCapture];
    [inputGPUImage processImage];
    
    UIImage * output = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    return output;
}

+ (UIImage*)inverseAlphaFilter:(UIImage*)image
{
    GPUImageFilter *filter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"inverseAlpha"];
    
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:image];
    [inputGPUImage addTarget:filter];
    
    [filter useNextFrameForImageCapture];
    [inputGPUImage processImage];
    
    UIImage *output = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    return output;
}

+ (UIImage*)inverseRGBFilter:(UIImage*)image
{
    GPUImageFilter *filter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"inverseRGB"];
    
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:image];
    [inputGPUImage addTarget:filter];
    
    [filter useNextFrameForImageCapture];
    [inputGPUImage processImage];
    
    UIImage *output = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    return output;
}

+ (UIImage*)customBorderFilter:(UIImage*)image
{
    GPUImageFilter *filter1 = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"customFill"];
    GPUImageSobelEdgeDetectionFilter *filter2 = [[GPUImageSobelEdgeDetectionFilter alloc] init];
    filter2.edgeStrength = 0.5;
    GPUImageFilter *filter3 = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"customClear"];
    GPUImageBoxBlurFilter *filter4 = [[GPUImageBoxBlurFilter alloc] init];
    filter4.blurRadiusInPixels = 1.0;
    GPUImageFilter *filter5 = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"customWhite"];

    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:image];
    [inputGPUImage addTarget:filter1];
    [filter1 addTarget:filter2];
    [filter2 addTarget:filter3];
    [filter3 addTarget:filter4];
    [filter4 addTarget:filter5];
    
    [filter5 useNextFrameForImageCapture];
    [inputGPUImage processImage];
    
    UIImage *output = [filter5 imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    return output;
}

@end
