//
//  ADWrapper.m
//  version 3.3
//
//  Created by 昭 陈 on 2016/11/24.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CfgCenter.h"
#import "ADWrapper.h"
#import "PriorityAdWrapper.h"
#import <DTBiOSSDK/DTBiOSSDK.h>
// #import "SequenceAdWrapper.h"
#ifdef AD_CHARTBOOST
#import "ChartboostWrapper.h"
#endif
#ifdef AD_ADMOB
#import "AdmobWrapper.h"
#endif
#ifdef AD_BAIDU
#import "BaiduWrapper.h"
#endif
#ifdef AD_FACEBOOK
#import "FacebookWrapper.h"
#import "FacebookMultiInterWrapper.h"
#endif
#ifdef AD_APPLOVIN_MAX
#import "ApplovinMaxWrapper.h"
#import "MaxApsAdLoaderCallback.h"
@import FBAudienceNetwork;
extern MaxApsAdLoaderCallback* rewardCallback;
MaxApsAdLoaderCallback* bannerCallback;
MaxApsAdLoaderCallback* interCallback;
#endif

BOOL applovin_initialized;
NSString* aps_appid;
NSString* aps_bannerid;
NSString* aps_leaderid;
NSString* aps_interid;
NSString* aps_rewardid;

@implementation ADWrapper
// {
//     "type": "sequence",
//     "ads": [{
//         "type": "admob",
//         "banner": "ca-app-XXX",
//         "interstitial": "ca-app-XXX",
//         "native": "ca-app-XXX"
//     },
//     {
//         "type": "priority",
//         "ads": [{
//             "type": "admob",
//             "banner": "ca-app-XXX",
//             "interstitial": "ca-app-XXX",
//             "native": "ca-app-XXX"
//         },
//         {
//             "type": "chartboost",
//             "appid": "aaaa",
//             "signature": "xxxx"
//         }]
//     },
//     {
//         "type": "chartboost",
//         "appid": "aaaa",
//         "signature": "xxxx"
//     }]
// }
+(ADWrapper*) createAD:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* type = config[@"type"];
    ADWrapper * ad = nil;
    NSLog(@" lai la1");
    // if([type isEqualToString:@"sequence"]) {
    //     ad = [self createSequenceAd: config vc:vc];
    // } else
    if ([type isEqualToString:@"priority"]) {
        ad = [self createPriorityAd: config vc:vc];
#ifdef AD_ADMOB
    } else if ([type isEqualToString:@"admob"]) {
        ad = [self createAdmobAd: config vc:vc];
#endif
#ifdef AD_CHARTBOOST
    } else if ([type isEqualToString:@"chartboost"]) {
        ad = [self createCharboostAd: config vc:vc];
#endif
#ifdef AD_BAIDU
    } else if ([type isEqual:@"baidu"]) {
        ad = [self createBaiduAd: config vc:vc];
#endif
#ifdef AD_FACEBOOK
    } else if ([type isEqualToString:@"facebook"]) {
        ad = [self createFacebookAd: config vc:vc];
    } else if ([type isEqualToString:@"facebookmulti"]) {
        ad = [self createFacebookAdMulti: config vc:vc];
#endif
#ifdef AD_APPLOVIN_MAX
    } else if ([type isEqualToString:@"maxwrap"]) {
        ad = [self createApplovinMaxAd: config vc:vc];
#endif
    }
    
    if(ad != nil) {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        if(UIDeviceOrientationIsLandscape(orientation)) {
            ad.orientation = AD_LANDSCAPE;
        } else {
            ad.orientation = AD_PORTRAIT;
        }
    }
    return ad;
}

+(ADWrapper*) createPriorityAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    
    NSArray* adlist = [config objectForKey:@"ads"];
    if(adlist == nil) return nil;
    
    NSMutableArray* ads = [self createAdFromList:adlist vc:vc];
    
    if(ads.count == 0)
        return nil;
    
    PriorityAdWrapper* sequence = [[PriorityAdWrapper alloc] initWithRootView:vc adlist:ads];
    return sequence;
}

