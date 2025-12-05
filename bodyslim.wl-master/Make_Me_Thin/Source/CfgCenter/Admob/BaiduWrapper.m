//
//  BaiduWrapper.m
//  EbookReader
//
//  Created by 昭 陈 on 2017/4/10.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CfgCenter.h"

#ifdef AD_BAIDU
#import "BaiduWrapper.h"

@implementation BaiduWrapper
{
    BaiduMobAdView *adBanner;
    BaiduMobAdInterstitial *interstitial;
    
    /* 广告条，对于pro版本，或者in-app版本，全屏需要关闭 */
    float adWeight;                // 广告的宽度
    float adHeight;                 // 广告的高度
    
    BOOL ad_inter_failed;
    int ad_inter_retry_count;
    
    ADAlignment bannerAlign;
}

@synthesize app_id;
@synthesize banner_id;
@synthesize interstitial_id;

@synthesize RootViewController;
@synthesize bannerReady;
@synthesize nativeReady;
@synthesize idx;

#pragma mark -
#pragma mark  baiduad init

- (id)initWithRootView:(AdmobViewController*) rootview appid:(NSString* )appid BannerId:(NSString* )bannerid InterstitialId:(NSString* )interid
{
    self = [super init];
    
    if(self)
    {
        RootViewController = rootview;
        app_id = appid;
        banner_id = bannerid;
        interstitial_id = interid;
        bannerReady = -1;
        nativeReady = -1;
        
        // 设定广告屏幕高度和宽度，并同时获取设备类型
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            adWeight = kBaiduAdViewBanner728x90.width;
            adHeight = kBaiduAdViewBanner728x90.height;
        }
        else
        {
            adWeight = kBaiduAdViewBanner320x48.width;
            adHeight = kBaiduAdViewBanner320x48.height;
        }
        
        bannerAlign = AD_TOP;
    }
    return self;
}

- (void)dealloc
{
    adBanner.delegate = nil;
    interstitial.delegate = nil;
    adBanner = nil;
    interstitial = nil;
}

-(void) init_first_time {
    [self init_admob_interstitial];
}

-(void)init_admob_banner
{
    adBanner = [[BaiduMobAdView alloc] init];
    adBanner.AdUnitTag = banner_id;
    adBanner.delegate = self;
    [adBanner start];
}

-(void) init_admob_banner:(float)width height:(float)height
{
    adBanner = [[BaiduMobAdView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    adBanner.AdUnitTag = banner_id;
    adBanner.delegate = self;
    [adBanner start];
    
    adWeight = width;
    adHeight = height;
}

-(void) init_admob_interstitial
{
    interstitial = [[BaiduMobAdInterstitial alloc] init];
    interstitial.AdUnitTag = interstitial_id;
    interstitial.delegate = self;
    interstitial.interstitialType = BaiduMobAdViewTypeInterstitialOther;
    [interstitial load];
    
    ad_inter_retry_count = 0;
    ad_inter_failed = false;
}

#pragma mark -
#pragma mark  baiduad banner

-(void) show_admob_banner:(UIView*)view placeid:(NSString *)place
{
    if(adBanner == nil)
        [self init_admob_banner:adWeight height:adHeight];
    
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
#pragma mark  baiduad interstitial

-(BOOL) show_admob_interstitial:(UIViewController*)viewController placeid:(int)place
{
    // 当广告还没就绪的时候，不增加显示次数
    if ([interstitial isReady]) {
        [interstitial presentFromRootViewController:viewController];
        NSLog(@"Show Inter Ad Idx:%d", idx);
        return YES;
    }
    return NO;
}

-(BOOL) admob_interstial_ready:(int) place
{
    if([interstitial isReady])
        return YES;
    
    if(ad_inter_failed)
    {
        [self _interstitial_reload];
    }
    return FALSE;
}

-(void) _interstitial_reload {
    ad_inter_failed = false;
    [interstitial load];
}

#pragma mark -
#pragma mark  admob remove

-(void)remove_all_ads:(UIView *)rootView
{
    [self remove_banner:rootView];
    [self remove_native:rootView];
    
    adBanner.delegate = nil;
    interstitial.delegate = nil;
}

-(void)remove_banner:(UIView*)rootView
{
    for (UIView *_subView in rootView.subviews) {
        if ([_subView isKindOfClass:[BaiduMobAdView class]]) {
            [_subView removeFromSuperview];
        }
    }
}

#pragma mark -
#pragma mark admob delegate

- (NSString *)publisherId
{
    return app_id;
}

-(BOOL) enableLocation
{
    return NO;
}

-(void) willDisplayAd:(BaiduMobAdView*) adview
{
    bannerReady = 1;
    NSLog(@"Baidu Load banner ok! idx %d", idx);
}

/**
 *  广告载入失败
 */
-(void) failedDisplayAd:(BaiduMobFailReason) reason;
{
    bannerReady = 0;
    NSLog(@"Failed to receive banner idx %d with error: %d", idx, reason);
    
    if(self.delegate != NULL) {
        [self.delegate bannerDidFailedLoad:self error: nil];
    }
}

// 全屏就绪后的，admob调用的回调函数
- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial
{
    ad_inter_retry_count = 0;
    ad_inter_failed = false;
    
    if(self.delegate != NULL) {
        [self.delegate interstitialDidReceiveAd];
    }
    
    NSLog(@"round ad ready, wait to show!");
}

// 关闭全屏后调用的回调函数
- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial
{
    if(self.delegate != NULL) {
        if([self.delegate interstitialDidDismissScreen])
            [self init_admob_interstitial];
    } else {
        [self init_admob_interstitial];
    }
}

- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(ad_inter_retry_count < 3) {
            ad_inter_retry_count++;
            [self _interstitial_reload];
            
            NSLog(@"retry round ad %d!", ad_inter_retry_count);
        }
        else {
            ad_inter_retry_count = 0;
            ad_inter_failed = true;
        }
    });
    
    NSLog(@"round ad failed");
}

@end

#endif
