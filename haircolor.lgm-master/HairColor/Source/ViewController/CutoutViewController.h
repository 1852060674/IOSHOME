//
//  CutoutViewController.h
//  HairColor
//
//  Created by ZB_Mac on 2016/11/22.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HideStatusBarViewController.h"

@interface CutoutViewController : HideStatusBarViewController
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *maskImage;

@property (nonatomic, copy) void(^actions)(BOOL accept, UIImage *maskImage, UIImage *refineMaskImage);
@end