// +(ADWrapper*) createSequenceAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
//     NSArray* adlist = [config objectForKey:@"ads"];
    
//     NSMutableArray* ads = [self createAdFromList:adlist vc:vc];
    
//     if(ads.count == 0)
//         return nil;
    
//     SequenceAdWrapper* sequence = [[SequenceAdWrapper alloc] initWithRootView:vc adlist:ads];
//     return sequence;
// }

+(NSMutableArray*) createAdFromList:(NSArray*) config vc: (AdmobViewController*)vc {
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    
    for(int i=0; i<config.count; i++) {
        ADWrapper* ad = [self createAD:config[i] vc: vc];
        if(ad != NULL) {
            [ret addObject:ad];
        }
    }
    
    return ret;
}

#ifdef AD_ADMOB
+(ADWrapper*) createAdmobAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* bannerid = config[@"banner"];
    NSString* interstitialid = config[@"interstitial"];
    NSString* nativeid = config[@"native"];
    if(bannerid == nil) bannerid = @"";
    if(interstitialid == nil) interstitialid = @"";
    if(nativeid == nil) nativeid = @"";
    double bbid = [config[@"bbid"] doubleValue];
    if(bbid < 0) {
        bbid = 0;
    }
    
    if([bannerid length] == 0 && [interstitialid length] == 0 && [nativeid length] == 0) {
        return nil;
    }
    
    AdmobWrapper* admob = [[AdmobWrapper alloc] initWithRootView:vc BannerId:bannerid InterstitialId:interstitialid NativeId:nativeid];
    int refreshfore = [config[@"fg"] intValue];
    int refreshback = [config[@"bg"] intValue];
    int refreshbackloaded = [config[@"bgloaded"] intValue];
    [admob setRefreshTimeLimitFG:refreshfore BG:refreshback BGLoaded:refreshbackloaded];
    [admob setUpdateBannerFailed:[config[@"uf"] intValue]==1];
    admob.bannerRevenue = bbid;
    return admob;
}
#endif

#ifdef AD_CHARTBOOST
+(ADWrapper*) createCharboostAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* appid = config[@"appid"];
    NSString* signature = config[@"signature"];
    if(appid == nil) appid = @"";
    if(signature == nil) signature = @"";
    
    if([appid length] == 0 || [signature length] == 0) {
        return nil;
    }
    
    ChartBoostWrapper* chartboost = [[ChartBoostWrapper alloc] initWithRootView:vc appid:appid signature:signature];
    return chartboost;
}
#endif

#ifdef AD_BAIDU
+(ADWrapper*) createBaiduAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* appid = config[@"appid"];
    NSString* bannerid = config[@"banner"];
    NSString* interstitialid = config[@"interstitial"];
    if(appid == nil) appid = @"";
    if(bannerid == nil) bannerid = @"";
    if(interstitialid == nil) interstitialid = @"";
    
    if([appid length] == 0 || ([bannerid length] == 0 && [interstitialid length] == 0)) {
        return nil;
    }
    
    BaiduWrapper* baidu = [[BaiduWrapper alloc] initWithRootView:vc appid:appid BannerId:bannerid InterstitialId:interstitialid];
    return baidu;
}
#endif

