//
//  PriorityRewardAdWrapper.h
//  Unity-iPhone
//
//  Created by 昭 陈 on 2019/3/18.
//

#ifndef PriorityRewardAdWrapper_h
#define PriorityRewardAdWrapper_h

#import "RewardAdWrapper.h"

@class AdmobViewController;

@interface PriorityRewardAdWrapper : RewardAdWrapper<RewardAdWrapperDelegate>

- (id)initWithRootView:(AdmobViewController*) rootview adlist:(NSArray* )ads;

@end

#endif /* PriorityRewardAdWrapper_h */
