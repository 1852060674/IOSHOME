//
//  CameraViewController.h
//  Meitu
//
//  Created by ZB_Mac on 15-4-9.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraViewController;

@protocol CameraViewControllerDelegate <NSObject>

@optional
-(void)cameraVCDidCancel:(CameraViewController *)cameraVC;
-(void)cameraVC:(CameraViewController *)cameraVC didFinishWithImage:(UIImage *)image;
-(void)cameraVC:(CameraViewController *)cameraVC didFinishWithColor:(UIColor *)color;

@end

@interface CameraViewController : UIViewController

@property (nonatomic, weak) id<CameraViewControllerDelegate> delegate;

@end
