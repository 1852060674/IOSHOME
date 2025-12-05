//
//  MGCameraHelper.m
//  SplitPics
//
//  Created by tangtaoyu on 15-3-5.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGCameraHelper.h"
@import ImageIO;
@import CoreMedia;

@implementation MGCameraHelper

+ (MGCameraHelper*)sharedInstance
{
    static dispatch_once_t once;
    static id singleton;
    dispatch_once(&once, ^{
        singleton = [[self alloc] init];
    });
    
    return singleton;
}

- (id)init
{
    if(self = [super init]){
        [self initParamWithPreset:AVCaptureSessionPreset640x480 devicePosition:AVCaptureDevicePositionFront];
    }
    
    return self;
}

-(id)initWithPreset:(NSString *)sessionPreset devicePosition:(AVCaptureDevicePosition)postion;
{
    if(self = [super init]){
        [self initParamWithPreset:sessionPreset devicePosition:postion];
    }
    
    return self;
}

-(void)initParamWithPreset:(NSString *)sessionPreset devicePosition:(AVCaptureDevicePosition)postion
{
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = sessionPreset; //采集图像大小
    
    AVCaptureDeviceInput *captureInput;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *device in devices){
        if(device.position == postion){
            captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            self.device = device;
        }
    }
    
    if(!captureInput){
        return;
    }
    [self.session addInput:captureInput];
    
    self.captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    [self.captureOutput setOutputSettings:outputSettings];
    [self.session addOutput:self.captureOutput];
}

/*
 *  获取静态图片
 */
- (void)captureStillImage:(void(^)(UIImage *image))block
{
    AVCaptureConnection *videoConnection = nil;
    for(AVCaptureConnection *connection in self.captureOutput.connections){
        for(AVCaptureInputPort *port in connection.inputPorts){
            if([[port mediaType] isEqualToString:AVMediaTypeVideo]){
                videoConnection = connection;
                break;
            }
        }
        if(videoConnection){
            break;
        }
    }
    
    //get image
    [self.captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        //[self.session stopRunning];
        CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, nil);
        if(exifAttachments){
            // Do something with the attachments.
        }
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *t_image = [[UIImage alloc] initWithData:imageData];
        if(_device.position == AVCaptureDevicePositionFront){
            t_image = [UIImage imageWithCGImage:t_image.CGImage
                                          scale:1.0
                                    orientation:UIImageOrientationLeftMirrored];
        }else{
            t_image = [UIImage imageWithCGImage:t_image.CGImage
                                          scale:1.0
                                    orientation:UIImageOrientationRight];
        }
        if(block){
            block(t_image);
        }
    }];
}

/*
 * @function 闪光灯调整
 * @return   闪光灯状态
 */
- (FlashStatus)changeFlash
{
    FlashStatus result = FlashOFF;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [_device hasFlash]){
        [_device lockForConfiguration:nil];
        if([_device flashMode] == AVCaptureFlashModeOff){
            result = FlashAUTO;
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }else if([_device flashMode] == AVCaptureFlashModeAuto){
            result = FlashON;
            [_device setFlashMode:AVCaptureFlashModeOn];
        }else{
            result = FlashOFF;
            [_device setFlashMode:AVCaptureFlashModeOff];
        }
        [_device unlockForConfiguration];
    }
    return result;
}

/*
 * @function 获取闪光灯状态
 * @return   闪光灯状态
 */
- (FlashStatus)flashStatus
{
    FlashStatus result = FlashOFF;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [_device hasFlash]){
        if([_device flashMode] == AVCaptureFlashModeOff){
            result = FlashAUTO;
        }else if([_device flashMode] == AVCaptureFlashModeAuto){
            result = FlashON;
        }else{
            result = FlashOFF;
        }
    }
    return result;
}

- (void)startRunning
{
    [_session startRunning];
}

- (void)stopRunning
{
    [_session stopRunning];
}

/*
 * @function  嵌入 预览试图 到 指定视图 中
 * @param view 指定的视图
 */
- (void)embedPreviewInView:(UIView*)view
{
    if(!_session){
        return;
    }
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.frame = view.bounds;
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [view.layer addSublayer:_preview];
}

/*
 * @function 改变预览方向
 * @param interfaceOrientation 图片方向
 */
- (void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(!_session){
        return;
    }
    [CATransaction begin];
    if (interfaceOrientation==UIInterfaceOrientationLandscapeRight) {
        self.imageOrientation=UIInterfaceOrientationLandscapeRight;
        self.preview.connection.videoOrientation=AVCaptureVideoOrientationLandscapeRight;
    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeLeft){
        self.imageOrientation=UIInterfaceOrientationLandscapeLeft;
        self.preview.connection.videoOrientation=AVCaptureVideoOrientationLandscapeLeft;
    }
    [CATransaction commit];
}

/*
 * @function 切换摄像头
 */
- (void)switchCameraPostion
{
    NSArray *inputs = self.session.inputs;
    for(AVCaptureDeviceInput *input in inputs){
        AVCaptureDevice *device = input.device;
        if([device hasMediaType:AVMediaTypeVideo]){
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if(position == AVCaptureDevicePositionFront){
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            }else{
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            }
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            _device = newCamera;
            
            [_session beginConfiguration];
            [_session removeInput:input];
            [_session addInput:newInput];
            [_session commitConfiguration];
            break;
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == position)
        {
            return device;
        }
    }
    return nil;
}

@end