#ifdef AD_FACEBOOK
+(ADWrapper*) createFacebookAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* bannerid = config[@"banner"];
    NSString* interstitialid = config[@"interstitial"];
    NSString* nativeid = config[@"native"];
    if(bannerid == nil) bannerid = @"";
    if(interstitialid == nil) interstitialid = @"";
    if(nativeid == nil) nativeid = @"";
    double bbid = [config[@"bbid"] doubleValue];
    if(bbid < 0) {
        bbid = 0;
    }
    
    if([bannerid length] == 0 && [interstitialid length] == 0 && [nativeid length] == 0) {
        return nil;
    }
    
    FacebookWrapper* facebook = [[FacebookWrapper alloc] initWithRootView:vc BannerId:bannerid InterstitialId:interstitialid NativeId:nativeid];
    int refreshfore = [config[@"fg"] intValue];
    int refreshback = [config[@"bg"] intValue];
    int refreshbackloaded = [config[@"bgloaded"] intValue];
    [facebook setRefreshTimeLimitFG:refreshfore BG:refreshback BGLoaded:refreshbackloaded];
    facebook.bannerRevenue = bbid;
    return facebook;
}

+(ADWrapper*) createFacebookAdMulti:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* bannerid = config[@"banner"];
    NSArray* interstitialids = [config objectForKey:@"interstitials"];
    NSString* nativeid = config[@"native"];
    
    if([bannerid length] == 0 && [interstitialids count] == 0 && [nativeid length] == 0) {
        return nil;
    }
    
    FacebookMultiInterWrapper* facebook = [[FacebookMultiInterWrapper alloc] initWithRootView:vc BannerId:bannerid InterstitialIds:interstitialids NativeId:nativeid];
    return facebook;
}
#endif

#ifdef AD_APPLOVIN_MAX
+(ADWrapper*) createApplovinMaxAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* bannerid = config[@"banner"];
    NSString* interstitialid = [config objectForKey:@"interstitial"];
    if(bannerid == nil) bannerid = @"";
    if(interstitialid == nil) interstitialid = @"";
    
    if([bannerid length] == 0 && [interstitialid length] == 0) {
        return nil;
    }
    
    ApplovinMaxWrapper* max = [[ApplovinMaxWrapper alloc] initWithRootView:vc bannerid:bannerid interid:interstitialid];
    if(bannerCallback == nil) {
        bannerCallback = [[MaxApsAdLoaderCallback alloc] init];
        [bannerCallback setAdType:1];
    }
    [bannerCallback addMaxAdObj:max];
    
    if(interCallback == nil) {
        interCallback = [[MaxApsAdLoaderCallback alloc] init];
        [interCallback setAdType:2];
    }
    [interCallback addMaxAdObj:max];
    
    
    return max;
}
#endif

