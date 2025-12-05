//
//  FacebookWrapper.m
//  SplitPics
//
//  Created by 昭 陈 on 2017/7/10.
//  Copyright © 2017年 ZBNetWork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CfgCenter.h"

#ifdef AD_FACEBOOK
#import "FacebookWrapper.h"

#ifndef LOG_USER_ACTION
#define LOG_USER_ACTION
#endif

#ifdef LOG_USER_ACTION
@import Flurry_iOS_SDK;
#endif

@implementation FacebookWrapper
{
    NSString* banner_id;         // banner
    NSString* interstitial_id;   // full screen
    NSString* native_id;   // native ad
    
    FBAdView* adBanner;
    FBInterstitialAd* interstitial_round;
    
    float adWeight;                // 广告的宽度
    float adHeight;                 // 广告的高度
    
    BOOL ad_inter_failed;
    int ad_inter_retry_count;
    BOOL ad_inter_ready;
    
    ADAlignment bannerAlign;
}

@synthesize RootViewController;
@synthesize bannerReady;
@synthesize nativeReady;
@synthesize idx;

#pragma mark -
#pragma mark  admob init

- (id)initWithRootView:(AdmobViewController*) rootview BannerId:(NSString* )bannerid InterstitialId:(NSString* )interid NativeId:(NSString* )nativeid
{
    self = [super init];
    
    if(self)
    {
        RootViewController = rootview;
        banner_id = bannerid;
        interstitial_id = interid;
        native_id = nativeid;
        
        if([banner_id isEqualToString:@""]) {
            bannerReady = AD_NOTSURPORT;
        } else {
            bannerReady = AD_NOTINIT;
        }
        nativeReady = 0;
        
        // 设定广告屏幕高度和宽度，并同时获取设备类型
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            adWeight = 320;
            adHeight = 90;
        }
        else
        {
            adWeight = 320;
            adHeight = 50;
        }
        
        bannerAlign = AD_TOP;
#ifdef DEBUG
        [FBAdSettings setLogLevel:FBAdLogLevelLog];
        [FBAdSettings addTestDevice:@"5f119ec97f8dafcac12ec2d2373807e0e8ef01f7"];
#endif
    }
    return self;
}

- (void)dealloc
{
    adBanner.delegate = nil;
    interstitial_round.delegate = nil;
    adBanner = nil;
    interstitial_round = nil;
}

-(void) init_first_time {
    [self init_admob_interstitial];
}

-(void)init_admob_banner
{
    adBanner = [[FBAdView alloc] initWithPlacementID:banner_id adSize:kFBAdSizeHeight50Banner rootViewController:self.RootViewController];
    adBanner.delegate = self;
    
    bannerReady = AD_LOADING;
    [adBanner loadAd];

#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadBanner" withParameters:@{@"id": banner_id, @"status": @"load"}];
#endif
}

-(void) init_admob_banner:(float)width height:(float)height
{
    //ignore width and height
    [self init_admob_banner];
}

-(void) init_admob_interstitial
{
    interstitial_round = [[FBInterstitialAd alloc] initWithPlacementID:interstitial_id];
    interstitial_round.delegate = self;
    
    ad_inter_retry_count = 0;
    
    [self _interstitial_reload];
}

#pragma mark -
#pragma mark  admob banner

-(void) show_admob_banner:(UIView*)view placeid:(NSString *)place
{
    if(adBanner == nil)
        [self init_admob_banner];
    
    //  将banner的view加入到父view中
    [view addSubview:adBanner];
    
    [self updateBannerPos];
}

-(void) updateBannerPos {
    UIView* parent = [adBanner superview];
    if(parent != nil) {
        CGSize size = parent.frame.size;
        CGSize ourSize = adBanner.frame.size;
        
        switch (bannerAlign) {
            case AD_TOP:
                [adBanner setCenter:CGPointMake(size.width/2, ourSize.height/2)];
                break;
            case AD_CENTER:
                [adBanner setCenter:CGPointMake(size.width/2, size.height/2)];
                break;
            case AD_BOTTOM:
                [adBanner setCenter:CGPointMake(size.width/2, size.height-ourSize.height/2)];
                break;
            default:
                break;
        }
    }
}

-(void) setBannerAlign:(ADAlignment) align {
    bannerAlign = align;
    [self updateBannerPos];
}

#pragma mark -
#pragma mark admob native

-(void) init_admob_native:(float)width height:(float)height
{
}

