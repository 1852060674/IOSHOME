//
//  ApplovinMaxWrapper.h
//  version 4.0.0
//
//  Created by 昭 陈 on 01/3/21.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#ifndef ApplovinMaxWrapper_h
#define ApplovinMaxWrapper_h

#import "ADWrapper.h"
//@import AppLovinSDK;
#import <AppLovinSDK/AppLovinSDK.h>
#import "ApplovinMaxRevenueDelegate.h"
//@import DTBiOSSDK;
#import <DTBiOSSDK/DTBiOSSDK.h>

@class AdmobViewController;

@interface ApplovinMaxWrapper : ADWrapper<MAAdViewAdDelegate>

@property (nonatomic, strong) ApplovinMaxRevenueDelegate *revenueDelegate;

- (id)initWithRootView:(AdmobViewController*) rootview bannerid:(NSString*)bannerid interid:(NSString*)interid;

- (void)onBannerAPSSuccess:(DTBAdResponse *)adResponse;
- (void)onBannerAPSFailure:(DTBAdError)error dtbAdErrorInfo:(DTBAdErrorInfo *)dtbAdErrorInfo;

- (void)onInterAPSSuccess:(DTBAdResponse *)adResponse;
- (void)onInterAPSFailure:(DTBAdError)error dtbAdErrorInfo:(DTBAdErrorInfo *)dtbAdErrorInfo;
- (CGFloat)getAdmobHeight;
@end

#endif /* ApplovinMaxWrapper_h */
