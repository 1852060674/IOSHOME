//
//  FakeLanchWindow.h
//  HairColor
//
//  Created by ZB_Mac on 16/3/7.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Admob.h"

@interface FakeLanchWindow : UIWindow<AdmobViewControllerDelegate>
@property (nonatomic, copy) void(^action)(BOOL popShown);

- (void) setParentViewController: (UIViewController*) parentVC;
@end
