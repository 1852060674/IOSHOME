//
//  ImageEnhanceService.m
//  Meitu
//
//  Created by ZB_Mac on 15-1-27.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "ImageEnhanceService.h"
#import "GPUImage.h"
#import "UIImage+mat.h"

//#import <sketchLib2.0_iOS/GPUImage.h>
@interface ImageEnhanceService ()
{
    BOOL _filterChained;
    BOOL _imageAttatched;
}
@property (nonatomic, strong) GPUImagePicture *srcImage;
@property (nonatomic, strong) GPUImageToneCurveFilter *curveFilter;
@property (nonatomic, strong) GPUImageHSBFilter *hsbFilter;
@property (nonatomic, strong) GPUImageExposureFilter *exposureFilter;
@end

@implementation ImageEnhanceService

-(ImageEnhanceService *)init
{
    self = [super init];
    
    if (self) {
        _filterChained = NO;
        _imageAttatched = NO;
    }
    return self;
}

-(GPUImageToneCurveFilter *)curveFilter
{
    if (_curveFilter==nil) {
        _curveFilter = [[GPUImageToneCurveFilter alloc] init];
    }
    return _curveFilter;
}

-(GPUImageHSBFilter *)hsbFilter
{
    if (_hsbFilter==nil) {
        _hsbFilter = [[GPUImageHSBFilter alloc] init];
    }
    return _hsbFilter;
}

-(GPUImageExposureFilter *)exposureFilter
{
    if (_exposureFilter==nil) {
        _exposureFilter = [[GPUImageExposureFilter alloc] init];
    }
    return _exposureFilter;
}

-(void)setBaseImage:(UIImage *)image
{
    [self.srcImage removeAllTargets];
    unsigned char *imageBuffer = [UIImage data8UC4WithImage:image];
    self.srcImage = [[GPUImagePicture alloc] initWith8UC4Buffer:imageBuffer andImageWidth:image.size.width andImageHeight:image.size.height];
    delete [] imageBuffer;
    
    _imageAttatched = NO;
}

-(UIImage *)enhanceBySaturation:(CGFloat)saturation andBrightness:(CGFloat)brightness andContrast:(CGFloat)contrast andExposure:(CGFloat)exposure
{
    self.saturation = saturation;
    self.brightness = brightness;
    self.contrast = contrast;
    self.exposure = exposure;
    
    UIImage *image = [self getProcessedImage];
    
    return image;
}

-(UIImage *)getProcessedImage
{
    if (_filterChained == NO) {
        [self.hsbFilter addTarget:self.exposureFilter];
        [self.exposureFilter addTarget:self.curveFilter];
        _filterChained = YES;
    }
    
    if (_imageAttatched == NO) {
        [self.srcImage addTarget:self.hsbFilter];
    }
    
    [self.curveFilter useNextFrameForImageCapture];
    [self.srcImage processImage];
    
    UIImage *result = [self.curveFilter imageFromCurrentFramebuffer];
    
    return result;
}

-(void)setBrightness:(CGFloat)brightness
{
    CGFloat value = brightness*100;
    CGFloat offset = value*0.24/255;
    
    NSArray *array = @[[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                       [NSValue valueWithCGPoint:CGPointMake(0.5-offset, 0.5)],
                       [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]];
    
//    NSArray *array = @[
//                       [NSValue valueWithCGPoint:CGPointMake(0.0, 1.0)],
//                       [NSValue valueWithCGPoint:CGPointMake(160/255.0, 0.5)],
//                       [NSValue valueWithCGPoint:CGPointMake(1.0, 0.0)]
//                       ];
    
    [self.curveFilter setRedControlPoints:array];
    [self.curveFilter setGreenControlPoints:array];
    [self.curveFilter setBlueControlPoints:array];
    
    _brightness = brightness;
}

-(void)setContrast:(CGFloat)contrast
{
    CGFloat value = contrast*100;
    CGFloat offset = value*0.24/255;
    
    [self.curveFilter setRgbCompositeControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                                     [NSValue valueWithCGPoint:CGPointMake(64.0/255.0, 64/255.0-offset)],
                                                     [NSValue valueWithCGPoint:CGPointMake(192/255.0, 192/255.0+offset)],
                                                     [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                                     ]];
    
    _contrast = contrast;
}

-(void)setSaturation:(CGFloat)saturation
{
    CGFloat value = saturation+1.0;
    
    [self.hsbFilter reset];
    [self.hsbFilter adjustSaturation:value];
    
    _saturation = saturation;
}

-(void)setExposure:(CGFloat)exposure
{
    CGFloat value = exposure*0.5;
    
    [self.exposureFilter setExposure:value];
    
    _exposure = exposure;
}

@end
