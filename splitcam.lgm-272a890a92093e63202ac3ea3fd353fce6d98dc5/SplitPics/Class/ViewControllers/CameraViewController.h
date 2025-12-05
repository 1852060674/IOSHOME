//
//  CameraViewController.h
//  SplitPics
//
//  Created by tangtaoyu on 15-3-6.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UnlockBlock)();

@interface CameraViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,UIAlertViewDelegate>

/**
 layoutIndexFromHome
 */
@property (assign, nonatomic) LayoutPattern currentLayoutIndex;

@property (nonatomic, strong) UIImagePickerController *pickerController;
@property (nonatomic, strong) UIPopoverController *popover;

@property (copy, nonatomic) UnlockBlock unlockBlock;

- (void)refreshViews;

@end
