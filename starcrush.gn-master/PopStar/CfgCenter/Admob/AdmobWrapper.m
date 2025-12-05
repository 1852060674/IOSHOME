//
//  AdmobWrapper.m
//  version 3.3
//
//  Created by 昭 陈 on 16/5/17.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Admob.h"
#import "AdmobWrapper.h"
#ifdef UNITY_MODE
#import "UnityAppController.h"
#endif

//#define ENABLE_ADJUST
//#define ENABLE_FIREBASE
#ifdef ENABLE_ADJUST
#import "Adjust.h"
#endif
#ifdef ENABLE_FIREBASE
#import "Firebase.h"
#endif

//#ifndef LOG_USER_ACTION
//#define LOG_USER_ACTION
//#endif

#ifdef LOG_USER_ACTION
//@import Flurry_iOS_SDK;
#import "Flurry.h"
#endif

@implementation AdmobWrapper
{
    GADBannerView *adBanner;
    GADInterstitialAd *interstitial_round;
    
    BOOL ad_inter_failed;
    int ad_inter_retry_count;
    
    NSString* curr_banner_place;
    int curr_inter_place;
    
    ADAlignment bannerAlign;
    
    BOOL bannerSuccessed;
    
    long refreshtime;
    long impressionTime;
    long impressionStart;
    
    int refreshForeground;
    int refreshBackground;
    int refreshBackgroundLoaded;
}

@synthesize banner_id;
@synthesize interstitial_id;
@synthesize native_id;

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
        nativeReady = -1;
        bannerSuccessed = FALSE;
        
        bannerAlign = AD_TOP;
        self->isBannerBackground = TRUE;
        
        refreshForeground = REFRESH_TIME_FOREGROUND;
        refreshBackground = REFRESH_TIME_BACKGROUND;
        refreshBackgroundLoaded = REFRESH_TIME_BACKGROUND_LOADED;
        
        [self resetImpressionTime];
    }
    return self;
}

- (void)dealloc
{
    adBanner.delegate = nil;
    adBanner.paidEventHandler = nil;
    interstitial_round.fullScreenContentDelegate = nil;
    interstitial_round.paidEventHandler = nil;
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

-(GADRequest*) getADRequest {
    GADRequest* request = [GADRequest request];
    return request;
}

-(void) reloadBannerView {
    [adBanner loadRequest:[self getADRequest]];
    refreshtime = time(NULL);
}

-(void)init_admob_banner
{
//    if(self.orientation == AD_PORTRAIT) {
//        adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
//    } else if([self.RootViewController useSmartBannerInLandscape]) {
//        adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
//    } else if(IS_IPAD) {
//        adBanner = [[GADBannerView alloc] initWithAdSize:GADAdSizeLeaderboard];
//    } else {
//        adBanner = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
//    }
#ifdef UNITY_MODE
    UnityAppController* gameScreen = (UnityAppController *)[UIApplication sharedApplication].delegate;
    CGFloat viewWidth = gameScreen.window.frame.size.width;
#else
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat viewWidth = screenRect.size.width;
#endif
    adBanner = [[GADBannerView alloc] initWithAdSize:GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)];
    
    adBanner.adUnitID = self.banner_id;
    adBanner.delegate = self;
    __weak AdmobWrapper* weakSelf = self;
    adBanner.paidEventHandler = ^(GADAdValue * _Nonnull advalue) {
        AdmobWrapper *strongSelf = weakSelf;
        // Extract the impression-level ad revenue data.
        NSDecimalNumber *value = advalue.value;
        NSString *currencyCode = advalue.currencyCode;
        
        [strongSelf logPaidAdRevenue:value currency:currencyCode responseInfo:strongSelf->adBanner.responseInfo.loadedAdNetworkResponseInfo unitId:strongSelf.banner_id];
    };
    [adBanner setRootViewController:self.RootViewController]; // 主要用于removeFromSuperview？
    adBanner.userInteractionEnabled = false;
    bannerReady = AD_LOADING;
    [self reloadBannerView];
    
#ifdef LOG_USER_ACTION
    [Flurry logEvent:curr_banner_place withParameters:@{@"id": banner_id, @"status": @"load"}];
#endif
}

- (void)init_admob_banner:(float)width height:(float)height {
    //ignore width and height
    [self init_admob_banner];
}

-(void) init_admob_interstitial
{
    if(interstitial_round != nil) {
        interstitial_round.fullScreenContentDelegate = nil;
        interstitial_round.paidEventHandler = nil;
        interstitial_round = nil;
    }
    
    if([self.interstitial_id isEqualToString:@""])
        return;
    
    ad_inter_retry_count = 0;
    [self _interstitial_reload];
}

