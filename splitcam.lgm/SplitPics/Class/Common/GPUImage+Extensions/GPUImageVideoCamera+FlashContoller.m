//
//  GPUImageVideoCamera+FlashContoller.m
//  SplitPics
//
//  Created by tangtaoyu on 15-3-6.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "GPUImageVideoCamera+FlashContoller.h"

@implementation GPUImageVideoCamera (FlashContoller)

- (FlashStatus)changeFlash
{
    FlashStatus result=OFF;
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && [self.inputCamera hasFlash])
    {
        [self.inputCamera lockForConfiguration:nil];
//        if([self.inputCamera flashMode] == AVCaptureFlashModeOff)
//        {
//            result=AUTO;
//            [self.inputCamera setFlashMode:AVCaptureFlashModeAuto];
//            NSLog(@"Flash Set AUTO");
//        }
//        else if([self.inputCamera flashMode] == AVCaptureFlashModeAuto)
//        {
//            result=ON;
//            [self.inputCamera setFlashMode:AVCaptureFlashModeOn];
//            NSLog(@"Flash Set ON");
//        }
//        else{
//            result=OFF;
//            [self.inputCamera setFlashMode:AVCaptureFlashModeOff];
//            NSLog(@"Flash Set OFF");
//        }
        
        if([self.inputCamera flashMode] == AVCaptureFlashModeOff)
        {
            result=ON;
            [self.inputCamera setFlashMode:AVCaptureFlashModeOn];
            NSLog(@"Flash Set ON");
        }
        else
        {
            result=OFF;
            [self.inputCamera setFlashMode:AVCaptureFlashModeOff];
            NSLog(@"Flash Set Off");
        }
        
        [self.inputCamera unlockForConfiguration];
    }
    
    return result;
}

- (FlashStatus)flashStatus
{
    FlashStatus result;
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && [self.inputCamera hasFlash])
    {
        if([self.inputCamera flashMode] == AVCaptureFlashModeOff)
        {
            result=OFF;
        }
        else{
            result=ON;
        }
    }
    return result;
}

//Focus
//https://github.com/BradLarson/GPUImage/issues/254
- (void)setFocusInPoint:(CGPoint)point InView:(UIView*)view
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [view frame].size;
    
    if (self.cameraPosition == AVCaptureDevicePositionFront) {
        point.x = frameSize.width - point.x;
    }
    pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));

    if ([_inputCamera isFocusPointOfInterestSupported] && [_inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([_inputCamera lockForConfiguration:&error]) {
            [_inputCamera setFocusPointOfInterest:pointOfInterest];
            [_inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
            
            if([_inputCamera isExposurePointOfInterestSupported] && [_inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                [_inputCamera setExposurePointOfInterest:pointOfInterest];
                [_inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            [_inputCamera unlockForConfiguration];
        }
    }
}

- (void)autoFocusAtPoint:(CGPoint)point
{
    
    if ([_inputCamera isFocusPointOfInterestSupported] && [_inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([_inputCamera lockForConfiguration:&error]) {
            [_inputCamera setFocusPointOfInterest:point];
            [_inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
            [_inputCamera unlockForConfiguration];
        }
        
    }
}
// Switch to continuous auto focus mode at the specified point
- (void)continuousFocusAtPoint:(CGPoint)point
{
    if ([_inputCamera isFocusPointOfInterestSupported] && [_inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error;
        if ([_inputCamera lockForConfiguration:&error]) {
            [_inputCamera setFocusPointOfInterest:point];
            [_inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [_inputCamera unlockForConfiguration];
        }
    }
}

//AutoFocus
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( [keyPath isEqualToString:@"adjustingFocus"] ){
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
        NSLog(@"Is adjusting focus? %@", adjustingFocus ? @"YES" : @"NO" );
        NSLog(@"Change dictionary: %@", change);
    }
}


- (void)setAutoExpose {
  NSError *error;
  if ([_inputCamera lockForConfiguration:&error]) {
//    if([_inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
//      [_inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
//    } else
      if([_inputCamera isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
      [_inputCamera setExposureMode:AVCaptureExposureModeAutoExpose];
    }
    [_inputCamera unlockForConfiguration];
  } else if (error) {
    NSLog(@"%@",error);
  }

}

@end

