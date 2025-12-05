//
//  MGGPUUtil.m
//  newFace
//
//  Created by tangtaoyu on 15-2-11.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "LemonUtil.h"

@implementation LemonUtil

+ (UIImage *)lemonFilter:(UIImage *)image Withname:(NSString *)name {
  UIImage *inputImage =image;

  UIImage *outputImage = nil;

  GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];


  GPUImageLookupFilter *lookUpFilter = [[GPUImageLookupFilter alloc] init];


  GPUImagePicture *lookupImg = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"png"]]];

  [lookupImg addTarget:lookUpFilter atTextureLocation:1];

  [stillImageSource addTarget:lookUpFilter atTextureLocation:0];

  [lookUpFilter useNextFrameForImageCapture];

  if([lookupImg processImageWithCompletionHandler:nil] && [stillImageSource processImageWithCompletionHandler:nil]) {

    outputImage= [lookUpFilter imageFromCurrentFramebuffer];

  }

  return outputImage;

}


+ (UIImage*)lemonFilter:(UIImage*)image WithIndex:(NSInteger)index
{
    GPUImagePicture *gpuImage = [[GPUImagePicture alloc] initWithImage:image];
    LemonEyeEmFilter *filter = [[LemonEyeEmFilter alloc] init];
    [gpuImage addTarget:filter];
    
    GPUImagePicture *maskImage1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lookup_v3" ofType:@"png"]]];
    GPUImagePicture *maskImage2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gradients" ofType:@"png"]]];
    GPUImagePicture *maskImage3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"heine_frame" ofType:@"png"]]];
    
    [maskImage1 addTarget:filter];
    [maskImage2 addTarget:filter];
    [maskImage3 addTarget:filter];
    
    [maskImage1 processImage];
    [maskImage2 processImage];
    [maskImage3 processImage];
        
    filter.colorMapIndex = index;
    
    [filter useNextFrameForImageCapture];
    [gpuImage processImage];
    
    UIImage *output = [filter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    
    [maskImage1 removeAllTargets];
    [maskImage2 removeAllTargets];
    [maskImage3 removeAllTargets];
    [maskImage1 removeOutputFramebuffer];
    [maskImage2 removeOutputFramebuffer];
    [maskImage3 removeOutputFramebuffer];
    
    [gpuImage removeAllTargets];
    [gpuImage removeOutputFramebuffer];
    [filter removeAllTargets];
    [filter removeOutputFramebuffer];
    
    return output;
}





@end
