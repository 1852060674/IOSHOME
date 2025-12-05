//
//  AdmobRewardAdWrapper.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2019/3/18.
//

#ifndef AdmobRewardAdWrapper_h
#define AdmobRewardAdWrapper_h

#import "RewardAdWrapper.h"
@import GoogleMobileAds;

@class GADRequest;

@class AdmobViewController;

@interface AdmobRewardAdWrapper : RewardAdWrapper<GADFullScreenContentDelegate>

-(GADRequest*) getADRequest;

- (id)initWithRootView:(AdmobViewController*) rootview adid:(NSString* )adid;

@end

#endif /* AdmobRewardAdWrapper_h */