#pragma mark -
#pragma mark  admob banner

-(void) show_admob_banner:(UIView*)view placeid:(NSString *)place
{
    if(adBanner == nil)
        [self init_admob_banner];
    
    curr_banner_place = place;
    
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
#ifdef UNITY_MODE
        UnityAppController* gameScreen = (UnityAppController *)[UIApplication sharedApplication].delegate;
        CGSize size = gameScreen.window.frame.size;//parent.bounds.size;
#else
        CGSize size = parent.bounds.size;
#endif
        CGSize ourSize = adBanner.frame.size;
        
        for(NSLayoutConstraint* constraint in parent.constraints) {
            if(constraint.firstItem == adBanner || constraint.secondItem == adBanner) {
                [parent removeConstraint:constraint];
            }
        }
        
        //cneter horizen
        [parent addConstraint:[NSLayoutConstraint
                               constraintWithItem:parent
                               attribute:NSLayoutAttributeCenterX
                               relatedBy:NSLayoutRelationEqual
                               toItem:adBanner
                               attribute:NSLayoutAttributeCenterX
                               multiplier:1.0 constant:0.0]];
        
        switch (bannerAlign) {
            case AD_TOP:
                [adBanner setCenter:CGPointMake(size.width/2, ourSize.height/2)];
                [parent addConstraint:[NSLayoutConstraint
                                       constraintWithItem:parent
                                       attribute:NSLayoutAttributeTop
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:adBanner
                                       attribute:NSLayoutAttributeTop
                                       multiplier:1.0 constant:0.0]];
                break;
            case AD_CENTER:
                [adBanner setCenter:CGPointMake(size.width/2, size.height/2)];
                [parent addConstraint:[NSLayoutConstraint
                                       constraintWithItem:parent
                                       attribute:NSLayoutAttributeCenterY
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:adBanner
                                       attribute:NSLayoutAttributeCenterY
                                       multiplier:1.0 constant:0.0]];
                break;
            case AD_BOTTOM:
                [adBanner setCenter:CGPointMake(size.width/2, size.height-ourSize.height/2)];
                [parent addConstraint:[NSLayoutConstraint
                                       constraintWithItem:parent
                                       attribute:NSLayoutAttributeBottom
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:adBanner
                                       attribute:NSLayoutAttributeBottom
                                       multiplier:1.0 constant:0.0]];
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

-(void) init_admob_native:(float)width height:(float)height {
    //not support
}

/* 显示原生广告 */
-(void) show_admob_native:(float)posx posy:(float)posy width:(float)width height:(float)height view:(UIView*)view placeid:(NSString *)place {
    //not support
}

#pragma mark -
#pragma mark  admob interstitial

-(BOOL) show_admob_interstitial:(UIViewController*)viewController placeid:(int)place
{
    if (interstitial_round == nil)
        return NO;

    // 当广告还没就绪的时候，不增加显示次数
    curr_inter_place = place;
    
    [interstitial_round presentFromRootViewController:viewController];
    NSLog(@"[ADUNION] Show Admob Inter Ad Idx:%d", idx);
        
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[self adPosition] withParameters:@{@"id": interstitial_id, @"status": @"show"}];
#endif
    return YES;
}

-(BOOL) admob_interstial_ready:(int)place
{
    if([interstitial_id isEqualToString:@""]) {
        return NO;
    }
    
    if(interstitial_round)
        return YES;
    
    if(ad_inter_failed)
    {
        [self _interstitial_reload];
    }
    return FALSE;
}

-(void) _interstitial_reload {
    ad_inter_failed = false;
    interstitial_round = nil;
    
    [GADInterstitialAd loadWithAdUnitID:interstitial_id
                                request:[self getADRequest]
                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
#ifdef LOG_USER_ACTION
            [Flurry logEvent:[self adPosition] withParameters:@{@"id": interstitial_id, @"status": @"failed"}];
#endif

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(ad_inter_retry_count < 3) {
                    ad_inter_retry_count++;
                    [self _interstitial_reload];
                    
                    NSLog(@"[ADUNION] retry Admob round ad %d!", ad_inter_retry_count);
                }
                else {
                    ad_inter_retry_count = 0;
                    ad_inter_failed = true;
                }
            });
            
            NSLog(@"[ADUNION] Admob round ad failed");
            
            if(self.delegate != NULL) {
                [self.delegate interstitialDidFailed];
            }
            return;
        } else {
            ad_inter_retry_count = 0;
            ad_inter_failed = false;
            
            interstitial_round = ad;
            interstitial_round.fullScreenContentDelegate = self;
            
            __weak AdmobWrapper *weakSelf = self;
            interstitial_round.paidEventHandler = ^void(GADAdValue *_Nonnull advalue){
                AdmobWrapper *strongSelf = weakSelf;
                // Extract the impression-level ad revenue data.
                NSDecimalNumber *value = advalue.value;
                NSString *currencyCode = advalue.currencyCode;
                
                [strongSelf logPaidAdRevenue:value currency:currencyCode responseInfo:strongSelf->interstitial_round.responseInfo.loadedAdNetworkResponseInfo unitId:strongSelf.interstitial_id];

            };
            
            if(self.delegate != NULL) {
                [self.delegate interstitialDidReceiveAd];
            }
            
            NSLog(@"[ADUNION] Admob round ad ready, wait to show!");
#ifdef LOG_USER_ACTION
            [Flurry logEvent:[self adPosition] withParameters:@{@"id": interstitial_id, @"status": @"loaded"}];
#endif
        }
    }];
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[self adPosition] withParameters:@{@"id": interstitial_id, @"status": @"load"}];
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
        if ([_subView isKindOfClass:[GADBannerView class]]) {
            [_subView removeFromSuperview];
        }
    }
    self->isBannerBackground = TRUE;
    [self recordImpressionStop];
}

