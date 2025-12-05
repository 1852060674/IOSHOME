//
//  SkinDetector.h
//  PlasticDoctor
//
//  Created by ZB_Mac on 16/1/29.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;

@interface SkinDetector : NSObject
+(UIImage *)getSkinMaskImageWithSrcImage:(UIImage *)srcImage;

@end
