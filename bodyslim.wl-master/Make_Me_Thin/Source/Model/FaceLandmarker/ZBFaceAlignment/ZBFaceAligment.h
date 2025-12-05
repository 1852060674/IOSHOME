//
//  ZBFaceAligment.h
//  PhotoEditor
//
//  Created by ZB_Mac on 2017/2/22.
//  Copyright © 2017年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern const NSInteger g_leftEye_left;
extern const NSInteger g_leftEye_right;
extern const NSInteger g_rightEye_left;
extern const NSInteger g_rightEye_right;
extern const NSInteger g_nose_bottom_left;
extern const NSInteger g_nose_bottom;
extern const NSInteger g_nose_bottom_right;
extern const NSInteger g_mouth_left;
extern const NSInteger g_mouth_right;
extern const NSInteger g_mouth_top;
extern const NSInteger g_mouth_bottom;
extern const NSInteger g_contour_chin;
extern const NSInteger g_contour_left_1;
extern const NSInteger g_contour_left_2;
extern const NSInteger g_contour_right_1;
extern const NSInteger g_contour_right_2;

@interface FaceLandmarks : NSObject
@property (nonatomic, strong) NSArray *landmarks;
@property (nonatomic, readwrite) CGRect faceArea;
@end

@interface ZBFaceAligment : NSObject
+(NSArray<FaceLandmarks *> *)aligmentFaceImage:(UIImage *)image;
+(FaceLandmarks *)aligmentFaceImage:(UIImage *)image inFaceRect:(CGRect)faceArea;
@end
