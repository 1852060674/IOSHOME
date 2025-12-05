//
//  ChartBoostWrapper.m
//  version 3.3
//
//  Created by 昭 陈 on 2016/11/24.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CfgCenter.h"

#ifdef AD_CHARTBOOST
#import "ChartboostWrapper.h"

@implementation ChartBoostWrapper
{
    NSString* appid;
    NSString* signature;
    
    BOOL ad_inter_failed;
    int ad_inter_retry_count;
}

@synthesize RootViewController;
@synthesize bannerReady;
@synthesize nativeReady;
@synthesize idx;

//@"4f21c409cd1cb2fb7000001b" @"92e2de2fd7070327bdeb54c15a5295309c6fcd2d"
- (id)initWithRootView:(AdmobViewController*) rootview appid:(NSString* )strAppid signature:(NSString* )strSignature {
    self = [super init];
    
    if(self != nil) {
        appid = strAppid;
        signature = strSignature;
        self.bannerReady = AD_NOTSURPORT;
        self.nativeReady = 0;
        
        ad_inter_retry_count = 0;
        ad_inter_failed = false;
    }
    
    return self;
}

-(void) init_first_time {
    [Chartboost startWithAppId:appid appSignature:signature delegate:self];
}

-(void) init_admob_banner {
    return;
}

-(void) init_admob_banner:(float)width height:(float)height {
    return;
}

-(void) init_admob_interstitial {
    ad_inter_failed = false;
    [Chartboost cacheInterstitial:CBLocationHomeScreen];
}

-(void) init_admob_native:(float)width height:(float)height {
    return;
}

-(void) show_admob_banner:(UIView*)view placeid:(NSString *)place {
    return;
}

-(void) setBannerAlign:(ADAlignment)align {
    
}

/* 显示原生广告 */
-(void) show_admob_native:(float)posx posy:(float)posy width:(float)width height:(float)height view:(UIView*)view placeid:(NSString *)place {
    return;
}

/* 展示全屏 */
-(BOOL) show_admob_interstitial:(UIViewController*)viewController placeid:(int)place {
    if([Chartboost hasInterstitial:CBLocationHomeScreen]) {
        [Chartboost showInterstitial:CBLocationHomeScreen];
        return YES;
    }
    return NO;
}

-(BOOL) admob_interstial_ready:(int) place {
    if([Chartboost hasInterstitial:CBLocationHomeScreen]) {
        return YES;
    } else if(ad_inter_failed) {
        [self init_admob_interstitial];
    }
    return NO;
}

/* 删除banner和全屏 */
-(void)remove_all_ads:(UIView *)rootView {
    return;
}

-(void)remove_banner:(UIView*)rootView {
    return;
}

-(void)remove_native:(UIView*)rootView {
    return;
}

#pragma mark -
#pragma mark Chartboost Delegate

-(void) didInitialize:(BOOL)status {
    if(![self admob_interstial_ready: 0]) {
       [self init_admob_interstitial];
    }
}

-(void) didCacheInterstitial:(CBLocation)location {
    NSLog(@"loaded chartboost interstitial");
    if(self.delegate != NULL) {
        [self.delegate interstitialDidReceiveAd];
    }
}

-(void) didFailToLoadInterstitial:(CBLocation)location withError:(CBLoadError)error {
    NSLog(@"failed to loaded chartboost interstitial");
    ad_inter_failed = true;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(ad_inter_retry_count < 3) {
            ad_inter_retry_count++;
            [self init_admob_interstitial];
            
            NSLog(@"retry round ad %d!", ad_inter_retry_count);
        }
        else {
            ad_inter_retry_count = 0;
            ad_inter_failed = true;
        }
    });
    
    NSLog(@"round ad failed");
}

-(void) didDismissInterstitial:(CBLocation)location {
    NSLog(@"close chartboost interstitial");
    if(self.delegate != NULL) {
        [self.delegate interstitialDidDismissScreen];
    }
    
    //chartboost seems automatical reload next interstitial ad
}

@end
#endif
