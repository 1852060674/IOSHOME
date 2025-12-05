//
//  MaxApsAdLoaderCallback.m
//  cutout
//
//  Created by 昭 陈 on 4/14/23.
//  Copyright © 2023 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "MaxApsAdLoaderCallback.h"

@implementation MaxApsAdLoaderCallback
{
    NSMutableArray* ad_list;
    int ad_type; //1 banner, 2 inter, 3 reward
}

- (id) init {
    self = [super init];
    if(self)
    {
        ad_list = [[NSMutableArray alloc] init];
        _isInUse = NO;
    }
    return self;
}

- (void)setAdType:(int) adtype {
    ad_type = adtype;
}

- (void)addMaxAdObj:(ApplovinMaxWrapper*) applovin_ad_obj {
    [ad_list addObject:applovin_ad_obj];
}

- (void)onSuccess:(DTBAdResponse *)adResponse {
    if(ad_type == 1) {
        for(int i=0; i<ad_list.count; i++) {
            [ad_list[i] onBannerAPSSuccess:adResponse];
        }
    } else if(ad_type == 2) {
        for(int i=0; i<ad_list.count; i++) {
            [ad_list[i] onInterAPSSuccess:adResponse];
        }
    }
}

- (void)onFailure:(DTBAdError)error dtbAdErrorInfo:(DTBAdErrorInfo *)dtbAdErrorInfo {
    if(ad_type == 1) {
        for(int i=0; i<ad_list.count; i++) {
            [ad_list[i] onBannerAPSFailure:error dtbAdErrorInfo:dtbAdErrorInfo];
        }
    } else if(ad_type == 2) {
        for(int i=0; i<ad_list.count; i++) {
            [ad_list[i] onInterAPSFailure:error dtbAdErrorInfo:dtbAdErrorInfo];
        }
    }
}

- (NSUInteger)adCount {
    return ad_list.count;
}

@end