-(void) init_first_time {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void) init_admob_banner {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void) init_admob_banner:(float)width height:(float)height {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void) init_admob_interstitial {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void) init_admob_native:(float)width height:(float)height {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void) show_admob_banner:(UIView*)view placeid:(NSString *)place {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void) setBannerAlign:(ADAlignment)align {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void) hide_banner{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(double) getBannerRevenue {
    return _bannerRevenue;
}

/* 显示原生广告 */
-(void) show_admob_native:(float)posx posy:(float)posy width:(float)width height:(float)height view:(UIView*)view placeid:(NSString *)place {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

/* 展示全屏 */
-(BOOL) show_admob_interstitial:(UIViewController*)viewController placeid:(int)tag{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}
-(BOOL) admob_interstial_ready:(int)place {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(BOOL) show_admob_reward:(UIViewController*)viewController placeid:(int)place {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}
-(BOOL) admob_reward_ready:(int)place {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

/* 删除banner和全屏 */
-(void)remove_all_ads:(UIView *)rootView {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void)remove_banner:(UIView*)rootView {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void)remove_native:(UIView*)rootView {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void) setUpdateBannerFailed:(bool) update {
    self.updateFailed = update;
}

- (bool) isBannerHaveSuccessBefore {
    return FALSE;
}

- (void) updateImpression:(UIView*)rootView {
}

- (void) delayInitAfterNetworkFinish {
    
}
+(void) initAdNetwork:(NSArray*)adconfig_list withCallback:(void (^)())finishCallback {
    if(adconfig_list != nil) {
        for(int i=0; i<adconfig_list.count; i++) {
            NSDictionary* adconfig = adconfig_list[i];
            NSString* configtype = [adconfig objectForKey:@"type"];
            if(configtype != nil && [configtype isEqualToString:@"max_aps"]) {
                aps_appid = adconfig[@"appid"];
                aps_bannerid = adconfig[@"bannerad"];
                aps_leaderid = adconfig[@"leaderad"];
                aps_interid = adconfig[@"interad"];
                aps_rewardid = adconfig[@"rewardad"];
            }
        }
    }
#ifdef AD_ADMOB
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ GADSimulatorID, @"e0c8839aa958ad5452ab7bc3e83f5c14" ];
#endif
#ifdef AD_APPLOVIN_MAX
    
    if(aps_appid != nil && ![aps_appid isEqualToString:@""] && [bannerCallback adCount]>0) {
        [[DTBAds sharedInstance] setAppKey: aps_appid];
        DTBAdNetworkInfo *adNetworkInfo = [[DTBAdNetworkInfo alloc] initWithNetworkName: DTBADNETWORK_MAX];
        [DTBAds sharedInstance].mraidCustomVersions = @[@"1.0", @"2.0", @"3.0"];
        [[DTBAds sharedInstance] setAdNetworkInfo: adNetworkInfo];
        [DTBAds sharedInstance].mraidPolicy = CUSTOM_MRAID;

#ifdef DEBUG
        [[DTBAds sharedInstance] setLogLevel: DTBLogLevelAll];
        [[DTBAds sharedInstance] setTestMode: YES];
#endif
        
        if(aps_bannerid != nil && ![aps_bannerid isEqualToString:@""]) {
            NSString* amazonAdSlotId;
            MAAdFormat* adFormat;
            if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad && aps_leaderid != nil && ![aps_leaderid isEqualToString:@""])
            {
                amazonAdSlotId = aps_leaderid;
                adFormat = MAAdFormat.leader;
            }
            else
            {
                amazonAdSlotId = aps_bannerid;
                adFormat = MAAdFormat.banner;
            }

            CGSize rawSize = adFormat.size;
            DTBAdSize *size = [[DTBAdSize alloc] initBannerAdSizeWithWidth: rawSize.width
                                                                    height: rawSize.height
                                                               andSlotUUID: amazonAdSlotId];

            DTBAdLoader* adLoader = [[DTBAdLoader alloc] init];
            [adLoader setAdSizes: @[size]];
            [adLoader loadAd: bannerCallback];
            bannerCallback.isInUse = YES;
        }
        
        if(aps_interid != nil && ![aps_interid isEqualToString:@""]) {
            DTBAdSize* size = [[DTBAdSize alloc] initVideoAdSizeWithPlayerWidth:320 height:480 andSlotUUID:aps_interid];
            DTBAdLoader* adLoader = [[DTBAdLoader alloc] init];
            [adLoader setAdSizes: @[size]];
            [adLoader loadAd: interCallback];
            interCallback.isInUse = YES;
        }
        
        // 11.16
        if(aps_rewardid != nil && ![aps_rewardid isEqualToString:@""]) {
            DTBAdSize* size = [[DTBAdSize alloc] initVideoAdSizeWithPlayerWidth:320 height:480 andSlotUUID:aps_rewardid];
            DTBAdLoader* adLoader = [[DTBAdLoader alloc] init];
            [adLoader setAdSizes: @[size]];
            [adLoader loadAd: rewardCallback];
            rewardCallback.isInUse = YES;
        }
    }
    
    
    applovin_initialized = false;
    [ALSdk shared].mediationProvider = @"max";
    [[ALSdk shared] initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {
        applovin_initialized = true;
        
        if(finishCallback != nil) {
            finishCallback();
        }
        if ( @available(ios 14.5, *) )
        {
        [FBAdSettings setAdvertiserTrackingEnabled:YES];
        }
#ifdef DEBUG
//        [[ALSdk shared] showMediationDebugger];
#endif
    }];
#endif
}

@end