-(void)remove_native:(UIView*)rootView {
}

#pragma mark -
#pragma mark admob delegate
- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView {
    adBanner.userInteractionEnabled = true;
    bannerReady = AD_LOADED;
    bannerSuccessed = TRUE;
    NSLog(@"[ADUNION] Admob Load banner ok! idx %d", idx);
    
    [self resetImpressionTime];
    
    if(self.delegate != NULL) {
        [self.delegate bannerDidLoaded:self];
    }
    
    if(!self->isBannerBackground) {
        [self recordImpressionStart];
    }
    
#ifdef LOG_USER_ACTION
    [Flurry logEvent:curr_banner_place withParameters:@{@"id": banner_id, @"status": @"loaded", @"click": @"show"}];
#endif
    
    refreshtime = time(NULL);
}

- (void)bannerView:(nonnull GADBannerView *)bannerView
didFailToReceiveAdWithError:(nonnull NSError *)error {
    if(bannerReady != AD_LOADED) {  //if has loaded then alway can show
        bannerReady = AD_FAILED;
        NSLog(@"[ADUNION] Failed to receive Admob banner idx %d with error: %@", idx, [error localizedFailureReason]);
        
        if(self.delegate != NULL) {
            [self.delegate bannerDidFailedLoad:self error: error];
        }
    } else {
        if(self.updateFailed) {
            bannerReady = AD_FAILED;
            NSLog(@"[ADUNION] Failed to receive Admob banner idx %d with error: %@", idx, [error localizedFailureReason]);
            
            if(self.delegate != NULL) {
                [self.delegate bannerDidFailedLoad:self error: error];
            }
        }
        NSLog(@"[ADUNION] Failed to refresh Admob banner idx %d with error: %@", idx, [error localizedFailureReason]);
    }

#ifdef LOG_USER_ACTION
    [Flurry logEvent:curr_banner_place withParameters:@{@"id": banner_id==nil ? @"" : banner_id, @"status": @"failed"}];
#endif
    
    refreshtime = time(NULL);
}

//原生
// not support anymore

// 全屏

// 关闭全屏后调用的回调函数
/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[self adPosition] withParameters:@{@"id": interstitial_id, @"status": @"closed"}];
#endif

    if(self.delegate != NULL) {
        [self.delegate interstitialWillDismissScreen];
        
        if([self.delegate interstitialDidDismissScreen])
            [self init_admob_interstitial];
    } else {
        [self init_admob_interstitial];
    }
}

- (NSString *) adPosition {
    return [NSString stringWithFormat:@"InterAd%d", curr_inter_place];
}


/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    if(self.delegate != NULL) {
        [self.delegate interstitialWillDismissScreen];
        
        if([self.delegate interstitialDidDismissScreen])
            [self init_admob_interstitial];
    } else {
        [self init_admob_interstitial];
    }
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[self adPosition]  withParameters:@{@"id": interstitial_id, @"click": @"show"}];
#endif
    if(self.delegate != NULL) {
        [self.delegate interstitialDidShow];
    }
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
#ifdef LOG_USER_ACTION
    [Flurry logEvent:[self adPosition]  withParameters:@{@"id": interstitial_id, @"click": @"click"}];
