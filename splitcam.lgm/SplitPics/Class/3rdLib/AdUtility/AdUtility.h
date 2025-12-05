//
//  AdUtility.h
//  Plastic Surgeon
//
//  Created by ZB_Mac on 15/6/23.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Admob.h"
#import "HomeViewController.h"
@interface AdUtility : NSObject
+(BOOL)hasAd;
+(BOOL)tryShowBannerInView:(UIView *)view atOrigin:(CGPoint)origin;
+(BOOL)tryShowInterstitialInVC:(UIViewController *)VC;

@end
