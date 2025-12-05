//
//  ShareViewController.h
//  ErasePhoto_new
//
//  Created by ZB_Mac on 14-11-30.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Admob.h"
@interface ShareViewController : UIViewController<AdmobViewControllerDelegate,ADWrapperDelegate>
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, readwrite) BOOL autoSave;
@property (nonatomic, readwrite) BOOL hasAd;
@end