#endif
    if(self.delegate != NULL) {
        [self.delegate interstitialDidClick];
    }
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
    NSLog(@"[ADUNION] Admob banner %d 已展示 %lds", idx, showtime);
    if(bannerReady != AD_FAILED && bannerReady != AD_LOADED) {
        return;
    }
    
    int timeelapse = refreshForeground;  // 前台120s刷新，后台每10分钟刷新, admob的情况是会自动刷新，所以就定成上限120，主要检测目的
    if(self->isBannerBackground) {
        timeelapse = refreshBackground;
        if(bannerReady == AD_LOADED) {  //后台成功banner就每小时刷新一次
            timeelapse = refreshBackgroundLoaded;
        }
    }
//    NSLog(@"banner %d%@刷新, 经过%lds", idx, self->isBannerBackground?@"后台":@"前台", now - refreshtime);
    if(now - refreshtime > timeelapse) {
        //前台成功且展示时间小于要求时间
        if(bannerReady == AD_LOADED && showtime < timeelapse && !self->isBannerBackground) {
            //do nothing
        } else {
            NSLog(@"[ADUNION] Admob banner %d%@刷新, 经过%lds", idx, self->isBannerBackground?@"后台":@"前台", now - refreshtime);
            [self reloadBannerView];
        }
    }
}

- (void) logPaidAdRevenue:(NSDecimalNumber*)revenue currency:(NSString*) currencyCode responseInfo:(GADAdNetworkResponseInfo*) info unitId:(NSString*)unitid {
    NSString *adSourceName = info.adSourceName;
    NSString *adSourceInstanceName = info.adSourceInstanceName;
#ifdef ENABLE_ADJUST
    ADJAdRevenue *adRevenue = [[ADJAdRevenue alloc] initWithSource:ADJAdRevenueSourceAppLovinMAX];
    // pass revenue and currency values
    [adRevenue setRevenue:revenue.doubleValue currency:currencyCode];
    // pass optional parameters
//    [adRevenue setAdImpressionsCount:adImpressionsCount];
    [adRevenue setAdRevenueNetwork:adSourceName];
    [adRevenue setAdRevenueUnit:unitid];
    [adRevenue setAdRevenuePlacement:adSourceInstanceName];
    
    // attach callback and/or partner parameter if needed
//    [adRevenue addCallbackParameter:key value:value];
//    [adRevenue addPartnerParameter:key value:value];

    // track ad revenue
    [Adjust trackAdRevenue:adRevenue];
#endif
    
    
#ifdef ENABLE_FIREBASE
    [FIRAnalytics logEventWithName:@"ad_impression_revenue" parameters:@{
        kFIRParameterValue:@(revenue.doubleValue),
        kFIRParameterCurrency:currencyCode,
        kFIRParameterAdSource:adSourceName,
        kFIRParameterAdFormat:adSourceInstanceName,
        kFIRParameterAdUnitName:unitid,
        kFIRParameterAdPlatform:@"Admob"
    }];
    [FIRAnalytics logEventWithName:kFIREventAdImpression parameters:@{
        kFIRParameterValue:@(revenue.doubleValue),
        kFIRParameterCurrency:currencyCode,
        kFIRParameterAdSource:adSourceName,
        kFIRParameterAdFormat:adSourceInstanceName,
        kFIRParameterAdUnitName:unitid,
        kFIRParameterAdPlatform:@"Admob"
    }];
    
    //log taichi 3.0
    double currentImpressionRevenue = revenue.doubleValue;
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    
    float previousTaichiTroasCache = [settings floatForKey:@"TaichiTroasCache"]; //App本地存储用于累计tROAS的缓存值
    float currentTaichiTroasCache = (float) (previousTaichiTroasCache + currentImpressionRevenue);//累加tROAS的缓存值
    //check是否应该发送TaichitROAS事件
    if (currentTaichiTroasCache >= 0.01) {//如果超过0.01就触发一次tROAS taichi事件
        [self LogTaichiTroasFirebaseAdRevenueEvent:currentTaichiTroasCache];
        [settings setFloat:0 forKey:@"TaichiTroasCache"];//重新清零，开始 计算
    } else {
        [settings setFloat:currentTaichiTroasCache forKey:@"TaichiTroasCache"];//先存着直到超过0.01才发送
    }
    [settings synchronize];
#endif
}

- (void) LogTaichiTroasFirebaseAdRevenueEvent:(float)TaichiTroasCache {
#ifdef ENABLE_FIREBASE
    //(Required)tROAS事件必须带Double类型的Value
    //(Required)tROAS事件必须带Currency的币种，如果是USD的话，就写USD，如果不是USD，务必把其他币种换算成USD
    [FIRAnalytics logEventWithName:@"Total_Ads_Revenue_001" parameters:@{
        kFIRParameterValue:@(TaichiTroasCache),
        kFIRParameterCurrency:@"USD"
    }];
#endif
}

@end
