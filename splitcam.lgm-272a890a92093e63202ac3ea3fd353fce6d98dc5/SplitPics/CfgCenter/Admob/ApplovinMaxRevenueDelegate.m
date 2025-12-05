//
//  ApplovinMaxRevenueDelegate.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2022/6/16.
//

#import <Foundation/Foundation.h>
#import "CfgCenter.h"
#ifdef ENABLE_ADJUST
#import "Adjust.h"
#import <AdjustSdk/AdjustSdk.h>
#endif
#ifdef ENABLE_FIREBASE_ADIMP
#import "Firebase.h"
#endif
#import "ApplovinMaxRevenueDelegate.h"

@implementation ApplovinMaxRevenueDelegate

- (void) didPayRevenueForAd:(MAAd *)ad {
#ifdef ENABLE_ADJUST
    ADJAdRevenue *adRevenue = [[ADJAdRevenue alloc] initWithSource:@"applovin_max_sdk"];
    // pass revenue and currency values
    [adRevenue setRevenue:ad.revenue currency:@"USD"];
    // pass optional parameters
//    [adRevenue setAdImpressionsCount:adImpressionsCount];
    [adRevenue setAdRevenueNetwork:ad.networkName];
    [adRevenue setAdRevenueUnit:ad.adUnitIdentifier];
    [adRevenue setAdRevenuePlacement:ad.placement];
    
    // attach callback and/or partner parameter if needed
//    [adRevenue addCallbackParameter:key value:value];
//    [adRevenue addPartnerParameter:key value:value];

    // track ad revenue
    [Adjust trackAdRevenue:adRevenue];
#endif
    
    
#ifdef ENABLE_FIREBASE_ADIMP
    [FIRAnalytics logEventWithName:@"ad_impression_revenue" parameters:@{
        kFIRParameterValue:@(ad.revenue),
        kFIRParameterCurrency:@"USD",
        kFIRParameterAdSource:ad.networkName,
        kFIRParameterAdFormat:ad.format,
        kFIRParameterAdUnitName:ad.adUnitIdentifier,
        kFIRParameterAdPlatform:@"Max"
    }];
    [FIRAnalytics logEventWithName:kFIREventAdImpression parameters:@{
        kFIRParameterValue:@(ad.revenue),
        kFIRParameterCurrency:@"USD",
        kFIRParameterAdSource:ad.networkName,
        kFIRParameterAdFormat:ad.format,
        kFIRParameterAdUnitName:ad.adUnitIdentifier,
        kFIRParameterAdPlatform:@"Max"
    }];
    
    //log taichi 3.0
    double currentImpressionRevenue = ad.revenue;
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
#ifdef ENABLE_FIREBASE_ADIMP
    //(Required)tROAS事件必须带Double类型的Value
    //(Required)tROAS事件必须带Currency的币种，如果是USD的话，就写USD，如果不是USD，务必把其他币种换算成USD
    [FIRAnalytics logEventWithName:@"Total_Ads_Revenue_001" parameters:@{
        kFIRParameterValue:@(TaichiTroasCache),
        kFIRParameterCurrency:@"USD"
    }];
#endif
}


@end
