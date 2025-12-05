//
//  SharedMatting.h
//  ShareMatting
//
//  Created by ZB_Mac on 16/9/27.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <opencv2/core/mat.hpp>

@interface SharedMatting : NSObject
+(UIImage *)sharedMattingMat:(cv::Mat)imageMat withMaskImage:(cv::Mat)maskMat;
+(UIImage *)sharedMattingImage:(UIImage *)image withMaskImage:(UIImage *)maskImage;
@end
