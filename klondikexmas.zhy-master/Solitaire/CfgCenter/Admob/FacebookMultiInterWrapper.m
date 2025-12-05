//
//  FacebookMultiInterWrapper.m
//  SplitPics
//
//  Created by 昭 陈 on 2017/7/12.
//  Copyright © 2017年 ZBNetWork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookMultiInterWrapper.h"


#ifndef LOG_USER_ACTION
#define LOG_USER_ACTION
#endif

#ifdef LOG_USER_ACTION
@import Flurry_iOS_SDK;
#endif

@interface FBInterstitialADStatus : NSObject

@property BOOL inter_failed;
@property int inter_failed_count;
@property BOOL inter_ready;
@property (weak, nonatomic) NSString* interadid;
@property (strong, nonatomic) FBInterstitialAd* interad;

@end

@implementation FBInterstitialADStatus

@synthesize inter_failed;
@synthesize inter_failed_count;
@synthesize interad;
@synthesize interadid;

- (id) initWithADID:(NSString*) adid {
    self = [super init];
    if(self) {
        inter_failed = false;
        inter_failed_count = 0;
        interad = nil;
        interadid = adid;
    }
    return self;
}

@end

@implementation FacebookMultiInterWrapper {
    NSMutableDictionary* interadsDict;
    NSArray* interadIds;
}

@synthesize idx;

- (id)initWithRootView:(AdmobViewController*) rootview BannerId:(NSString* )bannerid InterstitialIds:(NSArray* )interids NativeId:(NSString* )nativeid {
    self = [super initWithRootView:rootview BannerId:bannerid InterstitialId:@"" NativeId:nativeid];
    if(self) {
        interadsDict = [[NSMutableDictionary alloc] initWithCapacity:interids.count];
        interadIds = interids;
    }
    return self;
}

- (void)dealloc
{
    for(FBInterstitialADStatus* adstatus in interadsDict.allValues) {
        adstatus.interad.delegate = nil;
        adstatus.interad = nil;
    }
    
    [interadsDict removeAllObjects];
}

- (void)init_admob_interstitial {
    for(int i=0; i<interadIds.count; i++) {
        FBInterstitialADStatus* adstatus = [[FBInterstitialADStatus alloc] initWithADID: interadIds[i]];
        [interadsDict setValue:adstatus forKey:interadIds[i]];
        
        [self _init_single_admob_interstitial:adstatus];
    }
}

- (void) _init_single_admob_interstitial:(FBInterstitialADStatus*) status {
    FBInterstitialAd* interstitial = [[FBInterstitialAd alloc] initWithPlacementID:status.interadid];
    interstitial.delegate = self;
    
    status.interad = interstitial;
    
    status.inter_failed_count = 0;
    [self _interstitial_reload: status];
}

- (void) _interstitial_reload: (FBInterstitialADStatus*) adstatus {
    adstatus.inter_failed = false;
    adstatus.inter_ready = false;
    [adstatus.interad loadAd];
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadInter" withParameters:@{@"id": adstatus.interadid, @"status": @"load"}];
#endif
}

- (void)show_admob_interstitial:(UIViewController *)viewController {
    // do nothing
}

- (FBInterstitialADStatus*) getADStatusForIndex:(int) tag {
    if(tag >= interadIds.count) {
        return nil;
    }
    
    FBInterstitialADStatus* status = [interadsDict valueForKey:interadIds[tag]];
    if (status == nil || status.interad == nil)
        return nil;
    
    return status;
}

- (FBInterstitialADStatus*) getADStatusForAD:(FBInterstitialAd*) ad {
    for(FBInterstitialADStatus* status in interadsDict.allValues) {
        if(status.interad == ad) {
            return status;
        }
    }
    return nil;
}

- (void)show_admob_interstitial:(UIViewController *)viewController tag:(int) tag {
    FBInterstitialADStatus* status = [self getADStatusForIndex:tag];
    if(status == nil)
        return;
    
    // 当广告还没就绪的时候，不增加显示次数
    if (status.inter_ready) {
        [status.interad showAdFromRootViewController:viewController];
        NSLog(@"Show FB Inter Ad Idx:%d id:%@", idx, status.interadid);
        
#ifdef LOG_USER_ACTION
        [Flurry logEvent:@"FBLoadInter" withParameters:@{@"id": interadIds[tag], @"status": @"show"}];
#endif
        
        [self _init_single_admob_interstitial: status];
    }
}

- (BOOL)admob_interstial_ready{
    return false;
}

- (BOOL)admob_interstial_ready:(int)tag {
    FBInterstitialADStatus* status = [self getADStatusForIndex:tag];
    if(status == nil)
        return FALSE;
    
    if(status.inter_ready)
        return YES;
    
    if(status.inter_failed)
    {
        [self _interstitial_reload:status];
    }
    return FALSE;
}

- (void)remove_all_ads:(UIView *)rootView {
    [super remove_all_ads:rootView];
}

#pragma mark -
#pragma admob delegate

- (void)interstitialAdDidLoad:(FBInterstitialAd *)ad {
    
    FBInterstitialADStatus* status = [self getADStatusForAD:ad];
    if(status == nil)
        return;
    
    status.inter_failed_count = 0;
    status.inter_failed = false;
    status.inter_ready = true;
    
    if(self.delegate != NULL) {
        [self.delegate interstitialDidReceiveAd];
    }
    
    NSLog(@"FB round ad ready, wait to show!");
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadInter" withParameters:@{@"id": status.interadid, @"status": @"loaded"}];
#endif
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)ad {
    
    FBInterstitialADStatus* status = [self getADStatusForAD:ad];
    if(status == nil)
        return;
    
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadInter" withParameters:@{@"id": status.interadid, @"status": @"closed"}];
#endif
    
    if(self.delegate != NULL) {
        if([self.delegate interstitialDidDismissScreen])
            [self _init_single_admob_interstitial: status];
    } else {
        [self _init_single_admob_interstitial: status];
    }
}

- (void)interstitialAd:(FBInterstitialAd *)ad didFailWithError:(NSError *)error {
    FBInterstitialADStatus* status = [self getADStatusForAD:ad];
    if(status == nil)
        return;
    
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"FBLoadInter" withParameters:@{@"id": status.interadid, @"status": @"failed"}];
#endif
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(status.inter_failed_count < 3) {
            status.inter_failed_count++;
            [self _interstitial_reload:status];
            
            NSLog(@"FB retry round ad %d!", status.inter_failed_count);
        }
        else {
            status.inter_failed_count = 0;
            status.inter_failed = true;
        }
    });
    
    NSLog(@"FB round ad failed");
}

@end
