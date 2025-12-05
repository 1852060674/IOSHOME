//
//  GPUImageVideoCamera+FlashContoller.h
//  SplitPics
//
//  Created by tangtaoyu on 15-3-6.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "GPUImage.h"

typedef enum {
    OFF=0,
    ON=1,
    AUTO=2
} FlashStatus;

@interface GPUImageVideoCamera (FlashContoller)

/**
 *  @function 闪光灯调整
 *  @return 闪光灯状态
 */
- (FlashStatus)changeFlash;
/**
 *  @function 获取闪光灯状态
 *  @return 闪光灯状态
 */
- (FlashStatus)flashStatus;

- (void)setFocusInPoint:(CGPoint)point InView:(UIView*)view;

- (void)setAutoExpose;

@end
