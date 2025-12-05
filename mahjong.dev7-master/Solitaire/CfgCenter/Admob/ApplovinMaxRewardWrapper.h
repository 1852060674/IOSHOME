//
//  ApplovinMaxRewardWrapper.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2021/9/7.
//

#ifndef ApplovinMaxRewardWrapper_h
#define ApplovinMaxRewardWrapper_h

#import "RewardAdWrapper.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <AppLovinSDK/AppLovinSDK.h>
#import "ApplovinMaxRevenueDelegate.h"
#import <DTBiOSSDK/DTBiOSSDK.h>
@class AdmobViewController;

@interface ApplovinMaxRewardWrapper : RewardAdWrapper<MARewardedAdDelegate>

@property (nonatomic, strong) ApplovinMaxRevenueDelegate *revenueDelegate;

- (id)initWithRootView:(AdmobViewController*) rootview adid:(NSString*)rewardid;

- (void)onrewardAPSSuccess:(DTBAdResponse *)adResponse;
- (void)onrewardAPSFailure:(DTBAdError)error dtbAdErrorInfo:(DTBAdErrorInfo *)dtbAdErrorInfo;
@end

#endif /* ApplovinMaxRewardWrapper_h */
