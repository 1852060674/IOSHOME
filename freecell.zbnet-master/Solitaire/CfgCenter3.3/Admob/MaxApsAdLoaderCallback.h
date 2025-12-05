//
//  MaxApsAdLoaderCallback.h
//  cutout
//
//  Created by 昭 陈 on 4/14/23.
//  Copyright © 2023 ZB_Mac. All rights reserved.
//

#ifndef MaxApsAdLoaderCallback_h
#define MaxApsAdLoaderCallback_h
#include "ApplovinMaxWrapper.h"
@import DTBiOSSDK;

@interface MaxApsAdLoaderCallback : NSObject<DTBAdCallback>

@property BOOL isInUse;

- (void)addMaxAdObj:(ApplovinMaxWrapper*) applovin_ad_obj;
- (void)setAdType:(int) adtype;
- (NSUInteger)adCount;

@end

#endif /* MaxApsAdLoaderCallback_h */
