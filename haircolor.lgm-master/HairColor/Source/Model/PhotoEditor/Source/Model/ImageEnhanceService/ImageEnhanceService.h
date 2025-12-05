//
//  ImageEnhanceService.h
//  Meitu
//
//  Created by ZB_Mac on 15-1-27.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ImageEnhanceService : NSObject

@property (nonatomic, readwrite) CGFloat saturation;
@property (nonatomic, readwrite) CGFloat brightness;
@property (nonatomic, readwrite) CGFloat contrast;
@property (nonatomic, readwrite) CGFloat exposure;

-(ImageEnhanceService *)init;
-(void)setBaseImage:(UIImage *)image;
// all paraments range from -1.0 to 1.0 with 0.0 being no change.
-(UIImage *)enhanceBySaturation:(CGFloat)saturation andBrightness:(CGFloat)brightness andContrast:(CGFloat)contrast andExposure:(CGFloat)exposure;
-(UIImage *)getProcessedImage;

@end
