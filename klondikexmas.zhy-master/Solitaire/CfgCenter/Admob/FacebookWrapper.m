//
//  FacebookWrapper.m
//  SplitPics
//
//  Created by 昭 陈 on 2017/7/10.
//  Copyright © 2017年 ZBNetWork. All rights reserved.
//

#import <Foundation/Foundation.h>

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
    BOOL bannerSuccessed;
    
    long refreshtime;
    long impressionTime;
    long impressionStart;
    
    int refreshForeground;
    int refreshBackground;
    int refreshBackgroundLoaded;
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
        bannerSuccessed = FALSE;
        
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
        self->isBannerBackground = TRUE;
        
        refreshForeground = REFRESH_TIME_FOREGROUND;
        refreshBackground = REFRESH_TIME_BACKGROUND;
        refreshBackgroundLoaded = REFRESH_TIME_BACKGROUND_LOADED;
        
        [self resetImpressionTime];
#ifdef DEBUG
        [FBAdSettings setLogLevel:FBAdLogLevelLog];
        [FBAdSettings addTestDevice:@"5f119ec97f8dafcac12ec2d2373807e0e8ef01f7"];
//        NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//        NSLog(@"Device IDFA %@", idfaString);
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

- (void) setRefreshTimeLimitFG:(int) foreground BG:(int) background BGLoaded:(int) backgroundloaded {
    refreshForeground = MAX(REFRESH_TIME_FOREGROUND, foreground);
    refreshBackground = MAX(REFRESH_TIME_BACKGROUND, background);
    refreshBackgroundLoaded = MAX(REFRESH_TIME_BACKGROUND_LOADED, backgroundloaded);
}

-(void) init_first_time {
    [self init_admob_interstitial];
    
    if(bannerReady != AD_NOTSURPORT) {
        [self init_admob_banner];
        
        //start time task watch refresh every 30s
        [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self
                                       selector: @selector(checkManulRefresh) userInfo: nil repeats: YES];
    }
}

-(void) reloadBannerView {
    if(bannerReady == AD_FAILED) {
        adBanner.delegate = nil;
        adBanner = [[FBAdView alloc] initWithPlacementID:banner_id adSize:kFBAdSizeHeight50Banner rootViewController:self.RootViewController];
        adBanner.delegate = self;
        adBanner.userInteractionEnabled = false;
    }
    [adBanner loadAd];
    refreshtime = time(NULL);
}

-(void)init_admob_banner
{
    adBanner = [[FBAdView alloc] initWithPlacementID:banner_id adSize:kFBAdSizeHeight50Banner rootViewController:self.RootViewController];
    adBanner.delegate = self;
    adBanner.userInteractionEnabled = false;
    bannerReady = AD_LOADING;
    [self reloadBannerView];

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
    if(interstitial_round != nil) {
        interstitial_round.delegate = nil;
        interstitial_round = nil;
    }
    
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
    
    self->isBannerBackground = FALSE;
    if(bannerReady == AD_LOADED) {
        [self recordImpressionStart];
    }
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
    
//    adBanner.delegate = nil;
//    interstitial_round.delegate = nil;
}

-(void)remove_banner:(UIView*)rootView
{
    for (UIView *_subView in rootView.subviews) {
        if ([_subView isKindOfClass:[FBAdView class]]) {
            [_subView removeFromSuperview];
        }
    }
    
    self->isBannerBackground = TRUE;
    [self recordImpressionStop];
}

-(void)remove_native:(UIView*)rootView
{
}


- (void) updateImpression:(UIView*)rootView {
    if(bannerReady == AD_FAILED) {
        return;
    }
    
    if(adBanner.superview != rootView) {
        for (UIView *_subView in rootView.subviews) {
            if ([_subView isKindOfClass:[FBAdView class]]) {
                [_subView removeFromSuperview];
            }
        }
        
        [rootView addSubview:adBanner];
        
        [self updateBannerPos];
        
        self->isBannerBackground = FALSE;
        if(bannerReady == AD_LOADED) {
            [self recordImpressionStart];
        }
    }
}
#pragma mark -
#pragma mark admob delegate
// banner 加载成功
-(void) adViewDidLoad:(FBAdView *)adView
{
    adBanner.userInteractionEnabled = true;
    bannerReady = AD_LOADED;
    bannerSuccessed = TRUE;
    NSLog(@"Load FB banner ok! idx %d", idx);
    
    [self resetImpressionTime];
    
    if(self.delegate != NULL) {
        [self.delegate bannerDidLoaded:self];
    }
    
    if(!self->isBannerBackground) {
        [self recordImpressionStart];
    }

#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadBanner" withParameters:@{@"id": banner_id, @"status": @"loaded"}];
#endif
    
    refreshtime = time(NULL);
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
    
    refreshtime = time(NULL);
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
        if([self.delegate interstitialDidDismissScreen])
            [self init_admob_interstitial];
    } else {
        [self init_admob_interstitial];
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

- (bool)isBannerHaveSuccessBefore {
    return bannerSuccessed;
}

#pragma mark -
#pragma mark banner impressionTimeCounting

-(void) resetImpressionTime {
    impressionTime = 0;
    impressionStart = -1;
}

-(void) recordImpressionStart {
    if(impressionStart < 0) {
        impressionStart = time(NULL);
    }
}

-(void) recordImpressionStop {
    if(impressionStart > 0) {
        long now = time(NULL);
        impressionTime += now - impressionStart;
        impressionStart = -1;
    }
}

#pragma mark -
#pragma mark manual refrash bannerad

-(void) checkManulRefresh {
    long now = time(NULL);
    long showtime = now-impressionStart+impressionTime;
    if(impressionStart < 0){
        showtime = 0;
    }
    NSLog(@"fb banner %d 已展示 %lds", idx, showtime);
    if(bannerReady != AD_FAILED && bannerReady != AD_LOADED) {
        return;
    }

    int timeelapse = refreshForeground;  // 前台40s刷新，后台100s刷新
    if(self->isBannerBackground) {
        timeelapse = refreshBackground;
        if(bannerReady == AD_LOADED) {  //后台成功banner就5分钟刷新一次
            timeelapse = refreshBackgroundLoaded;
        }
    }
//    NSLog(@"banner %d%@刷新, 经过%lds", idx, self->isBannerBackground?@"后台":@"前台", now - refreshtime);
    if(now - refreshtime > timeelapse) {
        if(bannerReady == AD_LOADED && showtime < timeelapse && !self->isBannerBackground) {
            //do nothing
        } else {
            NSLog(@"banner %d%@刷新, 经过%lds", idx, self->isBannerBackground?@"后台":@"前台", now - refreshtime);
            [self reloadBannerView];
        }
    }
}

@end