/* 显示原生广告 */
-(void) show_admob_native:(float)posx posy:(float)posy width:(float)width height:(float)height view:(UIView*)view placeid:(NSString *)place
{
}

#pragma mark -
#pragma mark  admob interstitial

-(BOOL) show_admob_interstitial:(UIViewController*)viewController placeid:(int)place
{
    // 当广告还没就绪的时候，不增加显示次数
    if (ad_inter_ready) {
        [interstitial_round showAdFromRootViewController:viewController];
        NSLog(@"Show FB Inter Ad Idx:%d", idx);

#ifdef LOG_USER_ACTION
        [Flurry logEvent:@"FBLoadInter" withParameters:@{@"id": interstitial_id, @"status": @"show"}];
#endif
        [self init_admob_interstitial];

        return YES;
    }
    return NO;
}

-(BOOL) admob_interstial_ready:(int) place
{
    if(ad_inter_ready)
        return YES;
    
    if(ad_inter_failed)
    {
        [self _interstitial_reload];
    }
    return FALSE;
}

-(void) _interstitial_reload {
    ad_inter_failed = false;
    ad_inter_ready = false;
    [interstitial_round loadAd];

#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadInter" withParameters:@{@"id": interstitial_id, @"status": @"load"}];
#endif
}

#pragma mark -
#pragma mark  admob remove

-(void)remove_all_ads:(UIView *)rootView
{
    [self remove_banner:rootView];
    [self remove_native:rootView];
    
    adBanner.delegate = nil;
    interstitial_round.delegate = nil;
}

-(void)remove_banner:(UIView*)rootView
{
    for (UIView *_subView in rootView.subviews) {
        if ([_subView isKindOfClass:[FBAdView class]]) {
            [_subView removeFromSuperview];
        }
    }
}

-(void)remove_native:(UIView*)rootView
{
}

#pragma mark -
#pragma mark admob delegate
// banner 加载成功
-(void) adViewDidLoad:(FBAdView *)adView
{
    bannerReady = AD_LOADED;
    NSLog(@"Load FB banner ok! idx %d", idx);
    
    if(self.delegate != NULL) {
        [self.delegate bannerDidLoaded:self];
    }


#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadBanner" withParameters:@{@"id": banner_id, @"status": @"loaded"}];
#endif
}

// banner加载失败
-(void) adView:(FBAdView *)adView didFailWithError:(NSError *)error
{
    bannerReady = AD_FAILED;
    NSLog(@"Failed to receive FB banner idx %d with error: %@", idx, [error localizedFailureReason]);
    
    if(self.delegate != NULL) {
        [self.delegate bannerDidFailedLoad:self error: error];
    }

#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadBanner" withParameters:@{@"id": banner_id, @"status": @"failed"}];
#endif
}

//原生
//- (void)nativeExpressAdViewDidReceiveAd:(GADNativeExpressAdView *)nativeExpressAdView
//{
//}
//
//- (void)nativeExpressAdView:(GADNativeExpressAdView *)nativeExpressAdView didFailToReceiveAdWithError:(GADRequestError *)error
//{
//}

// 全屏就绪后的，admob调用的回调函数
-(void) interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    ad_inter_retry_count = 0;
    ad_inter_failed = false;
    ad_inter_ready = true;
    
    if(self.delegate != NULL) {
        [self.delegate interstitialDidReceiveAd];
    }
    
    NSLog(@"FB round ad ready, wait to show!");
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadInter" withParameters:@{@"id": interstitial_id, @"status": @"loaded"}];
#endif
}

// 关闭全屏后调用的回调函数
-(void) interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadInter" withParameters:@{@"id": interstitial_id, @"status": @"closed"}];
#endif
    if(self.delegate != NULL) {
        [self.delegate interstitialDidDismissScreen];
    }
}

-(void) interstitialAdWillClose:(FBInterstitialAd *)interstitialAd {
    if(self.delegate != NULL) {
        [self.delegate interstitialWillDismissScreen];
    }
}

-(void) interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadInter" withParameters:@{@"id": interstitial_id, @"status": @"failed"}];
#endif
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(ad_inter_retry_count < 3) {
            ad_inter_retry_count++;
            [self _interstitial_reload];
            
            NSLog(@"retry FB round ad %d!", ad_inter_retry_count);
        }
        else {
            ad_inter_retry_count = 0;
            ad_inter_failed = true;
        }
    });
    
    NSLog(@"FB round ad failed");
}

@end

#endif
