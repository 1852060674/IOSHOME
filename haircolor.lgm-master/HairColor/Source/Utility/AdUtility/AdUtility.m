//
//  AdUtility.m
//  Plastic Surgeon
//
//  Created by ZB_Mac on 15/6/23.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "AdUtility.h"
//#import "GlobalSettingManger.h"
static int showCnt = 0;

@implementation AdUtility
+(BOOL)hasAd
{
#ifdef ENABLE_AD
    return ![[AdmobViewController shareAdmobVC] IsPaid:kRemoveAd] && ![[AdmobViewController shareAdmobVC] IsPaid:kUnlockAll] && !PRO_VERSION;
#else
    return NO;
#endif
}
+(BOOL)advanceMaskAvailable
{
//    return PRO_VERSION || [[AdmobViewController shareAdmobVC] IsPaid:kUnlockAll] || [[AdmobViewController shareAdmobVC] IsPaid:kAdvancedMask];
    return YES;

}
+(BOOL)advanceColorAvailable
{
//    return PRO_VERSION || [[AdmobViewController shareAdmobVC] IsPaid:kUnlockAll] || [[AdmobViewController shareAdmobVC] IsPaid:kAdvancedColor];
//    return YES;
    return ![self hasAd];
}

+(BOOL)basicOrnamentAvailable
{
    return YES;
//    return PRO_VERSION || [[AdmobViewController shareAdmobVC] IsPaid:kUnlockAll] || [[AdmobViewController shareAdmobVC] IsPaid:kBasicOrnament];
}

+(BOOL)advanceOrnamentAvailable
{
//    return PRO_VERSION || [[AdmobViewController shareAdmobVC] IsPaid:kUnlockAll] || [[AdmobViewController shareAdmobVC] IsPaid:kAdvanceOrnament];
    return YES;

}

+(BOOL)frameFilterAvailable
{
//    return PRO_VERSION || [[AdmobViewController shareAdmobVC] IsPaid:kUnlockAll] || [[AdmobViewController shareAdmobVC] IsPaid:kFrameFilter];
    return YES;
}

+(BOOL)allPurchased
{
    return [[AdmobViewController shareAdmobVC] IsPaid:kUnlockAll] || PRO_VERSION || ([self advanceColorAvailable] && [self advanceMaskAvailable] && [self advanceOrnamentAvailable] && [self basicOrnamentAvailable] && [self frameFilterAvailable] && ![self hasAd]);
}

+(BOOL)tryShowBannerInView:(UIView *)view
{
#ifdef ENABLE_AD
    if ([self hasAd]) {
//        for (UIView *subView in view.subviews) {
//            if ([subView isKindOfClass:[GADBannerView class]]) {
//                return NO;
//            }
//        }
        [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0 posy:0 view:view];
        return YES;
    }
#endif
    return NO;
}

+(BOOL)tryShowInterstitialInVC:(UIViewController *)VC ignoreTimeInterval:(BOOL)ignore
{
    BOOL shown = NO;
    
//    if (showCnt>=5)
//    {
//        return shown;
//    }
#ifdef ENABLE_AD
    if ([self hasAd]) {
        shown = [[AdmobViewController shareAdmobVC] try_show_admob_interstitial:VC ignoreTimeInterval:ignore];
    }
#endif
    if (shown) {
        ++showCnt;
    }
    return shown;
}

@end
