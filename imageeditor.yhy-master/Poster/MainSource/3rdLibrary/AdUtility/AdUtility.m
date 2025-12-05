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
    return true;//![[AdmobViewController shareAdmobVC] IsPaid:kRemoveAd];
}
+(BOOL)tryShowBannerInView:(UIView *)view placeid:(NSString*) placeid
{
#ifdef ENABLE_AD
    if ([self hasAd]) {
        [[AdmobViewController shareAdmobVC] show_admob_banner:view placeid:placeid];
        return YES;
    }
#endif
    return NO;
}
+(BOOL)tryShowInterstitialInVC:(UIViewController *)VC placeid:(int)place ignoreTimeInterval:(BOOL)ignore
{
    BOOL shown = NO;
#ifdef ENABLE_AD

    if ([self hasAd]) {
        shown = [[AdmobViewController shareAdmobVC] try_show_admob_interstitial:VC placeid:place ignoreTimeInterval:ignore];
    }
#endif
    return shown;
}

+(BOOL)tryShowInterstitialInVC:(UIViewController *)VC placeid:(int)place
{
    return [self tryShowInterstitialInVC:VC placeid:place ignoreTimeInterval:NO];
}
@end
