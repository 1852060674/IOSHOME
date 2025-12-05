//
//  ApplovinMaxRevenueDelegate.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2022/6/16.
//

#import <Foundation/Foundation.h>
#ifdef ENABLE_ADJUST
#import "Adjust.h"
#endif
#import "ApplovinMaxRevenueDelegate.h"

@implementation ApplovinMaxRevenueDelegate

- (void) didPayRevenueForAd:(MAAd *)ad {
#ifdef ENABLE_ADJUST
    ADJAdRevenue *adRevenue = [[ADJAdRevenue alloc] initWithSource:ADJAdRevenueSourceAppLovinMAX];
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
}

@end
