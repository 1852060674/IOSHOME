//
//  MGCameraHelper.h
//  SplitPics
//
//  Created by tangtaoyu on 15-3-5.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;
@import UIKit;

typedef NS_ENUM(NSInteger, FlashStatus){
    FlashOFF,
    FlashON,
    FlashAUTO
};

@interface MGCameraHelper : NSObject

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (strong, nonatomic) AVCaptureDevice *device;

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) UIImageOrientation imageOrientation;

+ (MGCameraHelper*)sharedInstance;

/*
    @param sessionPreset 捕获预置图像大小
    @param postion 获取前后摄像头
 */
- (id)initWithPreset:(NSString *)sessionPreset devicePosition:(AVCaptureDevicePosition)postion;

- (void)startRunning;
- (void)stopRunning;

- (void)captureStillImage:(void(^)(UIImage *image))block;
- (void)embedPreviewInView:(UIView *)view;

-(void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (void)switchCameraPostion;
- (FlashStatus)changeFlash;
- (FlashStatus)flashStatus;

@end
