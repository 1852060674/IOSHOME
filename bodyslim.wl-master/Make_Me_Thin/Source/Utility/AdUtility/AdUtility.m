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
    BOOL enableAd = NO;
#ifdef ENABLE_AD
    enableAd = YES;
#endif
    BOOL hasRemoveAd = NO;
#ifdef ENABLE_IAP
    hasRemoveAd = [[AdmobViewController shareAdmobVC] IsPaid:kRemoveAd];
#endif

    return enableAd && !hasRemoveAd && !PRO_VERSION;
}

+(BOOL)shouldShowIAP
{
    BOOL shouldShow = NO;
#ifdef ENABLE_IAP
    shouldShow = ![[AdmobViewController shareAdmobVC] IsPaid:kRemoveAd];
#endif
    
    return shouldShow && !PRO_VERSION;
}

+(BOOL)tryShowBannerInView:(UIView *)view
{
#ifdef ENABLE_AD
    if ([self hasAd]) {
        [[AdmobViewController shareAdmobVC] show_admob_banner:view];
        return YES;
    }
#endif
    return NO;
}
+(BOOL)tryShowInterstitialInVC:(UIViewController *)VC ignoreTimeInterval:(BOOL)ignore
{
    BOOL shown = NO;
#ifdef ENABLE_AD

    if ([self hasAd]) {
        shown = [[AdmobViewController shareAdmobVC] try_show_admob_interstitial:VC ignoreTimeInterval:ignore];
    }
#endif
    return shown;
}

+(BOOL)tryShowInterstitialInVC:(UIViewController *)VC
{
    return [self tryShowInterstitialInVC:VC ignoreTimeInterval:NO];
}
@end
