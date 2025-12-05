//
//  AdUtility.m
//  Plastic Surgeon
//
//  Created by ZB_Mac on 15/6/23.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "AdUtility.h"

@implementation AdUtility
+(BOOL)hasAd
{
//    return NO;
    return ![[AdmobViewController shareAdmobVC] IsPaid:kRemoveAd];
}
+(BOOL)tryShowBannerInView:(UIView *)view atOrigin:(CGPoint)origin
{
#ifdef ENABLE_AD
    if ([self hasAd]) {
        [[AdmobViewController shareAdmobVC] show_admob_banner:0 posy:0 view:view];
        return YES;
    }
#endif
    return NO;
}
+(BOOL)tryShowInterstitialInVC:(UIViewController *)VC
{
    BOOL shown = NO;
#ifdef ENABLE_AD

    if ([self hasAd]) {
        shown = [[AdmobViewController shareAdmobVC] try_show_admob_interstitial:VC ignoreTimeInterval:NO];
    }
#endif
    return shown;
}

@end
