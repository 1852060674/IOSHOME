//
//  MGGPUUtil.h
//  newFace
//
//  Created by tangtaoyu on 15-2-11.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "LemonEyeEmFilter.h"

@interface LemonUtil : NSObject

+ (UIImage*)lemonFilter:(UIImage*)image WithIndex:(NSInteger)index;
+ (UIImage*)lemonFilter:(UIImage*)image Withname:(NSString *)name;

@end
