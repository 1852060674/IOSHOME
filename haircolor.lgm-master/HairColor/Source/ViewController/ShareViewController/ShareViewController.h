//
//  ShareViewController.h
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/8.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "HideStatusBarViewController.h"

@interface ShareViewController : HideStatusBarViewController
@property (nonatomic, strong) UIImage *originalImage;
-(UIView *)getContentView;

@end
