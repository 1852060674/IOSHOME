//
//  GPUImageSufaceSmoothFilter.h
//  Plastic Surgeon
//
//  Created by ZB_Mac on 15/12/28.
//  Copyright © 2015年 ZB_Mac. All rights reserved.
//

#import "GPUImageFilter.h"
//#import <sketchLib2.0_iOS/GPUImage.h>
@interface GPUImageSufaceSmoothFilter : GPUImageFilter
{
    GLint threholdUniform;
}
@property (nonatomic, readwrite) CGFloat threhold;
@property (nonatomic, readwrite) CGFloat xOffset;
@property (nonatomic, readwrite) CGFloat yOffset;
@property (nonatomic, readwrite) CGFloat strenght;
@end
