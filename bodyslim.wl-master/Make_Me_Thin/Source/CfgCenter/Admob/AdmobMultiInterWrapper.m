//
//  AdmobMultiInterWrapper.m
//  SplitPics
//
//  Created by 昭 陈 on 2017/7/11.
//  Copyright © 2017年 ZBNetWork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdmobMultiInterWrapper.h"

#ifndef LOG_USER_ACTION
#define LOG_USER_ACTION
#endif

#ifdef LOG_USER_ACTION
@import Flurry_iOS_SDK;
#endif

@interface InterstitialADStatus : NSObject

@property BOOL inter_failed;
@property int inter_failed_count;
@property (weak, nonatomic) NSString* interadid;
@property (strong, nonatomic) GADInterstitialAd* interad;

@end

@implementation InterstitialADStatus

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

@implementation AdmobMultiInterWrapper {
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
    for(InterstitialADStatus* adstatus in interadsDict.allValues) {
        adstatus.interad.fullScreenContentDelegate = nil;
        adstatus.interad = nil;
    }
    
    [interadsDict removeAllObjects];
}

- (void)init_admob_interstitial {
    for(int i=0; i<interadIds.count; i++) {
        InterstitialADStatus* adstatus = [[InterstitialADStatus alloc] initWithADID: interadIds[i]];
        [interadsDict setValue:adstatus forKey:interadIds[i]];
        
        [self _init_single_admob_interstitial:adstatus];
    }
}

//never use
- (void) _init_single_admob_interstitial:(InterstitialADStatus *) status {
//    GADInterstitialAd* interstitial = [[GADInterstitialAd alloc] initWithAdUnitID:status.interadid];
//    interstitial.fullScreenContentDelegate = self;
//
//    status.interad = interstitial;
//
//    status.inter_failed_count = 0;
//    [self _interstitial_reload: status];
}

//never use
- (void) _interstitial_reload: (InterstitialADStatus*) adstatus {
//    adstatus.inter_failed = false;
//    [adstatus.interad loadRequest: [self getADRequest]];
//#ifdef LOG_USER_ACTION
//    [Flurry logEvent:@"ADLoadInter" withParameters:@{@"id": adstatus.interadid, @"status": @"load"}];
//#endif
}

- (InterstitialADStatus*) getADStatusForIndex:(int) tag {
    if(tag >= interadIds.count) {
        return nil;
    }
    
    InterstitialADStatus* status = [interadsDict valueForKey:interadIds[tag]];
    if (status == nil || status.interad == nil)
        return nil;
    
    return status;
}

- (InterstitialADStatus*) getADStatusForAD:(GADInterstitialAd *) ad {
    for(InterstitialADStatus* status in interadsDict.allValues) {
        if(status.interad == ad) {
            return status;
        }
    }
    return nil;
}

//never use
- (BOOL)show_admob_interstitial:(UIViewController *)viewController placeid:(int) place {
//    InterstitialADStatus* status = [self getADStatusForIndex:place];
//    if(status == nil)
//        return NO;
//
//    // 当广告还没就绪的时候，不增加显示次数
//    if ([status.interad isReady]) {
//        [status.interad presentFromRootViewController:viewController];
//        NSLog(@"Show Inter Ad Idx:%d id:%@", idx, status.interadid);
//
//#ifdef LOG_USER_ACTION
//        [Flurry logEvent:@"ADLoadInter" withParameters:@{@"id": interadIds[place], @"status": @"show"}];
//#endif
//        return YES;
//    }
    return NO;
}
//never use
- (BOOL)admob_interstial_ready:(int)place {
//    if([interstitial_id isEqualToString:@""]) {
//        return NO;
//    }
//
//    if(interstitial_round)
//        return YES;
//
//    if(ad_inter_failed)
//    {
//        [self _interstitial_reload];
//    }
    return FALSE;
}

- (void)remove_all_ads:(UIView *)rootView {
    [super remove_all_ads:rootView];
}

#pragma mark -
#pragma admob delegate

- (void)interstitialDidReceiveAd:(GADInterstitialAd *)ad {
    
    InterstitialADStatus* status = [self getADStatusForAD:ad];
    if(status == nil)
        return;
    
    status.inter_failed_count = 0;
    status.inter_failed = false;
    
    if(self.delegate != NULL) {
        [self.delegate interstitialDidReceiveAd];
    }
    
    NSLog(@"round ad ready, wait to show!");
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"ADLoadInter" withParameters:@{@"id": status.interadid, @"status": @"loaded"}];
#endif
}

- (void)interstitialDidDismissScreen:(GADInterstitialAd *)ad {
    
    InterstitialADStatus* status = [self getADStatusForAD:ad];
    if(status == nil)
        return;
    
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"ADLoadInter" withParameters:@{@"id": status.interadid, @"status": @"closed"}];
#endif
    
    if(self.delegate != NULL) {
        if([self.delegate interstitialDidDismissScreen])
            [self _init_single_admob_interstitial: status];
    } else {
        [self _init_single_admob_interstitial: status];
    }
}

- (void)interstitial:(GADInterstitialAd *)ad didFailToReceiveAdWithError:(GADErrorCode *)error {

    InterstitialADStatus* status = [self getADStatusForAD:ad];
    if(status == nil)
        return;
    
#ifdef LOG_USER_ACTION
    [Flurry logEvent:@"ADLoadInter" withParameters:@{@"id": status.interadid, @"status": @"failed"}];
#endif
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(status.inter_failed_count < 3) {
            status.inter_failed_count++;
            [self _interstitial_reload:status];
            
            NSLog(@"retry round ad %d!", status.inter_failed_count);
        }
        else {
            status.inter_failed_count = 0;
            status.inter_failed = true;
        }
    });
    
    NSLog(@"round ad failed");
}

@end
