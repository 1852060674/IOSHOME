//
//  HairColorViewController.h
//  HairColor
//
//  Created by ZB_Mac on 2016/11/21.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HideStatusBarViewController.h"

@interface HairColorViewController : HideStatusBarViewController
-(UIView *)getContentView;
-(UIImage *)getContentImage;
-(void)hairAreaSelected;

@end
