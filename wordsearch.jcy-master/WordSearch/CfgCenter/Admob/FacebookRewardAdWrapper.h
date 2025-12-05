//
//  FacebookRewardAdWrapper.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2019/3/18.
//

#ifndef FacebookRewardAdWrapper_h
#define FacebookRewardAdWrapper_h

#import "RewardAdWrapper.h"
@import FBAudienceNetwork;

@interface FacebookRewardAdWrapper : RewardAdWrapper<FBRewardedVideoAdDelegate>

- (id)initWithRootView:(AdmobViewController*) rootview adid:(NSString* )adid;

@end

#endif /* FacebookRewardAdWrapper_h */
